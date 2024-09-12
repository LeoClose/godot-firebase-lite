#A HTTP SSE Client script based on WolfgangSenff's SSE Client script on github:
#https://github.com/WolfgangSenff/HTTPSSEClient
#full credit for this script goes to him, I just edited some things to fit
#Godot 4 and to return needed data
extends Node

signal new_sse_event(headers, data, path)
signal connected(name)
signal connection_error(error)

const event_tag = "event:"
const data_tag = "data:"
const continue_internal = "continue_internal"

var httpclient = HTTPClient.new()
var is_connected = false

var domain
var url_after_domain
var port
var told_to_connect = false
var connection_in_progress = false
var request_in_progress = false
var is_requested = false
var response_body = PackedByteArray()

func connect_to_host(domain : String, url_after_domain : String, port : int = -1):
	self.url_after_domain = url_after_domain
	var err = httpclient.connect_to_host(domain, port)
	if err == OK:
		emit_signal("connected", self.name)
		is_connected = true
	else:
		emit_signal("connection_error", str(err))

func attempt_to_request(httpclient_status):
	if httpclient_status == HTTPClient.STATUS_CONNECTING or httpclient_status == HTTPClient.STATUS_RESOLVING:
		return
	elif httpclient_status == HTTPClient.STATUS_CONNECTED:
		var err = httpclient.request(HTTPClient.METHOD_POST, "/"+url_after_domain, ["Accept: text/event-stream"])
		if err == OK:
			is_requested = true

func _process(delta):
	if !is_connected:
		return
		
	httpclient.poll()
	var httpclient_status = httpclient.get_status()
	if !is_requested:
		if !request_in_progress:
			attempt_to_request(httpclient_status)
		return
		
	var httpclient_has_response = httpclient.has_response()
		
	if httpclient_has_response or httpclient_status == HTTPClient.STATUS_BODY:
		var headers = httpclient.get_response_headers_as_dictionary()

		httpclient.poll()
		var chunk = httpclient.read_response_body_chunk()
		if(chunk.size() == 0):
			return
		else:
			response_body = response_body + chunk
			
		var body = response_body.get_string_from_utf8()
		if body:
			var event_data = get_event_data(body)
			if event_data["event"] != "keep-alive":
				if response_body.size() > 0: # stop here if the value doesn't parse
					response_body.resize(0)
					emit_signal("new_sse_event", headers, event_data, str(self.name))
			else:
				if event_data.event != continue_internal:
					response_body.resize(0)

func get_event_data(body):
	match body[7]:
		"k":
			body = JSON.new().parse_string(body.replace("event", '{"event"').replace("keep-alive", '"keep-alive",').replace("data:", '"data":')+"}")
		"p":
			body = JSON.new().parse_string(body.replace("event", '{"event"').replace("put", '"put",').replace("data:", '"data":')+"}")
			body["data"] = body["data"]["data"]
	return body

func _exit_tree():
	if httpclient:
		httpclient.close()

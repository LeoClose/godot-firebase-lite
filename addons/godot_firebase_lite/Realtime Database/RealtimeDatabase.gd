extends Node

@onready var databaseHttp : HTTPRequest = get_node("HTTPRequest")
var listenerNode

signal refUpdated(data)

func write(path : String, writeData : Dictionary):
	return await processRequest(path, HTTPClient.METHOD_PUT, writeData)

func push(path : String, pushData : Dictionary):
	return await processRequest(path, HTTPClient.METHOD_POST, pushData)

func update(path : String, updateData : Dictionary):
	return await processRequest(path, HTTPClient.METHOD_PATCH, updateData)

func delete(path : String):
	return await processRequest(path, HTTPClient.METHOD_DELETE)

func read(path):
	return await processRequest(path, HTTPClient.METHOD_GET)

func processRequest(path, method, body = []):
	path = path.trim_suffix("/").trim_prefix("/")
	var url
	if FirebaseLite.authToken == null:
		url = "%s/%s.json" % [FirebaseLite.firebaseConfig["databaseURL"], path]
	else:
		url = "%s/%s.json?auth=%s" % [FirebaseLite.firebaseConfig["databaseURL"], path, FirebaseLite.authToken]
	if method == HTTPClient.METHOD_GET or method == HTTPClient.METHOD_DELETE:
		databaseHttp.request(url, [], method)
	else:
		databaseHttp.request(url, [], method, JSON.stringify(body))
	var data = await databaseHttp.request_completed
	var decodedData = JSON.new().parse_string(str(data[3].get_string_from_utf8()))
	if data[1] != 200: #Request for writing data was not approved
		printerr("Firebase Error (Realtime Database): there was an error with processing your request, received data: " + str(decodedData))
		return [ERR_DATABASE_CANT_WRITE, decodedData]
	else:
		return [OK, decodedData]

func listen(path : String):
	path = path.trim_prefix("/").trim_suffix(".json").trim_suffix("/")
	var listener = load("res://addons/godot_firebase_lite/Realtime Database/Listener.tscn").instantiate()
	var nodePath = path.replace("/", "_").replace(".", "_").replace(":", "_").replace("@", "_").replace('"', "_").replace("@", "_")
	listener.name = nodePath
	self.add_child(listener)
	var listenerNode = get_node(nodePath)
	listenerNode.connect("connected", listenerConnected, 0)
	listenerNode.connect_to_host(str(FirebaseLite.firebaseConfig["databaseURL"]), str(path+".json"), 443)

func listenerConnected(name):
	get_node(str(name)).connect("new_sse_event", sseEvent, 0)

func sseEvent(headers, event, data, key):
	data["key"] = str(key)
	emit_signal("refUpdated", data)

extends Node
class_name RealtimeDatabase

signal refUpdated(data)
signal refDeleted(ref)

func write(path : String, writeData : Dictionary):
	return await processRequest(path, HTTPClient.METHOD_PUT, writeData)

func push(path : String, pushData : Dictionary):
	return await processRequest(path, HTTPClient.METHOD_POST, pushData)

func update(path : String, updateData : Dictionary):
	return await processRequest(path, HTTPClient.METHOD_PATCH, updateData)

func delete(path : String):
	return await processRequest(path, HTTPClient.METHOD_DELETE)

func read(path : String):
	return await processRequest(path, HTTPClient.METHOD_GET)

func processRequest(path, method, body = []):
	var databaseHttp = HTTPRequest.new()
	add_child(databaseHttp)
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
	databaseHttp.queue_free()
	if data[1] != 200: #Request for writing data was not approved
		printerr("Firebase Error (Realtime Database): there was an error with processing your request, received data: " + str(decodedData))
		return ERR_DATABASE_CANT_WRITE
	else:
		return decodedData

func listen(path : String):
	path = path.trim_prefix("/").trim_suffix(".json").trim_suffix("/")
	var listener = load("res://addons/godot_firebase_lite/httpsse_client/Listener.tscn").instantiate()
	var nodePath = path.replace("/", "_").replace(".", "_").replace(":", "_").replace("@", "_").replace('"', "_").replace("@", "_")
	listener.name = nodePath
	self.add_child(listener)
	var listenerNode = get_node(nodePath)
	listenerNode.connect("connected", listenerConnected, 0)
	listenerNode.connect_to_host(str(FirebaseLite.firebaseConfig["databaseURL"]), str(path+".json"), 443)

func disconnectRef(path : String):
	path = path.trim_prefix("/").trim_suffix(".json").trim_suffix("/")
	var nodePath = path.replace("/", "_").replace(".", "_").replace(":", "_").replace("@", "_").replace('"', "_").replace("@", "_")
	var err = get_node_or_null("/root/FirebaseLite/Realtime Database/"+nodePath)
	if err != null:
		err.queue_free()
	else:
		printerr("Firebase (Realtime Database): %s is not connected to any listeners")
		return ERR_CANT_RESOLVE
	return OK

func listenerConnected(name):
	get_node(str(name)).connect("new_sse_event", sseEvent, 0)

func sseEvent(headers, data, key):
	var result = {"key": "", "data": ""}
	if data["data"] == null:
		emit_signal("refDeleted", key)
		return
	result["key"] = key
	result["data"] = data["data"]
	emit_signal("refUpdated", result)

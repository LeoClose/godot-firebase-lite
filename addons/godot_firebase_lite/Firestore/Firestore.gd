extends Node

@onready var databaseHttp : HTTPRequest = get_node("HTTPRequest")

func write(path, data):
	path = path.trim_prefix("/").trim_suffix("/").replace(" ", "%20")
	var collection = path.left(path.find("/"))
	path = path.replace(collection+"/", "")
	var str = "%s?documentId=%s" % [collection, path]
	return await processRequest(str, HTTPClient.METHOD_POST, data)

func read(path):
	return await processRequest(path, HTTPClient.METHOD_GET)

func update(path, data):
	return await processRequest(path, HTTPClient.METHOD_PATCH, data)

func delete(path):
	return await processRequest(path, HTTPClient.METHOD_DELETE)

func firestore2godot(dict):
	var result
	for value in dict:
		match value:
			"stringValue": result = str(dict[value])
			"booleanValue": result = bool(dict[value])
			"nullValue": result = null
			"integerValue": result = int(dict[value])
			"doubleValue": result = float(dict[value])
			"mapValue":
				var map : Dictionary
				for field in dict[value]["fields"].keys():
					map[field] = firestore2godot(dict[value]["fields"][field])
				result = map
			"arrayValue":
				var array : Array
				for item in dict[value]["values"]:
					array.append(firestore2godot(item))
				result = array
	return result

func godot2firestore(key):
	var result : Dictionary
	match typeof(key):
		TYPE_BOOL: result = {"booleanValue": key}
		TYPE_INT: result = {"integerValue": key}
		TYPE_NIL: result = {"nullValue": key}
		TYPE_FLOAT: result = {"doubleValue": key}
		TYPE_STRING: result = {"stringValue": key}
		TYPE_STRING_NAME: result = {"stringValue": key}
		TYPE_DICTIONARY:
			var fields : Dictionary = {}
			for keys in key.keys():
				fields[keys] = godot2firestore(key[keys])
			result["mapValue"] = {}
			result["mapValue"]["fields"] = fields
		TYPE_ARRAY:
			var items : Array
			for item in key:
				items.append(godot2firestore(item))
			result["arrayValue"] = {}
			result["arrayValue"]["values"] = items
	return result

func processDictionary(dict, type):
	var result : Dictionary
	for key in dict.keys():
		match type:
			0:
				if typeof(dict[key]) == TYPE_DICTIONARY or typeof(dict[key]) == TYPE_ARRAY:
					result[key] = godot2firestore(dict[key])
				else:
					result[key] = godot2firestore(key)
			1:
				result[key] = firestore2godot(dict[key])
	return result

func processRequest(doc, method, body = []):
	var url = "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/%s" % [FirebaseLite.firebaseConfig["projectId"], doc]
	var headers
	if FirebaseLite.authToken == null:
		headers = ["Content-Type: application/json"]
	else:
		headers = ["Content-Type: application/json", "Authorization: Bearer %s" % FirebaseLite.authToken]
	if method == HTTPClient.METHOD_GET or method == HTTPClient.METHOD_DELETE:
		databaseHttp.request(url, headers, method)
	else:
		body = await processDictionary(body, 0)
		databaseHttp.request(url, headers, method, JSON.stringify({"fields": body}))
	var data = await databaseHttp.request_completed
	var decodedData = JSON.new().parse_string(str(data[3].get_string_from_utf8()))
	if data[1] != 200: #Request for writing data was not approved
		printerr("Firebase Error (Firestore): there was an error with processing your request, received data: " + str(decodedData))
		return [ERR_DATABASE_CANT_WRITE, decodedData]
	else:
		var result = null
		if "fields" in decodedData.keys():
			result = await processDictionary(decodedData["fields"], 1)
		return [OK, result]

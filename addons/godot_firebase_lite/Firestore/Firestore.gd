extends Node
class_name Firestore

const operators = ["LESS_THAN", "LESS_THAN_OR_EQUAL", "GREATER_THAN",
		"GREATER_THAN_OR_EQUAL", "EQUAL", "NOT_EQUAL", "ARRAY_CONTAINS",
		"IN", "ARRAY_CONTAINS_ANY", "NOT_IN"]

func write(path: String, data : Dictionary):
	path = path.trim_prefix("/").trim_suffix("/").replace(" ", "%20")
	var collection = path.left(path.find("/"))
	path = path.replace(collection+"/", "")
	var url = "%s?documentId=%s" % [collection, path]
	return await processRequest(url, HTTPClient.METHOD_POST, data)

func read(path: String):
	return await processRequest(path, HTTPClient.METHOD_GET)

func update(path: String, data : Dictionary):
	return await processRequest(path, HTTPClient.METHOD_PATCH, data)

func delete(path: String):
	return await processRequest(path, HTTPClient.METHOD_DELETE)

func query(collection: String, field: String, operator: String, values):
	if operators.has(operator) == false:
		printerr("Firebase (Firestore): Invalid query operator. Valid operators are: "+str(operators))
	else:
		return await processQuery(collection, field, operator, values)

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
					result[key] = godot2firestore(dict[key])
			1:
				result[key] = firestore2godot(dict[key])
				
	return result

func getHeaders():
	var headers
	if FirebaseLite.authToken == null:
		headers = ["Content-Type: application/json"]
	else:
		headers = ["Content-Type: application/json", "Authorization: Bearer %s" % FirebaseLite.authToken]
	return headers

func processRequest(doc, method, body = []):
	var databaseHttp = HTTPRequest.new()
	add_child(databaseHttp)
	var url = "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents/%s" % [FirebaseLite.firebaseConfig["projectId"], doc]
	var headers = getHeaders()
	if method == HTTPClient.METHOD_GET or method == HTTPClient.METHOD_DELETE:
		databaseHttp.request(url, headers, method)
	else:
		body = await processDictionary(body, 0)
		databaseHttp.request(url, headers, method, JSON.stringify({"fields": body}))
	var data = await databaseHttp.request_completed
	var decodedData = JSON.new().parse_string(str(data[3].get_string_from_utf8()))
	databaseHttp.queue_free()
	if data[1] != 200: #Request for writing data was not approved
		printerr("Firebase Error (Firestore): there was an error with processing your request, received data: " + str(decodedData))
		return ERR_DATABASE_CANT_WRITE
	else:
		var result = null
		if "fields" in decodedData.keys():
			result = await processDictionary(decodedData["fields"], 1)
		return result

func processQuery(collection, field, op, values):
	var databaseHttp = HTTPRequest.new()
	add_child(databaseHttp)
	var url = "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents:runQuery" % [FirebaseLite.firebaseConfig["projectId"]]
	var headers = getHeaders()
	var body = {"structuredQuery": {
		"from": [{
			"collectionId": "%s" % collection,
			"allDescendants": true
		}],
		"where": {
			"fieldFilter": {
				"field": {
					"fieldPath": "%s" % field
				},
				"op": "%s" % op,
				"value": godot2firestore(values)
			}
		}
	}}
	databaseHttp.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	var data = await databaseHttp.request_completed
	var decodedData = JSON.new().parse_string(str(data[3].get_string_from_utf8()))
	databaseHttp.queue_free()
	if data[1] != 200: #Request for reading data was not approved
		printerr("Firebase Error (Firestore): "+decodedData[0]["error"]["message"])
		return ERR_DATABASE_CANT_WRITE
	else:
		var result : Array
		if !decodedData[0].size() > 1:
			return []
		for document in decodedData:
			result.append({"document": document["document"]["name"].replace("projects/%s/databases/(default)/documents/%s/" % [FirebaseLite.firebaseConfig["projectId"], collection], ""), "fields": document["document"]["fields"]})
		for x in len(result):
			for fields in result[x]["fields"]:
				result[x]["fields"][fields] = firestore2godot(result[x]["fields"][fields])
		return result

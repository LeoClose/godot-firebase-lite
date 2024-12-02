extends Node
class_name Storage

func upload(file: String, path: String, meta: Dictionary = {}):
	var fileAccess = FileAccess.open(file, FileAccess.READ)
	var content = fileAccess.get_buffer(fileAccess.get_length())
	fileAccess.close()
	
	var fileName = file.get_file()
	var extension = fileName.get_extension()
	var type = get_type(extension)
	var form = type.get_base_dir()
	
	var body = PackedByteArray()
	body.append_array("\r\n--WebKitFormBoundaryePkpFF7tjBAqx29L\r\n".to_utf8_buffer())
	body.append_array(str("Content-Disposition: form-data; name=\"%s\"; filename=\"%s\"\r\n" % [form, fileName]).to_utf8_buffer())
	body.append_array(str("Content-Type: %s\r\n\r\n" % type).to_utf8_buffer())
	body.append_array(content)
	body.append_array("\r\n--WebKitFormBoundaryePkpFF7tjBAqx29L--\r\n".to_utf8_buffer())
	
	var databaseHttp = HTTPRequest.new()
	add_child(databaseHttp)
	databaseHttp.request_raw(get_url(path, "alt=media"), ["Authorization: Bearer %s" % FirebaseLite.authToken,"Content-Type: multipart/form-data;boundary=\"WebKitFormBoundaryePkpFF7tjBAqx29L\""], HTTPClient.METHOD_POST, body)
	var data = await databaseHttp.request_completed
	var decodedData = JSON.new().parse_string(str(data[3].get_string_from_utf8()))
	databaseHttp.queue_free()
	if data[1] != 404:
		if not meta.is_empty():
			addMeta(path, meta)
	else:
		return ERR_CANT_CREATE
	return decodedData

func download(path: String, file: String):
	var databaseHttp = HTTPRequest.new()
	add_child(databaseHttp)
	databaseHttp.request_raw(get_url(path, "alt=media"), ["Authorization: Bearer %s" % FirebaseLite.authToken], HTTPClient.METHOD_GET)
	var data = await databaseHttp.request_completed
	var fileAccess = FileAccess.open(file, FileAccess.WRITE)
	fileAccess.store_buffer(data[3])
	fileAccess.close()
	databaseHttp.queue_free()
	return str(data[2])

func delete(path: String):
	var databaseHttp = HTTPRequest.new()
	add_child(databaseHttp)
	databaseHttp.request(get_url(path, "alt=media"), ["Authorization: Bearer %s" % FirebaseLite.authToken], HTTPClient.METHOD_DELETE)
	var data = await databaseHttp.request_completed
	databaseHttp.queue_free()
	if data[1] == 404:
		return ERR_CANT_RESOLVE
	return OK

func addMeta(path: String, meta: Dictionary):
	var databaseHttp = HTTPRequest.new()
	add_child(databaseHttp)
	databaseHttp.request(get_url(path, "alt=media"), ["Authorization: Bearer %s" % FirebaseLite.authToken, "Content-Type: application/json"], HTTPClient.METHOD_PATCH, JSON.stringify({"metadata": meta}))
	var data = await databaseHttp.request_completed
	var decodedData = JSON.new().parse_string(str(data[3].get_string_from_utf8()))
	databaseHttp.queue_free()
	return decodedData

func list():
	var databaseHttp = HTTPRequest.new()
	add_child(databaseHttp)
	databaseHttp.request(get_url("", "fields=id,name,metadata"), ["Authorization: Bearer %s" % FirebaseLite.authToken, "Content-Type: application/json"], HTTPClient.METHOD_GET)
	var data = await databaseHttp.request_completed
	var decodedData = (str(data[3].get_string_from_utf8()))
	databaseHttp.queue_free()
	decodedData = JSON.new().parse_string(decodedData)
	return decodedData

func get_url(path: String, parameter: String):
	path = path.replace("/", "%2F")
	path = "https://firebasestorage.googleapis.com/v0/b/"+FirebaseLite.firebaseConfig["storageBucket"]+"/o/"+path+"?"+parameter
	return path

func get_type(extension: String):
	match extension:
		"jpeg", "jpg":
			return "image/jpeg"
		"png":
			return "image/png"
		"txt":
			return "text/plain"
		"json":
			return "application/json"
		"jsonld":
			return "application/ld+json"
		"wav":
			return "audio/wav"
		"mp3":
			return "audio/mp3"
		"ogg", "oga", "opus":
			return "audio/ogg"
		"ogv":
			return "video/ogg"
		"ogx":
			return "application/ogx"
		"mp4":
			return "video/mp4"
		"ico":
			return "image/vnd.microsoft.icon"
		"gif":
			return "image/gif"
		"ttf":
			return "font/ttf"
		"otf":
			return "font/otf"
		"woff":
			return "font/woff"
		"woff2":
			return "font/woff2"
		"pdf":
			return "application/pdf"
		"rtf":
			return "application/rtf"
		"doc":
			return "application/msword"
		"docx":
			return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
		"csv":
			return "text/csv"
		"htm", "html":
			return "text/html"
		"css":
			return "text/css"
		"mjs", "js":
			return "text/javascript"
		"jar":
			return "application/java-archive"
		"mpeg":
			return "video/mpeg"
		"svg":
			return "image/svg+xml"
		"tif", "tiff":
			return "image/tiff"
		"xml":
			return "application/xml"
		"rar":
			return "application/vnd.rar"
		_:
			return "application/octet-stream"

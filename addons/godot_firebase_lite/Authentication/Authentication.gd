extends Node
class_name Authentication

func initializeAuth(type : int, email : String = "", password : String = ""):
	match type:
		1: return await processRequest("signUp", {'returnSecureToken':true})
		2: return await processRequest("signUp", {'email':email,'password':password,'returnSecureToken':true})
		3: return await processRequest("signInWithPassword", {'email':email,'password':password,'returnSecureToken':true})

func getUserData():
	return await processRequest("lookup", {'idToken':FirebaseLite.authToken})

func changeEmail(email : String):
	return await processRequest("update", {'idToken':FirebaseLite.authToken,'email':email,'returnSecureToken':true})

func changePassword(password : String):
	return await processRequest("update", {'idToken':FirebaseLite.authToken,'password':password,'returnSecureToken':true})

func updateDisplayName(displayName : String):
	return await processRequest("update", {'idToken':FirebaseLite.authToken,'displayName':displayName,'returnSecureToken':true})

func updatePhoto(photoUrl : String):
	return await processRequest("update", {'idToken':FirebaseLite.authToken,'photoUrl':photoUrl,'returnSecureToken':true})

func linkWithEmail(email : String, password : String):
	return await processRequest("update", {'idToken':FirebaseLite.authToken,'email':email,'password':password,'returnSecureToken':true})

func sendEmailVerification():
	return await processRequest("sendOobCode", {'requestType':'VERIFY_EMAIL','idToken':FirebaseLite.authToken})

func deleteAccount():
	return await processRequest("delete", {'idToken':FirebaseLite.authToken})

func unlinkProvider(providers : Array):
	return await processRequest("update", {'idToken':FirebaseLite.authToken,'deleteProvider':providers,'returnSecureToken':true})

func processRequest(event, datats):
	if event == "signUp" or event == "signInWithPassword":
		if FirebaseLite.authToken != null: 
			printerr("User already logged in")
			return ERR_CANT_CONNECT
	else:
		if FirebaseLite.authToken == null:  
			printerr("Firebase (Authentication): User not logged in")
			return ERR_CANT_CONNECT
	var authHttp = HTTPRequest.new()
	add_child(authHttp)
	authHttp.request("https://identitytoolkit.googleapis.com/v1/accounts:"+event+"?key="+FirebaseLite.firebaseConfig["apiKey"], ["Content-Type: application/json"], HTTPClient.METHOD_POST, JSON.stringify(datats))
	var data = await authHttp.request_completed
	var decodedData = JSON.parse_string(data[3].get_string_from_utf8())
	authHttp.queue_free()
	if data[1] == 400: #Response code: 400 | There was an error
		printerr("Firebase (Authentication): There was an error, received data: %s" % decodedData)
		return ERR_CANT_CONNECT
	elif data[1] == 200: #Response code: 200 | Request was succesful and data was received
		if decodedData["kind"] == "identitytoolkit#SignupNewUserResponse":
			FirebaseLite.authToken = decodedData["idToken"]
		return decodedData

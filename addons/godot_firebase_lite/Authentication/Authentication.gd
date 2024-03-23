@tool
extends Node

@onready var authHttp : HTTPRequest = get_node("HTTPRequest") 

func initializeAuth(type : int, email : String = "", password : String = ""):
	if FirebaseLite.authToken != null: return [ERR_CANT_CONNECT, "User already logged in"]
	match type:
		1: return await processRequest("https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=", {'returnSecureToken':true})
		2: return await processRequest("https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=", {'email':email,'password':password,'returnSecureToken':true})
		3: return await processRequest("https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=", {'email':email,'password':password,'returnSecureToken':true})

func getUserData():
	if FirebaseLite.authToken == null: return [ERR_CANT_CONNECT, "User not logged in"]
	return await processRequest("https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=", {'idToken':FirebaseLite.authToken})

func changeEmail(email : String):
	if FirebaseLite.authToken == null: return [ERR_CANT_CONNECT, "User not logged in"]
	return await processRequest("https://identitytoolkit.googleapis.com/v1/accounts:update?key=", {'idToken':FirebaseLite.authToken,'email':email,'returnSecureToken':true})

func changePassword(password : String):
	if FirebaseLite.authToken == null: return [ERR_CANT_CONNECT, "User not logged in"]
	return await processRequest("https://identitytoolkit.googleapis.com/v1/accounts:update?key=", {'idToken':FirebaseLite.authToken,'password':password,'returnSecureToken':true})

func updateDisplayName(displayName : String):
	if FirebaseLite.authToken == null: return [ERR_CANT_CONNECT, "User not logged in"]
	return await processRequest("https://identitytoolkit.googleapis.com/v1/accounts:update?key=", {'idToken':FirebaseLite.authToken,'displayName':displayName,'returnSecureToken':true})

func updatePhoto(photoUrl : String):
	if FirebaseLite.authToken == null: return [ERR_CANT_CONNECT, "User not logged in"]
	return await processRequest("https://identitytoolkit.googleapis.com/v1/accounts:update?key=", {'idToken':FirebaseLite.authToken,'photoUrl':photoUrl,'returnSecureToken':true})

func linkWithEmail(email : String, password : String):
	if FirebaseLite.authToken == null: return [ERR_CANT_CONNECT, "User not logged in"]
	return await processRequest("https://identitytoolkit.googleapis.com/v1/accounts:update?key=", {'idToken':FirebaseLite.authToken,'email':email,'password':password,'returnSecureToken':true})

func sendEmailVerification():
	if FirebaseLite.authToken == null: return [ERR_CANT_CONNECT, "User not logged in"]
	return await processRequest("https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=", {'requestType':'VERIFY_EMAIL','idToken':FirebaseLite.authToken})

func deleteAccount():
	if FirebaseLite.authToken == null: return [ERR_CANT_CONNECT, "User not logged in"]
	return await processRequest("https://identitytoolkit.googleapis.com/v1/accounts:delete?key=", {'idToken':FirebaseLite.authToken})

func unlinkProvider(providers : Array):
	if FirebaseLite.authToken == null: return [ERR_CANT_CONNECT, "User not logged in"]
	return await processRequest("https://identitytoolkit.googleapis.com/v1/accounts:update?key=", {'idToken':FirebaseLite.authToken,'deleteProvider':providers,'returnSecureToken':true})

func processRequest(url, datats):
	authHttp.request(url+FirebaseLite.firebaseConfig["apiKey"], ["Content-Type: application/json"], HTTPClient.METHOD_POST, JSON.stringify(datats))
	var data = await authHttp.request_completed
	var decodedData = JSON.parse_string(data[3].get_string_from_utf8())
	if data[1] == 400: #Response code: 400 | There was an error
		print("Firebase Authentication Error: " + decodedData["error"]["message"])
		return [ERR_CANT_CONNECT, decodedData]
	elif data[1] == 200: #Response code: 200 | Request was succesful and data was received
		if decodedData["kind"] == "identitytoolkit#SignupNewUserResponse":
			FirebaseLite.authToken = decodedData["idToken"]
		return [OK, decodedData]

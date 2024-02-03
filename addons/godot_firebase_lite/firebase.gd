@tool
extends Node

const firebaseConfig : Dictionary = {
  "apiKey": "apiKey",
  "authDomain": "projectId",
  "projectId": "projectId",
  "databaseURL": "datanaseUrl",
  "storageBucket": "storageBucket",
  "messagingSenderId": "messagingSenderId",
  "appId": "appId",
  "measurementId": "measurementId",
  "googleAPIKey": "googleAPIKey", #AKA WebAPIKey, browserKey
};

#Firebase Apps References
var initialized = false
var Authentication : Node
var RealtimeDatabase : Node
var Firestore : Node
#Other
var authToken = null

#Signals
signal firebaseInitialized

func initializeFirebase(FirebaseApps : Array, config : Dictionary = {}) -> void:
	if config == {}:
		config = firebaseConfig
	if initialized == true: pass
	var temporaryApp
	for app in FirebaseApps:
		match app:
			"Authentication": 
				temporaryApp = load("res://addons/godot_firebase_lite/Authentication/Authentication.tscn").instantiate()
			"Realtime Database":
				temporaryApp = load("res://addons/godot_firebase_lite/Realtime Database/RealtimeDatabase.tscn").instantiate()
			"Firestore":
				temporaryApp = load("res://addons/godot_firebase_lite/Firestore/Firestore.tscn").instantiate()
		temporaryApp.name = app
		self.add_child(temporaryApp)
		match app:
			"Authentication":
				Authentication = get_node(str(temporaryApp.name))
			"Realtime Database":
				RealtimeDatabase = get_node(str(temporaryApp.name))
			"Firestore":
				Firestore = get_node(str(temporaryApp.name))
	initialized = true

func terminateFirestore() -> void:
	self.queue_free()

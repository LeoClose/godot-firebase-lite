@tool
extends Node

const firebaseConfig : Dictionary = {
  "apiKey": "AIzaSyAtTsc0sKbGyq1LnePOpX_p3u9HnhH-xxo",
  "authDomain": "godot-firebase-lite.firebaseapp.com",
  "projectId": "godot-firebase-lite",
  "databaseURL": "https://godot-firebase-lite-default-rtdb.europe-west1.firebasedatabase.app",
  "storageBucket": "godot-firebase-lite.appspot.com",
  "messagingSenderId": "940493254029",
  "appId": "1:940493254029:web:9c36c466fc1e04d23721c4",
  "measurementId": "G-655LJLZH32",
  "googleAPIKey": "AIzaSyDn3gbE3pkTvD62hntM-X5qADcaDJs0evw", #AKA WebAPIKey, browserKey
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

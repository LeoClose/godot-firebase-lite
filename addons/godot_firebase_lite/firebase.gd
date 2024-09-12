@tool
extends Node

#Firebase Apps References
var Authentication : Authentication
var RealtimeDatabase : RealtimeDatabase
var Firestore : Firestore
var Storage : Storage
#Other
var authToken = null
#Firebase config
var firebaseConfig : Dictionary

func initialize(config : Dictionary):
	if config.is_empty():
		printerr("Firebase (Initializing): Insufficient firebase configuration")
		return ERR_CANT_CREATE
	else:
		firebaseConfig = config
	Authentication = load("res://addons/godot_firebase_lite/Authentication/Authentication.tscn").instantiate()
	RealtimeDatabase = load("res://addons/godot_firebase_lite/Realtime Database/RealtimeDatabase.tscn").instantiate()
	Firestore = load("res://addons/godot_firebase_lite/Firestore/Firestore.tscn").instantiate()
	Storage = load("res://addons/godot_firebase_lite/Storage/Storage.tscn").instantiate()
	add_child(Authentication)
	add_child(RealtimeDatabase)
	add_child(Firestore)
	add_child(Storage)
	return OK

func terminate(app: String):
	match app:
		"Authentication":
			Authentication.queue_free()
		"Realtime Database":
			RealtimeDatabase.queue_free()
		"Firestore":
			Firestore.queue_free()
		"Storage":
			Storage.queue_free()
		_:
			printerr("Firebase (Initializing): %s doesn't exist" % app)
			return ERR_CANT_RESOLVE
	return OK

func terminateFirestore() -> void:
	self.queue_free()

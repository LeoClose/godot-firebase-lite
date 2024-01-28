@tool
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("FirebaseLite", "res://addons/godot_firebase_lite/firebase.tscn")
	add_custom_type("FirebaseHTTPSSEClient", "Node", preload("res://addons/godot_firebase_lite/Realtime Database/HTTPSSEClient.gd"), preload("res://addons/godot_firebase_lite/HTTPSSEClientIcon.png"))

func _exit_tree():
	remove_autoload_singleton("FirebaseLite")
	remove_custom_type("FirebaseHTTPSSEClient")

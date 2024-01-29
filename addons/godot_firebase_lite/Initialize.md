# Initialize Godot Firebase Lite plugin

> [!NOTE]
> Before using it, you have to initialize the plugin first, but it's easy and has to be done once every project!

## Providing your Firebase configuration
**You can paste your Firebase configuration either in __addons/godot_firebase_lite/firebase.gd__ or in the ```initializeFirebase``` function upon initialization via script**

## Initialize Firebase
```GDScript
FirebaseLite.initializeFirebase(FirebaseApps : Array, Configuration : Dictionary)
```
> [!NOTE]
> FirebaseApps are the apps you wish to use and should be passed like this: ["Authentication", "Firestore", "Realtime Database"]

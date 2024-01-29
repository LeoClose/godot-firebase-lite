# Firestore with Godot Firebase Lite

> [!NOTE]
> Values from all the functions are returned in an array [ERROR, receivedData] where **ERROR** is either 0 (OK) or an error that occured and **receivedData** is data received from your request

## Write (Create)
> [!CAUTION]
> Usin write will create a new document if it doesn't exist yet or overwrite the existing one
```GDScript
FirebaseLite.Firestore.write(path : String, data : Dictionary)
```
> [!TIP]
> It should look like this: ```FirebaseLite.Firestore.write("collection/document", {"key": "value"})```

## Update
```GDScript
FirebaseLite.Firestore.update(path : String, data : Dictionary)
```

## Read
```GDScript
FirebaseLite.Firestore.read(path : String)
```

## Delete
```GDScript
FirebaseLite.Firestore.delete(path : String)
```

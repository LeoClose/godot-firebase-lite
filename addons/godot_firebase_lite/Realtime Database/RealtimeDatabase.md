# Realtime Database with Godot Firebase Lite

> [!NOTE]
> Values from all the functions are returned in an array [ERROR, receivedData] where **ERROR** is either 0 (OK) or an error that occured and **receivedData** is data received from your request

## Write (Create)
> [!CAUTION]
> Usin write will create a new document if it doesn't exist yet or overwrite the existing one
```GDScript
FirebaseLite.RealtimeDatabase.write(path : String, data : Dictionary)
```
> [!TIP]
> It should look like this: ```FirebaseLite.RealtimeDatabase.write("path/path/path", {"key": "value"})```

## Push
**the equivalent of the JavaScript ```push()``` method**
```GDScript
FirebaseLite.RealtimeDatabase.push(path : String, data : Dictionary)
```

## Update
```GDScript
FirebaseLite.RealtimeDatabase.update(path : String, updateData : Dictionary)
```

## Read
```GDScript
FirebaseLite.RealtimeDatabase.update(path : String)
```

## Delete
## Read
```GDScript
FirebaseLite.RealtimeDatabase.delete(path : String)
```

## Listen For Changes
```GDScript
FirebaseLite.RealtimeDatabase.listen(path : String)
```
> [!NOTE]
> To receive data, connect ```"refUpdated"``` signal to ```FirebaseLite.RealtimeDatabase```

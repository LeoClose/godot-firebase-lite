# Authentication with Godot Firebase Lite

> [!NOTE]
> Values from all the functions are returned in an array [ERROR, receivedData] where **ERROR** is either 0 (OK) or an error that occured and **receivedData** is data received from your request

## Setting up your Firebase project to use Authentication
Before starting, you have to set up Authentication in your Firebase project first and select login/signup options that you will provide (Anonymouse or Email/Password).
You can do so under "Sign-in method" and "Add new provider"

## Login/Signup
> [!IMPORTANT]
>**When logged in, authToken is automatically saved to FirebaseLite.authToken and Authentication for other Firebase resources is automatic**

**Sign in anonymously**
```GDScript
FirebaseLite.Authentication.initializeAuth(1)
```
**Sign up with email / password**
```GDScript
FirebaseLite.Authentication.initializeAuth(2, email : String, password : String)
```
**Sign in with email / password**
```GDScript
FirebaseLite.Authentication.initializeAuth(3, email : String, password  : String)
```

## Get User Data
**Returns currently logged in user data in this format:**
```JSON
{
      "localId": "ZY1rJK0...",
      "email": "user@example.com",
      "emailVerified": false,
      "displayName": "John Doe",
      "providerUserInfo": [
        {
          "providerId": "password",
          "displayName": "John Doe",
          "photoUrl": "http://localhost:8080/img1234567890/photo.png",
          "federatedId": "user@example.com",
          "email": "user@example.com",
          "rawId": "user@example.com",
          "screenName": "user@example.com"
        }
      ],
      "photoUrl": "https://lh5.googleusercontent.com/.../photo.jpg",
      "passwordHash": "...",
      "passwordUpdatedAt": 1.484124177E12,
      "validSince": "1484124177",
      "disabled": false,
      "lastLoginAt": "1484628946000",
      "createdAt": "1484124142000",
      "customAuth": false
}
```
```GDScript
FirebaseLite.Authentication.getUserData()
```

## Send E-mail Verification
**Send e-mail verification to currently logged in user**
> [!TIP]
>**This requires the usage of [Confirm Email Verification](https://firebase.google.com/docs/reference/rest/auth#section-confirm-email-verification), which you will have to do with your website hosted on Firebase**
```GDScript
FirebaseLite.Authentication.sendEmailVerification()
```

## Link account with E-mail
**Link currently logged in user to an e-mail account with new password**

```GDScript
FirebaseLite.Authentication.linkWithEmail(email : String, password : String)
```

## Delete Account
**Delete currently logged in users account from your Firebase project**
```GDScript
FirebaseLite.Authentication.deleteAccount()
```

## Unlink Provided
**Unlink providers listen in the array as a string from currently logged in users account from your Firebase project**

**Available providers: ["anonymous", "email", "phone"]**
```GDScript
FirebaseLite.Authentication.unlinkProvider(providers : Array)
```

## Change E-mail
**Change currently logged in users e-mail connected with his account**
```GDScript
FirebaseLite.Authentication.changeEmail(email : String)
```

## Change Password
**Change currently logged in users password connected with his account**
```GDScript
FirebaseLite.Authentication.changePassword(password : String)
```

## Update Display Name
**Update currently logged in users display name in your Firebase project**
```GDScript
FirebaseLite.Authentication.updateDisplayName(displayName : String)
```

## Update Photo
**Update currently logged in users photo in your Firebase project**
```GDScript
FirebaseLite.Authentication.updatePhoto(photoUrl : String)
```

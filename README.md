# Task 10 · Firebase CRUD

An Android Flutter app for adding, editing, deleting, and favoriting items. The main screen uses the teal header, gray background, and item cards from the class reference. Cloud Firestore stores each item's name, quantity, creation time, and favorite status.

## Run on the Android emulator

1. Open this project folder in Android Studio and start an Android Virtual Device.
2. In a terminal at the project root, start the local Firestore server with the Firebase CLI. Keep this terminal running while using the app.

   ```powershell
   firebase emulators:start --only firestore --project demo-firebase-note
   ```

3. In a second terminal, run the app or select the Android emulator in Android Studio and click **Run**.

   ```powershell
   flutter pub get
   flutter run
   ```

The Android emulator reaches the laptop's Firestore server through `10.0.2.2:8080`. To keep your items when stopping the Firestore server, append `--export-on-exit=./firebase-export` to the Firebase command. Once that directory exists, append `--import=./firebase-export` on subsequent starts.

## Connect your own Firebase project

The included `lib/firebase_options.dart` points to the local Firestore emulator through the `demo-firebase-note` project ID. To connect to a cloud project, follow [FlutterFire setup](https://firebase.google.com/docs/flutter/setup) and run `flutterfire configure --platforms=android` from the project root. Select your Firebase project and let FlutterFire replace `lib/firebase_options.dart`. The app initializes from that file and selects the emulator only for project IDs beginning with `demo-`. Set the appropriate Firestore access rules in your cloud project. The included `firestore.emulator.rules` is for the local demo.

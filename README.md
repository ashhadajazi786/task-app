
# ✅ Flutter Task App

A clean and simple task manager built with Flutter and Firebase. Users can sign up, log in, add tasks, mark them completed, and see task status like overdue (red outline) and completed (black tick). Includes a profile page and logout feature.

---

## 🧪 Test Login

- **Email:** m.ashhad017@gmail.com  
- **Password:** Ashhad123@

---

Overview

Task Manager App is a Flutter application that allows users to manage tasks with full CRUD functionality, Firebase authentication, real-time updates, and integration with a fake user API. The app uses Provider for state management and Firebase for backend services.

Features
Authentication

User signup and login using Firebase Authentication

Logout functionality

Redirects to HomePage if user is already logged in

Task Management (CRUD)

Add Task: Enter title, description, select date & time

Update Task: Edit existing tasks

Delete Task: Remove tasks permanently

Toggle Completion: Mark tasks as completed or pending

Filter Tasks: View All, Completed, or Pending tasks

Real-Time Updates

Tasks update in real-time using Firestore snapshots

API Integration

Fetches fake users from an external API

Displays fake users in a separate screen

Real User Details

Displays logged-in user details stored in Firebase Firestore

Project Structure
lib/
├── main.dart                  # App entry point
├── provider/
│   └── task_provider.dart     # Task management (CRUD, toggle, filter)
├── screens/
│   ├── home.dart              # Home page with task list
│   ├── login.dart             # Login screen
│   ├── signup.dart            # Signup screen
│   ├── splashscreen.dart      # Splash screen
│   ├── userdetails.dart       # Logged-in user details page
│   └── api_product_screen.dart# Fake API users list
├── firebase_options.dart      # Firebase configuration

Dependencies
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5
  firebase_core: ^2.20.0
  firebase_auth: ^4.7.0
  cloud_firestore: ^5.5.0
  intl: ^0.18.1
  http: ^1.1.1

T
Firebase Setup

Create a Firebase project

Enable Authentication (Email/Password)

Enable Cloud Firestore

Add Android/iOS apps in Firebase console

Download google-services.json (Android) or GoogleService-Info.plist (iOS)

Configure firebase_options.dart using flutterfire configure

Usage


Install dependencies:

flutter pub get


Run the app:

flutter run


Signup/login → manage tasks → view API users → logout
Have feedback or issues?

**Email:** m.ashhad017@gmail.com

---

## 📌 Note

- This app is designed for learning/demo purpose.
- UI is optimized for general usage with clean logic.
- Firebase setup required for full functionality.

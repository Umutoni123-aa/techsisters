# TechSisters

## About the app

TechSisters is a mobile application designed to empower women through digital education. It helps women access learning materials, develop new skills, and improve their knowledge through online learning.

## Features

Users can create an account and log in to access the application. After logging in, they can explore available courses, access learning materials, and follow lessons to improve their skills.

## Architecture

The application is organized into three main layers. The data layer communicates with Firebase and manages data storage and retrieval. The domain layer contains the main business logic and rules of the application. The presentation layer manages the user interface, screens, and BLoC/Cubit state management.

## Database (Firestore)

The application uses Firebase Firestore as its database. Data is organized into the users, courses and notes collections. The users collection stores each learner's profile and learning data (XP, streak, learning goal and skill level), and has two subcollections: progress, which tracks the learner's progress in each course, and projects, which stores the learner's projects. The courses collection contains the learning courses, and each course has a lessons subcollection with the lesson content, questions and video. The notes collection stores personal notes created by users. The full diagram is in docs/erd.png.

The Firestore security rules ensure that users can only access their own data. A user can read and update their own profile, and can create, read, update and delete their own progress, projects and notes. Logged-in users can read courses and lessons, but they cannot create, edit, or delete them directly from the application.

## How to run the app

1. Download the project: git clone https://github.com/Umutoni123-aa/techsisters.git
2. Install the packages: cd techsisters, then flutter pub get
3. Start the app: flutter run

## Known limitations

Currently, the app has a limited number of learning resources and requires an internet connection to access its features. In the future, we plan to add more courses, support offline learning, and improve the user experience.

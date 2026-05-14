# Circle - Say Better Things, Faster

##  Project Overview

Circle is a modern social media app focused on content quality and user interaction. It provides standard social features (authentication, posts, likes, comments, profiles) supercharged with four unique AI capabilities powered by Google Gemini. The app is built with scalability and best practices in mind, featuring offline support, a robust state management solution, and a fully implemented design system with light and dark modes.

---

##  Key Features

### Core Social Features
- **User Authentication:** Email/password sign-up, login, and password reset.
- **Content Feed:** A real-time, scrollable feed of posts from all users.
- **Interactions:** Like and comment on posts to engage with the community.
- **User Profiles:** View and edit your own profile, or check out other users' profiles and posts.
- **Explore & Search:** Discover new users and trending content.
- **Notifications:** Real-time alerts for likes and comments (accessed from the top bar).

###  Four AI-Powered Features
*All AI features are securely proxied through Firebase Cloud Functions.*

1.  **Mood-to-Post**
    - **What it does:** Transforms a user's mood (e.g., "feeling adventurous") into a full post draft with text and hashtags.
    - **Benefit:** Eliminates writer's block and encourages more frequent, engaging posts.

2.  **Smart Reply**
    - **What it does:** Analyzes a post and a comment, then suggests three contextual, one-tap replies (e.g., funny, supportive, curious).
    - **Benefit:** Saves time and elevates the quality of interactions within comment threads.

3.  **Tone Transformer**
    - **What it does:** Rewrites a user's drafted post into three distinct tones: Professional (LinkedIn style), Funny/Meme (casual, witty), and Emotional/Story (heartfelt).
    - **Benefit:** Dramatically increases post quality and helps users tailor their message for maximum impact.

4.  **Feed Summarizer**
    - **What it does:** For users who have been inactive for 2+ days, it provides a one-line summary of the top 5 recent posts.
    - **Benefit:** Reduces the "fear of missing out" (FOMO) and provides a quick, easy re-entry point to the platform.

---

##  Tech Stack & Architecture


| Category | Choice | Justification |
|---|---|---|
| **Architecture** | Clean Architecture (Feature-First) | Highly scalable, testable, and maintainable codebase structure. |
| **State Management** | Riverpod (latest) | Reactive, compile-safe, and boilerplate-free state management. |
| **Navigation** | GoRouter | Declarative, URL-based navigation with deep linking support. |
| **Backend (BaaS)** | Firebase (Auth, Firestore, Storage, FCM) | Real-time, scalable, and secure back-end services with minimal overhead. |
| **AI Feature Layer** | Firebase Cloud Functions + Gemini API | Secure serverless proxy to protect API keys and add authentication, validation, and rate limiting. |
| **Local Database/Cache** | Hive | Ultra-fast, lightweight, NoSQL key-value store for offline feed caching. |
| **Networking** | Dio + Retrofit (code gen) | Type-safe HTTP client with interceptor support for logging and token refresh. |
| **Image Handling** | image_picker, cached_network_image, flutter_image_compress | Robust picking, performant caching, and efficient compression. |
| **Animation** | Flutter AnimatedBuilder + Rive | Smooth, declarative UI animations and high-quality interactive micro-interactions (e.g., like hearts). |
| **Validation** | Riverpod + Custom Extensions | Reactive form state management, fully integrated with the app's state logic. |
| **Logging & Error Reporting** | Logger + Firebase Crashlytics | Structured debugging logs and real-time production crash monitoring. |
| **Code Quality** | flutter_lints + very_good_analysis + dart_code_metrics | Strict static analysis and linting rules to enforce community best practices. |

### Architecture Diagram
```
lib/
├── core/
│   ├── constants/          # App strings, assets, API endpoints
│   ├── theme/              # Light/dark ThemeData configuration
│   ├── routes/             # GoRouter setup and route definitions
│   ├── utils/              # Helper functions, extensions, validators
│   ├── widgets/            # Shared, reusable UI components
│   └── services/           # Dio client, Firebase instances, AI service interface
├── features/
│   ├── auth/               # Authentication (Login, SignUp, Forgot Password)
│   │   ├── data/           # Models, Repositories
│   │   ├── domain/         # Entities, Usecases
│   │   └── presentation/  # Providers, Screens, Widgets
│   ├── feed/               # Main posts feed with likes & comments
│   ├── profile/            # User's own and others' profiles
│   ├── notifications/      # Real-time activity updates
│   └── ai/                 # Gemini feature integration (Mood-to-Post, etc.)
├── main.dart               # App entry point
└── firebase_options.dart   # Firebase configuration
```

---

##  Theme & Design

- **System:** Full support for Light and Dark themes using Flutter's `ThemeData`.
- **Persistence:** The user's theme preference is saved locally with Hive.
- **Default:** The app automatically matches the device's system theme.

---

##  App Screens & Navigation

- **Onboarding:** Intro screen for first-time users.
- **Bottom Navigation Bar:**
    -  **Feed:** The main home screen with a scrollable list of posts.
    -  **Explore:** Search for users and browse trending content.
    -  **AI Studio:** The dedicated hub for all four Gemini features.
    -  **Me:** Your personal profile (view, edit, view posts, logout).
- **Other Screens:** `Splash`, `Login`, `SignUp`, `ForgotPassword`, `Other User Profile`, `Comments` screen.
- **AI Quick Access:** Inline buttons for AI features are also available contextually in the Feed, Post Creation, and Comments screens.

---

##  Secure AI Implementation

The Flutter app never directly calls the Gemini API or stores an API key. The secure flow is:
1.  **Flutter App** authenticates the user and calls a Firebase Cloud Function.
2.  **Cloud Function** validates the Firebase Auth token and applies rate limiting.
3.  **Cloud Function** securely reads the `GEMINI_API_KEY` from its environment secrets.
4.  **Cloud Function** makes the request to the Gemini API.
5.  **Cloud Function** processes and returns the result to the Flutter App.


---


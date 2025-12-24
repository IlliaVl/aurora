# Aurora - Senior Flutter Engineer Task Solution

This repository contains the complete Flutter application built as a solution to the Senior Mobile Engineer (Flutter) test assignment for Aurora.

The app is built to be production-ready, demonstrating a clean, scalable, and testable architecture.

## 🚀 Final App Demo

A short video of the final application in action, demonstrating all features, premium UI polish, seamless transitions, and graceful error handling.

[**Watch the Demo Video (Google Drive)**](https://drive.google.com/file/d/1Zs-3ifE9y0P9WIrVCG0VbxtgB3o3a95S/view?usp=sharing)

## ✨ Features

* **Random Image Fetching:** Loads a new image from the provided API by pressing the "Another" button.

* **Immersive UI:** The app background features a blurred, "Ambilight-style" effect that perfectly matches the loaded image.

* **Premium UI Polish:**

   * **Squared Image:** The image is always displayed in a centered, 1:1 aspect ratio square.

* **Seamless Transitions:**

   * **Image Cross-Fade:** When a new image is loaded, it fades in *directly* from the previous image.

   * **Synchronized Background:** The blurred background cross-fades in perfect sync with the foreground image.

   * **Fixed-Size Button:** The "Another" button maintains a consistent size, seamlessly swapping its `Text` for a `CircularProgressIndicator` during loading.

* **Advanced Caching:**

   * **Offline Support:** The app uses **Hive (Community Edition)** to cache image data locally. If the network fails, the last successfully loaded image is retrieved from the local database, ensuring the app remains functional offline.

* **Accessibility (A11y):**

   * **Semantic Labels:** All interactive elements and images are wrapped in semantic widgets (e.g., "Randomly fetched image from Unsplash", "Fetch another random image") to support screen readers like TalkBack.

   * **High Contrast:** Text and button colors dynamically adapt to ensure optimal contrast ratios in both light and dark environments.

* **Light & Dark Mode Support:**

   * **Adaptive Design:** The app respects the system's theme settings.

   * **Dark Mode:** Features a deep, immersive aesthetic with an orange accent color and white text.

   * **Light Mode:** Offers a clean, airy look with a high-contrast black button and orange text, as per design requirements.

* **Graceful Error Handling:**

   * **User-Friendly Popups:** If the API fails or an image URL is a 404, the app shows a simple `SnackBar` with a clean error message (e.g., "Oops! The image could not be found").

   * **Persistent State:** If an error occurs, the previous image (and its blurred background) stays on screen, providing a seamless, non-disruptive experience.

## 🏛️ Architecture

This app is built using a production-ready, feature-driven Clean Architecture model to demonstrate best practices, testability, and separation of concerns.

* **Clean Architecture:** The project is separated into three distinct layers:

   * **`features/domain`**: Contains the core business logic (Use Cases) and abstract contracts (Repositories). It is pure Dart.

   * **`features/data`**: Contains the concrete implementations for fetching data (Data Sources, Repositories) and parsing models.

   * **`features/presentation`**: Contains the Flutter UI (Pages) and the state management (BLoC).

* **BLoC (State Management):** Uses `flutter_bloc` to manage all UI states (`Initial`, `Loading`, `Loaded`, `Error`), completely decoupling the business logic from the view.

* **Dependency Injection:** Uses `get_it` and `injectable` for robust dependency inversion and to manage all services and repositories.
* 
## 🚀 Getting Started

To run this project, you must first run the build runner to generate the necessary files for `freezed` and `injectable`.

### 1. Get Dependencies

```bash
flutter pub get
```

### 2. Run Build Runner

**This step is mandatory.**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Run the App

```bash
flutter run
```

# Seasonal Job Matching Platform - Features and Architecture

Welcome to the comprehensive guide of the Seasonal Job Matching Platform! This document will walk you through every feature, how they connect, and the underlying app logic. We've built this application with Flutter and Riverpod, focusing on a smooth user experience for job seekers looking for seasonal work.

## Table of Contents
1. [Core Architecture](#core-architecture)
2. [Authentication System](#authentication-system)
3. [Job Search & Discovery](#job-search--discovery)
4. [User Profile & Applications](#user-profile--applications)
5. [Notification System](#notification-system)
6. [Additional Features](#additional-features)
7. [Data Flow & Connections](#data-flow--connections)
8. [Technical Implementation Details](#technical-implementation-details)

---

## Core Architecture

At the heart of our application lies a robust architecture designed for scalability and maintainability. We use **Flutter Riverpod** for state management, which allows us to reactively update the UI based on state changes. Dependency injection is handled through Riverpod providers, making it easy to swap implementations and test components.

- **State Management**: Riverpod providers, notifiers, and async notifiers manage everything from authentication state to paginated job lists.
- **Navigation**: A custom `NavigationService` with a global navigator key (`rootNavigatorKey`) enables app-wide navigation without context.
- **Network Layer**: We use **Dio** as our HTTP client, configured with interceptors for authentication and error handling.
- **Backend Communication**: The app communicates with a RESTful API, with endpoints defined in `endpoints.dart`.

The `main.dart` file initializes Firebase, sets up notifications, and configures system UI overlays before launching the app with a `ProviderScope` to enable Riverpod.

---

## Authentication System

The authentication system is the gateway to the app, ensuring secure access to personalized features.

### Registration and Login
- **Signup**: Users can create an account by providing their name, country, phone number, email, and password. The `SignupRequestModel` captures this data, which is sent to the `USERS` endpoint (which is the signup endpoint). Upon success, the backend returns an `AuthResponseModel` containing user details and possibly a token.
- **Login**: Existing users log in with email and password via the `LOGIN` endpoint (`USERS/login`). The response includes user information and authentication token.

### Session Management
- **Token Storage**: After authentication, the token and user ID are securely stored using `AuthStorage` (which uses `flutter_secure_storage`). This ensures that even if the app restarts, the user remains logged in.
- **Session Restoration**: At app startup, `AuthNotifier` checks for stored credentials. If found, the user is automatically authenticated.
- **Logout**: Clears stored tokens and invalidates all relevant providers to reset the app state. It also clears the locally tracked set of applied jobs.

### Security Interceptors
- **AuthInterceptor**: Automatically attaches the stored token to outgoing requests.
- **Error Interceptor**: Handles 403 errors (session expired) by clearing storage and logging out the user, then triggering a session expired dialog. It also avoids interfering with authentication endpoints.

### FCM Token Registration
Upon login or signup, the app registers the device's Firebase Cloud Messaging (FCM) token with the backend. This enables push notifications. The token is associated with the user's account and device type (iOS/Android).

---

## Job Search & Discovery

The job search feature is designed to help users find seasonal jobs efficiently, with a focus on performance and user experience.

### Job Listings
- **Paginated Loading**: Jobs are loaded in pages (default page size is 50). The `PaginatedJobs` provider manages a state that includes the list of jobs, current page, total pages, and a set of viewed job IDs.
- **Infinite Scroll**: For the first 200 jobs (4 pages), the app automatically loads more when the user scrolls near the bottom. After that, a "Load More" button appears.
- **Server-Side Filtering**: Users can search by title, filter by job type, location, and salary type. These filters are sent to the `/jobs/filter` endpoint, which returns paginated results.
- **Job Model**: Each job is represented by `JobModel`, which includes details like title, description, type, location, start date, salary, status, and more. The model uses Freezed for immutability and JSON serialization.

### Job Display
- **Job Cards**: The `JobCard` widget displays job information in a visually appealing card with company avatar, title, location, type, salary, and date. It also shows a "New" badge for jobs posted within the last 7 days.
- **View Tracking**: Tapping a job card navigates to the job details and marks the job as viewed in the current session. Viewed jobs are dimmed (opacity reduced) in the list.
- **Favorites**: Users can favorite jobs from the card. The favorite state is managed by `PersonalInformationProvider` (which stores a list of favorite job IDs) and synchronized with the backend via `FavoritesController`.

### Job Details
- **Job View Screen**: Tapping a job card opens a detailed view (`JobView`) that shows the full job description, requirements, benefits, and comments. Users can apply from this screen.
- **Apply for Job**: The application process uses `ApplyForJobUseCase`, which validates the input and calls `ApplicationsRepository`. The repository checks for existing applications and then submits the application with a description (cover letter). The user's applied jobs list is updated accordingly.

---

## User Profile & Applications

The profile section allows users to manage their personal information, track applications, and set job preferences.

### Personal Information
- **Profile Data**: The `PersonalInformationAsyncNotifier` fetches user data, applied job IDs, favorite job IDs, and fields of interest from separate endpoints and combines them into a `PersonalInformationModel`.
- **Editable Fields**: Users can update their name, email, phone, and country. Changes are sent to the backend and the local state is optimistically updated.

### Applications Management
- **Applied Jobs**: The `ApplicationsScreen` shows a list of jobs the user has applied to. It uses `ApplicationsProvider` to fetch applied jobs from the backend.
- **Application Details**: Each application has a detail screen (`ApplicationsDetailScreen`) showing the job details, application status, and any updates.

### Fields of Interest
- Users can set their fields of interest (e.g., agriculture, tourism) which are used to provide personalized job recommendations. These are managed by `PersonalInformationAsyncNotifier` and updated via dedicated endpoints.

### Resume Management
- Users can upload and manage their resumes. The `ResumeProvider` handles resume file picking and uploading. The service (`ResumeService`) sends the file to the backend.

---

## Notification System

The notification system keeps users informed about application status changes and other relevant events.

### Push Notifications
- **Firebase Cloud Messaging**: The `NotificationService` initializes FCM, requests permission, and handles foreground and background messages.
- **Token Management**: The FCM token is obtained and registered with the backend. It is refreshed and re-registered if needed.
- **Message Handling**: The service can parse application status notifications from the message data.

### In-App Notifications
- **Notification List**: The `NotificationsScreen` displays a list of notifications fetched via `NotificationsApiService` from the `/notifications/{userId}` endpoint.
- **Unread Count**: The `unreadNotificationCountProvider` computes the number of unread notifications and displays it on a badge in the app bar.
- **Refresh**: Pull-to-refresh and manual refresh are supported.

---

## Additional Features

### Internationalization
The app supports multiple languages using Flutter's `flutter_localizations` and our own `AppLocalizations`. The `localeProvider` allows users to switch languages, and the app responds by updating the `MaterialApp`'s locale.

### Theme System
We use a custom `AppTheme` that provides light and dark themes. The theme includes color schemes, text styles, and component themes for a consistent look.

### Responsive Design
The UI is built to adapt to different screen sizes, with particular attention to scrolling lists and detail screens.

### Haptic Feedback
The app provides haptic feedback (light, medium, selection click) for interactive elements like job cards, favorite buttons, and pull-to-refresh.

### Animations
We use animations for:
- Job card tap scaling
- Favorite button scaling
- Shimmer loading effects
- Page transitions (via the navigation system)

---

## Data Flow & Connections

Let's trace how data moves through the app with a few examples.

### Authentication Flow
1. User enters credentials in `LoginScreen`.
2. `AuthNotifier.login` is called, which uses `AuthService.login`.
3. `AuthService` uses the Dio client (with base URL from `AppConfig`) to POST to `/users/login`.
4. On success, the token and user ID are saved to `AuthStorage`.
5. `AuthNotifier` updates its state to `authenticated`, which triggers a rebuild of the app's UI (e.g., navigating to home).
6. The Dio interceptor now attaches the token to future requests.

### Job Browsing Flow
1. `JobsScreen` displays `JobCardSection`.
2. `JobCardSection` watches `paginatedJobsProvider`.
3. `PaginatedJobs` (the notifier) calls `JobsServicesProvider.fetchJobsPage` or `searchJobs` depending on filters.
4. The service uses Dio to GET from `/jobs?page=X` or `/jobs/filter?page=X&...`.
5. The response is parsed into a `PaginatedJobsResponse`, which includes a list of `JobModel` objects and pagination metadata.
6. The state is updated, and the UI rebuilds to show the new jobs.
7. When the user scrolls, `NotificationListener` triggers `loadNextPage` or `loadMore`.

### Applying for a Job Flow
1. User taps "Apply" on `JobView`.
2. `ApplyForJobUseCase.execute` is called with user ID, job ID, and description.
3. The use case calls `ApplicationsRepository.apply`.
4. The repository first checks if the user has already applied (via `hasApplied`), then posts to `/applications/user/{userId}/job/{jobId}`.
5. On success, the use case returns the application data.
6. The UI shows a success message, and `PersonalInformationNotifier.refreshAppliedJobs` is called to update the applied jobs list.

### Notification Flow
1. On app start, `NotificationService.initialize` sets up FCM.
2. When a user logs in, `AuthNotifier._registerFcmToken` is called, which gets the current FCM token and registers it with the backend via `NotificationsApiService.registerToken`.
3. When the backend sends a notification, FCM delivers it to the device.
4. If the app is in the foreground, `onMessage` listener is triggered. If the app is opened from a notification, `onMessageOpenedApp` is triggered.
5. The `NotificationService` can parse the message and call a callback (set by the UI) to update the notifications list.

---

## Technical Implementation Details

### State Management Patterns
We use several Riverpod patterns:
- **Provider**: For exposing services (e.g., `authServiceProvider`).
- **NotifierProvider**: For mutable state notifiers (e.g., `AuthNotifier`, `JobsFilterNotifier`).
- **AsyncNotifierProvider**: For asynchronous state that loads data (e.g., `PersonalInformationAsyncNotifier`, `JobNotifier`).
- **FutureProvider.family**: For parameterized, one-time async data (e.g., `notificationsProvider`).
- **Generated Providers**: Some providers use Riverpod generator (e.g., `@riverpod` annotation) for reduced boilerplate.

### API Communication
- **Dio Configuration**: The `dioProvider` creates a Dio instance with base URL, timeouts, and headers. It also adds interceptors.
- **Endpoints**: All API paths are defined in `endpoints.dart` as constants and helper functions.
- **Error Handling**: Dio exceptions are caught and converted to user-friendly messages.

### Data Models
- **Freezed**: Many models are defined with Freezed for immutable data classes and union types. This includes `JobModel`, `AuthResponseModel`, `NotificationModel`, etc.
- **JSON Serialization**: Freezed generates `fromJson` and `toJson` methods. Custom `JsonKey` converters handle type mismatches (e.g., `_forceString` to convert any value to string).

### UI Components
We have a set of reusable widgets:
- **AppCard**: A styled card container.
- **AnimatedScaleButton**: A button with a scale animation on press.
- **StatusBadge**: Displays status with color coding.
- **NewBadge**: Shows a "New" label for recent items.
- **ShimmerLoading**: A shimmer effect for loading states.

### Performance Optimizations
- **Pagination**: Only loads the data needed, reducing initial load time and memory usage.
- **Selective Rebuilding**: Riverpod's provider system ensures only widgets that depend on changed state are rebuilt.
- **Optimistic Updates**: Actions like favoriting update the local state immediately, then sync with the backend.
- **Avoid Unnecessary Rebuilds**: We use `const` widgets where possible and carefully manage provider dependencies.

### Security
- **Secure Storage**: Sensitive data (tokens, user ID) are stored securely.
- **Token Handling**: Tokens are automatically attached and refreshed.
- **Session Expiration**: Handled gracefully with user feedback.

---

This wraps up our detailed tour of the Seasonal Job Matching Platform. The codebase is structured to be modular, testable, and scalable, with a clear separation between UI, business logic, and data layers. We hope this guide helps you understand and navigate the project with ease!

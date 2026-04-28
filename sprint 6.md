# Mobile App Tasks: Seasonal Job Matching Platform

## Task 1: Fix and Upgrade the Notifications Page

**Objective:** Resolve the current runtime error preventing notifications from loading, implement local notification memory management, and update the UI to distinguish between read and unread states.

**Context & Error Logs:**
The notifications are powered by Firebase. Currently, when the app opens or the user refreshes the page, no notifications appear. The following errors are thrown:

```text
I/flutter (19071): [NotificationService] Foreground message: Application Update
W/FirebaseMessaging(19071): Unable to log event: analytics library is missing
I/flutter (19071): [NotificationsApiService] Error fetching notifications: type 'Null' is not a subtype of type 'String' in type cast
```
*Hint for Agent:* The `type 'Null' is not a subtype of type 'String'` error indicates that during JSON deserialization in `NotificationsApiService` (or the Notification model), a field is being explicitly cast to a `String` but the API is returning `null`. Ensure all nullable fields in the JSON parsing are safely handled (e.g., `json['title'] ?? ''` or making the model property nullable `String?`).

**Requirements:**
1.  **Bug Fix:** Fix the JSON parsing/type casting error in the `NotificationsApiService` or corresponding model so notifications fetch successfully.
2.  **Add Firebase Analytics:** Resolve the Firebase messaging warning by ensuring the `firebase_analytics` package is properly initialized (if required by the project), or suppress the warning if analytics are not needed.
3.  **UI Updates:**
    * Add a "Clear All" button to wipe notifications.
    * Style read and unread notifications differently using opacity (e.g., unread is fully opaque, read is semi-transparent).
4.  **Local Memory Management:**
    * Limit the stored untracked notifications to a maximum of 20.
    * Automatically remove any notifications that are older than 3 months to save memory.

## Task 2: Email Notifications Toggle

**Objective:** Update the User model and Profile settings UI to allow users to opt in or out of email notifications.

**Context & API Details:**
The backend `getUser` request now returns a new parameter: `wantsEmails`. 

Example GET response:
```json
{
  "id": 168,
  "name": "Cali",
  "country": "Egypt",
  "number": "+200118156789",
  "email": "a@a.com",
  "wantsEmails": null,
  "jobPostingCredits": null
}
```

**Requirements:**
1.  **Model Update:** Update the Flutter User model/entity to include `wantsEmails`. Handle the fact that it might initially be `null`.
2.  **UI Update:** Add a toggle switch in the Profile/Settings page labeled "Receive Email Notifications".
3.  **API Integration:** When the user toggles the switch, send a `PATCH` request to update the backend. 
    * *Payload format required by backend:* ```json
        { "wantsEmails" : "true" } 
        ```
        or 
        ```json
        { "wantsEmails" : "false" }
        ```
    * Update the local state management so the UI reflects the change immediately after a successful API call.

## Task 3: Arabic Language Support & RTL Implementation

**Objective:** Introduce dynamic bilingual support (English and Arabic) with proper Right-to-Left (RTL) rendering.

**Requirements:**
1.  **UI Update:** Add a language selection option (Dropdown or Toggle) in the Profile Settings to switch between English and Arabic.
2.  **State Management:** Ensure the selected language is saved locally (e.g., using `SharedPreferences` or secure storage) so the app remembers the user's preference on the next launch.
3.  **Flutter L10n Implementation Best Practices:**
    * Use the official `flutter_localizations` and `intl` packages.
    * Set up the `MaterialApp` to dynamically rebuild with the new `Locale('ar')` or `Locale('en')` when the user switches languages via the state manager.
    * **RTL Geometry:** Audit the app's UI for hardcoded directional alignments. Replace standard layout properties with Directionality-aware properties where applicable to ensure the UI flips correctly for Arabic:
        * Replace `EdgeInsets.only(left: 10, right: 20)` with `EdgeInsetsDirectional.only(start: 10, end: 20)`.
        * Replace `Alignment.centerLeft` with `AlignmentDirectional.centerStart`.
        * Replace `Positioned(left: ...)` with `Positioned.directional(textDirection: ..., start: ...)`.
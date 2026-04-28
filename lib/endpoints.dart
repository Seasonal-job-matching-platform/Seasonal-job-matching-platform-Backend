// API path segments (base URL is provided by AppConfig)
const String USERS = "users";
const String JOBS = "jobs";
const String APPLICATIONS = "applications";
const String AUTH = "auth";
// const String APPLY_FOR_JOB = "$APPLICATIONS/USE";
// Example user routes
String userById(String id) => "$USERS/$id";
String editUserById(String id) => "$USERS/$id";
String applyForJob(String userId, String jobId) =>
    "$APPLICATIONS/user/$userId/job/$jobId";
String getUserApplications(String userId) => "$APPLICATIONS/user/$userId";
String getUserAppliedJobs(String userId) => "$APPLICATIONS/userjobs/$userId";
String getRecommendedJobs(String userId) => "$USERS/$userId/recommended-jobs";
// Auth routes
const String SIGNUP = USERS;
const String LOGIN = "$USERS/login";

// Resume routes
const String RESUMES = "resumes";
String resumeById(String id) => "$RESUMES/$id";
String getUserFavoriteJobs(String userId) => "$USERS/$userId/favorite-jobs";

// Notification routes
const String NOTIFICATION_TOKEN_REGISTER = "notification-token/register-token";
const String NOTIFICATIONS_BASE = "notifications";
String NOTIFICATIONS(String userId) => "$NOTIFICATIONS_BASE/$userId";

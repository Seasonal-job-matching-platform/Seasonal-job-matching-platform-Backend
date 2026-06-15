# Seasonal Job Matching API

This document describes the HTTP API for the backend application. It covers the `UserController` and `JobController` endpoints, request/response bodies, status codes, and examples.

## Base URL

- Local development: `http://localhost:8080`

---

## Users

Base path: `/api/users`

### GET /api/users
- Description: Retrieve all users.
- Response: 200 OK
- Response body: JSON array of `UserResponseDTO` objects

UserResponseDTO shape:
```json
{
  "name": "string",
  "country": "string",
  "number": "string (11 digits)",
  "email": "string"
}
```

Example:
```bash
curl -s http://localhost:8080/api/users | jq
```

---

### GET /api/users/{id}
- Description: Retrieve a user by ID.
- Path parameters:
  - `id` (long) - user database id
- Responses:
  - 200 OK: returns `UserResponseDTO`
  - 404 Not Found: user with given id doesn't exist

Example:
```bash
curl -s http://localhost:8080/api/users/1 | jq
```

---

### POST /api/users
- Description: Create a new user.
- Request body: `UserCreateDTO` (JSON)
- Responses:
  - 200 OK: body contains `{ "message": "User created successfully", "user": <UserResponseDTO> }`
  - 400 Bad Request: body contains `{ "error": "..." }`

Example request body:
```json
{
  "name": "Alice",
  "country": "Egypt",
  "number": "01234567890",
  "email": "alice@example.com",
  "password": "secret"
}
```

Example:
```bash
curl -X POST -H "Content-Type: application/json" -d @user.json \
  http://localhost:8080/api/users
```

---

### PATCH /api/users/{id}
- Description: Partially update a user. Only provided fields are updated.
- Request body: `UserEditDTO` (JSON)
- Responses:
  - 200 OK: `{ "message": "User edited successfully", "user": <UserResponseDTO> }`
  - 400 Bad Request: `{ "error": "..." }`
  - 404 Not Found: if user not found

Example request body (update email only):
```json
{
  "email": "new@example.com"
}
```

---

### DELETE /api/users/{id}
- Description: Delete user by ID.
- Responses:
  - 200 OK: `User deleted successfully!`
  - 404 Not Found: if user not found

Example:
```bash
curl -X DELETE http://localhost:8080/api/users/1
```

---

### POST /api/users/login
- Description: Authenticate a user with email and password.
- Request body: `UserLoginDTO` (JSON)
- Responses:
  - 200 OK: `{ "message": "Login successful", "user": <UserResponseDTO> }`
  - 401 Unauthorized: `{ "error": "..." }`

Example request body:
```json
{
  "email": "alice@example.com",
  "password": "secret"
}
```

---

### GET /api/users/{id}/jobs
- Description: Get all jobs posted by a specific user (employer view).
- Response: 200 OK, array of `JobResponseDTO` objects

Example:
```bash
curl -s http://localhost:8080/api/users/1/jobs | jq
```

---

### GET /api/users/{userId}/applied/{jobId}
- Description: Check if a user has applied to a specific job.
- Responses:
  - 200 OK: `{ "hasApplied": true }` or `{ "hasApplied": false }`
  - 400 Bad Request: `{ "error": "..." }`

Example:
```bash
curl -s http://localhost:8080/api/users/1/applied/5 | jq
```

---

### GET /api/users/FOI/{userId}
- Description: Get fields of interest for a user.
- Response: 200 OK, `UserFieldsOfInterestResponseDTO`
  ```json
  {
    "fieldsOfInterest": ["Agriculture", "Tourism", "Retail"]
  }
  ```

Example:
```bash
curl -s http://localhost:8080/api/users/FOI/1 | jq
```

---

## Jobs

Base path: `/api/jobs`

### GET /api/jobs
- Description: Retrieve all jobs.
- Response: 200 OK, array of `JobResponseDTO`

JobResponseDTO (common fields):
```json
{
  "id": 0,
  "title": "string",
  "description": "string",
  "type": "FULL_TIME | PART_TIME | TEMP",
  "location": "string",
  "startDate": "dd-MM-yyyy",
  "duration": 0,
  "salary": "HOURLY | MONTHLY | YEARLY",
  "amount": 0.0,
  "status": "OPEN | CLOSED",
  "numOfPositions": 1,
  "workArrangement": "ON_SITE | REMOTE | HYBRID",
  "createdAt": "dd-MM-yyyy",
  "jobposterId": 0,
  "jobposterName": "string",
  "requirements": ["string"],
  "categories": ["string"],
  "benefits": ["string"]
}
```

Example:
```bash
curl -s http://localhost:8080/api/jobs | jq
```

---

### GET /api/jobs/{id}
- Description: Get a job by id.
- Responses:
  - 200 OK: JobResponseDTO
  - 404 Not Found: if job doesn't exist

Example:
```bash
curl http://localhost:8080/api/jobs/1
```

---

### POST /api/jobs
- Description: Create a new job.
- Request body: `JobCreateDTO` (JSON)
- Responses:
  - 200 OK: `{ "message": "Job created successfully", "job": <JobResponseDTO> }`
  - 400 Bad Request: `{ "error": "..." }`

Example request body (job create):
```json
{
  "title": "Seasonal Helper",
  "description": "Help with harvest",
  "type": "TEMP",
  "location": "Farmville",
  "startDate": "01-06-2025",
  "duration": 120,
  "salary": "HOURLY",
  "amount": 15.50,
  "status": "OPEN",
  "numOfPositions": 5,
  "workArrangement": "ON_SITE",
  "jobposterId": 1,
  "requirements": ["Physical fitness", "Experience with farm work"],
  "categories": ["Agriculture", "Seasonal"],
  "benefits": ["Free accommodation", "Meals provided"]
}
```

---

### PATCH /api/jobs/{id}
- Description: Partially update a job. Only provided fields are updated.
- Request body: `JobEditDTO` (JSON)
- Responses:
  - 200 OK: `{ "message": "Job edited successfully", "job": <JobResponseDTO> }`
  - 400 Bad Request: `{ "error": "..." }`
  - 404 Not Found: if job not found
 
Example request body (update salary, amount, and add requirements):
```json
{
  "salary": "MONTHLY",
  "amount": 2000.0,
  "requirementsToAdd": ["Driver's license"],
  "requirementsToRemove": ["Previous experience"]
}
```

Note: For array fields (requirements, categories, benefits), use the add/remove pattern:
- `requirementsToAdd`: List of strings to add to existing requirements
- `requirementsToRemove`: List of strings to remove from existing requirements
- Same pattern applies to `categoriesToAdd`/`categoriesToRemove` and `benefitsToAdd`/`benefitsToRemove`


### GET /api/jobs/{jobId}/recommended-applicants
- Description: Retrieve the most suitable candidates that applied to the specified job (Employer view). Only the job owner (poster) can call this API.
- Path parameters:
  - `jobId` (long) - job database id
- Headers:
  - `Authorization: Bearer <token>`
- Responses:
  - 200 OK: JSON array of recommended applicant DTOs containing candidate details
  - 401 Unauthorized: if user is not authenticated
  - 403 Forbidden: if user is not the owner (poster) of the job
  - 404 Not Found: if job with given id does not exist

Example output:
```json
[
  {
    "userId": 92,
    "name": "John Doe",
    "skills": [
      "Puppet Construction",
      "Storytelling",
      "Improv"
    ],
    "experience": [
      "Puppeteer",
      "Children's Workshop Lead"
    ],
    "describeYourself": "It was always my dream to become an actor and I know I can steal the spotlight with the right opportunities. I am looking forward to joining your team.",
    "languages": [
      "English"
    ],
    "fieldsOfInterest": [
      "Human Resources",
      "Recruitment",
      "Seasonal Hiring",
      "Employee Wellness"
    ],
    "education": [
      "Drama Education Program"
    ]
  }
]
```

---

### DELETE /api/jobs/{id}
- Description: Delete a job by ID.
- Responses:
  - 200 OK: `Job deleted successfully!`
  - 404 Not Found: if job not found

Example:
```bash
curl -X DELETE http://localhost:8080/api/jobs/1
```

---

## Resumes

Base path: `/api/resumes`

### GET /api/resumes/{id}
- Description: Get a resume by user ID (not resume ID).
- Path parameters:
  - `id` (long) - user database id
- Responses:
  - 200 OK: `ResumeResponseDTO` or `"Resume not found!"`
  - 500 Internal Server Error: if database error occurs

ResumeResponseDTO shape:
```json
{
  "education": ["string"],
  "experience": ["string"],
  "certificates": ["string"],
  "skills": ["string"],
  "languages": ["string"]
}
```

Example:
```bash
curl -s http://localhost:8080/api/resumes/1 | jq
```

---

### POST /api/resumes/{userId}
- Description: Create a new resume for a user.
- Path parameters:
  - `userId` (long) - user database id
- Request body: `ResumeCreateDTO` (JSON)
- Responses:
  - 200 OK: `{ "message": "Resume created successfully", "resume": <ResumeResponseDTO> }`
  - 400 Bad Request: `{ "error": "..." }`

Example request body:
```json
{
  "education": ["Bachelor's in Agriculture", "High School Diploma"],
  "experience": ["2 years farm work", "Seasonal harvest assistant"],
  "certificates": ["Food Safety Certificate"],
  "skills": ["Tractor operation", "Crop management"],
  "languages": ["English", "Arabic"]
}
```

---

### PATCH /api/resumes/{userId}
- Description: Partially update a resume. Uses add/remove pattern for array fields.
- Path parameters:
  - `userId` (long) - user database id
- Request body: `ResumeEditDTO` (JSON)
- Responses:
  - 200 OK: `{ "message": "Job edited successfully", "resume": <ResumeResponseDTO> }`
  - 400 Bad Request: `{ "error": "..." }`

Example request body:
```json
{
  "skillsToAdd": ["First Aid Certified"],
  "skillsToRemove": ["Tractor operation"],
  "educationToAdd": ["Master's in Agriculture"],
  "languagesToAdd": ["French"]
}
```

Note: All array fields use the add/remove pattern:
- `educationToAdd`/`educationToRemove`
- `experienceToAdd`/`experienceToRemove`
- `certificatesToAdd`/`certificatesToRemove`
- `skillsToAdd`/`skillsToRemove`
- `languagesToAdd`/`languagesToRemove`

---

### DELETE /api/resumes/{userId}
- Description: Delete a resume by user ID.
- Path parameters:
  - `userId` (long) - user database id
- Responses:
  - 200 OK: `Resume deleted successfully!` or `Resume not found!`

Example:
```bash
curl -X DELETE http://localhost:8080/api/resumes/1
```

---

## Applications

Base path: `/api/applications`

### POST /api/applications/user/{userId}/job/{jobId}
- Description: Create a new application (user applies to a job).
- Path parameters:
  - `userId` (long) - user database id
  - `jobId` (long) - job database id
- Request body: `ApplicationCreateDTO` (JSON)
- Responses:
  - 200 OK: `{ "message": "Application submitted successfully", "application": <ApplicationResponseDTO> }`
  - 400 Bad Request: `{ "error": "..." }`

Example request body:
```json
{
  "coverLetter": "I am interested in this position..."
}
```

---

### GET /api/applications/user/{userId}
- Description: Get all applications submitted by a specific user (Job Seeker view).
- Path parameters:
  - `userId` (long) - user database id
- Response: 200 OK, array of `ApplicationResponseDTO` objects

Example:
```bash
curl -s http://localhost:8080/api/applications/user/1 | jq
```

---

### GET /api/applications/userjobs/{userId}
- Description: Get list of job IDs that a user has applied to.
- Path parameters:
  - `userId` (long) - user database id
- Response: 200 OK, `JobIdsFromApplicationsResponseDTO`
  ```json
  {
    "jobIds": [1, 5, 10]
  }
  ```

Example:
```bash
curl -s http://localhost:8080/api/applications/userjobs/1 | jq
```

---

### GET /api/applications/job/{jobId}
- Description: Get all applications for a specific job (Employer view).
- Path parameters:
  - `jobId` (long) - job database id
- Response: 200 OK, array of `ApplicationWebResponseDTO` objects

Example:
```bash
curl -s http://localhost:8080/api/applications/job/1 | jq
```

---

### PATCH /api/applications/{applicationId}/status/employer/{employerId}
- Description: Update application status (e.g., ACCEPTED, REJECTED, PENDING). Only the job poster (employer) can update status.
- Path parameters:
  - `applicationId` (long) - application database id
  - `employerId` (long) - employer/user database id
- Request body: `ApplicationStatusUpdateDTO` (JSON)
- Responses:
  - 200 OK: `{ "message": "Application status updated successfully", "application": <ApplicationResponseDTO> }`
  - 400 Bad Request: `{ "error": "..." }` (includes authorization failures)

Example request body:
```json
{
  "status": "ACCEPTED"
}
```

Status values: `PENDING`, `ACCEPTED`, `REJECTED`

---

### DELETE /api/applications/{applicationId}
- Description: Delete (withdraw) an application by its ID.
- Path parameters:
  - `applicationId` (long) - application database id
- Responses:
  - 200 OK: `{ "message": "Application deleted successfully." }`
  - 400 Bad Request: `{ "error": "..." }`

Example:
```bash
curl -X DELETE http://localhost:8080/api/applications/1
```

---

## Notes & Troubleshooting

- Partial updates: Use `PATCH` and include only fields you want to change. The service layer should preserve existing values for fields not present in the DTO.
- DTO/Entity mismatches: If MapStruct or Jackson complains about missing properties, verify DTO and entity property names match and that Lombok-generated getters/setters are available at compile time (check annotation processor configuration in `pom.xml`).
- Authentication/Authorization: No auth is included in these controllers. Add security if needed before production.

---


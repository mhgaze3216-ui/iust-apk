# REST API contract

Base URL: `/api/v1`. All dates/times are ISO-8601 UTC unless a field is explicitly a date. IDs are UUIDs. All authenticated requests send `Authorization: Bearer <accessToken>` and `Accept: application/json`; JSON writes also send `Content-Type: application/json`.

## Response and error shape

Successful reads/writes use `{ "data": ... }`. Lists use `{ "data": [], "meta": { "nextCursor": null } }` when cursor pagination is enabled. Errors use `{ "error": { "code": "VALIDATION_ERROR", "message": "...", "details": [] } }`. Standard statuses: `200`, `201`, `204`, `400`, `401`, `403`, `404`, `409`, `429`, `500`, `503`.

## Authentication and identity

| Method / path | Access | Body / headers | Response |
|---|---|---|---|
| `POST /auth/login` | Public, rate-limited | `{ "username": "campus-id-or-email", "password": "..." }` | `200 { "data": { "user": { "id", "username", "email", "role", "fullName" }, "accessToken": "...", "refreshToken": "...", "tokenType": "Bearer", "expiresIn": "15m" } }` |
| `POST /auth/refresh` | Public, rate-limited | `{ "refreshToken": "..." }` | `200 { "data": { "accessToken": "...", "refreshToken": "...", "tokenType": "Bearer", "expiresIn": "15m" } }`; rotates/revokes the submitted refresh token. |
| `POST /auth/logout` | Any authenticated role | Bearer + `{ "refreshToken": "..." }` | `204`; revoke refresh session. |
| `GET /me` | Any authenticated role | Bearer | `200 { "data": { "id", "username", "email", "role", "fullName" } }` |
| `POST /auth/password/forgot` | Public, rate-limited | `{ "email": "..." }` | Always avoids account enumeration; currently returns `503 EMAIL_NOT_CONFIGURED` until a delivery provider is configured. |
| `POST /auth/password/reset` | Public, one-time reset token | `{ "token": "...", "newPassword": "..." }` | `204` |
| `POST /auth/password/change` | Authenticated | `{ "currentPassword": "...", "newPassword": "..." }` | `204` |
| `GET /me/preferences` / `PATCH /me/preferences` | Any authenticated role | `{ "preferredLanguage": "ar", "notifications": { "academic": true } }` | Current or updated preferences |

`student`, `doctor`, `staff`, and `admin` are authenticated roles. Guest is anonymous, not an account role. The server—not the Flutter route or body—determines the principal and enforces ownership/permissions.

## File uploads

Uploads require a bearer token and `multipart/form-data` with a single field named `file`. The maximum file size is 10 MB; accepted types are PDF, DOCX, XLSX, JPEG, and PNG. The API validates the declared type against the file signature, rate-limits uploads, and stores files in a private Firebase Storage bucket. Signed download URLs expire after 15 minutes.

| Method / path | Access | Request | Response |
|---|---|---|---|
| `POST /upload` | Any authenticated role | `file` multipart field | `201 { "data": { "storageKey", "signedUrl", "expiresAt", "fileName", "contentType", "fileSizeBytes" } }`; stages an object under the caller's storage prefix. |
| `POST /requests/:id/attachments` | Authorized request owner, department staff, or admin | `file` multipart field | Uploads file and persists request attachment metadata. |
| `POST /students/me/documents` | Student | `file`, `title`, and `category` multipart fields | Uploads and persists a private student document. |
| `GET /students/me/documents` | Student | — | Own document metadata; download links are minted separately. |
| `GET /students/me/documents/:id/download` | Document owner | — | Short-lived signed URL for the owned file. |
| `POST /admin/documents` | Admin | `file`, `title`, `category`, `version`, optional `isPublished` multipart fields | Uploads and registers a university document. |
| `GET /public/documents/:id/download` | Public, published documents only | — | Short-lived signed URL. |
| `POST /doctors/me/archive/uploads` | Doctor | `file` multipart field | Stages an owned archive file and returns a signed read URL. |
| `POST /doctors/me/archive` | Doctor | JSON metadata including `storageKey` returned by archive upload | Registers metadata only when the file belongs to the caller. |
| `GET /doctors/me/archive/:id/download` | Archive owner | — | Short-lived signed URL. |

## Public university content (anonymous GET)

Query filters and pagination are implemented per route; not all list routes currently accept `q`, `limit`, or `cursor`.

| Method / path | Response fields |
|---|---|
| `GET /public/faculties` | `id, code, nameAr, nameEn, description, departments[]` |
| `GET /public/faculties/:facultyId` | Faculty details and public departments |
| `GET /public/departments` | `id, facultyId, code, nameAr, nameEn, description, contactEmail` |
| `GET /public/courses?departmentId=&termId=` | `id, code, nameAr, nameEn, creditHours, departmentId` |
| `GET /public/services` | `id, departmentId, name, description, requirements[], fees, expectedDuration` |
| `GET /public/faqs?category=&departmentId=` | `id, category, question, answer, departmentId` |
| `GET /public/news?category=` | `id, category, title, summary, content, publishedAt` |
| `GET /public/scholarships` | `id, title, description, eligibility, deadline, documentIds[]` |
| `GET /public/documents?category=` | `id, title, category, version`; download at `/public/documents/:id/download` |
| `GET /public/transport/routes` | `id, name, stops[], departures[], serviceDate` |
| `GET /public/maps/buildings` | `id, nameAr, code, description, mapVersion, floors[]` |
| `GET /public/maps/buildings/:buildingId/floors/:floorId/rooms?q=` | `id, roomNumber, nameAr, type, coordinates` |
| `GET /public/maps/search?q=` | Matching building/floor/room/marker locations |

## Student

All routes below require role `student`; the server uses the authenticated user's ID.

| Method / path | Body / response |
|---|---|
| `GET /students/me` | Profile, faculty/department, semester, advisor, GPA/credit summary |
| `PATCH /students/me` | Allowlisted contact/profile fields only; returns updated profile |
| `GET /students/me/courses?termId=` | Enrollments joined to course and section |
| `GET/POST /students/me/documents` | List own document metadata or upload multipart fields `file`, `title`, and `category` |
| `GET /students/me/documents/:id/download` | Owner-only short-lived signed download URL |
| `GET /students/me/schedule?termId=` | Course/section sessions, room, instructor |
| `GET /students/me/grades?termId=` | Only published grades; components, total, letter grade |
| `GET /students/me/study-plan` | Required/completed/current/remaining credits and plan courses |
| `GET /students/me/exams?termId=` | Exam date, time, course, room, type |
| `GET /students/me/advising` | Advisor profile and advising appointments |
| `GET /students/me/library?q=` | Faculty/major-filtered library resources |
| `GET /students/me/registration/offerings?termId=` | Offerings plus eligibility, capacity, holds, conflicts |
| `POST /students/me/registration` | `{ "sectionId": "uuid", "action": "enroll" }`; returns enrollment/waitlist state |
| `DELETE /students/me/registration/:enrollmentId` | Drop only when registration rules allow; returns `204` |
| `GET /students/me/tasks?dueFrom=&dueTo=&status=` | Paginated task records |
| `POST /students/me/tasks` | `{ "courseId": "uuid|null", "title": "...", "description": "...", "dueAt": "...", "estimatedMinutes": 30, "priority": "medium" }`; `201` |
| `PATCH /students/me/tasks/:taskId` | Allowlisted task fields/status; ownership required |
| `DELETE /students/me/tasks/:taskId` | Owned task only; `204` |
| `GET /students/me/study-sessions` | Session history and totals |
| `POST /students/me/study-sessions` | `{ "courseId": "uuid|null", "taskId": "uuid|null", "focusMinutes": 25, "breakMinutes": 5, "startedAt": "...", "endedAt": "...", "completed": true }`; `201` |
| `GET /students/me/notifications?unreadOnly=` | User's notifications |
| `PATCH /students/me/notifications/:notificationId/read` | Marks own notification read; `204` |
| `POST /notifications/read-all` | Marks all own notifications read; returns `{ "data": { "updated": 0 } }` |
| `GET /students/me/feed?courseId=&cursor=` | Enrolled-course feed, comments and caller reaction state |
| `POST /students/me/feed` | `{ "courseId": "uuid", "type": "question|discussion|resource", "title": "...", "content": "..." }`; must be enrolled |
| `GET /students/me/feed/:postId/comments` | Paginated comments |
| `POST /students/me/feed/:postId/comments` | `{ "content": "..." }` |
| `PUT /students/me/feed/:postId/reaction` | `{ "liked": true, "following": false }`; idempotent upsert |
| `GET /students/me/doctors` | Instructors from the student's enrolled sections |
| `GET /students/me/conversations` | Participant conversations, unread counts |
| `POST /students/me/conversations` | `{ "doctorId": "uuid", "courseId": "uuid" }`; require shared course |
| `GET /students/me/conversations/:id/messages?cursor=` | Participant-only messages |
| `POST /students/me/conversations/:id/messages` | `{ "body": "..." }`; participant-only |
| `PATCH /students/me/conversations/:id/read` | Update own read cursor; `204` |
| `GET /students/me/announcements` | Published announcements for the student's enrolled sections |
| `GET /students/me/calendar?termId=` | Academic calendar events, term dates and registration deadlines |
| `GET /students/me/transport?date=` | Current university routes, departures and service alerts |
| `POST /students/me/advising` | `{ "advisorUserId": "uuid", "subject": "...", "message": "..." }`; create advising request |

## Doctor / faculty

Require role `doctor`; enforce section assignment for every read/write.

| Method / path | Body / response |
|---|---|
| `GET /doctors/me` / `PATCH /doctors/me` | Profile and allowlisted editable fields |
| `GET /doctors/me/courses?termId=` | Assigned sections, course, schedule, student counts |
| `GET /doctors/me/sections/:sectionId/roster?q=` | Enrolled students; only assigned section |
| `GET /doctors/me/sections/:sectionId/grades` | Grade components, weights and publication state |
| `PUT /doctors/me/sections/:sectionId/grades/:studentId` | `{ "components": { "midterm": 24, "coursework": 18, "final": 42 } }`; validate bounds/weights and audit |
| `POST /doctors/me/sections/:sectionId/grades/publish` | Publish locked grade set; approval policy may require staff |
| `GET /doctors/me/sections/:sectionId/attendance` | Session list and attendance summaries |
| `POST /doctors/me/sections/:sectionId/attendance` | `{ "heldAt": "...", "room": "..." }`; create session |
| `PUT /doctors/me/attendance/:sessionId/records` | `{ "records": [{ "studentId": "uuid", "status": "present|late|absent|excused" }] }` |
| `POST /doctors/me/attendance/:sessionId/finalize` | Finalize immutable attendance; audited |
| `GET/POST /doctors/me/assignments` | List/create assignment; validate course ownership/deadline |
| `GET /doctors/me/assignments/:id/submissions` | Student submissions |
| `PATCH /doctors/me/submissions/:id` | Grade/feedback/status |
| `GET /doctors/me/questions?courseId=&status=` | Course questions |
| `POST /doctors/me/questions/:id/answers` | `{ "body": "..." }` |
| `GET/POST /doctors/me/announcements` | List/create assigned-section announcement; students see published announcements for enrolled sections |
| `GET/POST /doctors/me/exam-schedules` | List/create/update exam schedules |
| `GET /doctors/me/archive?type=&courseId=&cursor=` | Archive metadata |
| `POST /doctors/me/archive/uploads` | Upload multipart `file` to private Firebase Storage; returns `storageKey` and a short-lived signed read URL |
| `POST /doctors/me/archive` | Register metadata after upload; `storageKey` must belong to the authenticated doctor |
| `GET /doctors/me/archive/:id/download` | Authorized short-lived signed download URL |
| `GET /doctors/me/notifications` | Doctor's notifications |
| `GET /doctors/me/transport?date=` | Doctor-visible university routes and departures |

## Staff and administration

Staff endpoints require `staff` or `admin`; administrative account/permission operations require `admin`. Apply department scopes and permission policy server-side.

| Method / path | Body / response |
|---|---|
| `GET /requests?status=&departmentId=&q=&cursor=` | Staff queue; students/doctors see only their own records |
| `POST /requests` | `{ "departmentId": "uuid", "category": "...", "title": "...", "description": "...", "priority": "normal" }`; `201` with server reference |
| `GET /requests/:id` | Request, authorized timeline, attachment metadata |
| `POST /requests/:id/attachments` | Upload a multipart `file`; saves attachment metadata and returns its signed URL |
| `POST /admin/requests/:id/assign` | `{ "staffUserId": "uuid" }`; department permission check |
| `PATCH /admin/requests/:id/status` | `{ "status": "in_review|waiting_on_user|completed|rejected", "note": "..." }`; transition audit |
| `POST /guest/inquiries/track` | Body `{ "reference": "INQ-...", "trackingSecret": "..." }`; rate-limited lookup |
| `POST /guest/inquiries` | `{ "name": "...", "email": "...", "phone": "...", "category": "...", "subject": "...", "message": "..." }`; require at least one contact method; return reference and one-time tracking secret |
| `GET /admin/inquiries?status=&departmentId=` | Authorized staff queue |
| `POST /admin/inquiries/:id/messages` | `{ "body": "..." }`; staff reply |
| `PATCH /admin/inquiries/:id/status` | `{ "status": "in_review|completed|rejected" }` |
| `GET/POST /appointments` | List own/staff-visible appointments; create `{ "departmentId": "uuid", "purpose": "...", "startsAt": "...", "endsAt": "..." }` |
| `GET /appointments/availability?departmentId=&date=` | Server-computed slots/capacity |
| `PATCH /appointments/:id` / `DELETE /appointments/:id` | Reschedule/cancel under policy |
| `GET/POST/PATCH/DELETE /admin/appointments/slots[/:id]` | Provision department appointment capacity; staff require `appointment.manage` |
| `GET/POST/PATCH/DELETE /admin/faqs[/:id]` | FAQ management |
| `GET/POST/PATCH /admin/news[/:id]` | Draft/publish/schedule news |
| `GET/POST/PATCH /admin/announcements[/:id]` | Audience and publication state |
| `GET /admin/users?q=&role=&status=` | Account search |
| `POST /admin/users` | Create account with server-generated temporary credential/reset flow |
| `PATCH /admin/users/:id` | Allowlisted role/profile/status updates; audit |
| `PUT /admin/users/:id/permissions` | `{ "permissions": ["request.review"] }`; admin only |
| `GET/POST/PATCH /admin/transport/routes[/:id]` | Manage route/stops/departures |
| `POST /admin/reports` | `{ "reportType": "...", "filters": {} }`; return report job |
| `GET /admin/reports/:id` | Job status and authorized download URL |
| `GET /admin/audit-events?entityType=&entityId=&cursor=` | Admin-only immutable audit history |
| `GET /admin/students/:studentId/schedule` | Authorized student schedule |
| `POST /admin/students/:studentId/schedule` | Add `{ "courseId", "termId", "dayOfWeek": 0, "startTime": "09:00", "endTime": "10:00", "room": "..." }`; staff scope and audit required |
| `PATCH /admin/students/:studentId/schedule/:scheduleId` / `DELETE ...` | Update/remove additional schedule entry; staff scope and audit required |
| `GET/POST/PATCH/DELETE /admin/maintenance[/:id]` | Maintenance windows; publish service-impact notices |
| `GET /admin/system/health` / `GET /admin/system/events?severity=&cursor=` | Operational status and system event log; admin only |
| `GET/PUT /admin/roles/:role/permissions` | Read/update allowlisted permission keys; audit and require admin |
| `GET /admin/academic-calendar?termId=` / `POST /admin/academic-calendar` | Read/create academic events |
| `GET/PUT /admin/academic-calendar/terms/:termId` | Read/update term registration-open and close timestamps |

## Current starter implementation

### Implemented route coverage in `src/server.ts`

- **Identity:** login, refresh, logout, password change, password reset-token consumption, current profile, and preferences. Forgot-password is present but returns `503 EMAIL_NOT_CONFIGURED`; there is no token-delivery provider.
- **Public:** faculty, department, course, FAQ, service, transaction, scholarship, document metadata, news, transport, and campus-map reads.
- **Student:** profile, courses, schedule, published grades, study plan, exams, advising read/create, library, calendar, transport, documents with owner-only signed downloads, department-filtered registration offerings/enroll/waitlist/drop, owned tasks, study sessions, notifications/read, enrolled-course feed/comments/reactions, enrolled doctors, and participant-only conversations/messages/read cursor.
- **Doctor:** profile, assigned courses/roster/grades/attendance, grade publication and attendance finalization (both lock completed records), assigned-section assignments/submissions/questions/exams/announcements, transport, notifications, and assigned-course participant conversations.
- **Staff and service requests:** own/department-scoped request list/create/detail, permission- and department-scoped queue/assignment/status transitions, guest inquiry submit/track and department-scoped staff replies/status, appointment availability/list/create/reschedule/cancel, and appointment-slot management. Staff actions require both an individual `staff_profiles.permissions` assignment and the persisted role policy.
- **Administration:** user search/update/permissions; Firebase-backed university document upload; FAQ CRUD; news and global announcement list/create/update; transport route/stops/departures list/create/update; report endpoints (explicit `503`); maintenance CRUD and system health/events; audit events; department-scoped student schedule read/create/update/delete; persisted role permission policies; academic events and term registration dates; and appointment-slot management.
- Lists are capped per handler; cursor-based pagination is not implemented. Department/ownership/role checks are enforced in the handlers.

### Pending or explicitly unavailable

- Email-dependent password-reset initiation and admin user creation return `503 EMAIL_NOT_CONFIGURED`; a reset can only consume a token provisioned through a trusted external process.
- File upload/download routes require Firebase Storage credentials. When Firebase is unconfigured, upload and signed-download requests return `503 STORAGE_NOT_CONFIGURED`; PostgreSQL-backed metadata remains available where the route does not need a signed URL.
- Report create/status endpoints return `503 REPORTS_NOT_CONFIGURED`; no report worker or output storage exists.
- News/announcement `scheduled` status returns `503 PUBLISH_SCHEDULER_NOT_CONFIGURED`; no scheduler exists.
- Admin schedule changes are additional manual entries alongside enrolled-section schedules; they do not change enrollment records or the university's authoritative timetable.
- Academic event editing/deletion and term-calendar dates beyond registration-open/close remain unsupported.
- Appointment slots are managed through staff/admin endpoints; staff can provision only for their own department when policy and individual permission allow it.
- Registration validates registration dates, capacity, ownership, and department scope, and supports waitlisting. The current schema has no student hold source, prerequisite enforcement policy, or normalized meeting-time conflict model, so those offering checks are not represented.
- Scheduled news/announcement states are rejected until a scheduler is configured. Future `publishAt` on news can defer public visibility, but does not run a background publication job.
- Public list search/cursor pagination and short-lived file download links are not implemented consistently; handlers only accept their explicitly validated filters and return bounded result sets.
- Maintenance windows are stored, but automatic service-impact notifications are not sent.
- Database-backed contract tests, authoritative university data integrations, and the remaining paths above are still required for a complete deployment. Flutter migration status is outside this API inventory.

## Database entities

`schema.sql` defines users and per-role profiles/persisted role permission policies; faculties/departments; terms/calendar events, courses, sections, enrollments, grades, attendance, and staff-managed student schedule entries; student documents, tasks and study sessions; feed posts/comments/reactions; conversations/messages; service requests, Firebase attachment metadata, and status audit events; guest inquiries/messages; appointments and appointment slots; services/transactions, scholarships/documents, library resources, transport routes/departures; notifications; global and section-linked announcements, FAQs, news; assignments/submissions/questions/exams/archive; campus buildings/floors/rooms; maintenance/system events; report jobs; refresh/reset sessions and audit events. Monetary and policy-rich content can be expanded as the university supplies authoritative source data.

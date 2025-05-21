> Won't be maintained anymore, moved to <a href="https://github.com/Ali1raz/flutter_dev_full_stack">Ali1raz/flutter_dev_full_stack</a>

<p align="center"><a href="https://laravel.com" target="_blank"><img src="https://raw.githubusercontent.com/laravel/art/master/logo-lockup/5%20SVG/2%20CMYK/1%20Full%20Color/laravel-logolockup-cmyk-red.svg" width="400" alt="Laravel Logo"></a></p>

## About Laravel

Laravel is a web application framework with expressive, elegant syntax. We believe development must be an enjoyable and creative experience to be truly fulfilling. Laravel takes the pain out of development by easing common tasks used in many web projects.

# Laravel Task Management API Documentation

## Authentication Endpoints

### Admin Login

-   **URL**: `/api/admin/login`
-   **Method**: `POST`
-   **Description**: Authenticate as an admin user, (default password is 12345678 for admin because admin was seeded)

-   **Request Body**:
    ```json
    {
        "email": "admin@example.com",
        "password": "password"
    }
    ```
-   **Response**: Returns authentication token

If OK **Response body**:

```json
{
    "user": {
        "id": 1,
        "name": "Ali Raza",
        "email": "admin@example.com",
        "email_verified_at": null,
        "created_at": "2025-05-18T09:22:28.000000Z",
        "updated_at": "2025-05-18T13:09:09.000000Z",
        "role": "admin",
        "registration_number": null
    },
    "token": "7|8KfJL4QetuqsO3XA343bpqKw1dnQiNRKQus0dtCU7c6308ce"
}
```

### Student Login

-   **URL**: `/api/student/login`
-   **Method**: `POST`
-   **Description**: Authenticate as a student
-   **Request Body**:

```json
{
    "registration_number": "STUQTIMFQ",
    "password": "12345678"
}
```

-   **Response**: Returns authentication token

```json
{
    "message": "Logged in Successfully",
    "user": {
        "id": 8,
        "name": "Waseem",
        "email": "waseem@example.com",
        "email_verified_at": null,
        "created_at": "2025-05-18T12:04:28.000000Z",
        "updated_at": "2025-05-18T13:06:56.000000Z",
        "role": "student",
        "registration_number": "STUQTIMFQ"
    },
    "token": "8|73rONWtOTGvnl1NWCCMNJnmn7p0QdI2y2Y7cTBJG1573593b"
}
```

## Admin Endpoints

All admin endpoints require `Authorization: Bearer {token}` header

### Admin Dashboard

-   **URL**: `/api/admin/dashboard`
-   **Method**: `GET`
-   **Description**: Get admin dashboard statistics
-   **Response**: Returns dashboard statistics

### Student Management

#### Register Student

-   **URL**: `/api/admin/register-student`
-   **Method**: `POST`
-   **Description**: Register a new student
-   **Request Body**:

```json
{
    "name": "waseem",
    "email": "waseem@example.com"
}
```

-   **Response data**:

```json
{
    "message": "Student registered successfully",
    "registration_number": "STUQTIMFQ",
    "password": "GRvsSH3vkV",
    "student": {
        "name": "waseem",
        "email": "waseem@example.com",
        "registration_number": "STUQTIMFQ",
        "role": "student",
        "updated_at": "2025-05-18T12:04:28.000000Z",
        "created_at": "2025-05-18T12:04:28.000000Z",
        "id": 8
    }
}
```

#### List Students

-   **URL**: `/api/admin/students`
-   **Method**: `GET`
-   **Description**: Get list of all students

**Response data**:

```json
{
    "students": [
        {
            "id": 6,
            "name": "salman",
            "email": "salman@example.com",
            "email_verified_at": null,
            "created_at": "2025-05-18T12:04:04.000000Z",
            "updated_at": "2025-05-18T12:04:04.000000Z",
            "role": "student",
            "registration_number": "STUY7PRPW"
        },
        {
            "id": 7,
            "name": "naveed",
            "email": "naveed@example.com",
            "email_verified_at": null,
            "created_at": "2025-05-18T12:04:14.000000Z",
            "updated_at": "2025-05-18T12:04:14.000000Z",
            "role": "student",
            "registration_number": "STUVQRX7Q"
        },
        {
            "id": 8,
            "name": "Waseem",
            "email": "waseem@example.com",
            "email_verified_at": null,
            "created_at": "2025-05-18T12:04:28.000000Z",
            "updated_at": "2025-05-18T13:06:56.000000Z",
            "role": "student",
            "registration_number": "STUQTIMFQ"
        }
    ]
}
```

#### View Student

-   **URL**: `/api/admin/students/{registration_number}`
-   **Method**: `GET`
-   **Description**: Get details of specific student

**Reponse data:**

```json
{
    "student": {
        "id": 6,
        "name": "salman",
        "email": "salman@example.com",
        "email_verified_at": null,
        "created_at": "2025-05-18T12:04:04.000000Z",
        "updated_at": "2025-05-18T12:04:04.000000Z",
        "role": "student",
        "registration_number": "STUY7PRPW"
    }
}
```

#### Update Student

-   **URL**: `/api/admin/students/{registration_number}`
-   **Method**: `PUT`
-   **Description**: Update student information
-   **Request Body**:

```json
{
    "name": "Salman Jutt"
}
```

**Response data:**

```json
{
    "message": "Student updated successfully",
    "student": {
        "id": 6,
        "name": "Salman Jutt",
        "email": "salman@example.com",
        "email_verified_at": null,
        "created_at": "2025-05-18T12:04:04.000000Z",
        "updated_at": "2025-05-21T02:35:32.000000Z",
        "role": "student",
        "registration_number": "STUY7PRPW"
    }
}
```

#### Delete Student

-   **URL**: `/api/admin/students/{registration_number}`
-   **Method**: `DELETE`
-   **Description**: Remove a student

**Response data:**

```json
{
    "message": "Student delted successfully"
}
```

### Task Management (Admin)

#### List Tasks

-   **URL**: `/api/admin/tasks`
-   **Method**: `GET`
-   **Description**: Get all tasks

**Response data:**

```json
{
    "role": "admin",
    "tasks": [
        {
            "id": 1,
            "title": "Math assignment 1",
            "description": "complete chap 3 and 4 by tomorrow",
            "is_completed": 0,
            "created_at": "2025-05-18T12:17:17.000000Z",
            "updated_at": "2025-05-18T12:17:17.000000Z",
            "due_date": "2025-05-31",
            "students": [
                {
                    "id": 5,
                    "name": "raza",
                    "registration_number": "STUQ8S1XO",
                    "pivot": {
                        "task_id": 1,
                        "registration_number": "STUQ8S1XO",
                        "is_completed": 0,
                        "created_at": "2025-05-18T12:17:17.000000Z",
                        "updated_at": "2025-05-18T12:17:17.000000Z"
                    }
                },
                {
                    "id": 7,
                    "name": "naveed",
                    "registration_number": "STUVQRX7Q",
                    "pivot": {
                        "task_id": 1,
                        "registration_number": "STUVQRX7Q",
                        "is_completed": 0,
                        "created_at": "2025-05-18T12:17:17.000000Z",
                        "updated_at": "2025-05-18T12:17:17.000000Z"
                    }
                },
                {
                    "id": 8,
                    "name": "waseem",
                    "registration_number": "STUQTIMFQ",
                    "pivot": {
                        "task_id": 1,
                        "registration_number": "STUQTIMFQ",
                        "is_completed": 0,
                        "created_at": "2025-05-18T12:17:17.000000Z",
                        "updated_at": "2025-05-18T12:17:17.000000Z"
                    }
                }
            ]
        }
    ]
}
```

#### Create Task

-   **URL**: `/api/admin/tasks`
-   **Method**: `POST`
-   **Description**: Create a new task
-   **Request Body**:

```json
{
    "title": "Science assignment 1",
    "description": "complete chap 3 and 4 by tomorrow",
    "due_date": "2025-05-31",
    "registration_numbers": ["STUQ8S1XO", "STUVQRX7Q", "STUQTIMFQ"]
}
```

**Response data:**

```json
{
    "message": "Task assigned using registration numbers",
    "task": {
        "title": "Science assignment 1",
        "description": "complete chap 3 and 4 by tomorrow",
        "due_date": "2025-05-31",
        "updated_at": "2025-05-21T02:26:53.000000Z",
        "created_at": "2025-05-21T02:26:53.000000Z",
        "id": 2
    }
}
```

#### Task Progress

-   **URL**: `/api/admin/tasks/{taskId}/progress`
-   **Method**: `POST`
-   **Description**: View task completion progress

**Response data:**

```json
{
    "task": "Math assignment 1",
    "progress": [
        {
            "student_id": 5,
            "name": "raza",
            "is_completed": 0
        },
        {
            "student_id": 7,
            "name": "naveed",
            "is_completed": 0
        },
        {
            "student_id": 8,
            "name": "Waseem",
            "is_completed": 1
        }
    ]
}
```

---

## Student Endpoints

All student endpoints require `Authorization: Bearer {token}` header

### Student Dashboard

-   **URL**: `/api/student/dashboard`
-   **Method**: `GET`
-   **Description**: Get student dashboard information

### Task Management (Student)

#### List Tasks

-   **URL**: `/api/student/tasks`
-   **Method**: `GET`
-   **Description**: Get all tasks assigned to the (signed in) student

```json
{
    "role": "student",
    "tasks": [
        {
            "id": 1,
            "title": "Math assignment 1",
            "description": "complete chap 3 and 4 by tomorrow",
            "is_completed": 0,
            "created_at": "2025-05-18T12:17:17.000000Z",
            "updated_at": "2025-05-18T12:17:17.000000Z",
            "due_date": "2025-05-31",
            "pivot": {
                "registration_number": "STUQTIMFQ",
                "task_id": 1,
                "is_completed": 0,
                "created_at": "2025-05-18T12:17:17.000000Z",
                "updated_at": "2025-05-18T12:17:17.000000Z"
            }
        }
    ]
}
```

#### Mark Task Complete

-   **URL**: `/api/student/tasks/{taskId}/complete`
-   **Method**: `POST`
-   **Description**: Mark a task as completed
-   **URL Parameters**:
    -   `taskId`: The ID of the task to mark as complete

**Success Response (200 OK):**

```json
{
    "message": "Task marked as complete",
    "task": {
        "id": 1,
        "title": "Task Title",
        "completed_at": "2025-05-21T02:35:32.000000Z"
    }
}
```

**Error Responses:**

1. Task Not Found (404):

```json
{
    "message": "Task not found",
    "error": "TASK_NOT_FOUND"
}
```

2. Task Not Assigned (403):

```json
{
    "message": "Task not assigned to you",
    "error": "TASK_NOT_ASSIGNED"
}
```

3. Already Completed (400):

```json
{
    "message": "Task already completed",
    "error": "TASK_ALREADY_COMPLETED"
}
```

4. Server Error (500):

```json
{
    "message": "An error occurred while completing the task",
    "error": "INTERNAL_SERVER_ERROR"
}
```

## Response Status Codes

-   `200 OK`: Request succeeded
-   `201 Created`: Resource created successfully
-   `400 Bad Request`: Invalid request parameters
-   `401 Unauthorized`: Authentication required or failed
-   `403 Forbidden`: Insufficient permissions
-   `404 Not Found`: Resource not found
-   `422 Unprocessable Entity`: Validation error
-   `500 Internal Server Error`: Server error

## Error Response Format

```json
{
    "message": "Error occured"
}
```

## Authentication

The API uses Laravel Sanctum for authentication. Include the token in all requests.

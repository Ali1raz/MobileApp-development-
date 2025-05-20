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

### Student Login

-   **URL**: `/api/student/login`
-   **Method**: `POST`
-   **Description**: Authenticate as a student
-   **Request Body**:
    ```json
    {
        "registration_number": "STUQTIMFQ",
        "password": "password"
    }
    ```
-   **Response**: Returns authentication token

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

#### View Student

-   **URL**: `/api/admin/students/{registration_number}`
-   **Method**: `GET`
-   **Description**: Get details of specific student

#### Update Student

-   **URL**: `/api/admin/students/{registration_number}`
-   **Method**: `PUT`
-   **Description**: Update student information
-   **Request Body**:
    ```json
    {
        "name": "Updated Name",
        "email": "updated@example.com"
    }
    ```

#### Delete Student

-   **URL**: `/api/admin/students/{registration_number}`
-   **Method**: `DELETE`
-   **Description**: Remove a student

### Task Management (Admin)

#### List Tasks

-   **URL**: `/api/admin/tasks`
-   **Method**: `GET`
-   **Description**: Get all tasks

#### Create Task

-   **URL**: `/api/admin/tasks`
-   **Method**: `POST`
-   **Description**: Create a new task
-   **Request Body**:
    ```json
    {
        "title": "Task Title",
        "description": "Task Description",
        "due_date": "2025-05-20"
    }
    ```

#### Task Progress

-   **URL**: `/api/admin/tasks/{taskId}/progress`
-   **Method**: `POST`
-   **Description**: View task completion progress

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
-   **Description**: Get all tasks assigned to the student

#### Mark Task Complete

-   **URL**: `/api/student/tasks/{taskId}/complete`
-   **Method**: `POST`
-   **Description**: Mark a task as completed

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
    "message": "Error message here",
    "errors": {
        "field": ["Error description"]
    }
}
```

## Authentication

The API uses Laravel Sanctum for authentication. Include the token in all requests:

```
Authorization: Bearer <your_token>
```

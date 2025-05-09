# Task Management API

A robust and optimized RESTful API for task management built with Express.js and MongoDB. This API provides features for creating, reading, updating, and deleting tasks with advanced filtering, pagination, and sorting capabilities.

## Features

- 🔄 **RESTful API** - Full CRUD operations for tasks
- 📱 **Pagination & Filtering** - Efficient data retrieval with pagination and filtering
- 🔍 **Search Capabilities** - Text search on task titles
- ⚡ **Performance Optimized** - Connection pooling, compression, and query optimization
- 🛡️ **Input Validation** - Robust validation for all inputs
- 📊 **Task Priority** - Priority levels for better task organization
- ⏱️ **Timestamps** - Automatic tracking of creation and update times
- 🔒 **Error Handling** - Comprehensive error handling and validation
- 🔄 **Auto Reconnection** - Automatic database reconnection handling

## Prerequisites

- Node.js (v14 or higher)
- MongoDB (v4.4 or higher)
- npm or yarn package manager

## Installation

1. Clone the repository:

2. Install dependencies:
```bash
npm install
```

3. Create a `.env` file in the root directory and these variables (make sure to REPLACE creds with yours):
```env
PORT=3000
MONGODB_URI=mongodb+srv://DATABASE_USERNAME:PASSWORD@YOUR_CLUSTER_NAME.hudulco.mongodb.net/?retryWrites=true&w=majority&appName=YOUR_CLUSTER_NAME
NODE_ENV=development
```

4. Start the server:
```bash
# Development mode with auto-reload
npm run dev
```

## API

### Tasks

#### Get All Tasks
```http
GET /api/tasks
```

Query Parameters:
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 10)
- `completed` (optional): Filter by completion status (true/false)

Response:
```json
{
  "tasks": [
    {
      "id": "string",
      "title": "string",
      "completed": boolean,
      "priority": number,
      "createdAt": "date",
      "updatedAt": "date",
      "status": "string"
    }
  ],
  "currentPage": number,
  "totalPages": number,
  "totalTasks": number
}
```

#### Get Single Task
```http
GET /api/tasks/:id
```

Response:
```json
{
  "id": "string",
  "title": "string",
  "completed": boolean,
  "priority": number,
  "createdAt": "date",
  "updatedAt": "date",
  "status": "string"
}
```

#### Create Task
```http
POST /api/tasks
```

Request Body:

Note: use headers before sending post request:

```
Accept: application/json
Content-Type: application/json
```

```json
{
  "title": "string",
  "completed": boolean,
  "priority": number
}
```

Response: Status: 201 Created

#### Update Task
```http
PATCH /api/tasks/:id
```

Request Body:
```json
{
  "title": "string",
  "completed": boolean,
  "priority": number
}
```

Response: Updated task object

#### Delete Task
```http
DELETE /api/tasks/:id
```

Response:
```json
{
  "message": "Task deleted successfully"
}
```

## Configuration

### Environment Variables

Create a `.env` file in the root directory with the following variables:

```env
PORT=3000                    # Server port
MONGODB_URI=mongodb://...    # MongoDB connection string
NODE_ENV=development         # Environment (development/production)
```

### MongoDB Connection Options

The application uses optimized MongoDB connection settings:
- Connection pooling (max 10 connections)
- Automatic retry on connection failure
- 5-second server selection timeout
- 45-second socket timeout
- IPv4 preferred (faster connection establishment)
- Graceful shutdown handling
- Automatic reconnection on disconnection

Connection Events:
- Error handling for connection issues
- Automatic reconnection on disconnection
- Graceful shutdown on application termination

## Error Handling

The API implements comprehensive error handling:

- 400: Bad Request (Invalid input)
- 404: Not Found (Resource not found)
- 500: Internal Server Error

Error Response Format:
```json
{
  "message": "Error message",
  "error": "Detailed error (development only)"
}
```

### Database Error Handling
- Automatic reconnection on connection loss
- Connection pool management
- Graceful shutdown handling
- Unhandled promise rejection handling

## Performance Optimizations

1. **Database**
   - Connection pooling
   - Indexed fields
   - Optimized queries
   - Lean queries for read operations
   - IPv4 preferred for faster connections
   - Automatic reconnection handling

2. **API**
   - Response compression
   - Pagination
   - Efficient filtering
   - Input validation

3. **Security**
   - Input sanitization
   - Error message sanitization in production
   - CORS enabled

## Development

### Scripts

- `npm run dev`: Start development server with auto-reload
- `npm start`: Start production server
- `npm test`: Run tests (when implemented)

### Project Structure

```
backend-api/
├── app.mjs              # Main application file
├── models/
│   └── Task.mjs        # Task model and schema
├── routes/
│   └── tasks.mjs       # Task routes and controllers
├── .env                # Environment variables
└── package.json        # Project dependencies
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add [what] feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
 
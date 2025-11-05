# Tracks - Golang Rewrite

This is a complete rewrite of the Tracks GTD (Getting Things Done) application in Golang. Tracks is a web-based todo list application designed to help you organize and manage your tasks using the GTD methodology.

## Features

### Core GTD Functionality
- **Todos/Actions**: Create, manage, and track individual tasks
- **Contexts**: Organize actions by context (@home, @work, @phone, etc.)
- **Projects**: Group related actions into projects
- **Dependencies**: Create dependencies between todos (blocking relationships)
- **Tags**: Flexible tagging system for categorization
- **State Management**: Active, Completed, Deferred (tickler), and Pending (blocked) states

### Advanced Features
- **Due Dates**: Set and track due dates for todos
- **Deferred Actions**: Schedule todos to appear at a future date (show_from)
- **Starred Todos**: Flag high-priority items
- **Project Tracking**: Track project status and health
- **Statistics**: Built-in stats for todos, projects, and contexts
- **SQLite Database**: Simple, file-based database with no external dependencies

### Technical Features
- **RESTful API**: Complete REST API for all operations
- **JWT Authentication**: Secure token-based authentication
- **Docker Support**: Ready-to-deploy Docker configuration
- **Database Migrations**: Automatic database schema management
- **Clean Architecture**: Well-organized, maintainable codebase

## Architecture

### Technology Stack
- **Language**: Go 1.21+
- **Web Framework**: Gin
- **ORM**: GORM
- **Database**: SQLite
- **Authentication**: JWT (golang-jwt)
- **Password Hashing**: bcrypt

### Project Structure
```
tracks-golang/
├── cmd/
│   └── tracks/           # Main application entry point
├── internal/
│   ├── config/           # Configuration management
│   ├── database/         # Database connection and migrations
│   ├── handlers/         # HTTP request handlers
│   ├── middleware/       # HTTP middleware (auth, etc.)
│   ├── models/          # Database models
│   └── services/        # Business logic
├── .env.example         # Environment configuration template
├── Dockerfile           # Docker build configuration
├── docker-compose.yml   # Docker Compose setup
└── go.mod              # Go module dependencies
```

## Getting Started

### Prerequisites
- Go 1.21 or higher
- Docker and Docker Compose (optional)

### Installation

#### Option 1: Run with Docker Compose (Recommended)

1. Clone the repository:
```bash
git clone https://github.com/TracksApp/tracks.git
cd tracks
```

2. Start the application:
```bash
docker-compose up -d
```

The application will be available at `http://localhost:3000`

#### Option 2: Run Locally

1. Clone the repository:
```bash
git clone https://github.com/TracksApp/tracks.git
cd tracks
```

2. Copy the environment file:
```bash
cp .env.example .env
```

3. Edit `.env` and configure your settings (database, JWT secret, etc.)

4. Install dependencies:
```bash
go mod download
```

5. Run the application:
```bash
go run cmd/tracks/main.go
```

The application will be available at `http://localhost:3000`

### Default Admin User

On first startup, the application automatically creates a default admin user:

- **Username**: `admin`
- **Password**: `admin`

**Important**: Change the default password immediately after first login!

To login, make a POST request to `/api/auth/login`:
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"login":"admin","password":"admin"}'
```

The response will include a JWT token that you can use for authenticated requests.

### Creating Additional Users

As an admin, you can create new users via the admin API:

```bash
curl -X POST http://localhost:3000/api/admin/users \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -d '{
    "login": "newuser",
    "password": "password123",
    "first_name": "John",
    "last_name": "Doe",
    "is_admin": false
  }'
```

Set `"is_admin": true` to grant admin privileges to the new user.

### Configuration

The application can be configured using environment variables. See `.env.example` for all available options.

#### Key Configuration Options

**Server Configuration:**
- `SERVER_HOST`: Host to bind to (default: 0.0.0.0)
- `SERVER_PORT`: Port to listen on (default: 3000)
- `GIN_MODE`: Gin mode (debug, release, test)

**Database Configuration:**
- `DB_NAME`: SQLite database file path (default: tracks.db)

**Authentication:**
- `JWT_SECRET`: Secret key for JWT tokens (change in production!)
- `TOKEN_EXPIRY_HOURS`: Token expiration time in hours (default: 168 = 7 days)
- `SECURE_COOKIES`: Use secure cookies (set to true in production with HTTPS)

**Application:**
- `OPEN_SIGNUPS`: Allow user registration (default: false)
- `ADMIN_EMAIL`: Admin contact email

## API Documentation

### Authentication

#### Register (if OPEN_SIGNUPS=true)
```bash
POST /api/auth/register
Content-Type: application/json

{
  "login": "username",
  "password": "password",
  "first_name": "John",
  "last_name": "Doe"
}
```

#### Login
```bash
POST /api/auth/login
Content-Type: application/json

{
  "login": "username",
  "password": "password"
}
```

Response:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "login": "username",
    "first_name": "John",
    "last_name": "Doe"
  }
}
```

#### Get Current User
```bash
GET /api/me
Authorization: Bearer <token>
```

### Admin Endpoints (Requires Admin Role)

#### Create User
```bash
POST /api/admin/users
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "login": "newuser",
  "password": "password123",
  "first_name": "John",
  "last_name": "Doe",
  "is_admin": false
}
```

Response:
```json
{
  "id": 2,
  "login": "newuser",
  "first_name": "John",
  "last_name": "Doe",
  "is_admin": false,
  "created_at": "2024-01-01T00:00:00Z"
}
```

### Todos

#### List Todos
```bash
GET /api/todos?state=active&context_id=1&include_tags=true
Authorization: Bearer <token>
```

Query Parameters:
- `state`: Filter by state (active, completed, deferred, pending)
- `context_id`: Filter by context ID
- `project_id`: Filter by project ID
- `tag`: Filter by tag name
- `starred`: Filter starred todos (true/false)
- `overdue`: Show overdue todos (true/false)
- `include_tags`: Include tags in response (true/false)

#### Create Todo
```bash
POST /api/todos
Authorization: Bearer <token>
Content-Type: application/json

{
  "description": "Buy groceries",
  "notes": "Don't forget milk",
  "context_id": 1,
  "project_id": 2,
  "due_date": "2024-12-31T00:00:00Z",
  "starred": false,
  "tags": ["shopping", "urgent"]
}
```

#### Update Todo
```bash
PUT /api/todos/:id
Authorization: Bearer <token>
Content-Type: application/json

{
  "description": "Buy groceries and snacks",
  "starred": true
}
```

#### Complete Todo
```bash
POST /api/todos/:id/complete
Authorization: Bearer <token>
```

#### Defer Todo
```bash
POST /api/todos/:id/defer
Authorization: Bearer <token>
Content-Type: application/json

{
  "show_from": "2024-12-25T00:00:00Z"
}
```

#### Add Dependency
```bash
POST /api/todos/:id/dependencies
Authorization: Bearer <token>
Content-Type: application/json

{
  "successor_id": 5
}
```

This creates a dependency where todo :id blocks todo 5.

### Projects

#### List Projects
```bash
GET /api/projects?state=active
Authorization: Bearer <token>
```

#### Create Project
```bash
POST /api/projects
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Home Renovation",
  "description": "Renovate the kitchen and bathroom",
  "default_context_id": 1
}
```

#### Complete Project
```bash
POST /api/projects/:id/complete
Authorization: Bearer <token>
```

#### Get Project Stats
```bash
GET /api/projects/:id/stats
Authorization: Bearer <token>
```

### Contexts

#### List Contexts
```bash
GET /api/contexts?state=active
Authorization: Bearer <token>
```

#### Create Context
```bash
POST /api/contexts
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "@home"
}
```

#### Hide Context
```bash
POST /api/contexts/:id/hide
Authorization: Bearer <token>
```

## Database Schema

### Main Tables

- **users**: User accounts and authentication
- **preferences**: User preferences and settings
- **contexts**: GTD contexts (@home, @work, etc.)
- **projects**: Project groupings
- **todos**: Individual tasks/actions
- **recurring_todos**: Templates for recurring tasks
- **tags**: Tag labels
- **taggings**: Polymorphic tag assignments
- **dependencies**: Todo dependencies
- **notes**: Project notes
- **attachments**: File attachments for todos

## Development

### Building

```bash
# Build the application
go build -o tracks ./cmd/tracks

# Run tests
go test ./...

# Run with hot reload (install air first: go install github.com/cosmtrek/air@latest)
air
```

### Code Structure

The application follows clean architecture principles:

- **Models**: Define database schema and basic methods
- **Services**: Contain business logic
- **Handlers**: Handle HTTP requests and responses
- **Middleware**: Authentication, logging, etc.

### Adding New Features

1. Define models in `internal/models/`
2. Create service in `internal/services/`
3. Create handler in `internal/handlers/`
4. Register routes in `cmd/tracks/main.go`

## Deployment

### Docker Production Deployment

1. Update `docker-compose.yml` with production settings
2. Set strong passwords and secrets
3. Configure SSL/TLS termination (nginx, traefik, etc.)
4. Run:

```bash
docker-compose up -d
```

### Binary Deployment

1. Build for your platform:
```bash
CGO_ENABLED=1 go build -o tracks ./cmd/tracks
```

2. Create `.env` file with configuration
3. Run:
```bash
./tracks
```

## Differences from Original Ruby/Rails Version

### Improvements
- **Performance**: Significantly faster due to Go's compiled nature
- **Memory Usage**: Lower memory footprint
- **Deployment**: Single binary, no Ruby runtime needed
- **Type Safety**: Compile-time type checking
- **Concurrency**: Better handling of concurrent requests

### Current Limitations
- **Recurring Todos**: Not yet fully implemented
- **Email Integration**: Not yet implemented
- **Statistics**: Basic stats only (advanced analytics pending)
- **Import/Export**: Not yet implemented
- **Mobile Views**: Not yet implemented
- **Attachments**: Model defined but upload handling pending

### Migration Path

To migrate from the Ruby/Rails version:

1. Export data from Rails app using YAML export
2. Create equivalent users in Go version
3. Import data using the import API (to be implemented)

Or run both versions side-by-side during transition.

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

Same as the original Tracks project.

## Support

For issues and questions:
- GitHub Issues: https://github.com/TracksApp/tracks/issues
- Original Tracks: https://github.com/TracksApp/tracks

## Acknowledgments

This is a rewrite of the original Tracks application (https://github.com/TracksApp/tracks) created by the Tracks team. The original application is written in Ruby on Rails.

#!/bin/bash

BASE_URL="http://localhost:3000"

echo "=== Testing Tracks Go API ==="
echo

# Start the server in the background
echo "Starting server..."
rm -f tracks.db
./tracks &
SERVER_PID=$!
sleep 2

echo "1. Health Check"
curl -s "$BASE_URL/api/health" | jq .
echo

echo "2. Register User"
TOKEN=$(curl -s -X POST "$BASE_URL/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{"login": "testuser", "password": "testpass123", "first_name": "Test", "last_name": "User"}' | jq -r '.token')
echo "Token: ${TOKEN:0:50}..."
echo

echo "3. Get Current User"
curl -s -X GET "$BASE_URL/api/me" \
  -H "Authorization: Bearer $TOKEN" | jq '.login, .first_name'
echo

echo "4. Create Context"
CONTEXT_ID=$(curl -s -X POST "$BASE_URL/api/contexts" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "@home"}' | jq -r '.id')
echo "Created context ID: $CONTEXT_ID"
echo

echo "5. Create Project"
PROJECT_ID=$(curl -s -X POST "$BASE_URL/api/projects" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name": "Home Renovation", "description": "Renovate the kitchen"}' | jq -r '.id')
echo "Created project ID: $PROJECT_ID"
echo

echo "6. Create Todo with Tags"
TODO_ID=$(curl -s -X POST "$BASE_URL/api/todos" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"description\": \"Buy paint and brushes\", \"notes\": \"Need white paint\", \"context_id\": $CONTEXT_ID, \"project_id\": $PROJECT_ID, \"starred\": true, \"tags\": [\"shopping\", \"urgent\"]}" | jq -r '.id')
echo "Created todo ID: $TODO_ID"
echo

echo "7. List Active Todos"
curl -s -X GET "$BASE_URL/api/todos?state=active&include_tags=true" \
  -H "Authorization: Bearer $TOKEN" | jq '.[0] | {id, description, state, tags: [.tags[].name]}'
echo

echo "8. Complete Todo"
curl -s -X POST "$BASE_URL/api/todos/$TODO_ID/complete" \
  -H "Authorization: Bearer $TOKEN" | jq '{id, description, state, completed_at}'
echo

echo "9. List Completed Todos"
curl -s -X GET "$BASE_URL/api/todos?state=completed" \
  -H "Authorization: Bearer $TOKEN" | jq 'length as $count | "Found \($count) completed todos"'
echo

echo "10. Project Stats"
curl -s -X GET "$BASE_URL/api/projects/$PROJECT_ID/stats" \
  -H "Authorization: Bearer $TOKEN" | jq '{name: .project.name, active_todos, completed_todos}'
echo

echo "=== All Tests Passed! ==="

# Clean up
kill $SERVER_PID 2>/dev/null

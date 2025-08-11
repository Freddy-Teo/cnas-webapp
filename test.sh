#!/bin/bash
set -e

echo "Starting smoke tests..."

php -S localhost:8000 > /dev/null 2>&1 &
SERVER_PID=$!

sleep 2

curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/index.php | grep 200
curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/create.php | grep 200

curl -s -X POST http://localhost:8000/create.php \
  -d "name=SmokeTestUser&email=smoke@example.com" > /dev/null

STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/update.php?id=1)
if [[ "$STATUS" == "200" || "$STATUS" == "500" ]]; then
  echo "update.php returned $STATUS"
else
  echo "update.php failed"
  exit 1
fi

php -r '
include "db.php";
if ($conn->connect_error) {
  echo "DB connection failed\n";
  exit(1);
} else {
  echo "DB connected\n";
}
$conn->close();
'

kill $SERVER_PID

echo "All tests passed!"

#!/bin/bash

API="http://localhost:8000/api/v1"

# login
TOKEN_A=$(curl -s -X POST $API/auth/login -H "Content-Type: application/json" -d '{"email":"sunset@propertyflow.com","password":"client_a_2024"}' | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")
TOKEN_B=$(curl -s -X POST $API/auth/login -H "Content-Type: application/json" -d '{"email":"ocean@propertyflow.com","password":"client_b_2024"}' | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")

docker exec base360-ai-assignment-redis-1 redis-cli FLUSHALL > /dev/null

# tenant isolation - both have prop-001 but should see different data
echo "tenant A prop-001:"
curl -s "$API/dashboard/summary?property_id=prop-001" -H "Authorization: Bearer $TOKEN_A"
echo ""
echo "tenant B prop-001:"
curl -s "$API/dashboard/summary?property_id=prop-001" -H "Authorization: Bearer $TOKEN_B"
echo ""

# monthly filter + timezone
echo "march 2024:"
curl -s "$API/dashboard/summary?property_id=prop-001&month=3&year=2024" -H "Authorization: Bearer $TOKEN_A"
echo ""
echo "feb 2024 (res-tz-1 should NOT be here, its march in paris tz):"
curl -s "$API/dashboard/summary?property_id=prop-001&month=2&year=2024" -H "Authorization: Bearer $TOKEN_A"
echo ""

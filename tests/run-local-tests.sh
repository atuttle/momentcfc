#!/bin/bash
# Test all engine/Java combinations locally

set -e  # Exit on error

# cd into the git repo's root
cd "$(git rev-parse --show-toplevel)"

CONFIGS=(
	"tests/server-lucee6-java21.json"
	"tests/server-acf2018-java11.json"
	"tests/server-acf2021-java11.json"
	"tests/server-acf2023-java17.json"
	"tests/server-acf2025-java21.json"
)

echo "Testing moment.cfc across multiple engines..."
echo "=============================================="

for config in "${CONFIGS[@]}"; do
	echo ""
	echo "Testing with: $config"
	echo "-------------------------------------------"
	
	# Stop any running servers
	box server stop name=$(jq -r '.name' "$config") 2>/dev/null || true
	
	# Start server with specific config (waits until ready)
	box server start serverConfigFile="$config" openbrowser=false --noSaveSettings
	
	# Get server info
	SERVER_PORT=$(box server info property=port serverConfigFile="$config")
	
	# Run TestBox tests via HTTP
	echo ""
	echo "Calling runner.cfm ..."
	TEST_OUTPUT=$(curl -f "http://127.0.0.1:$SERVER_PORT/tests/runner.cfm?reporter=text")
	echo "$TEST_OUTPUT"
	
	# Check if tests failed by looking for [Failed: N] where N > 0
	if echo "$TEST_OUTPUT" | grep -q '\[Failed: [1-9][0-9]*\]'; then
		echo ""
		echo "FAILED: Tests failed for $config"
		box server stop serverConfigFile="$config"
		exit 1
	fi
	
	# Check if there were errors
	if echo "$TEST_OUTPUT" | grep -q '\[Errors: [1-9][0-9]*\]'; then
		echo ""
		echo "FAILED: Tests had errors for $config"
		box server stop serverConfigFile="$config"
		exit 1
	fi
	
	echo ""
	echo ""
	echo "✓ PASSED: $config"
	
	# Stop server
	box server stop serverConfigFile="$config"
done

echo ""
echo "=============================================="
echo "All tests passed! ✓"

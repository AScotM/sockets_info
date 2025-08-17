#!/bin/bash
#
# ss-to-json.sh
# Convert `ss -tunp` output to JSON
#

set -euo pipefail

# Check if `ss` supports --json
if ss --help 2>&1 | grep -q -- "--json"; then
    # Direct JSON output available
    ss -tunp --json | jq '.'
    exit 0
fi

# Fallback to AWK parser if --json not supported
RAW_DATA=$(ss -tunp)

echo "$RAW_DATA" | awk '
BEGIN {
    print "["
    first_entry = 1
}
NR > 1 {  # Skip header line
    if (!first_entry) {
        print ","
    }
    first_entry = 0

    # Extract fields (fragile but works for default `ss -tunp`)
    proto = $1
    state = $2
    local_ip_port = $5
    peer_ip_port = $6

    # Process info may be missing
    process = ""
    if (NF >= 7) {
        process = substr($0, index($0,$7))
    }

    # Escape quotes and backslashes for JSON safety
    gsub(/\\/,"\\\\",process)
    gsub(/"/,"\\\"",process)

    # Print JSON entry
    printf "  {\n"
    printf "    \"proto\": \"%s\",\n", proto
    printf "    \"state\": \"%s\",\n", state
    printf "    \"local\": \"%s\",\n", local_ip_port
    printf "    \"peer\": \"%s\",\n", peer_ip_port
    printf "    \"process\": \"%s\"\n", process
    printf "  }"
}
END {
    print "\n]"
}
' | jq '.'   # Pretty-print JSON

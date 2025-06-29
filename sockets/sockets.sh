#!/bin/bash

# Get raw socket data
RAW_DATA=$(ss -tunp)

# Convert to JSON
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

    # Extract fields (adjust based on your `ss` output)
    proto = $1
    state = $2
    local_ip_port = $5
    peer_ip_port = $6
    process = substr($0, index($0,$7))  # Everything after column 6

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
' | jq '.'  # Pretty-print JSON (requires `jq`)

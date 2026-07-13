#!/bin/sh
# Generate the HTML page from environment variables

set -e

if [ -z "${TITLE}" ]; then
    echo "ERROR: The 'TITLE' environment variable is not defined or empty." >&2
    exit 1
fi

if [ -z "${MESSAGE}" ]; then
    echo "ERROR: The 'MESSAGE' environment variable is not defined or empty." >&2
    exit 1
fi

# Replace placeholders in the template and output to index.html
sed -e "s|{{TITLE}}|${TITLE}|g" \
    -e "s|{{MESSAGE}}|${MESSAGE}|g" \
    ./index.html.template > ./index.html

# Serve with lighttpd (runs in foreground, binds to port 8080)
exec lighttpd -D -f ./lighttpd.conf
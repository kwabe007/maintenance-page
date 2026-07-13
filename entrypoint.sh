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

echo "Downloading image and capturing headers..."

# 1. Download the image and capture the HTTP response headers.
# We save headers to a temporary file because curl writes the file
# but we need to check if it actually exists/succeeded.
HEADER_FILE=$(mktemp)
curl -fL "$IMAGE_URL" -D "$HEADER_FILE" -o "image"

# Check if curl succeeded (Exit code 0) and the file "image" actually exists

if [ $? -eq 0 ] && [ -f "image" ]; then
    echo "Download successful."

    # 2. Try to extract the filename from the Content-Disposition header
    # e.g., Content-Disposition: attachment; filename="photo.png"
    IMAGE_FILENAME=$(grep -i "content-disposition" "$HEADER_FILE" | grep -oE "filename=[^;]+" | cut -d= -f2 | tr -d '"\r\n')

    # If Content-Disposition didn't give us a filename, fall back to the URL path
    if [ -z "$IMAGE_FILENAME" ]; then
        IMAGE_FILENAME=$(basename "$IMAGE_URL" | cut -d? -f1) # strips query parameters if any
    fi

    # Fallback to a default if the URL didn't have a clean filename either
    if [ -z "$IMAGE_FILENAME" ] || [ "$IMAGE_FILENAME" = "/" ]; then
        IMAGE_FILENAME="downloaded_image"
    fi

    echo "Extracted filename: $IMAGE_FILENAME"

    # 3. Rename the "image" file to its actual filename
    mv "image" "/app/serve/$IMAGE_FILENAME"

else
    echo "Error: Failed to download image or image does not exist at URL."
    exit 1
fi

# Clean up the temporary header file
rm -f "$HEADER_FILE"

# Replace placeholders in the template and output to index.html
if [ -n "$IMAGE_FILENAME" ]; then
    IMG_TAG_REPLACEMENT="<img src=\"/$IMAGE_FILENAME\" alt=\"Downloaded Image\" height=\"${IMAGE_HEIGHT_PX:-auto}\">"
else
    IMG_TAG_REPLACEMENT=""
fi

# 2. Run the pure POSIX sed command
sed -e "s|{{TITLE}}|${TITLE}|g" \
    -e "s|{{MESSAGE}}|${MESSAGE}|g" \
    -e "s|{{IMG_TAG}}|${IMG_TAG_REPLACEMENT}|g" \
    /app/index.html.template > /app/serve/index.html

# Serve with lighttpd (runs in foreground, binds to port 8080)
exec lighttpd -D -f ./lighttpd.conf
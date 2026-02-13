#!/bin/sh
# Generate the HTML page from environment variables

TITLE="${MAINTENANCE_TITLE:-Under Maintenance}"
MESSAGE="${MAINTENANCE_MESSAGE:-We will be back shortly.}"
IMAGE_URL="${MAINTENANCE_IMAGE_URL:-}"

if [ -n "$IMAGE_URL" ]; then
  IMAGE="<img src=\"$IMAGE_URL\" style=\"max-width:300px;margin-bottom:1.5rem;\">"
else
  IMAGE=""
fi

# Replace placeholders in the template
sed -e "s|{{TITLE}}|$TITLE|g" \
    -e "s|{{MESSAGE}}|$MESSAGE|g" \
    -e "s|{{IMAGE}}|$IMAGE|g" \
    /usr/share/nginx/html/index.html.template > /usr/share/nginx/html/index.html

# Serve with Nginx
exec "$@"
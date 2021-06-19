#!/bin/sh

# TODO make this an environment variable or smth
BASE_URL="https://edearth.github.io"

SCRIPT_FOLDER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREVIEW_TEMPLATE="$SCRIPT_FOLDER/templates/preview.html"

generate_article_preview() {
  PREVIEW_TEMPLATE_REPLACE_KEYWORD='ARTICLE_URL'
  SIMPLIFIED_DATE_REPLACE_KEYWORD='SIMPLIFIED_DATE'
  post="$1"
  post_url="$2"
  
  post_id="$(get-property.sh "$post" id)"
  simplified_date="$(date -d "$(get-property.sh "$post" date)" -u +"%Y-%m-%d %H:%M")"

  pandoc \
    --variable="$PREVIEW_TEMPLATE_REPLACE_KEYWORD":"posts/$post_id.html" \
    --variable="$SIMPLIFIED_DATE_REPLACE_KEYWORD":"$simplified_date" \
    --template "$PREVIEW_TEMPLATE" \
    "$post"
}

generate_article_preview "$1" "$2"

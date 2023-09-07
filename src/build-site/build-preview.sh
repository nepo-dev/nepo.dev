#!/bin/sh

SCRIPT_FOLDER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREVIEW_TEMPLATE="$SCRIPT_FOLDER/templates/preview.html"

generate_article_preview() {
  PREVIEW_TEMPLATE_REPLACE_KEYWORD='ARTICLE_URL'
  SIMPLIFIED_DATE_REPLACE_KEYWORD='SIMPLIFIED_DATE'
  post="$1"
  
  post_id="$(get-property.sh "$post" id)"
  simplified_date="$(date -d "$(get-property.sh "$post" date)" -u +"%Y-%m-%d")"

  pandoc \
    --variable="$PREVIEW_TEMPLATE_REPLACE_KEYWORD":"posts/$post_id.html" \
    --variable="$SIMPLIFIED_DATE_REPLACE_KEYWORD":"$simplified_date" \
    --template "$PREVIEW_TEMPLATE" \
    "$post"
}

generate_article_preview "$1"

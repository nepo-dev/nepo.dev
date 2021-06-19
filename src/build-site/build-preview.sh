#!/bin/sh

# TODO make this an environment variable or smth
BASE_URL="https://edearth.github.io"

SCRIPT_FOLDER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREVIEW_TEMPLATE="$SCRIPT_FOLDER/templates/preview.html"

generate_article_preview() {
  PREVIEW_TEMPLATE_REPLACE_KEYWORD='ARTICLE_URL'
  post="$1"
  post_url="$2"
  
  pandoc \
    --variable="$PREVIEW_TEMPLATE_REPLACE_KEYWORD":"$post_url" \
    --template "$PREVIEW_TEMPLATE" \
    "$post"
}

generate_article_preview "$1" "$2"

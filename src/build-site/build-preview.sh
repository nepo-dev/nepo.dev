#!/bin/sh

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

INDEX_CONTENT_TEMP_FILE="temp.html"
BASE_URL="https://edearth.github.io"
POST_SRC_FOLDER="$CWD/../posts"
POST_BUILD_FOLDER="$CWD/../../posts"
PREVIEW_TEMPLATE="$CWD/templates/preview.html"

#TODO:
# * generate preview() -> build/temp folder

# in reality this is generating+adding the article preview to a temporary file
generate_article_preview() {
  PREVIEW_TEMPLATE_REPLACE_KEYWORD='ARTICLE_URL'
  post="$1"
  temp_file="$2"
  generated_post_url="$BASE_URL/posts/$post.html"
  
  pandoc \
    --variable="$PREVIEW_TEMPLATE_REPLACE_KEYWORD":"$generated_post_url" \
    --template "$PREVIEW_TEMPLATE" \
    "$POST_SRC_FOLDER/$post.md" >> "$POST_BUILD_FOLDER/$post.html"
}


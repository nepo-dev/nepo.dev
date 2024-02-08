#!/bin/sh

SCRIPT_FOLDER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATH="$PATH:$SCRIPT_FOLDER"

gen_index_content() {
  while read -r post; do
    build-preview.sh "$post"
  done
}

generate_index() {
  INDEX_FILE="index.html"
  INDEX_TEMPLATE="$SCRIPT_FOLDER/templates/index.html"
  INDEX_TEMPLATE_REPLACE_KEYWORD='\$CONTENT\$'
  METADATA_REPLACE_KEYWORD='\$METADATA\$'
  HEADER_REPLACE_KEYWORD='\$HEADER\$'
  BASE_URL_REPLACE_KEYWORD_REGEX='\$BASE_URL\$'
  index_content="$(cat | sed -z 's/\n/\\n/g')"

  # add contents from temporary file
  # then manually replace $BASE_URL$
  cat "$INDEX_TEMPLATE" | \
    sed "/$METADATA_REPLACE_KEYWORD/d" | \
    sed "/$HEADER_REPLACE_KEYWORD/d" | \
    sed "s|$INDEX_TEMPLATE_REPLACE_KEYWORD|$index_content|" | \
    sed "s|$BASE_URL_REPLACE_KEYWORD_REGEX|$BASE_URL|g"
}

gen_index_content | generate_index

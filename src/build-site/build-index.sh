#!/bin/sh

SCRIPT_FOLDER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATH="$PATH:$SCRIPT_FOLDER"

# TODO make this an environment variable or smth
BASE_URL="https://edearth.github.io"

gen_index_content() {
  while read -r post; do
    build-preview.sh "$post"
  done
}

generate_index() {
  INDEX_FILE="index.html"
  INDEX_TEMPLATE="$SCRIPT_FOLDER/templates/index.html"
  INDEX_TEMPLATE_REPLACE_KEYWORD='\$CONTENT\$'
  BASE_URL_REPLACE_KEYWORD_REGEX='\$BASE_URL\$'
  index_content="$(cat | sed -z 's/\n/\\n/g')"

  # add contents from temporary file
  # then manually replace $BASE_URL$
  cat "$INDEX_TEMPLATE" | \
    sed "s|$INDEX_TEMPLATE_REPLACE_KEYWORD|$index_content|" | \
    sed "s|$BASE_URL_REPLACE_KEYWORD_REGEX|$BASE_URL|g"
}

gen_index_content | generate_index

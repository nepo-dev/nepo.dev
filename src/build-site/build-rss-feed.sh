#!/bin/sh

SCRIPT_FOLDER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATH="$PATH:$SCRIPT_FOLDER"

# TODO make this an environment variable or smth
BASE_URL="https://edearth.github.io"

build_feed_entry () {
  ENTRY_TEMPLATE="$SCRIPT_FOLDER/templates/atom_entry.xml"

  pandoc \
    --template "$ENTRY_TEMPLATE" \
    --variable "BASE_URL":"$BASE_URL" \
    "$post"
}

gen_feed_content() {
  while read -r post; do
    build_feed_entry "$post"
  done
}

generate_feed() {
  FEED_TEMPLATE="$SCRIPT_FOLDER/templates/feed.atom"
  BASE_URL_REPLACE_KEYWORD_REGEX='\$BASE_URL\$'
  CONTENT_REPLACE_KEYWORD='\$CONTENT\$'
  DATE_REPLACE_KEYWORD='\$LAST_UPDATED_DATE\$'

  feed_content="$(cat - | sed -z 's/\n/\\n/g')"
  last_update="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"

  # add contents then manually replace $BASE_URL$
  cat "$FEED_TEMPLATE" | \
    sed "s|$CONTENT_REPLACE_KEYWORD|$feed_content|" | \
    sed "s|$DATE_REPLACE_KEYWORD|$last_update|" | \
    sed "s|$BASE_URL_REPLACE_KEYWORD_REGEX|$BASE_URL|g"
}

gen_feed_content | generate_feed

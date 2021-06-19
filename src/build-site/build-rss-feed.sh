#!/bin/sh

SCRIPT_FOLDER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATH="$PATH:$SCRIPT_FOLDER"

# TODO make this an environment variable or smth
BASE_URL="https://edearth.github.io"

CONTENT_REPLACE_KEYWORD='\$CONTENT\$'

# Pandoc generates anchors (<a>) for each line in code blocks
# When viewed in newsboat, it will show those links
# We have this function in order to avoid that
#
# Credit for the sed command: https://unix.stackexchange.com/a/112149
# '/foo/{:start /bar/!{N;b start};/your_regex/p}'
# This adds everything from /foo/ to /bar/ to the pattern space
# After the ';' we can execute whatever command we want on that match,
# be it a print, a substitution...
remove_code_links () {
  sed '/<div class="sourceCode"/{:start /<\/div>/!{N;b start};s/<a href[^<]*<\/a>//g}'
}

build_feed_entry () {
  ENTRY_TEMPLATE="$SCRIPT_FOLDER/templates/atom_entry.xml"

  entry_content="$(pandoc "$post" | remove_code_links | html-escape.sh)"

  pandoc \
    --no-highlight \
    --template "$ENTRY_TEMPLATE" \
    --variable "CONTENT":"$entry_content" \
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
  DATE_REPLACE_KEYWORD='\$LAST_UPDATED_DATE\$'

  feed_content="$(cat - | sed -z 's/\n/\\n/g')"
  last_update="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"

  cat "$FEED_TEMPLATE" | \
    sed "s|$DATE_REPLACE_KEYWORD|$last_update|" | \
    sed "s|$BASE_URL_REPLACE_KEYWORD_REGEX|$BASE_URL|g" | \
    awk -vcontent="$feed_content" "/$CONTENT_REPLACE_KEYWORD/{print content;print;next}1" | \
    grep -v "$CONTENT_REPLACE_KEYWORD"
}

gen_feed_content | generate_feed

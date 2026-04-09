#!/bin/sh

SCRIPT_FOLDER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATH="$PATH:$SCRIPT_FOLDER"

generate_portfolio_page() {
  INDEX_TEMPLATE="$SCRIPT_FOLDER/templates/index.html"
  INDEX_TEMPLATE_REPLACE_KEYWORD='\$CONTENT\$'
  METADATA_REPLACE_KEYWORD='\$METADATA\$'
  HEADER_REPLACE_KEYWORD='\$HEADER\$'
  BASE_URL_REPLACE_KEYWORD_REGEX='\$BASE_URL\$'

  PORTFOLIO_TEMPLATE="$SCRIPT_FOLDER/templates/portfolio.html"
  portfolio_page_content="$(cat "$PORTFOLIO_TEMPLATE" | sed -z 's/\n/\\n/g')"

  echo "base url is: $BASE_URL" >&2

  # add contents from temporary file
  # then manually replace $BASE_URL$
  cat "$INDEX_TEMPLATE" | \
    sed "/$METADATA_REPLACE_KEYWORD/d" | \
    sed "/$HEADER_REPLACE_KEYWORD/d" | \
    sed "s|$INDEX_TEMPLATE_REPLACE_KEYWORD|$portfolio_page_content|" | \
    sed "s|$BASE_URL_REPLACE_KEYWORD_REGEX|$BASE_URL|g"
}

generate_portfolio_page

#!/bin/sh

# TODO make this an environment variable or smth
BASE_URL="https://edearth.github.io"

SCRIPT_FOLDER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARTICLE_TEMPLATE="$SCRIPT_FOLDER/templates/article.html"

BASE_URL_REPLACE_KEYWORD='BASE_URL'
BASE_URL_REPLACE_KEYWORD_REGEX='\$BASE_URL\$'
SIMPLIFIED_DATE_REPLACE_KEYWORD='SIMPLIFIED_DATE'


generate_article() {
  post="$1"
  simplified_date="$(date -d "$(get-property.sh "$post" date)" -u +"%Y-%m-%d %H:%M")"

  # pandoc doesn't replace the variables in the file we want to convert,
  # only on the template. So it has to be done manually
  sed "s%$BASE_URL_REPLACE_KEYWORD_REGEX%$BASE_URL%g" "$post" \
    | pandoc -s \
      -M document-css=false \
      --variable="$BASE_URL_REPLACE_KEYWORD":"$BASE_URL" \
      --variable="$SIMPLIFIED_DATE_REPLACE_KEYWORD":"$simplified_date" \
      --template "$ARTICLE_TEMPLATE" \
      --highlight-style=kate
}

generate_article "$1"


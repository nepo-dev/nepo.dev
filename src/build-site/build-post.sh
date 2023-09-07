#!/bin/sh

PATH="$PATH:$SCRIPT_FOLDER"

SCRIPT_FOLDER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ARTICLE_TEMPLATE="$SCRIPT_FOLDER/templates/article.html"

BASE_URL_REPLACE_KEYWORD='BASE_URL'
BASE_URL_REPLACE_KEYWORD_REGEX='\$BASE_URL\$'
SIMPLIFIED_DATE_REPLACE_KEYWORD='SIMPLIFIED_DATE'

generate_article_content() {
  post="$1"
  simplified_date="$(date -d "$(get-property.sh "$post" date)" -u +"%Y-%m-%d")"

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

generate_menu() {
  INDEX_TEMPLATE="$SCRIPT_FOLDER/templates/index.html"
  INDEX_TEMPLATE_REPLACE_KEYWORD='\$CONTENT\$'
  BASE_URL_REPLACE_KEYWORD_REGEX='\$BASE_URL\$'
  article_content="$(cat | sed -z 's/\n/\\n/g')"

  # add contents from temporary file
  # then manually replace $BASE_URL$
  cat "$INDEX_TEMPLATE" | \
    awk -vcontent="$article_content" "/$INDEX_TEMPLATE_REPLACE_KEYWORD/{print content;print;next}1" | \
    grep -v "$INDEX_TEMPLATE_REPLACE_KEYWORD" | \
    sed "s%$BASE_URL_REPLACE_KEYWORD_REGEX%$BASE_URL%g"
}

generate_article_content "$1" | generate_menu


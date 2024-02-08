#!/bin/sh

PATH="$PATH:$SCRIPT_FOLDER"

SCRIPT_FOLDER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

POST="$1"
BASE_URL_REPLACE_KEYWORD='BASE_URL'
BASE_URL_REPLACE_KEYWORD_REGEX='\$BASE_URL\$'
PREVIEW_IMAGE_URL="$(get-property.sh "$POST" 'preview-image')"
PREVIEW_IMAGE_REPLACE_KEYWORD='PREVIEW_IMAGE'

generate_article_content() {
  ARTICLE_TEMPLATE="$SCRIPT_FOLDER/templates/article.html"
  SIMPLIFIED_DATE_REPLACE_KEYWORD='SIMPLIFIED_DATE'
  simplified_date="$(date -d "$(get-property.sh "$POST" date)" -u +"%Y-%m-%d")"

  # pandoc doesn't replace the variables in the file we want to convert,
  # only on the template. So it has to be done manually
  #sed "s%$BASE_URL_REPLACE_KEYWORD_REGEX%$BASE_URL%g" "$POST" \ |
    pandoc -s "$POST" \
      -M document-css=false \
      --variable="$BASE_URL_REPLACE_KEYWORD":"$BASE_URL" \
      --variable="$SIMPLIFIED_DATE_REPLACE_KEYWORD":"$simplified_date" \
      --template "$ARTICLE_TEMPLATE" \
      --highlight-style=kate #| \
    #sed -z 's/\n/\\n/g'
}

generate_article_metadata() {
  ARTICLE_METADATA_TEMPLATE="$SCRIPT_FOLDER/templates/metadata.html"
  pandoc -s "$POST" \
    -M document-css=false \
    --variable="$PREVIEW_IMAGE_REPLACE_KEYWORD":"$PREVIEW_IMAGE_URL" \
    --variable="$BASE_URL_REPLACE_KEYWORD":"$BASE_URL" \
    --template "$ARTICLE_METADATA_TEMPLATE"
}

generate_article_header() {
  ARTICLE_HEADER_TEMPLATE="$SCRIPT_FOLDER/templates/article_header.html"
  pandoc -s "$POST" \
    -M document-css=false \
    --variable="$PREVIEW_IMAGE_REPLACE_KEYWORD":"$PREVIEW_IMAGE_URL" \
    --variable="$BASE_URL_REPLACE_KEYWORD":"$BASE_URL" \
    --template "$ARTICLE_HEADER_TEMPLATE"
}

generate_page() {
  INDEX_TEMPLATE="$SCRIPT_FOLDER/templates/index.html"
  CONTENT_REPLACE_KEYWORD='\$CONTENT\$'
  METADATA_REPLACE_KEYWORD='\$METADATA\$'
  HEADER_REPLACE_KEYWORD='\$HEADER\$'
  article_content="$(generate_article_content)"
  article_metadata="$(generate_article_metadata)"
  article_header="$(generate_article_header)"

  # add contents from temporary file
  # then manually replace $BASE_URL$
  cat "$INDEX_TEMPLATE" | \
    awk -vcontent="$article_content" "/$CONTENT_REPLACE_KEYWORD/{print content;next}1" | \
    awk -vcontent="$article_metadata" "/$METADATA_REPLACE_KEYWORD/{print content;next}1" | \
    awk -vcontent="$article_header" "/$HEADER_REPLACE_KEYWORD/{print content;next}1" | \
    sed "s%$BASE_URL_REPLACE_KEYWORD_REGEX%$BASE_URL%g"
}

 generate_page

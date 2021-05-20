#!/bin/sh

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BASE_URL="https://edearth.github.io"
POST_SRC_FOLDER="$CWD/../posts"
POST_BUILD_FOLDER="$CWD/../../posts"
ARTICLE_TEMPLATE="$CWD/templates/article.html"

BASE_URL_REPLACE_KEYWORD='BASE_URL'
BASE_URL_REPLACE_KEYWORD_REGEX='\$BASE_URL\$'

#TODO:
# X generate_article() -> build folder

generate_article() {
  post="$1"

  # pandoc doesn't replace the variables in the file we want to convert,
  # only on the template. So it has to be done manually
  sed "s%$BASE_URL_REPLACE_KEYWORD_REGEX%$BASE_URL%g" "$POST_SRC_FOLDER/$post.md" \
    | pandoc -s \
      -M document-css=false \
      --variable="$BASE_URL_REPLACE_KEYWORD":"$BASE_URL" \
      --template "$ARTICLE_TEMPLATE" \
      --highlight-style=kate \
      -o "$POST_BUILD_FOLDER/$post.html"
}

generate_article "$1"


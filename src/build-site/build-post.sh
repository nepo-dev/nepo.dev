#!/bin/sh

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

INDEX_CONTENT_TEMP_FILE="temp.html"
BASE_URL="https://edearth.github.io"
POST_SRC_FOLDER="src"
POST_BUILD_FOLDER="posts"

#TODO:
# * generate_article() -> build folder
# * generate preview() -> build/temp folder

generate_article() {
  ARTICLE_TEMPLATE="templates/article.html"
  BASE_URL_REPLACE_KEYWORD='BASE_URL'
  BASE_URL_REPLACE_KEYWORD_REGEX='\$BASE_URL\$'
  post="$1"

  # pandoc doesn't replace the variables in the file we want to convert,
  # only on the template. So it has to be done manually
  sed "s%$BASE_URL_REPLACE_KEYWORD_REGEX%$BASE_URL%g" "$POST_SRC_FOLDER/$post" \
    | pandoc -s \
      -M document-css=false \
      --variable="$BASE_URL_REPLACE_KEYWORD":"$BASE_URL" \
      --template "$ARTICLE_TEMPLATE" \
      --highlight-style=kate \
      -o "$POST_BUILD_FOLDER/${post%.*}.html"
}

# in reality this is generating+adding the article preview to a temporary file
generate_article_preview() {
  PREVIEW_TEMPLATE="templates/preview.html"
  PREVIEW_TEMPLATE_REPLACE_KEYWORD='ARTICLE_URL'
  post="$1"
  temp_file="$2"
  generated_post_url="$POST_BUILD_FOLDER/${post%.*}.html"
  
  pandoc \
    --variable="$PREVIEW_TEMPLATE_REPLACE_KEYWORD":"$generated_post_url" \
    --template "$PREVIEW_TEMPLATE" \
    "$POST_SRC_FOLDER/$post" >> "$temp_file"
}

generate_index() {
  INDEX_FILE="index.html"
  INDEX_TEMPLATE="templates/index.html"
  INDEX_TEMPLATE_REPLACE_KEYWORD='\$CONTENT\$'
  BASE_URL_REPLACE_KEYWORD_REGEX='\$BASE_URL\$'
  temp_file_with_article_list="$1"

  cp "$INDEX_TEMPLATE" "$INDEX_FILE"
  # add contents from temporary file
  sed -i -e "/$INDEX_TEMPLATE_REPLACE_KEYWORD/{ r $temp_file_with_article_list" -e "d}" "$INDEX_FILE"
  # manually replace $BASE_URL$
  sed -i "s%$BASE_URL_REPLACE_KEYWORD_REGEX%$BASE_URL%g" "$INDEX_FILE"
}

main() {
  mkdir -p "$POST_BUILD_FOLDER"

  for post in $($CWD/get-property.sh $CWD/$POST_SRC_FOLDER/$file id
); do
    echo "Generating ${post%.*}.html"
    #generate_article "$post"
    #generate_article_preview "$post" "$INDEX_CONTENT_TEMP_FILE"
  done

  echo "Generating index.html"
  #generate_index "$INDEX_CONTENT_TEMP_FILE"
  #rm "$INDEX_CONTENT_TEMP_FILE"
  echo "Build finished ✅"
}

main

#!/bin/sh

ARTICLE_TEMPLATE="templates/article.html"
PREVIEW_TEMPLATE="templates/preview.html"
PREVIEW_TEMPLATE_REPLACE_KEYWORD='ARTICLE_URL'
INDEX_TEMPLATE="templates/index.html"
INDEX_CONTENT_TEMP_FILE="temp.html"
BASE_URL="https://edearth.github.io"
BASE_URL="file:///home/edearth/dev/newpage"
BASE_URL_REPLACE_KEYWORD='BASE_URL'
BASE_URL_REPLACE_KEYWORD_REGEX='\$BASE_URL\$'
INDEX_FILE="index.html"
POST_FOLDER="posts"


get_posts_with_date() {
  for post in $(ls $POST_FOLDER | grep '.md'); do
    date=$(grep -Po '(?<=date:)\s?\d{4}-\d{2}-\d{2}' $POST_FOLDER/$post | sed -e 's/^[ \t]*//')
    echo "$date $post"
  done
}

get_ordered_post_list() {
  get_posts_with_date | sort -r | awk '{print $2}'
}

#in reality this is adding index_preview to a temporal file
generate_index_preview() {
  post="$1"
  temp_file="$2"
  generated_post_url="$POST_FOLDER/${post%.*}.html"
  
  pandoc --variable="$PREVIEW_TEMPLATE_REPLACE_KEYWORD":"$generated_post_url" --template "$PREVIEW_TEMPLATE" "$POST_FOLDER/$post" >> "$temp_file"
}

generate_article() {
  post="$1"

  #pandoc doesn't replace the variables in the file to convert, so it has to be done manually
  sed "s%$BASE_URL_REPLACE_KEYWORD_REGEX%$BASE_URL%g" "$POST_FOLDER/$post" \
    | pandoc -s --variable=BASE_URL:"$BASE_URL" --template "$ARTICLE_TEMPLATE" --highlight-style=zenburn -o "$POST_FOLDER/${post%.*}.html"
}

generate_index() {
  INDEX_TEMPLATE_REPLACE_KEYWORD='\$CONTENT\$'
  temp_file_with_article_list="$1"

  cp "$INDEX_TEMPLATE" "$INDEX_FILE"
  #add contents from temporal file
  sed -i -e "/$INDEX_TEMPLATE_REPLACE_KEYWORD/{ r $temp_file_with_article_list" -e "d}" "$INDEX_FILE"
  #manually replace $BASE_URL$
  sed -i "s%$BASE_URL_REPLACE_KEYWORD_REGEX%$BASE_URL%g" "$INDEX_FILE"
}

for post in $(get_ordered_post_list); do
  echo "Generating ${post%.*}.html"
  generate_article "$post"
  generate_index_preview "$post" "$INDEX_CONTENT_TEMP_FILE"
done

echo "Generating index.html"
generate_index "$INDEX_CONTENT_TEMP_FILE"
rm "$INDEX_CONTENT_TEMP_FILE"
echo "Build finished ✅"


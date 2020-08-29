#!/bin/sh

ARTICLE_TEMPLATE="templates/article.html"
PREVIEW_TEMPLATE="templates/preview.html"
PREVIEW_TEMPLATE_REPLACE_KEYWORD="<!--URL-->"
INDEX_TEMPLATE="templates/index.html"
INDEX_CONTENT_TEMP_FILE="temp.html"
INDEX_TEMPLATE_REPLACE_KEYWORD="<!--CONTENT-->"
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

generate_index_preview() {
  pandoc "$POST_FOLDER/$1" --template "$PREVIEW_TEMPLATE" >> "$INDEX_CONTENT_TEMP_FILE"
  post_url="$POST_FOLDER/${1%.*}.html"
  sed -i "s#<!--URL-->#$post_url#" "$INDEX_CONTENT_TEMP_FILE"
}

generate_article() {
  pandoc -s "$POST_FOLDER/$1" --template "$ARTICLE_TEMPLATE" -o "$POST_FOLDER/${1%.*}.html"
}

generate_index() {
  cp "$INDEX_TEMPLATE" "$INDEX_FILE"
  sed -i "/^$INDEX_TEMPLATE_REPLACE_KEYWORD/ r $INDEX_CONTENT_TEMP_FILE" "$INDEX_FILE"
}

for post in $(get_ordered_post_list); do
  echo "Generating ${post%.*}.html"
  generate_article "$post"
  generate_index_preview "$post"
done

echo "Generating index.html"
generate_index 
rm "$INDEX_CONTENT_TEMP_FILE"
echo "Build finished ✅"


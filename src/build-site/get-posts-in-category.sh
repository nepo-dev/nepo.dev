#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Usage: get-posts-in-category CATEGORY" >&2
  exit 1
fi

SCRIPT_FOLDER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATH="$PATH:$SCRIPT_FOLDER"
POST_SRC_FOLDER="../posts"

list_posts_in_category() {
  for file in $(ls "$POST_SRC_FOLDER"); do
    if [ $(get-property.sh $POST_SRC_FOLDER/$file "category") = "$1" ]; then
      echo $POST_SRC_FOLDER/$file
    fi
  done
}

order_by_date() {
  while read -r post; do
    date="$(get-property.sh $post date)"
    echo "$date $POST_SRC_FOLDER/$post"
  done | sort -r | awk '{print $2}'
}

list_posts_in_category "$1" | order_by_date


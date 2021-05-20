#!/bin/bash

#if [ "$#" -ne 2 ] || ! [ -a "$1" ]; then
#  echo "Usage: get-property FILE PROPERTY-KEY" >&2
#  exit 1
#fi

CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POST_SRC_FOLDER="../posts"

list_posts() {
  for file in $(ls "$CWD/$POST_SRC_FOLDER"); do
    $CWD/get-property.sh $CWD/$POST_SRC_FOLDER/$file id
  done
}

list_posts_ordered_by_property() {
  for post in $(list_posts); do
    date="$(bash -c "$CWD/get-property.sh $CWD/$POST_SRC_FOLDER/$post.md $1")"
    echo "$date $post"
  done | sort -r | awk '{print $2}'
}

list_posts_ordered_by_property date


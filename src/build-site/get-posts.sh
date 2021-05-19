#!/bin/bash

#if [ "$#" -ne 2 ] || ! [ -a "$1" ]; then
#  echo "Usage: get-property FILE PROPERTY-KEY" >&2
#  exit 1
#fi

SCRIPT_FOLDER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATH="$PATH:$SCRIPT_FOLDER"
POST_SRC_FOLDER="../posts"

list_posts() {
  for file in $(ls "$SCRIPT_FOLDER/$POST_SRC_FOLDER"); do
    get-property.sh $SCRIPT_FOLDER/$POST_SRC_FOLDER/$file id
  done
}

list_posts_ordered_by_property() {
  for post in $(ls "$POST_SRC_FOLDER"); do
    date="$(get-property.sh $POST_SRC_FOLDER/$post $1)"
    echo "$date $POST_SRC_FOLDER/$post"
  done | sort -r | awk '{print $2}'
}

list_posts_ordered_by_property date


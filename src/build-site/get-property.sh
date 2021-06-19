#!/bin/sh

if [ "$#" -ne 2 ] || ! [ -a "$1" ]; then
  echo "Usage: get-property FILE PROPERTY-KEY" >&2
  exit 1
fi

trim_whitespace() {
  while read -r line; do
    echo "${line##*( )}"
  done
}

get_metadata () {
  sed -n '/---/{p; :loop n; p; /---/q; b loop}' "$1"
}

get_property () {
  while read -r line; do
    echo "$line" | grep -Po "^$1:.*" | cut -d: -f2- | trim_whitespace
  done
}

get_metadata "$1" | get_property "$2"

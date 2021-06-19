#!/bin/sh

SCRIPT_FOLDER="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATH="$PATH:$SCRIPT_FOLDER"

# TODO export BASE_URL so scripts called from this one have it
BASE_URL="https://edearth.github.io"
BUILD_DIR="$SCRIPT_FOLDER/build"
PROJECT_ROOT="$SCRIPT_FOLDER/../.."

main() {
  # Setup
  rm -rf "$BUILD_DIR"
  mkdir -p "$BUILD_DIR"
  mkdir -p "$BUILD_DIR/posts"

  # Build posts' content
  get-posts.sh | while read -r post; do
    post_id="$(get-property.sh "$post" id)"
    echo "Generating $post_id.html"
    build-post.sh "$post" > "$BUILD_DIR/posts/$post_id.html"
  done

  # Build index file
  echo "Generating index.html"
  get-posts.sh | build-index.sh > "$BUILD_DIR/index.html"

  # Build RSS file
  echo "Generating atom feed"
  get-posts.sh | build-rss-feed.sh > "$BUILD_DIR/feed.atom"

  # Move to root + cleanup
  echo "Moving build files to project root"
  rm "$PROJECT_ROOT/index.html" || true
  mv "$BUILD_DIR/index.html" "$PROJECT_ROOT/index.html"
  rm "$PROJECT_ROOT/feed.atom" || true
  mv "$BUILD_DIR/feed.atom" "$PROJECT_ROOT/feed.atom"
  rm -rf "$PROJECT_ROOT/posts" || true
  mv "$BUILD_DIR/posts" "$PROJECT_ROOT/posts"
  
  rm -rf "$BUILD_DIR"
  echo "Build finished ✅"
}

main

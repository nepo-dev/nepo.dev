#!/bin/sh

# do this for each article
pandoc -s "$1" --template article-template.html -o "converted.html"
pandoc posts/universal-document-language.md --template feed-item-template.html >> test.html #this you add to the index page

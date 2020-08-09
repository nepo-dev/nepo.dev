#!/bin/sh
pandoc -s "$1" --template article-template.html -o "converted.html"

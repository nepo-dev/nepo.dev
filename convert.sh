#!/bin/sh
pandoc -s "$1" --template index.html -o "converted.html"

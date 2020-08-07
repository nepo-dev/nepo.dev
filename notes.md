select until end of style "V/</style", then "y"ank and copy to clipboard with ":w !xclip -i -sel c"
or select all inside tag "vit" and copy to clipboard


Now I have a new file with all my css, but... darn! It kept the indentation so every line has 4 whitespaces at the beginning. How can I remove it?
```css
   .thing {
     prop
   }
```

"^v", select first 4 spaces, then "G" and all lines have been selected. We just have to "d"/"x" to remove all of them.


## Conclusion

The important part is understanding this is not _the_ way to do these things in in vim. They're _one of many_. What vim provides is a new language with which we can interact with computers more efficiently.

Personally, to me it's like a game. Since I'm still learning the language I constantly go through this process of: find something I want to change, think "I could try doing this... but there's no way this could work", try that and it fucking works. I get a dopamine hit and I feel like I gained more mastery over this new language. It's amazing.

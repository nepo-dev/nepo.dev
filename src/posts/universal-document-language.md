---
id: universal-document-language
uuid: 708e86b3-a0ce-4bab-b9d7-312c602478f8
title: 'A universal document language'
author: Juan Antonio Nepormoseno Rosales
date: 2020-08-12T00:00:00Z
last-update: 2020-08-12T00:00:00Z
abstract: On how to use Markdown and Pandoc to generate documents in multiple formats (HTML, PDF, DOC, PPT, ODT...)

---

I love Markdown.
It's a simple to use, minimalist markup language.
It's completely text based, so it's very lightweight and it works extremely well when used with a VCS like Git. 
Here is an example:

```md
---
title: 'My document'
author:
* John Doe
---

Paragraph

* List item 1
* List item 2

## Section 2

Another paragraph

```

And not only can you use it for text files, you can use it to generate other types of documents as well.

## Converting documents

There are multiple tools to achieve this, but today I want to talk about **[Pandoc](https://pandoc.org/)**.
Pandoc is a **universal document converter**.
It allows converting from and to different formats, like from Open/Libre Office's ODT to Microsoft Word's DOCX or viceversa.
From word processor formats like the previous 2, to HTML, PDF, Slides, Wiki, TeX...
and the best of all: it allows converting to and from **Markdown**.

Why is this good?
Well, you can write a document in Markdown and maintain a local git repository for it, so you can keep a **history** of the changes you made.
And then you can **convert** it to a **PDF/Word** format, so a colleague can read your notes in visual form.
With the same file, you can even convert it to a **slideshow** format, so you can present it in front of people.
Need to add this info in a web page?
You just convert it to **HTML**.
It is _extremely_ flexible.
And if you already take notes in Markdown, the process to adapt your notes to another format/document is trivially easy and quick.

```sh
# Markdown to ODT
pandoc document.md -o 

# Markdown to PDF (using xelatex)
pandoc document.md --pdf-engine=xelatex -o document.pdf

# Markdown to HTML
# -s (for standalone) is optional, used to generate tags 
# like the headers, body, etc. and make a whole HTML file
pandoc document.md -s -o document.html

# Markdown to slideshow (using Beamer)
pandoc document.md -t beamer -o slides.pdf
```

Not convinced yet?
What if I told you you could automate the styling of the document?
That would allow you to **focus on the content** and leave the formatting to Pandoc.
That can be easily achieved with a custom template.

# Writing your own template

Writing your own template is easy to do.
Let's take an HTML template as an example.
We start by making a dummy HTML:

```html
<html>
  <head>
    <link rel="stylesheet" type="text/css"...
    ...
  </head>
  <body>
    <h1>Title</h1>
    <p>Lorem ipsum...</p>
  </body>
</html>
```

Then we can use the default template as a reference to start building our own.
You can use the `-D` option to get the standard template for a format, like this:

```sh
pandoc -D html > template.html
```

From the get go, we see properties like "author-meta", "date-meta" or "keywords".
To keep this post short I'll just stick to the "title" and "body", but you can [read the official documentation](https://pandoc.org/MANUAL.html#variables) if you want to see all you can do with it.
You can also use conditionals, loops and embed templates on other templates, if you need to do something more complex.
But let's go back to our example.

To use these properties in our document, we can use either of two formats:

* `$prop$`
* `${prop}`

So to add the title and the content of our document to our HTML template, we just need to do:

```html
<html>
  <head>
    <link rel="stylesheet" type="text/css"...
    ...
  </head>
  <body>
    <h1>${title}</h1>
    <p>${body}</p>
  </body>
</html>
```

And, using the example Markdown document at the beginning of the article, the resulting HTML would look like:

```html
<html>
  <head>
    <link rel="stylesheet" type="text/css"...
    ...
  </head>
  <body>
    <h1>My document</h1>
    <p>Paragraph</p>
    <ul>
      <li>List item 1</li>
      <li>List item 2</li>
    </ul>
    <h2>Section 2</h2>
    <p>Another paragraph</p>
  </body>
</html>
```

The best part is that you don't even need to write your own template.
You can just search for more on the Internet.
There is a selection of them in [Pandoc's official repository](https://github.com/jgm/pandoc/wiki/User-contributed-templates).

# Conclusion

The key takeaway from this post is this:
Markdown emphasizes focusing on the content, not the style.
Pandoc allows us to keep these two tasks separated.
By using it, we can write our documents in Markdown and rely on our template to apply the style in the end, automatically.

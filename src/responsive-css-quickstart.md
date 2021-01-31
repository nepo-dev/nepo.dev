---
title: 'Painless responsive CSS: water, flexboxes and grids'
author:
- Juan Antonio Nepormoseno Rosales
date: 2021-01-31
abstract:
 A quickstart guide on how to style the layout of a website while keeping it simple.
---

When I started this blog I had no idea of how to write modern CSS,
nor did I know the slightest thing about how to make a website responsive.
I started making a stylesheet with lots of minute details,
like setting multiple margins in pixels for all classes,
organizing the layout based on those margins,
using weird tricks to center divs,
etc.

Only when I tried making the site responsive
I realized I had a huge problem.
I tried to fix it, but in the end
[this untenable mess](https://github.com/Edearth/edearth.github.io/blob/b88d46ff96841cf4d30a7b84bca2f09c33bc6cb9/edearth.css)
had to go and I had to start from the ground up.

In this post I share some of the lessons I learned
and a recommendation to use some tools to save time.

## Desing for mobile first

One of the simple but important lessons I learned
is to design the site for mobile first, rather than desktop.
Since mobile is more restrictive,
due to its limited horizontal space,
it lends itself to linear layouts.
This forces you to keep your layout simple,
so you'll be making decisions about what to show or what to keep,
instead of focusing on how you want to display it.

This step takes place before you even start writing the first line of HTML or CSS,
so it should be quick to iterate until you find a design you're comfortable with.

## Responsive elements: water.css

A friend introduced me to this wonderful tool.
It's a ready-made collection of styles
that make HTML elements look good
while keeping them responsive.
To put it simply:
instead of painstakingly going over every element on your site
and writing CSS to make sure they scale well,
you can just re-use someone else's CSS!

You only need to do a couple of things to start using it.
You want to make your website aware of the device's resolution with the `viewport` tag
and import the `water.css` stylesheet.
Like this:

```html
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/water.css@2/out/water.css">
</head>
```

This is just an example.
There are other tools similar to this one out there.
Tailwind, Materialize or Foundation for Apps
might be the right thing for you.
But these are frameworks and they require some learning.
If what you want is [taking it easy](https://youtu.be/q2gN6_alzVQ),
just use `water.css`.

## Responsive layout: flexbox and grid layout

In my initial search for modern responsive techniques,
I came across this video by Una Kravets ([\@una](https://twitter.com/una))
where she talks about flexbox and grid layouts.

<iframe width="560" height="315" src="https://www.youtube-nocookie.com/embed/qm0IfG1GyZU" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

Watch it from beginning 'til end, it's worth your time.
There is also [this website version](https://1linelayouts.glitch.me/)
in case you want to play around with the result
or you want a convenient cheat sheet.

As a quick takeaway:
if you need to position two elements in a row
and you need them to scale,
you can create a parent element with `display: flex;`.
Then you define what percentage those elements will take with `flex: 50%`.
The flexbox will then take care of scaling them for you,
and if you add `flex-wrap: wrap;` to the parent,
it will position them in a new row when they can't fit in the screen.

```html
<div style="display: flex;">
  <p style="flex: 60%;">
    This column takes 60% of the available space.
  </p>
  <p style="flex: 30%;">
    This one just 30%.
  </p>
</div>
```

<div style="display: flex;">
<p style="flex: 70%; background-color: khaki;">This column takes 70% of the available space.</p>
<p style="flex: 30%; background-color: palevioletred;">This one just 30%.</p>
</div>

## Conditions: media queries

There are some cases where you want to show something just on desktop.
Or maybe you need to move an element to the next row when browsing on mobile.
You can do that with media queries.

The idea behind them is easy to understand.
You can think of them as simple conditions.
Is the screen bigger than 500px?
Is the site being browsed in a mobile device in portrait mode?
Then apply these CSS rules.

<details>
  <summary>Example</summary>

```css
@media (min-width: 500px) {
  /*the style for this class will only be applied when the screen's width is 500px or more*/
  .normal-css {
    background-color: white;
    color: black;
  }
}

@media (orientation: portrait) {
  /*the style for this class will only be applied when the device is in portrait mode*/
  .normal-css {
    background-color: white;
    color: black;
  }
}
```

</details>

An example of how to use it in combination with the flexbox layout
is to position a horizontal line of elements vertically.
In the following example the boxes will be positioned vertically,
since they're set to fill 100% of the flexbox with `flex: 100%;`.
But if the viewport is bigger than 500px they'll be positioned side by side,
since they'll have the property `flex: 50%;`.

Check the following example in a mobile device and in a desktop:

<div>
<style>
.example { flex: 100%; }
@media (min-width: 500px) { .example { flex: 50%; } }
</style>
<div style="background-color: lightblue; width: 100%;">
<div style="display: flex; flex-wrap: wrap;">
<p class="example" style="background-color: khaki;">This column takes all horizontal space when the container is too small.</p>
<p class="example" style="background-color: palevioletred;">So this one is being pushed to the next row.</p>
</div>
</div>
</div>

<details>
  <summary>Example</summary>

CSS:

```css
.example {
  flex: 100%;
}

@media (min-width: 500px) {
  .example {
    flex: 50%;
  }
}
```

HTML:

```html
<div style="display: flex; flex-wrap: wrap;">
  <p class="example">
    This column takes all horizontal space when the container is too small.
  </p>
  <p class="example">
    So this one is being pushed to the next row.
  </p>
</div>
```

</details>

-------------

That's all for now. I hope you found some of this useful!

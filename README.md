# Shopbox.js

* A simple extensible lightbox that separates animation and presentation completely from Javascript. Animation and styling is all CSS3, no crappy images, no crappy JS animations.
* Can display iframes, html, images.
* Doesn't do image galleries or captions, though it should be easy to extend if you really really want that.

  See the shopbox_example.html

## Runtime Dependencies

* jQuery

## Development Dependencies

* Coffeescript
* Java (for compiler/minifier)
* Rake

  If you change the source, run `rake compile` before checking in so that the minified JS is up to date.

## Compiling

    rake compile

## To Do

* Needs to know height/width of images.
* Default styles.
* Loading spinner.

## Issues

* large screen size is a performance issue with css animation
* markup needs to be cleaned up
* default styles
* style example page to be nice
* add tutorial in readme
* batman integration?
* verify cross-browser

## Authors

* Christoper Lobay
* Steven Soroka

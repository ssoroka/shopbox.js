# Shopbox.js

* A simple extensible lightbox that separates animation and presentation completely from Javascript. Animation and styling is all CSS3, no crappy images, no crappy JS animations.
* Can display iframes, html, images, and video
* auto adjusts shopbox size to fit image size
* shows spinner while waiting for large images or iframes to load
* Doesn't do image galleries or captions, though it should be easy to extend if you really really want that.

## Usage examples

Attach shopbox to all elements with class "shopbox":

    $('.shopbox').shopbox();

Attach shopbox to a specific id, and load an image when it's clicked:

    $('#image_link').shopbox('http://cvcl.mit.edu/hybrid/cat2.jpg');

Attach shopbox to a specific id and load custom html when it's clicked:

    $('#content_link').shopbox('<h1>Serious cat is not amused.</h1> <img src="http://cvcl.mit.edu/hybrid/cat2.jpg">');

Attach shopbox to a specific id and load a url in an iframe when it's clicked in a 800x600 shopbox window:

    $('#iframe_link').shopbox('http://shop.shopyasukoazuma.com/', {width: 800, height: 600});

Attach shopbox to a specific id and have it pull in some nodes already in the DOM:

    $('#iframe_link').shopbox($('#hidden_content'), {width: 800, height: 600});

Alternatively, you can pass the width and height using data attributes, and the target url using href:

    <a href="http://shop.shopyasukoazuma.com/" id="iframe_link" data-shopbox-width='800' data-shopbox-height='600'>iframe link</a>

This works for images, too; the image to be shown is taken from the "src" attribute.

shopbox_example.html uses some of these examples

## Runtime Dependencies

* jQuery

## Development Dependencies

* Coffeescript
* Java (for compiler/minifier)
* Rake

  If you change the source, run `rake compile` before checking in so that the minified JS is up to date.

## Compiling

    rake compile

## To Do / Issues

* Default styles.
* large screen size is a performance issue with css animation
* markup needs to be cleaned up
* style example page to be nice
* add tutorial in readme
* batman integration?
* verify cross-browser
* resize shopbox with browser resize if necessary
* add/verify video support

## Authors

* Christoper Lobay
* Steven Soroka

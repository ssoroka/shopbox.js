(function() {
  var ShopBox;

  ShopBox = (function() {
    var image_exts;

    function ShopBox() {}

    ShopBox.box = null;

    ShopBox.template = '<div id="shopbox" class="shopbox-hidden"><div id="shopbox-spinner" class="shopbox-spinner">Loading</div><span id="shopbox-loading-message">Click anywhere to close</span><div id="shopbox-main"><a id="shopbox-close" href="#">Close</a><div id="shopbox-content"></div></div></div>';

    ShopBox.init = function() {
      if ($('#shopbox').length === 0) {
        $('body').prepend(this.template);
        ShopBox.wrapper = $('#shopbox');
        ShopBox.spinner = $('#shopbox-spinner');
        ShopBox.loading_message = $('#shopbox-loading-message');
        ShopBox.main = $('#shopbox-main');
        ShopBox.close = $('#shopbox-close');
        ShopBox.content = $('#shopbox-content');
        ShopBox.class_visible = 'shopbox-visible';
        ShopBox.class_hidden = 'shopbox-hidden';
        ShopBox.class_loaded = 'shopbox-loaded';
        this.close.click(ShopBox.closeBox);
        $(window).bind('keydown', function(event) {
          if (event.which === 27) return ShopBox.closeBox();
        });
        return $(this.wrapper, this.spinner).bind('click', function(event) {
          if (event.target === this) return ShopBox.closeBox();
        });
      }
    };

    ShopBox.show = function(content) {
      ShopBox.wrapper.removeClass(ShopBox.class_hidden);
      return setTimeout((function() {
        return ShopBox.wrapper.addClass(ShopBox.class_visible);
      }), 0);
    };

    ShopBox.closeBox = function(event) {
      if (event) event.preventDefault();
      return ShopBox.hide();
    };

    ShopBox.hide = function() {
      if (!ShopBox.wrapper.hasClass(ShopBox.class_visible)) return;
      ShopBox.wrapper.removeClass(ShopBox.class_visible);
      return ShopBox.wrapper.transitionEnd(function() {
        ShopBox.wrapper.addClass(ShopBox.class_hidden).removeClass(ShopBox.class_loaded);
        return ShopBox.main.removeClass(ShopBox.class_visible);
      });
    };

    ShopBox.startSpinner = function() {
      ShopBox.spinner.addClass(ShopBox.class_visible);
      ShopBox.loading_message.addClass(ShopBox.class_visible);
      return ShopBox.main.removeClass(ShopBox.class_visible);
    };

    ShopBox.finishSpinner = function(event) {
      var content;
      content = event.target || event;
      ShopBox.loading_message.removeClass(ShopBox.class_visible);
      ShopBox.spinner.removeClass(ShopBox.class_visible);
      ShopBox.main.addClass(ShopBox.class_visible);
      ShopBox.content.html(content);
      return ShopBox.wrapper.addClass(ShopBox.class_loaded);
    };

    ShopBox.setTypeStyle = function(style) {
      return ShopBox.wrapper.removeClass('shopbox-html shopbox-image shopbox-iframe shopbox-video').addClass(style);
    };

    ShopBox.loadFromContent = function(urlOrContent, options, element) {
      var dimensions, div, iframe, img, type, url;
      if (urlOrContent === void 0) urlOrContent = element.attr('href');
      type = options['type'] || this.typeFromContent(urlOrContent);
      ShopBox.content.css({
        'width': '',
        'height': ''
      });
      ShopBox.main.css({
        'margin-left': '',
        'margin-top': ''
      });
      ShopBox.show();
      if (type !== 'content') {
        url = "" + urlOrContent + "?" + (Math.random() * 1000000000000000000);
        ShopBox.startSpinner();
      }
      this.setTypeStyle("shopbox-" + type);
      switch (type) {
        case 'image':
          img = $('<img />');
          img.load(function(event) {
            ShopBox.setSize({
              height: options.height || this.height,
              width: options.width || this.width
            });
            return ShopBox.finishSpinner(event);
          });
          img.attr('src', url);
          return window.img = img;
        case 'iframe':
          iframe = $('<iframe></iframe>');
          iframe.hide();
          dimensions = {
            height: options.height || 400,
            width: options.width || 600
          };
          iframe.css(dimensions);
          ShopBox.setSize(dimensions);
          iframe.load(function(event) {
            iframe.show();
            return ShopBox.finishSpinner(event);
          });
          iframe.attr('src', url);
          return ShopBox.content.html(iframe);
        default:
          div = $('<div />').css({
            display: 'none'
          });
          dimensions = {
            height: options.height || 400,
            width: options.width || 600
          };
          ShopBox.content.html(div);
          div.ready(function() {
            return setTimeout((function() {
              ShopBox.setSize(dimensions);
              div.remove();
              return ShopBox.finishSpinner(urlOrContent);
            }), 0);
          });
          return div.html(urlOrContent);
      }
    };

    ShopBox.setSize = function(dimensions) {
      var max_height, max_width;
      max_width = document.width - 50;
      max_height = document.height - 50;
      if (max_width < dimensions.width) dimensions.width = max_width;
      if (max_height < dimensions.height) dimensions.height = max_height;
      ShopBox.content.css(dimensions);
      return ShopBox.main.css({
        'margin-left': -dimensions.width / 2 - 10,
        'margin-top': -dimensions.height / 2 - 10
      });
    };

    image_exts = ['jpg', 'jpeg', 'png', 'bmp', 'gif'];

    ShopBox.typeFromContent = function(urlOrContent) {
      var ext;
      if ((urlOrContent.nodeType != null) || urlOrContent instanceof jQuery) {
        return 'object';
      }
      ext = urlOrContent.split('.').pop().toLowerCase();
      if (image_exts.indexOf(ext) >= 0) {
        return 'image';
      } else if (urlOrContent.match(/^https?\:\/\/\S+$/)) {
        return 'iframe';
      } else {
        return 'html';
      }
    };

    return ShopBox;

  })();

  window.ShopBox = ShopBox;

  jQuery.fn.shopbox = function(urlOrContent, options) {
    var elements;
    if (options == null) options = {};
    elements = this;
    ShopBox.init();
    return elements.each(function(i, element) {
      return $(element).click(function(event) {
        event.preventDefault();
        return ShopBox.loadFromContent(urlOrContent, options, $(element));
      });
    });
  };

  jQuery.fn.transitionEnd = function(func) {
    return this.one('TransitionEnd webkitTransitionEnd transitionend oTransitionEnd', func);
  };

}).call(this);

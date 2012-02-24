(function() {
  var ShopBox;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  ShopBox = (function() {
    var image_exts;
    function ShopBox() {}
    ShopBox.box = null;
    ShopBox.template = '<div id="shopbox" class="shopbox-hidden"><div id="shopbox-spinner" class="shopbox-spinner">Loading</div><span id="shopbox-loading-message">Click anywhere to close</span><div id="shopbox-main"><a id="shopbox-close" href="#">Close</a><div id="shopbox-content"></div></div></div>';
    ShopBox.init = __bind(function() {
      if ($('#shopbox').length === 0) {
        $('body').prepend(this.template);
        this.wrapper = $('#shopbox');
        this.spinner = this.wrapper.find('#shopbox-spinner');
        this.loading_message = this.wrapper.find('#shopbox-loading-message');
        this.main = this.wrapper.find('#shopbox-main');
        this.close = this.main.find('#shopbox-close');
        this.content = this.main.find('#shopbox-content');
        this.visible = 'shopbox-visible';
        this.hidden = 'shopbox-hidden';
        this.loaded = 'shopbox-loaded';
        this.close.click(this.closeBox);
        $(window).bind('keydown', __bind(function(event) {
          if (event.which === 27) {
            return this.closeBox();
          }
        }, this));
        return $(this.wrapper, this.spinner).bind('click', __bind(function(event) {
          if (event.target === this.wrapper[0]) {
            return this.closeBox();
          }
        }, this));
      }
    }, ShopBox);
    ShopBox.show = __bind(function(content) {
      this.wrapper.removeClass(this.hidden);
      return setTimeout((__bind(function() {
        return this.wrapper.addClass(this.visible);
      }, this)), 0);
    }, ShopBox);
    ShopBox.closeBox = __bind(function(event) {
      if (event) {
        event.preventDefault();
      }
      return this.hide();
    }, ShopBox);
    ShopBox.hide = __bind(function() {
      if (!this.wrapper.hasClass(this.visible)) {
        return;
      }
      this.wrapper.removeClass(this.visible);
      return this.wrapper.transitionEnd(__bind(function() {
        this.wrapper.addClass(this.hidden).removeClass(this.loaded);
        return this.main.removeClass(this.visible);
      }, this));
    }, ShopBox);
    ShopBox.startSpinner = __bind(function() {
      this.spinner.addClass(this.visible);
      this.loading_message.addClass(this.visible);
      return this.main.removeClass(this.visible);
    }, ShopBox);
    ShopBox.finishSpinner = __bind(function(event) {
      var content;
      content = event.target || event;
      this.loading_message.removeClass(this.visible);
      this.spinner.removeClass(this.visible);
      this.main.addClass(this.visible);
      this.content.html(content);
      return this.wrapper.addClass(this.loaded);
    }, ShopBox);
    ShopBox.setTypeStyle = __bind(function(style) {
      return this.wrapper.removeClass('shopbox-html shopbox-image shopbox-iframe shopbox-video').addClass(style);
    }, ShopBox);
    ShopBox.loadFromContent = __bind(function(urlOrContent, options, element) {
      var dimensions, div, iframe, img, type, url;
      if (!(urlOrContent != null)) {
        urlOrContent = element.attr('href');
      }
      type = options['type'] || this.typeFromContent(urlOrContent);
      this.content.css({
        'width': '',
        'height': ''
      });
      this.main.css({
        'margin-left': '',
        'margin-top': ''
      });
      this.show();
      if (type !== 'content') {
        url = urlOrContent;
        if (options.cache === false) {
          url = "" + url + "?" + (Math.random() * 1000000000000000000);
        }
      }
      this.startSpinner();
      this.setTypeStyle("shopbox-" + type);
      console.log(type);
      switch (type) {
        case 'image':
          img = $('<img />');
          img.hide();
          this.content.html(img);
          img.load(__bind(function(event) {
            this.setSize({
              height: options.height || img.height(),
              width: options.width || img.width()
            });
            img.show();
            return this.finishSpinner(event);
          }, this));
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
          this.setSize(dimensions);
          iframe.load(__bind(function(event) {
            iframe.show();
            return this.finishSpinner(event);
          }, this));
          iframe.attr('src', url);
          return this.content.html(iframe);
        default:
          div = $('<div />');
          div.hide();
          this.content.html(div);
          div.ready(__bind(function() {
            return setTimeout((__bind(function() {
              this.setSize({
                height: options.height || div.height(),
                width: options.width || div.width()
              });
              div.remove();
              return this.finishSpinner(urlOrContent);
            }, this)), 0);
          }, this));
          return div.html(urlOrContent);
      }
    }, ShopBox);
    ShopBox.setSize = __bind(function(dimensions) {
      var max_height, max_width;
      max_width = document.width - 50;
      max_height = document.height - 50;
      dimensions.height || (dimensions.height = 400);
      dimensions.width || (dimensions.width = 600);
      if (max_width < dimensions.width) {
        dimensions.width = max_width;
      }
      if (max_height < dimensions.height) {
        dimensions.height = max_height;
      }
      console.log(dimensions);
      this.content.css(dimensions);
      return this.main.css({
        'margin-left': -dimensions.width / 2 - 10,
        'margin-top': -dimensions.height / 2 - 10
      });
    }, ShopBox);
    image_exts = ['jpg', 'jpeg', 'png', 'bmp', 'gif'];
    ShopBox.typeFromContent = __bind(function(urlOrContent) {
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
    }, ShopBox);
    return ShopBox;
  }).call(this);
  window.ShopBox = ShopBox;
  jQuery.fn.shopbox = function(urlOrContent, options) {
    var elements;
    if (options == null) {
      options = {};
    }
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

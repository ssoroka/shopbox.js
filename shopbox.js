(function() {
  var ShopBox;
  ShopBox = (function() {
    function ShopBox() {}
    ShopBox.box = null;
    ShopBox.template = '\
    <div class="shopbox shopbox-hidden">\
      <div class="shopbox-spinner"></div>\
      <div class="shopbox-main">\
        <div class="shopbox-inner">\
          <a class="shopbox-close" href="#">Close</a>\
          <div class="shopbox-content"></div>\
        </div>\
      </div>\
    </div>\
  ';
    ShopBox.init = function() {
      if (!$('.shopbox').length > 0) {
        $('body').prepend(this.template);
        $('.shopbox-close').click(ShopBox.closeBox);
        $('body').bind('keydown', function(event) {
          if (event.which === 27) {
            return ShopBox.closeBox();
          }
        });
        return $('.shopbox, .shopbox-spinner').bind('click', function(event) {
          if (event.target === this) {
            return ShopBox.closeBox();
          }
        });
      }
    };
    ShopBox.show = function(content) {
      $('.shopbox').removeClass('shopbox-hidden');
      return setTimeout((function() {
        return $(".shopbox").addClass("shopbox-visible");
      }), 0);
    };
    ShopBox.closeBox = function(event) {
      if (event) {
        event.preventDefault();
      }
      return ShopBox.hide();
    };
    ShopBox.hide = function() {
      if (!$('.shopbox').hasClass('shopbox-visible')) {
        return;
      }
      $('.shopbox').removeClass('shopbox-visible');
      return $('.shopbox').transitionEnd(function() {
        $('.shopbox').addClass('shopbox-hidden');
        $('.shopbox-main').removeClass('shopbox-visible');
        return $('.shopbox').removeClass('shopbox-loaded');
      });
    };
    ShopBox.startSpinner = function() {
      $('.shopbox-spinner').addClass('shopbox-visible');
      return $('.shopbox-main').removeClass('shopbox-visible');
    };
    ShopBox.finishSpinner = function(event) {
      var content, spinner;
      content = event.target || event;
      spinner = $('.shopbox-spinner');
      if (spinner.hasClass('shopbox-visible')) {
        spinner.removeClass('shopbox-visible');
      }
      $('.shopbox-main').addClass('shopbox-visible');
      $('.shopbox .shopbox-content').html(content);
      return $('.shopbox').addClass('shopbox-loaded');
    };
    ShopBox.setTypeStyle = function(style) {
      return $('.shopbox').removeClass('shopbox-html shopbox-image shopbox-iframe shopbox-video').addClass(style);
    };
    ShopBox.loadFromUrl = function(urlOrContent, options, element) {
      var dimensions, iframe, img, type, url;
      if (urlOrContent === void 0) {
        urlOrContent = element.attr('href');
      }
      type = options['type'] || this.typeFromUrl(urlOrContent);
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
          return $('.shopbox .shopbox-content').append(iframe);
        default:
          ShopBox.setSize(options);
          return ShopBox.finishSpinner(urlOrContent);
      }
    };
    ShopBox.setSize = function(dimensions) {
      var content, max_height, max_width;
      max_width = document.width - 50;
      max_height = document.height - 50;
      if (max_width < dimensions.width) {
        dimensions.width = max_width;
      }
      if (max_height < dimensions.height) {
        dimensions.height = max_height;
      }
      dimensions.height || (dimensions.height = '');
      dimensions.width || (dimensions.width = '');
      content = $('.shopbox-content');
      content.css(dimensions);
      return setTimeout((function() {
        return $('.shopbox-main').css({
          'margin-left': -content.width() / 2 - 10,
          'margin-top': -content.height() / 2 - 10
        });
      }), 0);
    };
    ShopBox.typeFromUrl = function(url) {
      var ext, image_exts;
      image_exts = ['jpg', 'jpeg', 'png', 'bmp', 'gif'];
      ext = url.split('.').pop().toLowerCase();
      if (image_exts.indexOf(ext) >= 0) {
        return 'image';
      } else if (url.match(/^https?\:\/\/\S+$/)) {
        return 'iframe';
      } else {
        return 'html';
      }
    };
    return ShopBox;
  })();
  window.ShopBox = ShopBox;
  jQuery.fn.shopbox = function(url, options) {
    var element;
    if (options == null) {
      options = {};
    }
    element = this;
    ShopBox.init();
    return element.click(function(event) {
      event.preventDefault();
      return ShopBox.loadFromUrl(url, options, element);
    });
  };
  jQuery.fn.transitionEnd = function(func) {
    return this.one('TransitionEnd webkitTransitionEnd transitionend oTransitionEnd', func);
  };
}).call(this);

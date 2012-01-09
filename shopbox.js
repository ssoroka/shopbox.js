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
        return $('.shopbox').bind('click', function(event) {
          if (event.target === this) {
            return ShopBox.closeBox();
          }
        });
      }
    };
    ShopBox.show = function(content) {
      console.log('show');
      $('.shopbox').removeClass('shopbox-hidden');
      return setTimeout((function() {
        console.log('show setTimeout');
        return $(".shopbox").addClass("shopbox-visible");
      }), 0);
    };
    ShopBox.closeBox = function(event) {
      if (event) {
        event.preventDefault();
      }
      $('.shopbox .shopbox-content').html('');
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
      console.log('startSpinner');
      $('.shopbox-spinner').addClass('shopbox-visible');
      return $('.shopbox-main').removeClass('shopbox-visible');
    };
    ShopBox.finishSpinner = function(event) {
      var content, spinner;
      console.log('finishSpinner');
      content = event.target;
      spinner = $('.shopbox-spinner');
      if (spinner.hasClass('shopbox-visible')) {
        spinner.removeClass('shopbox-visible');
        $('.shopbox-main').addClass('shopbox-visible');
        console.log('Setting content to:');
        console.log(content);
        $('.shopbox .shopbox-content').html(content);
        return $('.shopbox').addClass('shopbox-loaded');
      }
    };
    ShopBox.setTypeStyle = function(style) {
      return $('.shopbox').removeClass('shopbox-content shopbox-image shopbox-iframe').addClass(style);
    };
    ShopBox.loadFromUrl = function(urlOrContent, options, element) {
      var iframe, img, type, url;
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
          img.load(ShopBox.finishSpinner);
          img.attr('src', url);
          return window.img = img;
        case 'iframe':
          iframe = $('<iframe ></iframe>');
          iframe.hide();
          iframe.load(function(event) {
            iframe.show();
            return ShopBox.finishSpinner(event);
          });
          iframe.attr('src', url);
          return $('.shopbox .shopbox-content').append(iframe);
        default:
          return $('.shopbox .shopbox-content').html(urlOrContent);
      }
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
        return 'content';
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

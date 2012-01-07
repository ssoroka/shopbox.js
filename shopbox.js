(function() {
  var ShopBox;

  ShopBox = (function() {

    function ShopBox() {}

    ShopBox.box = null;

    ShopBox.template = '\
    <div class="shopbox shopbox-hidden">\
      <div class="shopbox-main">\
        <div class="shopbox-inner">\
          <a class="shopbox-close" href="#">Close</a>\
          <div class="shopbox-content"></div>\
        </div>\
      </div>\
    </div>\
  ';

    ShopBox.show = function(content) {
      $('.shopbox').removeClass('shopbox-hidden');
      return setTimeout((function() {
        return $(".shopbox").addClass("shopbox-visible");
      }), 0);
    };

    ShopBox.init = function() {
      if (!$('.shopbox').length > 0) {
        $('body').prepend(this.template);
        $('.shopbox-close').click(ShopBox.closeBox);
        $('body').bind('keydown', function(event) {
          if (event.which === 27) return ShopBox.closeBox();
        });
        return $('.shopbox').bind('click', function(event) {
          if (event.target === this) return ShopBox.closeBox();
        });
      }
    };

    ShopBox.closeBox = function(event) {
      if (event) event.preventDefault();
      return ShopBox.hide();
    };

    ShopBox.hide = function() {
      if (!$('.shopbox').hasClass('shopbox-visible')) return;
      $('.shopbox').removeClass('shopbox-visible');
      return $('.shopbox').transitionEnd(function() {
        return $('.shopbox').addClass('shopbox-hidden');
      });
    };

    ShopBox.setContent = function(content) {
      var contentbox;
      contentbox = $('.shopbox .shopbox-content');
      contentbox.html(content);
      if (content.match(/^\<img /)) {
        return this.setTypeStyle('image');
      } else if (content.match(/^\<iframe /)) {
        return this.setTypeStyle('iframe');
      } else {
        return this.setTypeStyle('content');
      }
    };

    ShopBox.setTypeStyle = function(style) {
      return $('.shopbox').removeClass('content image iframe').addClass(style);
    };

    ShopBox.getContent = function(urlOrContent, options, element) {
      if (urlOrContent === void 0) urlOrContent = element.attr('href');
      switch (options['type'] || this.typeFromUrl(urlOrContent)) {
        case 'image':
          return "<img src=\"" + urlOrContent + "\" />";
        case 'iframe':
          return "<iframe src=\"" + urlOrContent + "\"></iframe>";
        default:
          return urlOrContent;
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
    if (options == null) options = {};
    element = this;
    ShopBox.init();
    return element.click(function(event) {
      event.preventDefault();
      ShopBox.setContent(ShopBox.getContent(url, options, element));
      return ShopBox.show();
    });
  };

  jQuery.fn.transitionEnd = function(func) {
    return this.one('TransitionEnd webkitTransitionEnd transitionend oTransitionEnd', func);
  };

}).call(this);

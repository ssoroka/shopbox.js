# - Simple markup
# - Able to display HTML, iFrames and IMGs
# - Center's content based on it's size and re-sizes
#   large images to fit inside browser window
# - Displayed by CSS animation, no JS animation
# - pass in link, iframe, remote content, image
#
# shopbox class
class ShopBox
  @box = null

  @template = '<div id="shopbox" class="shopbox-hidden"><div id="shopbox-spinner" class="shopbox-spinner">Loading</div><span id="shopbox-loading-message">Click anywhere to close</span><div id="shopbox-main"><a id="shopbox-close" href="#">Close</a><div id="shopbox-content"></div></div></div>'

  @init = () ->
    if $('#shopbox').length == 0
      $('body').prepend @template

      ShopBox.wrapper = $('#shopbox')
      ShopBox.spinner = $('#shopbox-spinner')
      ShopBox.loading_message = $('#shopbox-loading-message')
      ShopBox.main = $('#shopbox-main')
      ShopBox.close = $('#shopbox-close')
      ShopBox.content = $('#shopbox-content')
      
      ShopBox.class_visible = 'shopbox-visible'
      ShopBox.class_hidden = 'shopbox-hidden' 
      ShopBox.class_loaded = 'shopbox-loaded'  

      # close on X click
      @close.click ShopBox.closeBox
      # close on escape
      $(window).bind 'keydown', (event) ->
        ShopBox.closeBox() if event.which == 27
      # close on click elsewhere
      $(@wrapper,@spinner).bind 'click', (event) ->
        if event.target == this
          ShopBox.closeBox()

  @show = (content) ->
    ShopBox.wrapper.removeClass(ShopBox.class_hidden)
    setTimeout (->
      ShopBox.wrapper.addClass ShopBox.class_visible
    ), 0

  @closeBox = (event) ->
    event.preventDefault() if event
    ShopBox.hide()

  @hide = () ->
    return unless ShopBox.wrapper.hasClass ShopBox.class_visible
    ShopBox.wrapper.removeClass ShopBox.class_visible
    ShopBox.wrapper.transitionEnd ->
      ShopBox.wrapper.addClass(ShopBox.class_hidden).removeClass ShopBox.class_loaded
      ShopBox.main.removeClass ShopBox.class_visible

  @startSpinner = () ->
    ShopBox.spinner.addClass ShopBox.class_visible
    ShopBox.loading_message.addClass ShopBox.class_visible
    ShopBox.main.removeClass ShopBox.class_visible

  @finishSpinner = (event) ->
    content = event.target || event
    ShopBox.loading_message.removeClass ShopBox.class_visible
    ShopBox.spinner.removeClass ShopBox.class_visible
    ShopBox.main.addClass ShopBox.class_visible
    ShopBox.content.html content
    ShopBox.wrapper.addClass ShopBox.class_loaded

  @setTypeStyle = (style) ->
    ShopBox.wrapper.removeClass('shopbox-html shopbox-image shopbox-iframe shopbox-video').addClass(style);

  @loadFromContent = (urlOrContent, options, element) ->
    if urlOrContent == undefined
      urlOrContent = element.attr 'href'
    type = options['type'] || @typeFromContent(urlOrContent)
    ShopBox.content.css({'width': '', 'height': ''})
    ShopBox.main.css({'margin-left': '', 'margin-top': ''})
    ShopBox.show()

    if type != 'content'
      url = "#{urlOrContent}?#{Math.random() * 1000000000000000000}"
      ShopBox.startSpinner()

    @setTypeStyle("shopbox-#{type}")
    switch type
      when 'image'
        img = $('<img />')
        img.load (event) ->
          ShopBox.setSize({height: options.height || @height, width: options.width || @width})
          ShopBox.finishSpinner event
        img.attr 'src', url
        window.img = img
      when 'iframe'
        iframe = $('<iframe></iframe>')
        iframe.hide()
        dimensions = {height: options.height || 400, width: options.width || 600}
        iframe.css(dimensions)
        ShopBox.setSize(dimensions)
        iframe.load (event) ->
          iframe.show()
          ShopBox.finishSpinner(event)
        iframe.attr 'src', url
        ShopBox.content.html iframe
      # when 'video'
      else
        div = $('<div />').css({display:'none'})
        dimensions = {height: options.height || 400, width: options.width || 600}
        ShopBox.content.html(div)
        div.ready () ->
          setTimeout (-> 
            ShopBox.setSize(dimensions)
            div.remove()
            ShopBox.finishSpinner(urlOrContent)
          ), 0
        div.html(urlOrContent)

  @setSize = (dimensions) ->
    max_width = document.width - 50
    max_height = document.height - 50
    dimensions.width = max_width if max_width < dimensions.width
    dimensions.height = max_height if max_height < dimensions.height

    ShopBox.content.css dimensions
    ShopBox.main.css({'margin-left': -dimensions.width / 2 - 10, 'margin-top': -dimensions.height / 2 - 10})

  image_exts = ['jpg', 'jpeg', 'png', 'bmp', 'gif']

  @typeFromContent = (urlOrContent) ->
    if urlOrContent.nodeType? || urlOrContent instanceof jQuery
        return 'object'
      ext = urlOrContent.split('.').pop().toLowerCase()
      if image_exts.indexOf(ext) >= 0
        return 'image'
      else if urlOrContent.match(/^https?\:\/\/\S+$/)
        return 'iframe'
      else
        return 'html'

window.ShopBox = ShopBox

# extend jQuery
jQuery.fn.shopbox = (urlOrContent, options = {}) ->
  elements = this
  ShopBox.init()
  elements.each (i, element) ->
    $(element).click (event) ->
      event.preventDefault()
      ShopBox.loadFromContent(urlOrContent, options, $(element))

jQuery.fn.transitionEnd = (func) ->
  @one 'TransitionEnd webkitTransitionEnd transitionend oTransitionEnd', func
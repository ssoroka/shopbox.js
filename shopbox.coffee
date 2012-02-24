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

  @init = () =>
    if $('#shopbox').length == 0
      $('body').prepend @template

      @wrapper = $('#shopbox')
      @spinner = @wrapper.find('#shopbox-spinner')
      @loading_message = @wrapper.find('#shopbox-loading-message')
      @main = @wrapper.find('#shopbox-main')
      @close = @main.find('#shopbox-close')
      @content = @main.find('#shopbox-content')
      
      @visible = 'shopbox-visible'
      @hidden = 'shopbox-hidden' 
      @loaded = 'shopbox-loaded'  

      # close on X click
      @close.click @closeBox
      # close on escape
      $(window).bind 'keydown', (event) =>
        @closeBox() if event.which == 27
      # close on click elsewhere
      $(@wrapper,@spinner).bind 'click', (event) =>
        if event.target == @wrapper[0]
          @closeBox()

  @show = (content) =>
    @wrapper.removeClass(@hidden)
    setTimeout (=>
      @wrapper.addClass @visible
    ), 0

  @closeBox = (event) =>
    event.preventDefault() if event
    @hide()

  @hide = () =>
    return unless @wrapper.hasClass @visible
    @wrapper.removeClass @visible
    @wrapper.transitionEnd =>
      @wrapper.addClass(@hidden).removeClass @loaded
      @main.removeClass @visible

  @startSpinner = () =>
    @spinner.addClass @visible
    @loading_message.addClass @visible
    @main.removeClass @visible

  @finishSpinner = (event) =>
    content = event.target || event
    @loading_message.removeClass @visible
    @spinner.removeClass @visible
    @main.addClass @visible
    @content.html content
    @wrapper.addClass @loaded

  @setTypeStyle = (style) =>
    @wrapper.removeClass('shopbox-html shopbox-image shopbox-iframe shopbox-video').addClass(style);

  @loadFromContent = (urlOrContent, options, element) =>
    if !urlOrContent?
      urlOrContent = element.attr 'href'
    type = options['type'] || @typeFromContent(urlOrContent)
    @content.css({'width': '', 'height': ''})
    @main.css({'margin-left': '', 'margin-top': ''})
    @show()

    if type != 'content'
      url = urlOrContent
      url = "#{url}?#{Math.random() * 1000000000000000000}" if options.cache == false

    @startSpinner()

    @setTypeStyle("shopbox-#{type}")
    console.log type
    switch type
      when 'image'
        img = $('<img />')
        img.hide()
        @content.html(img)
        img.load (event) =>
          @setSize({height: options.height || img.height(), width: options.width || img.width()})
          img.show()
          @finishSpinner event
        img.attr 'src', url
        window.img = img
      when 'iframe'
        iframe = $('<iframe></iframe>')
        iframe.hide()
        dimensions = {height: options.height || 400, width: options.width || 600}
        iframe.css(dimensions)
        @setSize(dimensions)
        iframe.load (event) =>
          iframe.show()
          @finishSpinner(event)
        iframe.attr 'src', url
        @content.html iframe
      # when 'video'
      else
        div = $('<div />')
        div.hide()
        @content.html(div)
        div.ready =>
          setTimeout (=> 
            @setSize(height: options.height || div.height(), width: options.width || div.width())
            div.remove()
            @finishSpinner(urlOrContent)
          ), 0
        div.html(urlOrContent)

  @setSize = (dimensions) =>
    max_width = document.width - 50
    max_height = document.height - 50
    dimensions.height ||= 400
    dimensions.width ||= 600
    dimensions.width = max_width if max_width < dimensions.width
    dimensions.height = max_height if max_height < dimensions.height
    console.log dimensions
    @content.css dimensions
    @main.css({'margin-left': -dimensions.width / 2 - 10, 'margin-top': -dimensions.height / 2 - 10})

  image_exts = ['jpg', 'jpeg', 'png', 'bmp', 'gif']

  @typeFromContent = (urlOrContent) =>
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
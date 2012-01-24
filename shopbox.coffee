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

  @template = '
    <div class="shopbox shopbox-hidden">
      <div class="shopbox-spinner"></div>
      <div class="shopbox-main">
        <div class="shopbox-inner">
          <a class="shopbox-close" href="#">Close</a>
          <div class="shopbox-content"></div>
        </div>
      </div>
    </div>
  '

  @init = () ->
    if $('.shopbox').length == 0
      $('body').prepend @template
      # close on X click
      $('.shopbox-close').click ShopBox.closeBox
      # close on escape
      $(window).bind 'keydown', (event) ->
        ShopBox.closeBox() if event.which == 27
      # close on click elsewhere
      $('.shopbox, .shopbox-spinner').bind 'click', (event) ->
        if event.target == this
          ShopBox.closeBox()

  @show = (content) ->
    $('.shopbox').removeClass('shopbox-hidden')
    setTimeout (->
      $(".shopbox").addClass "shopbox-visible"
    ), 0

  @closeBox = (event) ->
    event.preventDefault() if event
    ShopBox.hide()

  @hide = () ->
    return unless $('.shopbox').hasClass('shopbox-visible')
    $('.shopbox').removeClass('shopbox-visible')
    $('.shopbox').transitionEnd ->
      $('.shopbox').addClass('shopbox-hidden');
      $('.shopbox-main').removeClass('shopbox-visible');
      $('.shopbox').removeClass 'shopbox-loaded'

  @startSpinner = () ->
    $('.shopbox-spinner').addClass 'shopbox-visible'
    $('.shopbox-main').removeClass 'shopbox-visible'

  @finishSpinner = (event) ->
    content = event.target || event
    spinner = $('.shopbox-spinner')
    if spinner.hasClass('shopbox-visible')
      spinner.removeClass 'shopbox-visible'
    $('.shopbox-main').addClass 'shopbox-visible'
    $('.shopbox .shopbox-content').html content
    $('.shopbox').addClass 'shopbox-loaded'

  @setTypeStyle = (style) ->
    $('.shopbox').removeClass('shopbox-html shopbox-image shopbox-iframe shopbox-video').addClass(style);

  @loadFromContent = (urlOrContent, options, element) ->
    if urlOrContent == undefined
      urlOrContent = element.attr 'href'
    type = options.type || @typeFromContent(urlOrContent)
    $('.shopbox-content').css({width: '', height: ''})
    $('.shopbox-main').css({'margin-left': '', 'margin-top': ''})
    ShopBox.show()

    if type in ['image', 'iframe']
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
        $('.shopbox .shopbox-content').html iframe
      # when 'object' or 'html'
      else
        div = $('<div />').css({display:'none'})
        $('.shopbox .shopbox-content').html(div)
        div.ready () ->
          setTimeout (->
            ShopBox.setSize(height: options.height || div.height(), width: options.width || div.width())
            div.remove()
            ShopBox.finishSpinner(urlOrContent)
          ), 0
        div.html(urlOrContent)

  @setSize = (dimensions) ->
    max_width = document.width - 50
    max_height = document.height - 50
    dimensions.width = max_width if max_width < dimensions.width
    dimensions.height = max_height if max_height < dimensions.height

    content = $('.shopbox-content')
    content.css dimensions
    $('.shopbox-main').css({'margin-left': -dimensions.width / 2 - 10, 'margin-top': -dimensions.height / 2 - 10})

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

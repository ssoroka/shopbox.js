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
    <div class="shopbox-background shopbox-hidden">
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
    if $('.shopbox-background').length == 0
      $('body').prepend @template
      # close on X click
      $('.shopbox-close').click ShopBox.closeBox
      # close on escape
      $(window).bind 'keydown', (event) ->
        ShopBox.closeBox() if event.which == 27
      # close on click elsewhere
      $('.shopbox-background, .shopbox-spinner').bind 'click', (event) ->
        if event.target == this
          ShopBox.closeBox()

  @show = (content) ->
    $('.shopbox-background').removeClass('shopbox-hidden')
    setTimeout (->
      $(".shopbox-background").addClass "shopbox-visible"
    ), 0

  @closeBox = (event) ->
    event.preventDefault() if event
    ShopBox.hide()

  @hide = () ->
    return unless $('.shopbox-background').hasClass('shopbox-visible')
    $('.shopbox-background').removeClass('shopbox-visible')
    $('.shopbox-background').transitionEnd ->
      $('.shopbox-background').addClass('shopbox-hidden');
      $('.shopbox-main').removeClass('shopbox-visible');
      $('.shopbox-background').removeClass 'shopbox-loaded'
  
  @startSpinner = () ->
    $('.shopbox-spinner').addClass 'shopbox-visible'
    $('.shopbox-main').removeClass 'shopbox-visible'

  @finishSpinner = (event) ->
    content = event.target || event
    spinner = $('.shopbox-spinner')
    if spinner.hasClass('shopbox-visible')
      spinner.removeClass 'shopbox-visible'
    $('.shopbox-main').addClass 'shopbox-visible'
    $('.shopbox-background .shopbox-content').html content
    $('.shopbox-background').addClass 'shopbox-loaded'

  @setTypeStyle = (style) ->
    $('.shopbox-background').removeClass('shopbox-html shopbox-image shopbox-iframe shopbox-video').addClass(style);

  @loadFromUrl = (urlOrContent, options, element) ->
    if urlOrContent == undefined
      urlOrContent = element.attr 'href'
    type = options['type'] || @typeFromUrl(urlOrContent)
    $('.shopbox-content').css({width: '', height: ''})
    $('.shopbox-main').css({'margin-left': '', 'margin-top': ''})
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
        $('.shopbox-background .shopbox-content').html iframe
      # when 'video'
      else
        div = $('<div />').css({display:'none'})
        $('.shopbox-background .shopbox-content').html(div)
        div.ready () ->
          setTimeout (->
            $('.shopbox-main').css({'margin-left': -div.width() / 2 - 10, 'margin-top': -div.height() / 2 - 10})
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
      
  @typeFromUrl = (url) ->
    image_exts = ['jpg', 'jpeg', 'png', 'bmp', 'gif']
    ext = url.split('.').pop().toLowerCase()
    if image_exts.indexOf(ext) >= 0
      return 'image'
    else if url.match(/^https?\:\/\/\S+$/) 
      return 'iframe'
    else
      return 'html'
      
window.ShopBox = ShopBox

# extend jQuery    
jQuery.fn.shopbox = (url, options = {}) ->
  elements = this
  ShopBox.init()
  elements.each (i, element) ->
    $(element).click (event) -> 
      event.preventDefault()
      ShopBox.loadFromUrl(url, options, $(element))

jQuery.fn.transitionEnd = (func) ->
  @one 'TransitionEnd webkitTransitionEnd transitionend oTransitionEnd', func

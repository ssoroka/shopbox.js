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
    if !$('.shopbox').length > 0
      $('body').prepend @template
      # close on X click
      $('.shopbox-close').click ShopBox.closeBox
      # close on escape
      $('body').bind 'keydown', (event) ->
        ShopBox.closeBox() if event.which == 27
      # close on click elsewhere
      $('.shopbox').bind 'click', (event) ->
        if event.target == this
          ShopBox.closeBox()

  @show = (content) ->
    console.log 'show'
    $('.shopbox').removeClass('shopbox-hidden')
    setTimeout (->
      console.log 'show setTimeout'
      $(".shopbox").addClass "shopbox-visible"
    ), 0

  @closeBox = (event) ->
    event.preventDefault() if event
    $('.shopbox .shopbox-content').html('')
    ShopBox.hide()

  @hide = () ->
    return unless $('.shopbox').hasClass('shopbox-visible')
    $('.shopbox').removeClass('shopbox-visible')
    $('.shopbox').transitionEnd ->
      $('.shopbox').addClass('shopbox-hidden');
      $('.shopbox-main').removeClass('shopbox-visible');
  
  @startSpinner = () ->
    console.log 'startSpinner'
    $('.shopbox-spinner').addClass 'shopbox-visible'
    $('.shopbox-main').removeClass 'shopbox-visible'

  @finishSpinner = (event) ->
    console.log 'finishSpinner'
    content = event.target
    spinner = $('.shopbox-spinner')
    if spinner.hasClass('shopbox-visible')
      spinner.removeClass 'shopbox-visible'
      $('.shopbox-main').addClass 'shopbox-visible'
      console.log 'Setting content to:'
      console.log content
      $('.shopbox .shopbox-content').html content
      $('.shopbox').addClass 'shopbox-loaded'

  @setTypeStyle = (style) ->
    $('.shopbox').removeClass('shopbox-content shopbox-image shopbox-iframe').addClass(style);

  @loadFromUrl = (urlOrContent, options, element) ->
    if urlOrContent == undefined
      urlOrContent = element.attr 'href'
    type = options['type'] || @typeFromUrl(urlOrContent)
    ShopBox.show()

    if type != 'content'
      url = "#{urlOrContent}?#{Math.random() * 1000000000000000000}"
      ShopBox.startSpinner()

    @setTypeStyle("shopbox-#{type}")
    switch type
      when 'image'
        img = $('<img />')
        img.load ShopBox.finishSpinner
        img.attr 'src', url
        window.img = img
      when 'iframe'
        iframe = $('<iframe ></iframe>')
        iframe.hide()
        iframe.load (event) ->
          iframe.show()
          ShopBox.finishSpinner(event)
        iframe.attr 'src', url
        $('.shopbox .shopbox-content').append(iframe)
      # when 'video'
      else
        $('.shopbox .shopbox-content').html(urlOrContent)

    
  @typeFromUrl = (url) ->
    image_exts = ['jpg', 'jpeg', 'png', 'bmp', 'gif']
    ext = url.split('.').pop().toLowerCase()
    if image_exts.indexOf(ext) >= 0
      return 'image'
    else if url.match(/^https?\:\/\/\S+$/) 
      return 'iframe'
    else
      return 'content'
      
window.ShopBox = ShopBox

# extend jQuery    
jQuery.fn.shopbox = (url, options = {}) ->
  element = this
  ShopBox.init()
  element.click (event) -> 
    event.preventDefault()
    ShopBox.loadFromUrl(url, options, element)

jQuery.fn.transitionEnd = (func) ->
  @one 'TransitionEnd webkitTransitionEnd transitionend oTransitionEnd', func

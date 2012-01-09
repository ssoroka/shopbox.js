# - Simple markup
# - Able to display HTML, iFrames and IMGs
# - Center's content based on it's size and re-sizes
#   large images to fit inside browser window
# - Displayed by CSS animation, no JS animation
# - pass in link, iframe, remote content, image
#
# shopbox class
class ShopBox
  this.box = null

  this.template = '
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

  this.show = (content) ->
    $('.shopbox').removeClass('shopbox-hidden')
    setTimeout (->
      $(".shopbox").addClass "shopbox-visible"
      ShopBox.startSpinner()
    ), 0

  this.init = () ->
    if !$('.shopbox').length > 0
      $('body').prepend this.template
      # close on X click
      $('.shopbox-close').click ShopBox.closeBox
      # close on escape
      $('body').bind 'keydown', (event) ->
        ShopBox.closeBox() if event.which == 27
      # close on click elsewhere
      $('.shopbox').bind 'click', (event) ->
        if event.target == this
          ShopBox.closeBox()

  this.closeBox = (event) ->
    event.preventDefault() if event
    ShopBox.hide()

  this.hide = () ->
    return unless $('.shopbox').hasClass('shopbox-visible')
    $('.shopbox').removeClass('shopbox-visible')
    $('.shopbox').transitionEnd ->
      $('.shopbox').addClass('shopbox-hidden');
  
  this.setContent = (content) ->
    console.log 'setContent'
    ShopBox.show()
    contentbox = $('.shopbox .shopbox-content')
    hiddenbox = $(content)
    # hiddenbox.html content
    # hiddenbox.load this.finishSpinner content
    setTimeout (->
      hiddenbox.load ShopBox.finishSpinner hiddenbox
    ), 0


    if content.match /^\<img /
      this.setTypeStyle('shopbox-image')
    else if content.match /^\<iframe /
      this.setTypeStyle('shopbox-iframe')
    else
      this.setTypeStyle('shopbox-content')

  this.startSpinner = () ->
    spinner = $('.shopbox-spinner')
    if !spinner.hasClass('shopbox-visible')
      spinner.addClass 'shopbox-visible'

  this.finishSpinner = (content) ->
    spinner = $('.shopbox-spinner')
    if spinner.hasClass('shopbox-visible')
      spinner.removeClass 'shopbox-visible'
      $('.shopbox .shopbox-content').html content
      $('.shopbox').addClass 'shopbox-loaded'

  this.setTypeStyle = (style) ->
    $('.shopbox').removeClass('shopbox-content shopbox-image shopbox-iframe').addClass(style);

  this.getContent = (urlOrContent, options, element) ->
    if urlOrContent == undefined
      urlOrContent = element.attr 'href'
    switch options['type'] || this.typeFromUrl(urlOrContent)
      when 'image'
        return "<img src=\"#{urlOrContent}\" />"
      when 'iframe'
        return "<iframe src=\"#{urlOrContent}\"></iframe>"
      else
        return urlOrContent
    
  this.typeFromUrl = (url) ->
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
    ShopBox.setContent ShopBox.getContent(url, options, element)

jQuery.fn.transitionEnd = (func) ->
  this.one 'TransitionEnd webkitTransitionEnd transitionend oTransitionEnd', func

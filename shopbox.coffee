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
    <div class="shopbox" >
      <a class="shopbox-close-button" href="#">x</a>
      <div class="shopbox-content">
      </div>
    </div>
  '
  this.show = (content) ->
    $('.shopbox').show()
    setTimeout (->
      $(".shopbox").addClass "shopbox-visible"
    ), 0     

  this.init = (url, options) ->
    if !$('.shopbox').length > 0
      $('body').prepend this.template
      $('.shopbox-close-button').click (event) ->
        event.preventDefault()
        ShopBox.hide()

  this.hide = () ->
    $('.shopbox').removeClass('shopbox-visible')
    $('.shopbox').bind 'webkitTransitionEnd', () ->
      $('.shopbox').unbind 'webkitTransitionEnd'
      $('.shopbox').hide();
  
  this.setContent = (content) ->
    $('.shopbox .shopbox-content').html content

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

# extend jQuery    
jQuery.fn.shopbox = (url, options = {}) ->
  element = this
  ShopBox.init(url, options)
  element.click (event) -> 
    event.preventDefault()
    # event.stopPropagation()
    ShopBox.setContent ShopBox.getContent(url, options, element)
    ShopBox.show()


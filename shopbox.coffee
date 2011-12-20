# - Simple markup
# - Able to display HTML, iFrames and IMGs
# - Center's content based on it's size and re-sizes
#   large images to fit inside browser window
# - Displayed by CSS animation, no JS animation
# - pass in link, iframe, remote content, image
#
# shopbox class
class ShopBox
  this.template = '
    <div class="shopbox">
      <a class="shopbox-close-button" href="#">x</a>
      <div class="shopbox-content">
        {{content}}
      </div>
    </div>
  '
  this.show = (content) ->
    $('body').prepend this.template.replace('{{content}}', content)
    # close button click event binding
    $('.shopbox-close-button').click ->
      $('.shopbox').remove();


  this.getContent = (urlOrContent, options) ->
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
  box = this
  box.click (event) -> 
    content = ShopBox.getContent url, options
    ShopBox.show content
    event.preventDefault()

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
    
  this.getContent = (url, options) ->
    switch options['type'] || typeFromUrl(url)
      when 'image'
        return "<img src=\"#{url}\" />"
      when 'iframe'
        return "<iframe src=\"#{url}\"></iframe>"
    
  this.typeFromUrl = (url) ->
    switch url.split('.').last()
      when 'jpg', 'jpeg', 'png', 'bmp', 'gif'
        return 'image'
      else 
        return 'iframe'



# extend jQuery    
jQuery.fn.shopbox = (url, options) ->
  box = this
  box.click (event) -> 
    content = ShopBox.getContent url, options
    ShopBox.show content
    event.preventDefault()

# close button click event binding
$('.shopbox-close-button').bind 'click', (e) ->
  $('.shopbox').remove();

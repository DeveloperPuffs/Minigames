
// No image storage anymore sry :(
screen.drawSpriteWithColor = function(sprite, x, y, width, height, color)
  local image = new Image(width, height, true)
  
  image.drawSprite(sprite, 0, 0, width, height)
  image.setBlending('source-in')
  image.fillRect(0, 0, width, height, color)
  
  screen.drawImage(image, x, y, width, height)
  
  return image
end



Brush = class
  constructor = function()
    this.name = "Brush"
    
    global.cursor = new Cursor("brush", 4, 4, 8, 8, false)
    this.canShoot = true
  end
  
  update = function()
    if mouse.press and this.canShoot then
      local angle = atan2d(mouse.y - global.player.y, mouse.x - global.player.x)
      local paintball = new Circle()
      paintball.x = global.player.x
      paintball.y = global.player.y
      paintball.width = global.player.width / 4
      paintball.height = global.player.height / 4
      paintball.radius = (paintball.width + paintball.height) / 4
      
      if paintball.collision() then
        global.shapes.removeElement(paintball)
        return
      end
      
      local hue = random.integerRange(0, 360)
      local lightness = random.integerRange(50, 75)
      paintball.fillColor = "hsl(" + hue + ", 100%, " + lightness + "%)"
      paintball.lineColor = "hsl(" + hue + ", 100%, " + lightness + "%)"
      
      paintball.vx = 2 * cosd(angle)
      paintball.vy = 2 * sind(angle)
      paintball.parent = global.player
      global.camera.shake(true)
      audio.playSound("shoot")
      
      this.canShoot = false
      after 0.2 seconds do this.canShoot = true end
    end
  end
  
  draw = function()
  end
end


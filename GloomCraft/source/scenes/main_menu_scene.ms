
global.MainMenuScene = class
  constructor = function(name)
    this.name = name
    
    this.light = new global.Light(0, 0, 0, 360)
    this.glow = new global.Glow(2048)
    
    this.dungeon = new global.Dungeon(30, 30, 3, 4, 100)
    this.dungeon.layers = global.getLayers(this.dungeon)
    this.dungeon.surfaces = global.getSurfaces(this.dungeon)
    
    this.angle = 0
    this.time = 0
    this.lift = 20
    this.sx = 1
    this.sy = 1
    
    this.playButton = new global.Button(
      0, -36, 100, 20, function(x, y)
        screen.setLineWidth(1)
        screen.fillRect(x, y, 100, 20, "#8d9199")
        screen.drawRect(x, y, 100, 20, "#2a2d38")
        screen.drawText("Play", x, y, 12, "2a2d38")
      end, function()
        local transition = function()
          global.sceneManager.setScene(global.SceneManager.GAME)
        end
        
        global.transition.requestTransition(transition, function() end, 1)
      end
    )
    
    this.instructionsButton = new global.Button(
      0, -60, 100, 20, function(x, y)
        screen.setLineWidth(1)
        screen.fillRect(x, y, 100, 20, "#8d9199")
        screen.drawRect(x, y, 100, 20, "#2a2d38")
        screen.drawText("Instructions", x, y, 12, "2a2d38")
      end, function()
        local transition = function()
          global.sceneManager.setScene(global.SceneManager.INSTRUCTIONS)
        end
        
        global.transition.requestTransition(transition, function() end, 1)
      end
    )
  end
  
  update = function()
    this.playButton.update()
    this.instructionsButton.update()
    this.time += global.clock.deltaTime
    this.angle = 2 * cos(this.time / 2)
    this.lift = 20 + (4 * sin(this.time * 1.5))
    this.sx = 1 + (0.05 * cos(this.time))
    this.sy = 1 + (0.05 * sin(this.time))
  end
  
  draw = function()
    local tx = this.dungeon.columns * -8
    local ty = this.dungeon.rows * -8
    screen.setTranslation(tx, ty)
    
    local ground = this.dungeon.layers.ground
    screen.drawImage(ground, ground.width / 2, ground.height / 2, ground.width, ground.height)
    
    local walls = this.dungeon.layers.walls
    screen.drawImage(walls, walls.width / 2, walls.height / 2, walls.width, walls.height)
    
    this.light.x = mouse.x - tx
    this.light.y = mouse.y - ty
    screen.drawShadows(this.light, this.dungeon.surfaces, 1)
    screen.setTranslation(0, 0)
    
    screen.fillRect(0, 0, screen.width, screen.height, "rgba(0, 0, 0, 0.4)")
    
    screen.setDrawRotation(this.angle)
    screen.setDrawScale(this.sx * 6, this.sy * 1.5)
    this.glow.draw(0, this.lift, 64, "white", 0.5)
    
    screen.setDrawScale(this.sx, this.sy)
    screen.drawSprite("title", 0, this.lift, 490 / 2, 135 / 2)
    screen.setDrawScale(1, 1)
    screen.setDrawRotation(0)
    
    this.playButton.draw()
    this.instructionsButton.draw()
    
    screen.drawText("Your Highscore: " + global.highScore, 0, -80, 8, 999)
  end
end


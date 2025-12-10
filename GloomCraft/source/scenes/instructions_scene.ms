
global.InstructionsScene = class
  constructor = function(name)
    this.name = name
    this.slide = 0
    this.displaySlide = 0
    this.speed = 0.1
    this.slides = [this.drawDescriptionSlide, this.drawControlsSlide]
    
    this.backToMainMenuButton = new global.Button(
      0, -80, 160, 20, function(x, y)
        screen.setLineWidth(1)
        screen.fillRect(x, y, 160, 20, "#8d9199")
        screen.drawRect(x, y, 160, 20, "#2a2d38")
        screen.drawText("Back to Main Menu", x, y, 12, "2a2d38")
      end, function()
        local transition = function()
          global.sceneManager.setScene(global.SceneManager.MAIN_MENU)
        end
        
        global.transition.requestTransition(transition, function() end, 1)
      end
    )
    
    this.slideLeftButton = new global.Button(
      -160, 0, 10, 20, function(x, y)
        screen.setLineWidth(1)
        screen.fillRect(x, y, 10, 20, "#8d9199")
        screen.drawRect(x, y, 10, 20, "#2a2d38")
        screen.drawText("<", x, y, 12, "2a2d38")
      end, function() global.sceneManager.scene.slideBy(-1) end
    )
    
    this.slideRightButton = new global.Button(
      160, 0, 10, 20, function(x, y)
        screen.setLineWidth(1)
        screen.fillRect(x, y, 10, 20, "#8d9199")
        screen.drawRect(x, y, 10, 20, "#2a2d38")
        screen.drawText(">", x, y, 12, "2a2d38")
      end, function() global.sceneManager.scene.slideBy(1) end
    )
  end
  
  update = function()
    this.backToMainMenuButton.update()
    this.slideLeftButton.update()
    this.slideRightButton.update()
    this.displaySlide += (this.slide - this.displaySlide) * this.speed
  end
  
  draw = function()
    this.backToMainMenuButton.draw()
    
    if this.slide then this.slideLeftButton.draw() end
    if not (this.slide == this.slides.length - 1) then
      this.slideRightButton.draw()
    end
    
    for index = 0 to this.slides.length - 1
      local translation = (this.displaySlide - index) * -356
      screen.setTranslation(translation, 0)
      this.slides[index]()
    end
    
    screen.setTranslation(0, 0)
  end
  
  drawDescriptionSlide = function()
    screen.drawText("Description", 0, 80, 16, 999)
    
    local lines = [
      "GloomCraft is a roguelike/roguelite game about" +
      "exploring dungeons and fighting monsters for",
      "ressources. The main goal of the game is to travel" +
      "through as many dungeons as possible in one run."
      "The further you go, the bigger the dungeons get.", "",
      "This game has been made in 14 days for the Pirate" +
      "Software Game Jam #15. All of the assets",
      "(code, sprites, sounds, music, images, font) used in"+
      "this game have been made by the game", "developer."
    ]
    
    screen.setDrawAnchor(-1, 0)
    local height = 50
    for line in lines
      screen.drawText(line, -144, height, 6, 999)
      height -= 10
    end
    
    screen.setDrawAnchor(0, 0)
  end
  
  drawControlsSlide = function()
    screen.drawText("Controls", 0, 80, 16, 999)
    
    local lines = [
      "Basic Movement: Arrow keys or WASD keys to move" +
      "(or ZSQD on the AZERTY keyboard)",
      "Rolling: Space, Left Shift, or Right Shift." +
      "Rolling allows you to travel fast in one direction. You are",
      "invincible while rolling.", "",
      "Fighting: Move your mouse to aim. Left click to shoot.",
      "Potions: Left click to drink, right click to throw away.", "",
      "Inventory: Use the digit keys or click" +
      "on the corresponding slot to select and equipment.",
      "Pouch: Material gathered from the game will go into the pouch.",
      "Press 'Z' to show or hide the pouch."
    ]
    
    screen.setDrawAnchor(-1, 0)
    local height = 50
    for line in lines
      screen.drawText(line, -144, height, 6, 999)
      height -= 10
    end
    
    screen.setDrawAnchor(0, 0)
  end
  
  slideBy = function(amount)
    this.slide = min(max(this.slide + amount, 0), this.slides.length - 1)
  end
end


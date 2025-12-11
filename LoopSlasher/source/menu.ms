MainMenuScene = class
  constructor = function()
    global.requestMusic("menu", 0.5)

    this.background = new Background()
    this.selectionGlow = new glow(256)
    this.transitioning = false
    this.selectionIndex = 0
    this.textFloat = 0
  end
  
  update = function(deltaTime)
    this.textFloat = sin(system.time() / 250) * 2

    local direction = keyboard.press.UP - keyboard.press.DOWN
    if direction then
      audio.playSound("click", 2)
    end

    this.selectionIndex -= direction
    if this.selectionIndex < 0 then
      this.selectionIndex = 2
    elsif this.selectionIndex > 2 then
      this.selectionIndex = 0
    end

    if keyboard.press.ENTER then
      if not this.transitioning then
        if this.selectionIndex == 0 then
          local transitionAction = function()
            global.currentScene = new GameScene()
          end
    
          if global.transition.requestTransition(transitionAction, false, 1) then
            this.transitioning = true
            audio.playSound("click", 2)
          end
        elsif this.selectionIndex == 2 then
          local transitionAction = function()
            global.currentScene = new HelpScene()
          end
    
          if global.transition.requestTransition(transitionAction, false, 1) then
            this.transitioning = true
            audio.playSound("click", 2)
          end
        end
      end
    end
    
    if this.selectionIndex == 1 then
      local direction = keyboard.press.RIGHT - keyboard.press.LEFT
      local graphicsModeBefore = global.graphicsMode
      global.graphicsMode = min(max(global.graphicsMode + direction, 0), 2)
      if graphicsModeBefore != global.graphicsMode then
        audio.playSound("click", 2)
      end
    end
  end
  
  draw = function()
    this.background.draw()
    screen.setAlpha(0.5)
    CRT(1000, 0, 0)
    screen.setAlpha(1)

    screen.setDrawRotation(this.textFloat / 2)
    screen.drawTextOutlined("Slasher", 50, 60, 36, "white", "black")
    screen.setDrawRotation(-this.textFloat / 2)
    screen.drawTextOutlined("Loop", -65, 60, 36, rgb(236, 198, 255), rgb(20, 3, 33))
    screen.resetDrawRotation()
    
    screen.setDrawScale(20, 1)
    this.selectionGlow.draw(0, 10 + this.selectionIndex * -20, 20, "white", 0.25)
    screen.resetDrawScale()
    
    local size1 = if this.selectionIndex == 0 then 16 else 12 end
    local size2 = if this.selectionIndex == 1 then 16 else 12 end
    local size3 = if this.selectionIndex == 2 then 16 else 12 end
      
    local graphicsTexts = ["[ Low ]", "[ Medium ]", "[ High ]"]

    screen.drawTextOutlined("Play", 0, 10, size1, "white", "black")
    screen.drawTextOutlined("Graphics: " + graphicsTexts[global.graphicsMode], 0, -10, size2, "white", "black")
    screen.drawTextOutlined("How to play", 0, -30, size3, "white", "black")
    
    if this.selectionIndex == 1 then
      screen.setLineWidth(1.5)

      if global.graphicsMode != global.GRAPHICS_LOW then
        screen.drawTextOutlined("<", -100 - this.textFloat / 2, -10, 18, "white", "black")
      end
  
      if global.graphicsMode != global.GRAPHICS_HIGH then
        screen.drawTextOutlined(">", 100 + this.textFloat / 2, -10, 18, "white", "black")
      end

      screen.resetLineWidth()
    end
    
    local texts = [
      "Press enter to play",
      "Press <- or -> on keyboard to change",
      "Press enter for more information"
    ]
    
    local y = this.textFloat + 30 - screen.height / 2
    screen.drawTextOutlined(texts[this.selectionIndex], 0, y, 16, "white", "black")
    screen.drawTextOutlined("Press the up and down arrows on the keyboard to change options", 0, y - 12, 8, "white", "black")
  end
end
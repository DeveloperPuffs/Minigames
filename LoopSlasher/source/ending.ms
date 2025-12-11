EndingScene = class
  constructor = function(gameStatistics)
    global.requestMusic("menu", 0.5)

    this.background = new Background()
    this.gameStatistics = gameStatistics
    this.transitioning = false
    this.textFloat = 0
  end
  
  update = function(deltaTime)
    this.textFloat = sin(system.time() / 250) * 2
    
    if keyboard.press.ENTER then
      if this.transitioning then
        return
      end

      local transitionAction = function()
        global.currentScene = new MainMenuScene()
      end
  
      if global.transition.requestTransition(transitionAction, false, 1) then
        this.transitioning = true
        audio.playSound("click", 2)
      end
    end
  end
  
  draw = function()
    this.background.draw()
    screen.setAlpha(0.5)
    CRT(1000, 0, 0)
    screen.setAlpha(1)

    screen.drawTextOutlined("Game Over", 0, 60, 36, "white", "black")
    
    local stats = this.gameStatistics
    local killsPerTrail = round(10 * stats.enemyKills / stats.trailsDrawn) / 10
    if killsPerTrail != stats.enemyKills / stats.trailsDrawn then
      killsPerTrail = "~" + killsPerTrail
    end

    screen.drawTextOutlined("Time survived: " + stats.timeText, 0, 15, 16, "white", "black")
    screen.drawTextOutlined("Kills per trail: " + killsPerTrail, 0, 0, 12, "white", "black")
    screen.drawTextOutlined("Enemies killed: " + stats.enemyKills, 0, -15, 12, "white", "black")
    screen.drawTextOutlined("Breakdown:", 0, -36, 8, "white", "black")

    local width = 2.5 * global.TILE_SIZE
    local enemyCount = stats.enemiesBreakdown.length
    local first = -screen.width / 2 + (screen.width - width * enemyCount) / 2
    for index = 0 to enemyCount - 1
      local enemyData = stats.enemiesBreakdown[index]
      local text = if enemyData.kills >= 1000 then ">999" else enemyData.kills end
      local left = first + width * index
      
      screen.setDrawAnchor(-1, 0)
      screen.drawSprite(enemyData.sprite, left, -50, 12, 12)
      screen.drawTextOutlined(text, left + 16, -50, 12, "white", "black")
      screen.resetDrawAnchor()
    end

    local y = this.textFloat + 20 - screen.height / 2
    screen.drawTextOutlined("Press enter to continue", 0, y, 16, "white", "black")
  end
end

Reward = class
  constructor = function()
    global.timer.freeze = true
    
    this.alpha = 0
    this.tween = TweenService.newTween(this, "alpha", 0, 1, 1, Tween.sineInOut)
    
    this.timeReward = Reward.generateTimeReward()
    this.moneyReward = Reward.generateMoneyReward()
  end
  
  update = function()
    local dismiss = function()
      global.gotReward = true
      audio.playSound("click", 0.5)
      if this.tween then TweenService.removeTween(this.tween) end
      this.tween = TweenService.newTween(this, "alpha", 1, 0, 1, Tween.sineInOut, function()
        global.timer.freeze = false
        global.reward = 0
      end)
    end
    
    if global.gotReward then return end
    if keyboard.press.DIGIT_1 then
      global.timer.travel(this.timeReward.time)
      dismiss()
    elsif keyboard.press.DIGIT_2 then
      global.balance += this.moneyReward.money
      dismiss()
    end
  end
  
  draw = function()
    screen.setTranslation(0, 0)
    screen.setAlpha(this.alpha / 2)
    screen.fillRect(0, 0, screen.width, screen.height, 0)
    screen.setAlpha(this.alpha)
    screen.setFont("plasmapuffs")
    screen.drawText("Treasure Chest", 0, 40, 12, 999)
    
    this.drawReward(1, this.timeReward, -60)
    this.drawReward(2, this.moneyReward, 60)
    
    screen.setAlpha(1)
  end
  
  drawReward = function(slot, reward, x)
    screen.setAlpha(this.alpha / 2)
    screen.setLineDash([4, 2])
    screen.setLineWidth(0.8)
    screen.drawRoundRect(x, -10, 100, 60, 1, 999)
    screen.setLineWidth(1)
    screen.setLineDash([0, 0])
    screen.setAlpha(this.alpha)
    
    if not reward then return end
    local splitText = function(text, chunk)
      local all = []
      local current = ""
      for character in text
        if current.length >= chunk and character == " " then
          all.push(current)
          current = ""
        else current += character end
      end
      
      all.push(current)
      return all
    end
    
    local y = 10
    
    for line in splitText(reward.name, 5)
      screen.drawText(line, x, y, 4, 999)
      y -= 8
    end
    
    for line in splitText(reward.description, 10)
      screen.drawText(line, x, y, 2, 999)
      y -= 4
    end
    
    screen.drawText("Press " + slot + "to select.", x, -30, 2, 999)
  end
end

Reward.generateTimeReward = function()
  local number = floor(global.timer.currentTime / 5)
  
  return object
      name = "Time Travel"
      description = "Go back in time by " + number + " minutes."
      time = number
  end
end

Reward.generateMoneyReward = function()
  local number = (5 * (global.balance + 1)) + random.nextInt(global.balance)
  
  return object
    name = "Profitable"
    description = "Earn $" + number + "dollars."
    money = number
  end
end




Timer = class
  constructor = function()
    this.freeze = false
    this.currentTime = 6 * 60
    this.timeSpeed = 6
  end
  
  update = function()
    if this.freeze then return end
    
    this.currentTime += system.deltaTime * this.timeSpeed
    if this.currentTime >= 1260 then
      global.setState(global.states.GAME_OVER)
      this.freeze = true
    end
  end
  
  draw = function(balance)
    local string = this.getTimeString() + " - " + balance
    screen.setTranslation(0, 0)
    screen.setFont("plasmapuffs")
    screen.setLineWidth(4)
    screen.drawTextOutline(string, 0, (screen.height / 2) - 10, 8, 0)
    screen.drawText(string, 0, (screen.height / 2) - 10, 8, 999)
    screen.setLineWidth(1)
  end
  
  getTimeString = function()
    local totalMinutes = this.currentTime
    local hours = floor(totalMinutes / 60)
    local minutes = floor(totalMinutes % 60)
    
    local period = if hours >= 12 then "PM" else "AM" end
    
    if period == "PM" and hours > 12 then hours = hours - 12
    elsif period == "AM" and hours == 0 then hours = 12 end
      
    local hoursString = "" + hours
    if hoursString.length == 1 then hoursString = "0" + hoursString end
    
    local minutesString = "" + minutes
    if minutesString.length == 1 then minutesString = "0" + minutesString end
    
    return hoursString + ":" + minutesString + period
  end
  
  travel = function(minutes)
    this.currentTime = this.currentTime - minutes
  end
end


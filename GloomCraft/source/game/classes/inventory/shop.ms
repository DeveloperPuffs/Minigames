
global.Shop = class
  instructions = "Left click on items to buy. Press 'E' to close the shop."
  
  constructor = function(game, parent)
    this.game = game
    this.parent = parent
    
    this.showing = false
    this.tween = false
    this.offset = 200
    
    this.stand = false
    this.columns = 5
    this.rows = 3
  end
  
  update = function()
  end
  
  draw = function()
    screen.setTranslation(0, this.offset - 60)
    screen.setDrawAnchor(-1, -1)
    screen.drawSprite("planks/half", 8, 0, 164, 152)
    
    screen.setLineWidth(4)
    screen.drawTextOutline("Shop Stand", 16, 136, 8, "#210f07")
    screen.drawText("Shop Stand", 16, 136, 8, 999)
    
    screen.setLineWidth(2)
    screen.drawTextOutline(global.Shop.instructions, 64, 136, 4, "#210f07")
    screen.drawText(global.Shop.instructions, 64, 136, 4, 999)
    
    if not this.stand then
      screen.setDrawAnchor(0, 0)
      screen.setTranslation(0, 0)
      return
    end
    
    local index = 0
    for row = this.rows - 1 to 0 by - 1
      for column = 0 to this.columns - 1
        if this.stand.data.length <= index then continue end
        local item = this.stand.data[index]
        
        local ineligible = false
        if item[1] > this.game.player.balance then
          ineligible = "Not enough money."
        elsif this.parent.slots.full then
          ineligible = "Inventory full."
        end
        
        local x = ((column + 0.5) * 24) + (column * 6) + 8
        local y = ((row + 1.5) * 24) + (row * 16) - 12
        
        local sx = x + 8
        local sy = y + this.offset - 48
        
        local hovering = global.cursor.hover(sx, sy, 24, 24)
        if hovering then
          if ineligible then
            local text = item[0].name + " (" + ineligible + ")"
            global.cursor.tooltip = [text, ["#210f07", "#de4040"]]
          else
            global.cursor.tooltip = [item[0].name, ["#210f07", "#995940"]]
          end
        end
        
        if global.cursor.click(sx, sy, 24, 24) and not ineligible then
          if this.game.player.balance >= item[1] then
            audio.playSound("transaction", 0.1)
            this.game.player.balance -= item[1]
            this.parent.slots.push(item[0])
            this.stand.data.removeElement(item)
          end
        end
        
        local sprite = "slots/wooden/"
        sprite += if hovering then "hover" else "idle" end
        screen.drawSprite(sprite + "_24", x, y, 24, 24)
        item[0].paint(x + (item[0].width / 4), y + 1 + (item[0].height / 4))
        
        if ineligible then
          screen.setAlpha(0.4)
          screen.drawSpriteWithColor(sprite + "_24", x, y, 24, 24, "black")
          screen.setAlpha(1)
        end
        
        local color = 999
        if ineligible == "Not enough money." then color = "#de4040" end
        
        screen.setDrawAnchor(0, 0)
        screen.setLineWidth(3)
        screen.drawTextOutline("$" + item[1], x + 12, y - 2, 6, "#210f07")
        screen.drawText("$" + item[1], x + 12, y - 2, 6, color)
        screen.setDrawAnchor(-1, -1)
        
        index += 1
      end
    end
    
    screen.setDrawAnchor(0, 0)
    screen.setTranslation(0, 0)
  end
  
  setVisibility = function(showing)
    if showing == this.showing then return end
    if this.tween then global.tweenService.removeTween(this.tween) end
    
    this.showing = showing
    local newOffset = if this.showing then 0 else 200 end
    this.tween = global.tweenService.createTween(
      this, "offset", this.offset, newOffset, 0.5, global.Easing.quadInOut
    )
  end
end


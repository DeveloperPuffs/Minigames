
global.Description = class
  constructor = function(game, parent)
    this.game = game
    this.parent = parent
    
    this.showing = false
    this.tween = false
    this.offset = 200
  end
  
  update = function()
  end
  
  draw = function()
    screen.setTranslation(-178, this.offset + 20)
    screen.setDrawAnchor(-1, -1)
    screen.drawSprite("book", 8, 0, 164, 72)
    
    local equipment = this.parent.slots.current
    if equipment.type == "number" then
      screen.drawText("[No Equipment]", 24, 40, 8, "#210f09")
    else
      screen.drawText(equipment.name, 24, 58, 8, "#210f09")
      
      local width = screen.textWidth(equipment.name, 8)
      screen.drawText("Hover on Icon", 26 + width, 62, 3, "#210f09")
      screen.drawText("to View Stats", 26 + width, 58, 3, "#210f09")
      
      local index = 0
      for row = 2 to 0 by - 1
        for column = 0 to 3
          if equipment.data.length <= index then continue end
          local d = equipment.data[index]
          
          local x = 24 + (column * 14)
          local y = 18 + (row * 14)
          
          screen.drawSprite("icons/" + d[1], x, y, 12, 12)
          
          local cx = x + 6 - 178
          local cy = y + 6 + 20
          if global.cursor.hover(cx, cy, 12, 12, false) then
            local text = d[0] + ": " + d[2]
            global.cursor.tooltip = [text, ["#210f07", "#995940"]]
          end
          
          index += 1
        end
      end
    end
    
    local ingredient = false
    if this.parent.state == global.Inventory.TABLE then
      if this.parent.table.drag then
        if this.parent.table.drag.identifier == "ingredient" then
          ingredient = this.parent.table.drag
        end
      end
      
      if not ingredient and this.parent.hovering then
        if this.parent.hovering.identifier == "ingredient" then
          ingredient = this.parent.table.hovering
        end
      end
    end
    
    if not ingredient then ingredient = this.parent.pouch.hovering end
    if ingredient then
      screen.drawText(ingredient.name, 98, 58, 8, "#210f09")
      
      local height = 58
      for line in ingredient.description.split("\n")
        height -= 6
        screen.drawText(line, 98, height, 3, "#210f09")
      end
    else
      screen.drawText("Stats", 98, 58, 8, "#210f09")
      local width = screen.textWidth("Stats", 8)
      screen.drawText("Hover on Icon", 100 + width, 62, 3, "#210f09")
      screen.drawText("to View Stats", 100 + width, 58, 3, "#210f09")
      
      local player = this.parent.parent
      screen.drawText("Balance: $" + player.balance, 98, 54, 3)
      
      local lifeBar = player.lifeBar
      local life = "Life: " + round(lifeBar.current) + "/" + lifeBar.total
      screen.drawText(life, 98, 50, 3)
      
      local manaBar = player.manaBar
      local mana = "Mana: " + round(manaBar.current) + "/" + manaBar.total
      screen.drawText(mana, 98, 46, 3)
      
      local index = 0
      for row = 2 to 0 by - 1
        for column = 0 to 3
          if player.data.length <= index then continue end
          local d = player.data[index]
          
          local x = 98 + (column * 14)
          local y = 4 + (row * 14)
          
          screen.drawSprite("icons/" + d[1], x, y, 12, 12)
          
          local cx = x + 6 - 178
          local cy = y + 6 + 20
          if global.cursor.hover(cx, cy, 12, 12, false) then
            local text = d[0] + ": " + d[2]
            global.cursor.tooltip = [text, ["#210f07", "#995940"]]
          end
          
          index += 1
        end
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


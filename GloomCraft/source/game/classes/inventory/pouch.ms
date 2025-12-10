
global.Pouch = class
  constructor = function(game, parent)
    this.game = game
    this.parent = parent
    
    this.showing = false
    this.tween = false
    this.offset = 200
    
    this.data = []
    this.page = 0
    this.columns = 6
    this.rows = 2
    this.hovering = false
    
    this.scaleLeft = 1
    this.scaleRight = 1
  end
  
  update = function()
    this.hovering = false
  end
  
  draw = function()
    screen.setTranslation(-178, this.offset - 60)
    screen.setDrawAnchor(-1, -1)
    screen.drawSprite("planks/quarter", 8, 0, 164, 72)
    
    screen.setLineWidth(4)
    screen.drawTextOutline("Pouch", 16, 56, 8, "#210f07")
    screen.drawText("Pouch", 16, 56, 8, 999)
    
    if this.parent.state == global.Inventory.IDLE then
      local closeText = "Press 'Z' to close the pouch."
      screen.setLineWidth(2)
      screen.drawTextOutline(closeText, 48, 56, 4, "#210f07")
      screen.drawText(closeText, 48, 56, 4, 999)
    end
    
    screen.setDrawAnchor(0, 0)
    
    if this.page then
      screen.setDrawScale(-1 * this.scaleLeft, this.scaleLeft)
      screen.drawSprite("arrow", 20, 36, 16, 16)
      if global.cursor.hover(20 - 178, 36 + this.offset - 60, 16, 16) then
        global.cursor.tooltip = ["Previous Page", ["#210f07", "#995940"]]
        this.scaleLeft += ((1.1 - this.scaleLeft) * 0.1)
        if mouse.press then
          this.scaleLeft = 0.8
          this.page -= 1
        end
      else this.scaleLeft += ((1 - this.scaleLeft) * 0.1) end
    else this.scaleLeft = 1 end
    
    if data.length > (this.page + 1) * this.columns * this.rows then
      screen.setDrawScale(this.scaleRight, this.scaleRight)
      screen.drawSprite("arrow", 160, 36, 16, 16)
      if global.cursor.hover(160 - 178, 36 + this.offset - 60, 16, 16) then
        global.cursor.tooltip = ["Next Page", ["#210f07", "#995940"]]
        this.scaleRight += ((1.1 - this.scaleRight) * 0.1)
        if mouse.press then
          this.scaleRight = 0.8
          this.page += 1
        end
      else this.scaleRight += ((1 - this.scaleRight) * 0.1) end
    else this.scaleRight = 1 end
    
    screen.setDrawScale(1, 1)
    
    local index = this.page * this.columns * this.rows
    for row = this.rows - 1 to 0 by - 1
      for column = 0 to this.columns - 1
        if data.length <= index then continue end
        
        local x = ((column + 1.5) * 16) + (column * 4) + 14
        local y = ((row + 1.5) * 16) + (row * 4)
        local item = this.data[index]
        local i = item[0]
        
        local cx = x - 178
        local cy = y + this.offset - 60
        local triggersClick = this.parent.state == global.Inventory.TABLE
        local hover = global.cursor.hover(cx, cy, 16, 16, triggersClick)
        if hover then
          global.cursor.tooltip = [i.name, ["#210f07", "#995940"]]
          this.hovering = item[0]
            
          if triggersClick then
            if mouse.pressed and not this.parent.table.drag then
              this.parent.table.drag = i
              item[1] -= 1
              
              if not item[1] then this.data.removeAt(index) end
            end
          end
        end
        
        local sprite = "slots/wooden/" + if hover then "hover" else "idle" end
        screen.drawSprite(sprite + "_16", x, y, 16, 16)  
        screen.drawSprite(i.sprite, x, y + 1, i.width, i.height)
          
        screen.setLineWidth(3)
        screen.drawTextOutline(item[1], x + 8, y - 8, 6, "#210f07")
        screen.drawText(item[1], x + 8, y - 8, 6, 999)
        
        index += 1
      end
    end
    
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
  
  add = function(ingredient)
    for item in this.data
      if item[0].name == ingredient.name then
        item[1] += 1
        return
      end
    end
    
    this.data.push([ingredient, 1])
  end
end


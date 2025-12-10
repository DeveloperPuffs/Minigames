
global.Table = class
  instructions = [
    (
      "Drag and drop from the pouch or equipment slots" +
      "onto the table to craft!"
    ),
    "Press 'E' to close the crafting bench."
  ]
  
  constructor = function(game, parent)
    this.game = game
    this.parent = parent
    
    this.showing = false
    this.tween = false
    this.offset = 200
    
    this.data = []
    this.drag = false
    this.drop = new global.Glow(32)
    this.hovering = false
  end
  
  update = function()
    this.hovering = false
  end
  
  draw = function()
    screen.setTranslation(0, this.offset - 60)
    screen.setDrawAnchor(-1, -1)
    screen.drawSprite("planks/half", 8, 0, 164, 152)
    
    screen.setLineWidth(4)
    screen.drawTextOutline("Crafting Bench", 16, 136, 8, "#210f07")
    screen.drawText("Crafting Bench", 16, 136, 8, 999)
    
    screen.setLineWidth(2)
    local y = 124
    for line in global.Table.instructions
      screen.drawTextOutline(line, 16, y, 4, "#210f07")
      screen.drawText(line, 16, y, 4, 999)
      y -= 8
    end
    
    screen.setAlpha(0.25)
    screen.setDrawScale(0.9, 0.9)
    screen.drawSprite("transmutation_circle", 32, 4, 120, 120)
    screen.setDrawScale(1, 1)
    screen.setAlpha(1)
    
    if this.drag then
      local width = this.drag.width
      local height = this.drag.height
      
      screen.setDrawScale(1.2, 1.2)
      local dx = mouse.x
      local dy = mouse.y + 60
      if this.drag.identifier == "equipment" then this.drag.paint(dx, dy)
      else screen.drawSprite(this.drag.sprite, dx, dy, width, height) end
      screen.setDrawScale(1, 1)
      
      if not mouse.pressed then
        if this.onTable(mouse.x, mouse.y, width, height) then
          local item = [this.drag, [mouse.x, mouse.y]]
          this.data.push(item)
          this.checkCraft(item)
        else
          if this.drag.identifier == "equipment" then
            this.parent.slots.push(this.drag)
          elsif this.drag.identifier == "ingredient" then
            this.parent.pouch.add(this.drag)
          end
        end
        
        this.drag = false
      end
    end
    
    for item in this.data
      local i = item[0]
      local p = item[1]
      
      local size = sqrt(pow(i.width, 2) +  pow(i.height, 2)) * 2
      this.drop.draw(p[0] - i.width, p[1] + 60 - i.height, size, "black", 0.5)
    end
    
    for item in this.data
      local i = item[0]
      local p = item[1]
      
      if i.identifier == "ingredient" then
        screen.drawSprite(i.sprite, p[0], p[1] + 60, i.width, i.height)
      elsif i.identifier == "equipment" then i.paint(p[0], p[1] + 60) end
      
      local x = p[0] + (i.width / 2)
      local y = p[1] + (i.height / 2)
      if global.cursor.hover(x, y, i.width, i.height) then
        this.hovering = i
        if not this.drag and mouse.pressed then
          this.data.removeElement(item)
          this.drag = i
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
  
  onTable = function(x, y, width, height)
    (
      x < 8 + 164 and
      x + width > 8 and
      y < -60 - this.offset + 152 and
      y + height > -60 - this.offset
    )
  end
  
  checkCraft = function(i)
    local group = [i]
    for item in this.data
      if item == i then continue end
      if (
        item[1][0] < i[1][0] + i[0].width and
        item[1][0] + item[0].width > i[1][0] and
        item[1][1] < i[1][1] + i[0].height and
        item[1][1] + item[0].height > i[1][1]
      ) then group.push(item) end
    end
    
    if group.length <= 1 then return end
    local ingredients = []
    local equipments = []
    for item in group
      if item[0].identifier == "ingredient" then ingredients.push(item)
      elsif item[0].identifier == "equipment" then equipments.push(item) end
    end
      
    for equipment in equipments
      if not ingredients.length then continue end
      ingredients = equipment[0].add(ingredients)
    end
      
    for item in group
      if item[0].identifier == "ingredient" then
        this.data.removeElement(item)
      end
    end
      
    local result = global.craft(ingredients)
    if result then
      audio.playSound("craft", 0.2)
      this.data = this.data.concat(result)
    else this.data = this.data.concat(ingredients) end
  end
end


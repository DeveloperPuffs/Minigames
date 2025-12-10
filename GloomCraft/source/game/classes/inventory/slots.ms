
global.Slots = class
  constructor = function(game, parent)
    this.game = game
    this.parent = parent
  
    this.list = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
    this.current = 0
    this.index = 0
    this.full = false
  end
  
  update = function()
    for index = 0 to 9
      local number = if index == 9 then 0 else index + 1 end
      if keyboard.press["DIGIT_" + number] then this.equip(this.list[index]) end
    end
  end
  
  draw = function()
    screen.setDrawAnchor(-1, -1)
    for index = 1 to 10
      local equipment = this.list[index - 1]
      local x = (index * 10.5) + ((index - 1) * 24) - 178
      
      local hovering = global.cursor.hover(x + 12, -80, 24, 24)
      if hovering then
        local name = "[Empty]"
        if not (equipment.type == "number") then name = equipment.name end
        global.cursor.tooltip = [name, ["#2a2d38", "#8d9199"]]
      end
      
      if hovering and this.parent.state == global.Inventory.TABLE then
        if mouse.pressed and not this.parent.table.drag then
          if this.parent.showing and not (equipment.type == "number") then
            this.parent.table.drag = equipment
            this.set(index - 1, false)
          end
        end
      end
      
      local clicking = global.cursor.click(x + 12, -80, 24, 24)
      if clicking then this.equip(index - 1) end
      
      local sprite = "slots/stone/"
      local current = index - 1 == this.index
      if current then sprite += if hovering then "focused" else "current" end
      else sprite += if hovering then "hover" else "idle" end end
      screen.drawSprite(sprite, x, -92, 24, 24)
        
      if not (equipment.type == "number") then
        local y = -78 - (equipment.width / 2)
        equipment.paint(x + 12 - (equipment.width / 2), y)
      end
      
      screen.setLineWidth(3)
      screen.drawTextOutline(index % 10, x + 10, -94, 6, "#2a2d38")
      screen.drawText(index % 10, x + 10, -94, 6, 999)
    end
    
    screen.setDrawAnchor(0, 0)
  end
  
  equip = function(equipment)
    if equipment.type == "number" then equipment = this.list[equipment] end
    if equipment == this.current then return end
    
    this.current = equipment
    this.index = this.list.indexOf(this.current)
    this.parent.equip(current)
    this.full = this.isFull()
  end
  
  set = function(index, equipment)
    if equipment then this.list[index] = equipment
    else this.list[index] = index
    end
    
    if index == this.index then this.equip(index) end
    this.full = this.isFull()
  end
  
  push = function(equipment)
    for item in this.list
      if item.type == "number" then
        this.set(item, equipment)
        return
      end
    end
  end
  
  remove = function(equipment)
    for index = 0 to this.list.length - 1
      if this.list[index] == equipment then
        this.set(index, false)
      end
    end
  end
  
  isFull = function()
    for i in this.list if i.type == "number" then return false end end
    return true
  end
end


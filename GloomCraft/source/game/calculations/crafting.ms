
global.craft = function(group)
  if group.length <= 1 then return group end
  
  local getResult = function(group, recipe)
    local left = [] + group
    local used = []
    
    for name in recipe[0]
      local found = false
      
      for item in left
        if item[0].name == name then
          found = true
          used.push(item)
          left.removeElement(item)
        end
      end
      
      if not found then return false end
    end
    
    local midpoint = [0, 0]
    for item in group
      midpoint[0] += item[1][0]
      midpoint[1] += item[1][1]
    end
    
    midpoint[0] /= group.length
    midpoint[1] /= group.length
    
    local result = global.Ingredient.getData(recipe[1])
    
    left.push([result, midpoint])
    return left
  end
  
  for recipe in global.recipes
    local result = getResult(group, recipe)
    if result then return result end
  end
  
  return false
end


global.recipes = [
  [["Purple Goo", "Green Goo", "Blue Goo", "Orange Goo"], "Black Goo"]
]


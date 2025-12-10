
global.Node = class
  constructor = function()
    this.parent = 0
    this.position = 0
    
    this.g = 0
    this.h = 0
    this.f = 0
  end
  
  equals = function(node)
    (
      this.position[0] == node.position[0] and 
      this.position[1] == node.position[1]
    )
  end
end

global.findPath = function(dungeon, start, target, distance = false)
  local startNode = new global.Node()
  startNode.position = [floor(start[0] / 16), floor(start[1] / 16)]
  
  local targetNode = new global.Node()
  targetNode.position = [floor(target[0] / 16), floor(target[1] / 16)]
  
  local adjacencies = [
    [0, -1], [-1, 0], [1, 0], [0, 1],
    [-1, -1], [-1, 1], [1, -1], [1, 1]
  ]
  
  local open = [startNode]
  local closed = []
  
  local searches = 0
  while open.length > 0
    if distance then
      if searches >= distance then return false else searches += 1 end
    end
    
    local currentNode = open[0]
    local currentIndex = 0
    
    for index = 0 to open.length - 1
      local node = open[index]
      
      if node.f < currentNode.f then
        currentNode = node
        currentIndex = index
      end
    end
    
    open.removeAt(currentIndex)
    closed.push(currentNode)
    
    if currentNode.equals(targetNode) then
      local path = []
      
      local current = currentNode
      while current
        path.push(current.position)
        current = current.parent
      end
      
      return path.reverse()
    end
    
    local children = []
    random.shuffle(adjacencies)
    for adjacency in adjacencies
      local column = currentNode.position[0] + adjacency[0]
      local row = currentNode.position[1] + adjacency[1]
      
      if not dungeon.colliderMap[row][column] then continue
      elsif abs(adjacency[0]) + abs(adjacency[1]) - 1 then
        if not dungeon.colliderMap[
          currentNode.position[0] + adjacency[0]
        ][currentNode.position[1]] then continue end
        
        if not dungeon.colliderMap[
          currentNode.position[0]
        ][currentNode.position[1] + adjacency[1]] then continue end
      end
      
      local newNode = new global.Node()
      newNode.parent = currentNode
      newNode.position = [column, row]
      children.push(newNode)
    end
    
    for child in children
      local childClosed = false
      for closedChild in closed
        if closedChild.equals(child) then
          childClosed = true
        end
      end
      
      if childClosed then continue end
      
      child.g = currentNode.g + 1
      child.h = (
        pow(child.position[0] - targetNode.position[0], 2) +
        pow(child.position[1] - targetNode.position[1], 2)
      )
      
      child.f = child.g + child.h
      
      local childOpened = false
      for openNode in open
        if openNode.equals(child) and openNode.g < child.g then
          childOpened = true
        end
      end
      
      if not childOpened then open.push(child) end
    end
  end
  
  return false
end



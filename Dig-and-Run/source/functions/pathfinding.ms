
global.tilePosition = function(x, y, width, height)
  [floor((x + (width * 8)) / 16), floor((y + (height * 8)) / 16) - 1]
end

Node = class
  equals = function(a, b)
    (a.position[0] == b.position[0] and a.position[1] == b.position[1])
  end
  
  constructor = function()
    this.parent = 0
    this.position = 0
    
    this.g = 0
    this.h = 0
    this.f = 0
  end
end

/*
A star pathfinding algorithm
https://medium.com/@nicholas.w.swift/easy-a-star-pathfinding-7e6689c7f7b2
*/
global.findPath = function(colliderMap, width, height, start, target, diagonals)
  local startNode = new Node()
  startNode.position = start
  
  local targetNode = new Node()
  targetNode.position = target
  
  local open = [startNode]
  local closed = []
  
  local adjacencies = [[0, -1], [-1, 0], [1, 0], [0, 1]]
  if diagonals then adjacencies.concat([[-1, -1], [-1, 1], [1, -1], [1, 1]]) end
  
  local currentLoops = 0
  while open.length > 0
    currentLoops += 1
    if currentLoops > max(width, height) then return false end
    
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
    
    if Node.equals(currentNode, targetNode) then
      local path = []
      
      local current = currentNode
      while current
        path.push(current.position)
        current = current.parent
      end
      
      return path.reverse()
    end
    
    local children = []
    for adjacency in adjacencies
     local nodePosition = [currentNode.position[0] + adjacency[0], currentNode.position[1] + adjacency[1]]
     
     if nodePosition[0] >= height or nodePosition[0] < 0 or nodePosition[1] >= width or nodePosition[1] < 0 then continue end
     if colliderMap[nodePosition[1]][nodePosition[0]] then continue end
     
     local newNode = new Node()
     newNode.parent = currentNode
     newNode.position = nodePosition
     children.push(newNode)
    end
    
    for child in children
      local childClosed = false
      for closedChild in closed
        if Node.equals(closedChild, child) then
          childClosed = true
        end
      end
      
      if childClosed then continue end
      
      child.g = currentNode.g + 1
      child.h = pow(child.position[0] - targetNode.position[0], 2) + pow(child.position[1] - targetNode.position[1], 2)
      child.f = child.g + child.h
      
      local childOpened = false
      for openNode in open
        if Node.equals(openNode, child) and openNode.g < child.g then
          childOpened = true
        end
      end
      
      if not childOpened then open.push(child) end
    end
  end
  
  return false
end






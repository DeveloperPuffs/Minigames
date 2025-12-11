/*
Collision Detection by PaulSt 240812

This library provides functions to detect collisions between basic shapes.
Following shapes are recognised by the object keys: 
  Point(x, y)
  Circle(x,y,radius) 
    - "r" instead of "radius" is also recognised
  Rectangle(x,y,width,height,angle) 
    - "w", "h" and "rotation"/"direction" instead of "width", "height" and "angle" are also recognised
    - angle in radians!
    - if angle == 0 then aabb algorithm

Functions:

Collide.elements(a, b) - automatically detects the shapes and returns if they collide

Collide.points(a,b) - compares two points
Collide.circles(a, b) - compares two circles
Collide.aabb(a, b) - compares two rectangles (both angles are 0)
Collide.rectangles(a,b) - compares two rotated rectangles (angleA != 0 or angleB != 0)

Collide.pointCircle(point, circle) - compares a point and a circle
Collide.pointAABB(point, rect) - compares a point and an unrotated rectangle (aabb)
Collide.pointRect(point, rect) - compares a point and a rotated rectangle

Collide.circleAABB(circle, rect) - compares a circle and an unrotated rectangle (aabb)
Collide.circleRect(circle, rect) - compares a circle and a rotated rectangle

NOW IT GETS INTERESTING:
Following functinos return a list of CollisionPair objects
Collide.elementList(element, list) - checks the element against the list of shapes 
Collide.list(list) - checks all elements in the list of shapes against each other
Collide.lists(listA, listB) - checks all elements of listA against all elements of listB

*/

CollisionPair = class
  constructor = function(a, b)
    bodyA = a
    bodyB = b
    timestamp = system.time()
    // what else could be interesting?
  end
end

Collide = object
  
  points = function(a,b)
    return (a.x == b.x) and (a.y == b.y)
  end
  
  // two aabb (axis aligned bounding boxes)
  aabb = function(a,b)
    local aW2 = (a.w or a.width)/2
    local aH2 = (a.h or a.height)/2
    local bW2 = (b.w or b.width)/2
    local bH2 = (b.h or b.height)/2
    return not((a.x+aW2 < b.x-bW2) 
            or (a.x-aW2 > b.x+bW2) 
            or (a.y+aH2 < b.y-bH2)
            or (a.y-aH2 > b.y+bH2))
  end
  
  // two circles
  circles = function(a,b)
    // dx^2 + dy^2 <= (ra+rb)^2
    local dx = a.x-b.x
    local dy = a.y-b.y
    local d  = (a.r or a.radius) + (b.r or b.radius)
    return dx*dx + dy*dy <= d*d 
  end
  
  // piont inside aabb?
  pointAABB = function(p, rect)
    local rw = rect.w or rect.width
    local rh = rect.h or rect.height
    return ((abs(p.x-rect.x) <= rw/2)
        and (abs(p.y-rect.y) <= rh/2))
  end
  
  // point inside circle?
  pointCircle = function(p,c)
    local cr = c.r or c.radius
    local dx = c.x-p.x
    local dy = c.y-p.y
    return ((dx*dx+dy*dy) <=  (cr * cr))
  end
  
  // circle overlaps aabb?
  circleAABB = function(c, r)
    local rW2 = (r.w or r.width)/2
    local rH2 = (r.h or r.height)/2
    local cr = c.r or c.radius
    local distX = abs(c.x - r.x)
    local distY = abs(c.y - r.y)
    if (distX > (rW2 + cr)) or (distY > (rH2 + cr)) then return false end //      
    if (distX <= rW2 or distY <= rH2) then return true end
    local dx = distX-rW2
    local dy = distY-rH2
    return (dx*dx+dy*dy) <= (cr*cr)
  end
  
  // point inside rotated Rectangle?
  pointRect = function(p, rect)
    local angle = -(rect.angle or rect.rotation or rect.direction)
    local pRotated = object x=p.x y=p.y end
    if angle != 0 then
      // rotate point by rect.angle around rect center
      local dx = p.x - rect.x
      local dy = p.y - rect.y
      local si = sin(angle)
      local co = cos(angle)
      pRotated.x = dx * co - dy * si + rect.x
      pRotated.y = dx * si + dy * co + rect.y
    end
    return pointAABB(pRotated, rect)
  end
  
  // circle overlaps rotated Rectangle?
  circleRect = function(c, rect)
    
    local angle = -(rect.angle or rect.rotation or rect.direction)
    if angle == 0 then
      return circleAABB(c, rect)
    end
    
    // rotate circle center by -angle around rectangle center
    local dx = c.x - rect.x
    local dy = c.y - rect.y
    local si = sin(angle)
    local co = cos(angle)
    
    local cRotated = object
      x = dx * co - dy * si + rect.x
      y = dx * si + dy * co + rect.y
      r = (c.r or c.radius)
    end
    return circleAABB(cRotated, rect)
  end
  
  // two rotated rectangles
  rectangles = function(a, b)
    
    local angleA = a.angle or a.rotation or a.direction
    local angleB = b.angle or b.rotation or b.direction
    if angleA == 0 and angleB == 0 then
      return aabb(a, b)
    end
    
    
    local verts1 = _getVerticesFromRect(a)
    local verts2 = _getVerticesFromRect(b)
    local axes = [
      object 
        x = verts1[1].x - verts1[0].x
        y = verts1[1].y - verts1[0].y
      end,
      object 
        x = verts1[3].x - verts1[0].x
        y = verts1[3].y - verts1[0].y
      end,
      object 
        x = verts2[1].x - verts2[0].x
        y = verts2[1].y - verts2[0].y
      end,
      object 
        x = verts2[3].x - verts2[0].x
        y = verts2[3].y - verts2[0].y
      end
    ]

    for axis in axes
      local proj1 = _project(verts1, axis)
      local proj2 = _project(verts2, axis)
      // using the Separating Axis Theorem (SAT)
      if not ((proj1[1] >= proj2[0]) and (proj2[1] >= proj1[0])) then
        return false // Separating axis found, no overlap
      end
    end
    return true // No separating axis found, rectangles overlap
  end
  
  //==== use these functions ====
  
  // element collides with elements?
  elements = function(a, b)
    local ar = a.r or a.radius
    local aw = a.w or a.width
    local ah = a.h or a.height
    local aIsPoint = not(ar or aw or ah)
    
    local br = b.r or b.radius
    local bw = b.w or b.width
    local bh = b.h or b.height
    local bIsPoint = not(br or bw or bh)
    
    // a is point
    if aIsPoint then
      // point + point
      if bIsPoint then
        return (a.x==b.x and a.y == b.y)
      // point + circle
      elsif br then
        return this.pointCircle(a,b)
      // point + rect
      else
        return this.pointRect(a,b)
      end
    // a is circle
    elsif ar then
      // circle + point
      if bIsPoint then
        return this.pointCircle(b,a)
      // circle + circle
      elsif br then
        return this.circles(a,b)
      // circle + rect
      else
        return this.circleRect(a,b)
      end
    // a is rectangle
    else
      // rect + point
      if bIsPoint then
        return this.pointRect(b,a)
      // rect + circle
      elsif br then
        return this.circleRect(b,a)
      // rect + rect
      else
        return this.rectangles(a,b)
      end
    end
  end
  
  // element collides with which elements of list?
  elementList = function(a, list)
    local result = []
    if list.length == 0 then return result end
    for j = 0 to list.length-1
      if this.elements(a,list[j]) then 
        result.push(new CollisionPair(a,list[j]))
      end
    end
    return result
  end
  
  // which elements overlap?
  list = function(list)
    result = []
    if list.length < 2 then return result end
    for i = 0 to list.length-2
      local a = list[i]
      result += this.elementList(a, list.slice(i+1))
    end
    return result
  end
  
  // which aelements of list a overlap with which elements of list b?
  lists = function(a,b)
    result = []
    if a.length==0 or b.length==0 then return result end
    for i = 0 to a.length-1
      result += this.elementList(a[i], b)
    end
    return result
  end
  
  
  // ==== helpers ====
  _getVerticesFromRect = function(rect)
    local angleRad = rect.angle or rect.direction or rect.rotation
    local co = cos(angleRad)
    local si = sin(angleRad)
    local halfWidth =  (rect.width  or rect.w) / 2
    local halfHeight = (rect.height or rect.h) / 2
    return [
      object
          x = rect.x + halfWidth * co - halfHeight * si
          y = rect.y + halfWidth * si + halfHeight * co
      end,
      object
          x = rect.x - halfWidth * co - halfHeight * si
          y = rect.y - halfWidth * si + halfHeight * co
      end,
      object
          x = rect.x - halfWidth * co + halfHeight * si
          y = rect.y - halfWidth * si - halfHeight * co
      end,
      object
          x = rect.x + halfWidth * co + halfHeight * si
          y = rect.y + halfWidth * si - halfHeight * co
      end
    ]
  end
  
  // Project points on an axis
  _project = function(vertices, axis)
    local low = vertices[0].x * axis.x + vertices[0].y * axis.y
    local high = low
    if vertices.length<2 then return [low, high] end
    for i = 1 to vertices.length-1
      local vertex = vertices[i]
      local projection = (vertex.x * axis.x + vertex.y * axis.y) //      
      if (projection < low)  then low = projection  end
      if (projection > high) then high = projection end
    end
    return [low, high]
  end
  
  
end


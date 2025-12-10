
// Does the math of rendering the shadows onto a view (image or screen)
global.renderShadows = function(view, light, surfaces, color)
  if not light.angleRange then
    screen.clear(color)
    return
  end
  
  local distance = screen.width * screen.height * -1
  screen.setColor(color)
  
  // Loop over each surface and cast shadows for each one of them
  for surface in surfaces
    local angle1 = atan2(light.y - surface.y1, light.x - surface.x1)
    local vertex1 = [cos(angle1) * distance, sin(angle1) * distance]
      
    local angle2 = atan2(light.y - surface.y2, light.x - surface.x2)
    local vertex2 = [cos(angle2) * distance, sin(angle2) * distance]
      
    // The path, flattened for passing through the 'fillPolygon' function
    local shadowQuad = [
      surface.x1, surface.y1,
      surface.x2, surface.y2,
      vertex2[0], vertex2[1],
      vertex1[0], vertex1[1]
    ]
    
    screen.fillPolygon(shadowQuad)
  end
  
  local angleRange = light.angleRange * light.angleRangeMultiplier
  angleRange = min(max(angleRange, 0), 360)
  
  if angleRange < 360 then
    // Draw triangles from the start to the end
    local distance = screen.width + screen.height
    local startAngle = light.angle + (angleRange / 2)
    local trianglesAngle = (360 - angleRange) / 3
    for index = 0 to 2
      local triangleStartAngle = startAngle + (index * trianglesAngle) - 1
      local triangleEndAngle = triangleStartAngle + trianglesAngle + 1
      screen.fillPolygon([
        light.x, light.y,
        light.x + (cosd(triangleStartAngle) * distance),
        light.y + (sind(triangleStartAngle) * distance),
        light.x + (cosd(triangleEndAngle) * distance), 
        light.y + (sind(triangleEndAngle) * distance)
      ])
    end
  end
end

// Shortcut for shadow rendering using the global 'screen' object
screen.drawShadows = function(light, surfaces, color)
  global.renderShadows(screen, light, surfaces, color)
end


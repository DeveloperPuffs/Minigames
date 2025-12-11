
// javascript

global.screen.fixDrawRotation = function() {
  
  // Gives 'null' if the current draw rotation is zero or non-numerical
  function getCurrentDrawRotation() {
    const currentDrawRotation = global.screen.getDrawRotation();
    const isValid = !isNaN(currentDrawRotation) && currentDrawRotation !== 0;
    return isValid ? currentDrawRotation : null;
  }
  
  // Defaults the current draw anchor to the origin
  function getCurrentDrawAnchor() {
    const currentDrawAnchor = global.screen.getDrawAnchor();
    const isValid = Array.isArray(currentDrawAnchor) || currentDrawAnchor.length >= 2;
    return isValid ? currentDrawAnchor : [0, 0];
  }
  
  // Rotates a list of points
  function rotatedPoints(points, degrees, origin) {
    const radians = degrees * (Math.PI / 180);  
    return points.map(([x, y]) => {
      const cosAngle = Math.cos(radians);
      const sinAngle = Math.sin(radians);
        
      const tx = x - origin[0];
      const ty = y - origin[1];
        
      const rx = (tx * cosAngle) - (ty * sinAngle);
      const ry = (tx * sinAngle) + (ty * cosAngle);
        
      return [rx + origin[0], ry + origin[1]];
    });
  }
  
  function fixDrawRotationForMethod(methodName) {
    const originalMethod = global.screen[methodName];
    
    global.screen[methodName] = function() {
      // Make sure the current drawing rotation is numeric and nonzero
      const currentDrawRotation = getCurrentDrawRotation();
      if (!currentDrawRotation) {
        originalMethod(...arguments);
        return;
      }
      
      // Whether the points are given from a list
      const pointsListed = Array.isArray(arguments[0]);
      
      // Set the color of the drawing
      if (
        (pointsListed && arguments.length == 2) ||
        (!pointsListed && arguments.length & 2 !== 0)
      ) global.screen.setColor(arguments[arguments.length - 1]);
      
      // Calculate the flat list of points
      const flatPoints = pointsListed ? arguments[0] : arguments;
      
      // Calculate the points
      const points = [];
      for (let index = 0; index < flatPoints.length; index++) {
        if (index % 2) points[points.length - 1].push(flatPoints[index]);
        else points.push([flatPoints[index]]);
      }
      
      // Remove the incomplete point at the end
      if (points[points.length - 1].length === 1) points.pop();
      
      // Calculate the bounding box of the whole drawing centered at the origin
      const size = [0, 0];
      for (const point of points) {
        size[0] = Math.max(size[0], Math.abs(point[0]));
        size[1] = Math.max(size[1], Math.abs(point[1]));
      }
      
      // Calculate the origin of the rotation using the current draw anchor
      const currentDrawAnchor = getCurrentDrawAnchor();
      const rotationOrigin = [currentDrawAnchor[0] * size[0], currentDrawAnchor[1] * size[1]];
      
      // Call the drawing method, but with rotated points's values
      originalMethod(rotatedPoints(points, currentDrawRotation, rotationOrigin).flat());
    }
  }
  
  // Override the following screen functions
  fixDrawRotationForMethod("drawPolygon");
  fixDrawRotationForMethod("drawPolyline");
  fixDrawRotationForMethod("drawQuadCurve");
  fixDrawRotationForMethod("drawBezierCurve");
  fixDrawRotationForMethod("fillPolygon");
  
  // Override the 'drawLine' function differently
  const drawLine = global.screen.drawLine;
  global.screen.drawLine = function() {
    // Make sure the current drawing rotation is numeric and nonzero
    const currentDrawRotation = getCurrentDrawRotation();
    if (!currentDrawRotation) {
      drawLine(...arguments);
      return;
    }
    
    // Get the values given from the arguments
    const [x1, y1, x2, y2, color] = [...arguments];
    if (color) global.screen.setColor(color);
    
    // Calculate the bounding box of the drawn line
    const halfSize = [Math.abs(x2 - x1) / 2, Math.abs(y2 - y1) / 2];
    const [x, y] = [(x1 + x2) / 2, (y1 + y2) / 2];
    
    // Calculate the origin of the rotation using the current drawing anchor
    const currentDrawAnchor = getCurrentDrawAnchor();
    const rotationOrigin = [
      x + (currentDrawAnchor[0] * halfSize[0]),
      y + (currentDrawAnchor[1] * halfSize[1])
    ];
    
    drawLine(...rotatedPoints([[x1, y1], [x2, y2]], currentDrawRotation, rotationOrigin).flat());
  }
}


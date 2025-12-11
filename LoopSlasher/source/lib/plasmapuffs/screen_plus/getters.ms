
// javascript

global.screen.loadGetters = function() {
  function createScreenGetter(setterMethodName, defaultValue) {
    
    let currentValue = Array.isArray(defaultValue) ? [...defaultValue] : defaultValue;
    const setterMethod = global.screen[setterMethodName];
    
    // Default Value
    global.screen[setterMethodName.replace("set", "default")] = defaultValue;
    
    // Setters
    global.screen[setterMethodName] = function() {
      if (arguments.length === 0) return;
      currentValue = arguments.length === 1 ? arguments[0]: Array.from(arguments);
      setterMethod.apply(global.screen, arguments);
    }
     
    // Getters
    global.screen[setterMethodName.replace("set", "get")] = function() {
      return currentValue;
    }
    
    // Resetters
    global.screen["re" + setterMethodName] = function() {
      const currentDefaultValue = global.screen[setterMethodName.replace("set", "default")];
      const argumentsList = Array.isArray(currentDefaultValue) ? currentDefaultValue : [currentDefaultValue];
      global.screen[setterMethodName](...argumentsList);
    }
  }
  
  // Map the default values of the screen setters
  const defaultsMap = {
    setColor: "black",
    setLineWidth: 1,
    setLineDash: [0, 0],
    setFont: "BitCell",
    setAlpha: 1,
    setLinearGradient: [0, 0, 0, 0, "black", "black"],
    setRadialGradient: [0, 0, 0, "black", "black"],
    setTranslation: [0, 0],
    setRotation: 0,
    setScale: [1, 1],
    setDrawRotation: 0,
    setDrawScale: [1, 1],
    setDrawAnchor: [0, 0],
    setBlending: "normal",
    setCursorVisible: true
  };
  
  // Overriding the screen setters
  for (const setterMethodName of Object.keys(defaultsMap)) {
    createScreenGetter(setterMethodName, defaultsMap[setterMethodName]);
  }
  
  global.screen.reset = function() {
    for (const property in global.screen) {
      if (property.startsWith("reset") && property !== "reset") {
        global.screen[property]();
      }
    }
  }
  
  const clearScreen = global.screen.clear;
  global.screen.clear = function(color) {
    clearScreen(color);
    global.screen.reset();
  }
  
  global.screen.reset();
}


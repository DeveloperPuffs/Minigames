
// javascript

global.PixelImage = class extends global.Image {
  constructor(width, height, centered) {
    super(width, height, centered);
    
    // Setup the image filter
    this.initContext();
    this.context.alpha = 1;
    this.context.filter = "url(#alias)";
    
    const handler = {
      get(target, property, receiver) {
        const method = target[property];
        if (typeof method !== "function") return method;
        
        if (method.name.includes("draw") || method.name.includes("fill")) {
          return function(...functionArguments) {
            global.setAliasAlpha(receiver.context.alpha);
            method.apply(receiver, functionArguments);
          }
        }
        
        return method;
      }
    }
    
    return new Proxy(this, handler);
  }
  
  // This adds compability to the microstudio number colors
  setColor(color) {
    if (color === undefined) return;
    if (typeof color === "number") {
      const number = Math.min(Math.max(Math.round(color), 0), 999);
      const red = 255 * (Math.floor(number / 100) % 10) / 9;
      const green = 255 * (Math.floor(number / 10) % 10) / 9;
      const blue = 255 * (number % 10) / 9;
      color = "rgb(" + red + ", " + green + ", " + blue + ")";
    }
    
    super.setColor(color);
  }
  
  // Triggering this will set the image's alpha
  setAlpha(alpha) { this.context.alpha = alpha; }
}


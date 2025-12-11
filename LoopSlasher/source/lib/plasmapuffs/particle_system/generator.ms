
// This will generate a random value with custom bias
Generator = class
  constructor = function(minimum, maximum)
    this.minimum = minimum
    this.maximum = maximum
    
    this.biasPosition = 0
    this.biasStrength = 0
    this.modifier = false
  end
  
  set = function(value)
    this.minimum = value
    this.maximum = value
  end
  
  setMinimum = function(minimum)
    this.minimum = minimum
    this.maximum = max(this.minimum, this.maximum)
  end
  
  setMaximum = function(maximum)
    this.maximum = maximum
    this.minimum = min(this.minimum, this.maximum)
  end
  
  setRange = function(minimum, maximum)
    this.setMinimum(minimum)
    this.setMaximum(maximum)
  end
  
  setAround = function(point, amount)
    this.minimum = point - (amount / 2)
    this.maximum = point + (amount / 2)
  end
  
  generateRaw = function()
    local value = random.next()
    if not this.biasStrength then
      return this.minimum + ((this.maximum - this.minimum) * value)
    end
    
    // The bias will be applied to this position
    local midpoint = (this.biasPosition + 1) / 2
    
    // Calculate the biased value
    if value < midpoint then value = pow(value / midpoint, 1 - this.biasStrength) * midpoint
    else value = 1 - (pow((1 - value) / (1 - midpoint), 1 - this.biasStrength) * (1 - midpoint))
    end
    
    // Scale the randomly generated value
    return (this.minimum + (this.maximum - this.minimum)) * value
  end
  
  generate = function()
    local generatedValue = this.generateRaw()
    if this.modifier then return this.modifier(generatedValue, this)
    else return generatedValue
    end
  end
end


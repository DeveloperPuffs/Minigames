
Object.clone = function()
  local cloned = object end
  
  for property in this
    local value = this[property]
    
    if value.type == "function" then cloned[property] = value
    elsif value.type == "number" then cloned[property] = value
    elsif value.type == "string" then cloned[property] = value
    elsif value.type == "list" then cloned[property] = [] + value
    elsif value.type == "object" then cloned[property] = value.clone()
    end
  end
  
  return cloned
end

// A function used to run a function with a list as the
// function arguments (packed arguments)
system.javascript("""
  global.call = function(target, functionName, packedArguments) {
    return target[functionName](...packedArguments);
  }
""")


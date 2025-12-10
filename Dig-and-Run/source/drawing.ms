
Drawing = class
  sort = function(a, b) a.order - b.order end
  queue = []
  
  constructor = function(parent, order, call)
    this.parent = parent
    this.order = order
    this.call = call
  end
  
  enqueue = function()
    Drawing.queue.push(this)
    Drawing.queue.sort(Drawing.sort)
  end
end


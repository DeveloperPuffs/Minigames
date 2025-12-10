
random.integerRange = function(a, b) floor((random.next() * (b - a)) + a) end
random.floatRange = function(a, b) (random.next() * (b - a)) + a end
random.choice = function(a) a[random.nextInt(a.length)] end
random.boolean = function() random.nextInt(2) end
random.sign = function() random.choice([-1, 1]) end
random.shuffle = function(c)
  c.sortList(function(a, b) random.next() - 0.5 end)
end

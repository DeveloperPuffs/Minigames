
Grid = object end
Grid.EMPTY = "Empty" // Empty Tile in the Grid
Grid.TILE = "Tile" // A Normal Honeycomb Tile
Grid.SLOT = "Slot" // A Slot to Place Honeycomb Blocks
Grid.BLOCK = "Block" // A Honeycomb Block
Grid.SPAWN = "Spawn" // Where the Bee Spawns
Grid.FILLED = "Filled" // A Honeycomb Block on a Slot
Grid.HOME = "Home" // The Bee Spawning on a Slot

Grid.slots = [Grid.SLOT, Grid.FILLED, Grid.HOME]

global.loadLevels = function()
  local parse = object end
  parse["."] = Grid.EMPTY
  parse["@"] = Grid.TILE
  parse["O"] = Grid.SLOT
  parse["0"] = Grid.FILLED
  parse["#"] = Grid.BLOCK
  parse["*"] = Grid.SPAWN
  parse["="] = Grid.HOME
  
  local createGrid = function(data, columns, rows)
    local grid = []
    grid.push([])
    
    for character in data
      if character == " " or character == "\n" then continue end
      if grid[grid.length - 1].length == columns then grid.push([]) end
      grid[grid.length - 1].push(parse[character])
    end
    
    grid.reverse()
    return grid
  end
  
  local level1 = object end
  level1.name = "Just a Beehive"
  level1.orientation = Beehive.FLAT
  level1.startAngle = 90
  level1.columns = 5
  level1.rows = 5
  level1.grid = createGrid("""
    ..@..
    @@O@@
    @@#@@
    @@*@@
    .@@@.
  """, level1.columns, level1.rows)
  
  local level2 = object end
  level2.name = "Also Just a Beehive"
  level2.orientation = Beehive.POINTY
  level2.startAngle = 0
  level2.columns = 5
  level2.rows = 5
  level2.grid = createGrid("""
    .@@@.
    @@@@.
    @#*O@
    @@@@.
    .@@@.
  """, level2.columns, level2.rows)
  
  local level3 = object end
  level3.name = "Two Too Many"
  level3.orientation = Beehive.FLAT
  level3.startAngle = 270
  level3.columns = 5
  level3.rows = 6
  level3.grid = createGrid("""
    ..*..
    @@@@@
    @O.#@
    @@.@@
    @#@O@
    .@@@.
  """, level3.columns, level3.rows)
  
  local level4 = object end
  level4.name = "Double Push"
  level4.orientation = Beehive.POINTY
  level4.startAngle = 240
  level4.columns = 4
  level4.rows = 7
  level4.grid = createGrid("""
    ..*.
    .@@.
    .@#@
    @@0@
    .@@O
    .@#.
    ..O.
  """, level4.columns, level4.rows)
  
  local level5 = object end
  level5.name = "Hexscape"
  level5.orientation = Beehive.FLAT
  level5.startAngle = 90
  level5.columns = 7
  level5.rows = 6
  level5.grid = createGrid("""
    ..@....
    ..O@O..
    .@###@.
    .O#*#O.
    .@O#O@.
    ...@...
  """, level5.columns, level5.rows)
  
  local level6 = object end
  level6.name = "Swiss Cheese"
  level6.orientation = Beehive.POINTY
  level6.startAngle = 60
  level6.columns = 5
  level6.rows = 5
  level6.grid = createGrid("""
    @.@@.
    .@.#@
    @@@.@
    .@@@@
    =@@.@
  """, level6.columns, level6.rows)
  
  local level7 = object end
  level7.name = "Roundabout"
  level7.orientation = Beehive.FLAT
  level7.startAngle = 30
  level7.columns = 9
  level7.rows = 6
  level7.grid = createGrid("""
    .....@@..
    ....@#@..
    ..#@.@@@@
    @@@...0O@
    *O@.@@...
    .@.@@....
  """, level7.columns, level7.rows)
  
  local level8 = object end
  level8.name = "Open Space"
  level8.orientation = Beehive.POINTY
  level8.startAngle = 240
  level8.columns = 7
  level8.rows = 6
  level8.grid = createGrid("""
    ..@@O*.
    .@O@#@O
    @O@#@O@
    .@#@@#@
    ..@#@..
    ..@@...
  """, level8.columns, level8.rows)
  
  local level9 = object end
  level9.name = "Procedural Honeycomb"
  level9.orientation = Beehive.FLAT
  level9.startAngle = 90
  level9.columns = 6
  level9.rows = 6
  level9.grid = createGrid("""
    @.@@.@
    .@O@..
    @#0#O@
    @@#.@O
    .O@#@.
    @@@@*@
  """, level9.columns, level9.rows)
  
  local level10 = object end
  level10.name = "Organize the Beeroom"
  level10.orientation = Beehive.POINTY
  level10.startAngle = 0
  level10.columns = 10
  level10.rows = 7
  level10.grid = createGrid("""
    OOOOOOOOOO
    @#@#@#@#@@
    @@#@#@#@#@
    @#@#*#@#@@
    @@#@#@#@#@
    @#@#@#@#@@
    OOOOOOOOOO
  """, level10.columns, level10.rows)
  
  return [level1, level2, level3, level4, level5, level6, level7, level8, level9, level10]
end


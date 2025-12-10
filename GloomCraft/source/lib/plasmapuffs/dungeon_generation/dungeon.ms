
// They are positionned based on their top left grid cell index
global.Room = class
  constructor = function(minimum, maximum)
    this.width = random.nextInt(maximum - minimum) + minimum
    this.height = random.nextInt(maximum - minimum) + minimum
    this.column = 0
    this.row = 0
  end
  
  // Shuffles the room's position
  shufflePosition = function(columns, rows)
    this.column = random.nextInt(columns - this.width)
    this.row = random.nextInt(rows - this.height)
  end
end

global.Dungeon = class
  WALL = "Wall"
  ROOM = "Room"
  TUNNEL = "Tunnel"
  FURNITURE = "Furniture"
  START = "Start"
  FINISH = "Finish"
  
  constructor = function(columns, rows, minimum, maximum, density)
    this.columns = columns
    this.rows = rows
    
    this.rooms = []
    this.tilemap = this.createTilemap(columns - 2, rows - 2)
    
    // Randomly create rooms and tunnels until reaching the specified density
    while true
      local newRoom = new global.Room(minimum, maximum)
      
      // Find a spot that is available for the new room
      local attempts = 0
      while true
        newRoom.shufflePosition(columns - 2, rows - 2)
        
        if this.canPlaceRoom(newRoom) then break
        elsif attempts > density then break
        else attempts += 1 end
      end
      
      // Exit if can't find a spot within the given density placement attempts
      if attempts > density then break
      else
        this.rooms.push(newRoom)
        this.addRoom(newRoom)
      end
      
      // Connect the room to the previous one using tunnels
      if this.rooms.length > 1 then
        local previousRoom = this.rooms[this.rooms.length - 2]
        this.createTunnel(newRoom, previousRoom)
      end
    end
    
    // Make sure there are at least two rooms
    if this.rooms.length < 2 then
      this = new global.Dungeon(columns, rows, minimum, maximum, density)
    end
    
    // Add the rooms again to cover overlapping tunnels
    for room in this.rooms this.addRoom(room) end
    
    // Add a border of walls around the rooms and tunnels
    this.addBorder()
    
    // Shift the positions of the rooms because of the added border
    for room in this.rooms
      room.column += 1
      room.row += 1
    end
    
    // Create the start and end positions
    this.startRoom = false
    this.finishRoom = false
    
    while true
      this.startRoom = random.choice(this.rooms)
      this.finishRoom = random.choice(this.rooms)
      if not (this.startRoom == this.finishRoom) then break end
    end
    
    this.start = [
      random.integerRange(
        this.startRoom.column, this.startRoom.column + this.startRoom.width
      ),
      random.integerRange(
        this.startRoom.row, this.startRoom.row + this.startRoom.height
      )
    ]
    
    this.finish = [
      random.integerRange(
        this.finishRoom.column, this.finishRoom.column + this.finishRoom.width
      ),
      random.integerRange(
        this.finishRoom.row, this.finishRoom.row + this.finishRoom.height
      )
    ]
    
    this.tilemap[this.start[1]][this.start[0]] = global.Dungeon.START
    this.tilemap[this.finish[1]][this.finish[0]] = global.Dungeon.FINISH
  end
  
  // Creates a tilemap filled with walls
  createTilemap = function(columns, rows)
    local tilemap = []
    
    for row = 0 to rows - 1
      tilemap.push([])
      
      for column = 0 to columns - 1
        tilemap[row].push(global.Dungeon.WALL)
      end
    end
    
    return tilemap
  end
  
  // Checks if a specific tile index is out of the dungeon's tilemap's bounds
  out = function(column, row)
    return (
      row < 0 or column < 0 or
      row >= this.tilemap.length or
      column >= this.tilemap[0].length
    )
  end
  
  // Adds a new room into the dungeon
  addRoom = function(room)
    for roomRow = room.row to room.row + room.height - 1
      for roomColumn = room.column to room.column + room.width - 1
        this.tilemap[roomRow][roomColumn] = global.Dungeon.ROOM
      end
    end
  end
  
  // Checks if a room can be placed at a specific position in the dungeon
  canPlaceRoom = function(room)
    for roomRow = room.row - 1 to room.row + room.height + 1
      for roomColumn = room.column - 1 to room.column + room.width + 1
        if this.out(roomColumn, roomRow) then continue end
        if not (this.tilemap[roomRow][roomColumn] == global.Dungeon.WALL) then
          return false
        end
      end
    end
    
    return true
  end
  
  // Creates a new tunnel horizontally
  createTunnelHorizontally = function(start, finish, row)
    for column = min(start, finish) to max(start, finish)
      this.tilemap[row][column] = global.Dungeon.TUNNEL
    end
  end
  
  // Creates a new tunnel vertically
  createTunnelVertically = function(start, finish, column)
    for row = min(start, finish) to max(start, finish)
      this.tilemap[row][column] = global.Dungeon.TUNNEL
    end
  end
  
  // Creates a tunnel between two rooms
  createTunnel = function(firstRoom, secondRoom)
    if random.boolean() then
      // Create horizontal tunnel first
      local startColumn = random.integerRange(
        firstRoom.column, firstRoom.column + firstRoom.width - 1
      )
      
      local endColumn = random.integerRange(
        secondRoom.column, secondRoom.column + secondRoom.width - 1
      )
      
      local startRow = random.integerRange(
        firstRoom.row, firstRoom.row + firstRoom.height - 1
      )
      
      this.createTunnelHorizontally(startColumn, endColumn, startRow)
      
      // Create vertical tunnel second
      local middleRow = random.integerRange(
        secondRoom.row, secondRoom.row + secondRoom.height - 1
      )
      
      this.createTunnelVertically(startRow, middleRow, endColumn)
    else
      // Create vertical tunnel first
      local startRow = random.integerRange(
        firstRoom.row, firstRoom.row + firstRoom.height - 1
      )
      
      local endRow = random.integerRange(
        secondRoom.row, secondRoom.row + secondRoom.height - 1
      )
      
      local startColumn = random.integerRange(
        firstRoom.column, firstRoom.column + firstRoom.width - 1
      )
      
      this.createTunnelVertically(startRow, endRow, startColumn)
      
      // Create horizontal tunnel second
      local middleColumn = random.integerRange(
        secondRoom.column, secondRoom.column + secondRoom.width - 1
      )
      
      this.createTunnelHorizontally(startColumn, middleColumn, endRow)
    end
  end
  
  // Adds a row and column of walls on each side to make sure no rooms or
  // corridors are touching the edge of the dungeon tilemap.
  addBorder = function()
    for row in this.tilemap
      row.insert(global.Dungeon.WALL)
      row.push(global.Dungeon.WALL)
    end
    
    local createRow = function()
      local row = []
      for index = 0 to this.tilemap[0].length - 1
        row.push(global.Dungeon.WALL)
      end
      
      return row
    end
    
    this.tilemap.insert(createRow())
    this.tilemap.push(createRow())
  end
end


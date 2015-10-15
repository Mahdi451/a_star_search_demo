-- main.lua


-- Internal globals.

local win_w, win_h

local maze_str
local maze = {}
local x_len, y_len

local entities = {}

local tile_size = 35

-- G[x][y] = {nbors of that grid pt}.
local G = {}


-- Internal functions.

function pr(...)
  print(string.format(...))
end

function draw_tile(x, y)
  love.graphics.rectangle('fill', x * tile_size, y * tile_size,
                          tile_size - 1, tile_size - 1)
end

function draw_dot(x, y, r)
  love.graphics.circle('fill',
                       (x + 0.5) * tile_size, (y + 0.5) * tile_size, r, 20)
end

function draw_path(path)
  local p = {}
  for _, coord in ipairs(path) do
    p[#p + 1] = (coord + 0.5) * tile_size
  end
  love.graphics.line(p)
end

-- This builds the graph structure in G.
-- G[x][y] = {nbors of grid point (x, y)}
function build_G()
  for x = 1, x_len do G[x] = {} end
  for y = 1, y_len do
    for x = 1, x_len do
      if maze[x][y] == 0 then  -- Make sure the grid space is not a wall.
        G[x][y] = {}  -- This is the nbor list.
        if maze[x + 1][y] == 0 then table.insert(G[x][y], {x + 1, y}) end
        if maze[x - 1][y] == 0 then table.insert(G[x][y], {x - 1, y}) end
        if maze[x][y + 1] == 0 then table.insert(G[x][y], {x, y + 1}) end
        if maze[x][y - 1] == 0 then table.insert(G[x][y], {x, y - 1}) end
      end
    end
  end

  -- Below is debug code to help verify that G is correct.
  --[[
  for y = 1, y_len do
    for x = 1, x_len do
      if G[x][y] then
        pr('G[%d][%d] has nbors:', x, y)
        for _, nbor in pairs(G[x][y]) do
          pr('  {%d, %d}', nbor[1], nbor[2])
        end
      end
    end
  end
  --]]
end

-- This returns a list of x, y pairs starting at the given arguments and
-- ending at the goal point x_len, 1.
function find_path(x, y)
  return {x, y, x + 1, y}
end

-- Entity class.

local Entity = {}

Entity.__index = Entity

function Entity:draw()
  love.graphics.setColor(100, 0, 120)
  draw_path(self.path)

  love.graphics.setColor(190, 0, 220)
  draw_dot(self.x, self.y, 7)
end

function Entity.new(x, y)
  local entity = {x = x, y = y}
  entity.path = find_path(x, y)
  return setmetatable(entity, Entity)
end


-- Love callbacks.

function love.load()
  win_w, win_h = love.graphics.getDimensions()

  maze_str = loadfile('maze.data')()

  -- Convert maze_str into a table of tables so that maze[x][y] is 0 or 1.
  -- 1 = a wall, 0 = no wall.
  maze = {}
  local x, y = 1, 1
  for line in maze_str:gmatch('[^\n]+') do
    if x_len == nil then
      x_len = #line
      for x = 0, x_len + 1 do maze[x] = {} end
    end
    x = 1
    for c in line:gmatch('.') do
      maze[x][y] = (c == '*' and 1 or 0)  -- Means c == '*' ? 1 : 0.
      x = x + 1
    end
    y = y + 1
  end
  y_len = #maze[1]

  -- Build the grid connectivity graph.
  build_G()

  -- Below is debug code to check that the maze was parsed correctly.
  --[[
  for y = 1, y_len do
    for x = 1, x_len do
      io.write(maze[x][y] .. ' ')
    end
    print('')
  end
  --]]
end

function love.update(dt)
end

function love.draw()
  love.graphics.setColor(20, 180, 40)

  -- Draw the maze.
  local bkg_color  = { 40,  40,  40}
  local wall_color = {160, 180, 130}
  local colors = {[0] = bkg_color, [1] = wall_color}
  for y = 1, y_len do
    for x = 1, x_len do
      love.graphics.setColor(colors[maze[x][y]])
      draw_tile(x, y)
    end
  end

  -- Draw the goal.
  love.graphics.setColor(0, 200, 0)
  draw_dot(x_len, 1, 10)

  -- Draw all the entities.
  for _, entity in pairs(entities) do
    entity:draw()
  end
end

function love.mousepressed(x, y, button)
  x = math.floor(x / tile_size)
  y = math.floor(y / tile_size)

  if maze[x][y] == 0 then
    table.insert(entities, Entity.new(x, y))
  end
end

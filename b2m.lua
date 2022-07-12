Bitmap = {
    new = function(self, width, height)
      local instance = setmetatable({ width=width, height=height }, self)
      instance:alloc()
      return instance
    end,
    alloc = function(self)
     self.pixels = {}
      for y = 1, self.height do
        self.pixels[y] = {}
        for x = 1, self.width do
          self.pixels[y][x] = 0x00000000
        end
      end
    end,
    clear = function(self, c)
      for y = 1, self.height do
        for x = 1, self.width do
          self.pixels[y][x] = c or 0x00000000
        end
      end
    end,
    get = function(self, x, y)
      x, y = math.floor(x+1), math.floor(y+1) -- given 0-based indices, use 1-based indices
      if ((x>=1) and (x<=self.width) and (y>=1) and (y<=self.height)) then
        return self.pixels[y][x]
      else
        return nil
      end
    end,
    set = function(self, x, y, c)
      x, y = math.floor(x+1), math.floor(y+1) -- given 0-based indices, use 1-based indices
      if ((x>=1) and (x<=self.width) and (y>=1) and (y<=self.height)) then
        self.pixels[y][x] = c or 0x00000000
      end
    end,
  }
  Bitmap.__index = Bitmap
  setmetatable(Bitmap, { __call = function (t, ...) return t:new(...) end })

  Bitmap.savePPM = function(self, filename)
    local fp = io.open(filename, "wb")    
    if fp == nil then return false end
    fp:write(string.format("P6\n%d %d\n%d\n", self.width, self.height, 255))
    for y = 1, self.height do
      for x = 1, self.width do
        local pix = self.pixels[y][x]
        fp:write(string.char(pix[1]), string.char(pix[2]), string.char(pix[3]))
      end
    end
    fp:close()
    return true
  end
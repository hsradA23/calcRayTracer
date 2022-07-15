-- Local functions are faster in lua
-- so we import them
local sqrt = math.sqrt
local floor = math.floor

-- VECTOR CLASS FUNCTIONS
vec = {}
function vec:new(a,b,c)
    if a == nil then
        newObj = {0,0,0}
    else
        newObj = {a,b,c}
    end
    self.__index = self
    return setmetatable(newObj, self)
end


function vec.__add(v1, v2)
    return vec:new(v1[1] + v2[1], 
    v1[2] + v2[2],
    v1[3] + v2[3])
end

function vec.__mul(v, v1)
    return vec:new(v1[1] * v, 
    v1[2]  * v,
    v1[3]  * v)
end


function vec.__sub(v1, v2)
    return vec:new(v1[1] - v2[1], 
    v1[2] - v2[2],
    v1[3] - v2[3])
end


function dot(v1, v2)
    return (v1[1] * v2[1]) + (v1[2] * v2[2]) + (v1[3] * v2[3])
end


function cross(v1,v2)
    return vec:new(
        (v1[2] * v2[3])-(v2[2] * v1[3]),
        (v2[1] * v1[3])-(v1[1] * v2[3]),
        (v1[1] * v2[2])-(v2[1] * v1[2])
    )
end

function vec:magnitude()
    return sqrt(self[1]^2 + self[2]^2 + self[3]^2 )
end

function vec:normalize()
    m = self:magnitude()
    return vec:new(self[1]/m , self[2]/m, self[3]/m)
end

function vec:fixColor()
    -- I store colors as vectors
    -- this function converts floats to integers
    self[1] = floor(self[1])
    self[2] = floor(self[2])
    self[3] = floor(self[3])
end



-- SPHERE CLASS FUNCTIONS
sphere = {}

function sphere:new(v,rad,c)
    -- vec is a vector pointing to the center of the sphere
    -- rad is the radius of the sphere
    -- col is the color (stored as a vector cause it saves memory lol)
    newObj = {vec=v, r=rad,col=c}
    self.__index = self
    return setmetatable(newObj, self)
end


function sphere:intersects(v, p)
    -- Returns nil if the sphere does not intersec a vector v passing through a point p
    -- Otherwise, returns the distance d
    -- https://en.wikipedia.org/wiki/Line%E2%80%93sphere_intersection
    oc = p - self.vec
    vv = dot(v,v)
    D = (2*dot(v,oc))^2 - 4 * vv * (dot(oc,oc) - self.r^2)
    
    if D > 0 then
        return (-2*dot(v,oc) - sqrt(D))/(2*vv)
    else
        return nil
    end
end

function sphere:getNormalAt(v)
    return v - self.vec
end

-- PLANE CLASS FUNCTIONS
plane = {}

function plane:new(n,p,c)
    -- vec is the Normal vector to the plane
    -- point is a point passing through the plane
    -- col is the color (stored as a vector)
    newObj = {vec=n, point=p,col=c}
    self.__index = self
    return setmetatable(newObj, self)
end

function plane:intersects(v, p)
    -- If the plane intersects to a vector v passing through point p
    -- returns the distance scalar to v
    -- Otherwise returns nil (also returns nil if distance scalar is negative)
    -- https://en.wikipedia.org/wiki/Line%E2%80%93plane_intersection
    num = dot(self.point - p ,self.vec)
    den = dot(v,self.vec)

    if den == 0 and num == 0 then
        return 0 -- plane is parallel to the line, intersects
    elseif den == 0 then
        return nil -- plane is parallel to the line
    else
        d = num/den -- intersects
        if d < 0 then -- cant be behind the camera
            return  nil
        else
            return d 
        end
    end
end

function plane:getNormalAt(v)
    return self.vec
end



-- Functions for the renderer

function bgcolor(h)
    -- The generates a linear gradient for the background
    -- Starts from color1 at the top to color2 at the bottom
    -- of the display
    v = (212-h)/212
    color1 = {149, 188, 245}
    color2 = {255, 255, 255}
    return {
        floor(color1[1]*v + color2[1]*(1-v)),
        floor(color1[2]*v + color2[2]*(1-v)),
        floor(color1[3]*v + color2[3]*(1-v))}
end

function min_dist(objs, vec)
    -- Given a list of objects, it finds the object that is closest
    -- to the vector assuming it starts from the origin.
    -- Performs a simple linear scan.
    origin = vec:new()
    m = {dist = objs[1]:intersects(vec, origin), obj = objs[1]}
    for o = 2, #objs do
        d = objs[o]:intersects(vec, origin)
        if d ~= nil and m.dist ~= nil and d<m.dist then
            m = {dist = objs[o]:intersects(vec, origin), obj = objs[o]}
        elseif m.dist == nil and d ~= nil then 
            m = {dist = objs[o]:intersects(vec, origin), obj = objs[o]}
        end
    end
    return m
end


---------------------------------
--- The main code starts here ---
---------------------------------

l = vec:new(-10,30,450)

objects = {
    plane:new(vec:new(0,1,0), vec:new(0,-30-50,0), vec:new(217, 214, 139)),
    sphere:new(vec:new(90,-30,400), 50, vec:new(255,255,255)),
    sphere:new(vec:new(-80,-30,600),50, vec:new(255,255,255)),
}

pixel_array = {}
function render()
    imem = collectgarbage("count")
    for px = 0, 318 do
        if px % 2 == 0 then
            collectgarbage("collect")
        end
        pixel_array[px] = {}
        for py=0, 212 do
            -- pv is the pixel vector, it points from the origin to the pixel
            pv = vec:new(px - 159,-py + 106 ,400)
            
            co = min_dist(objects, pv) -- closest object + the distance
            dist = co.dist
            if  dist ~= nil and dist > 0 then
                is = dist*(pv) -- Point of intersection of the ray
                norm = co.obj:getNormalAt(is) ---# Normal vector to the object at the ray intersection

                alp = (dot(norm:normalize(), (l-dist*pv):normalize())) -- Lambert's cosine law

                -- Check if any object casts a shadow
                ill = true
                for os=1,#objects do
                    if objects[os]:intersects(l-is,l) ~= nil and objects[os] ~= co.obj then
                        ill = false
                    end
                end

                if not ill then
                    alp = alp * 0.5
                end


                if alp < 0 then
                    alp = 0
                end

                pcolor = alp*co.obj.col
                pcolor:fixColor()
            else
                pcolor = bgcolor(py)
            end
                pixel_array[px][py] = pcolor
        end
    end
    fmem = collectgarbage("count")
    print(imem, fmem, fmem-imem)
end


render()

-- This makes the code be able to run on both the calculator
-- and a lua interpreter, without having to edit anything
if platform == nil then
    local bmp = require('b2m') 
    local b = Bitmap:new(318, 212)
    b:clear({255,255,255})
    for i = 0,318 do
        for j = 0,212 do
            b:set(i,j,pixel_array[i][j])
        end
    end
    b:savePPM('p6.ppm')
else
    function on.paint(gc)
        for i = 0,318 do
            for j = 0,212 do
                gc:setColorRGB(unpack(pixel_array[i][j]))
                gc:drawRect(i,j,0,0)
            end
        end
    end
end
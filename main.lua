-- VECTOR FUNCTIONS
vec = {}
function vec:new(a,b,c)
    if a == nil then
        newObj = {x=0,y=0,z=0}
    else
        newObj = {x=a,y=b,z=c}
    end
    self.__index = self
    return setmetatable(newObj, self)
end


function vec.__add(v1, v2)
    return vec:new(v1.x + v2.x, 
    v1.y + v2.y,
    v1.z + v2.z)
end

function vec.__mul(v, v1)
    return vec:new(v1.x * v, 
    v1.y  * v,
    v1.z  * v)
end


function vec.__sub(v1, v2)
    return vec:new(v1.x - v2.x, 
    v1.y - v2.y,
    v1.z - v2.z)
end


function dot(v1, v2)
    return (v1.x * v2.x) + (v1.y * v2.y) + (v1.z * v2.z)
end


function cross(v1,v2)
    return vec:new(
        (v1.y * v2.z)-(v2.y * v1.z),
        (v2.x * v1.z)-(v1.x * v2.z),
        (v1.x * v2.y)-(v2.x * v1.y)
    )
end

function vec:magnitude()
    return math.sqrt(self.x^2 + self.y^2 + self.z^2 )
end

function vec:normalize()
    m = self:magnitude()
    return vec:new(self.x/m , self.y/m, self.z/m)
end


-- SPHERE FUNCTIONS
sphere = {}

function sphere:new(v,rad)
    newObj = {vec=v, r=rad,t=0}
    self.__index = self
    return setmetatable(newObj, self)
end


function sphere:intersects(v)
    c = self.vec -- center of the sphere
    te = dot(c,v)
    vv = dot(v,v)
    d = te * te - vv * (dot(c,c) - self.r*self.r)
    if d > 0 then
        return (2*te - math.sqrt(d))/(2*vv)
    else
        return nil
    end
end

function sphere:getNormalAt(v)
    return v - self.vec
end

-- Plane Function
plane = {}

function plane:new(n,p)
    newObj = {vec=n, point=p,t=1}
    self.__index = self
    return setmetatable(newObj, self)
end

function plane:intersects(v)
    den = dot(v,self.vec)
    num = dot(self.point,self.vec)

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
        math.floor(color1[1]*v + color2[1]*(1-v)),
        math.floor(color1[2]*v + color2[2]*(1-v)),
        math.floor(color1[3]*v + color2[3]*(1-v))}
end

function min_dist(objs, vec)
    m = {dist = objs[1]:intersects(vec), obj = objs[1]}
    for o = 2, #objs do
        d = objs[o]:intersects(vec)
        if d ~= nil and m.dist ~= nil and d<m.dist then
            m = {dist = objs[o]:intersects(vec), obj = objs[o]}
        elseif m.dist == nil and d ~= nil then 
            m = {dist = objs[o]:intersects(vec), obj = objs[o]}
        end
    end
    return m
end


---------------------------------
--- The main code starts here ---
---------------------------------

l = vec:new(0,30,500)

objects = {
    plane:new(vec:new(0,1,0), vec:new(0,-30-50,0)),
    sphere:new(vec:new(70,-30,400), 50),
    sphere:new(vec:new(-80,-30,600),50),
}

pixel_array = {}
for px = 0, 318 do
    pixel_array[px] = {}
    for py=0, 212 do
        pv = vec:new(px - 159,-py + 106 ,400)
        
        co = min_dist(objects, pv) -- closest object + the distance
        dist = co.dist
        if  dist ~= nil and dist > 0 then

            norm = co.obj:getNormalAt(dist*(pv)) ---# Normal vector to the sphere at the ray intersection
            alp = (dot(norm:normalize(), (l-dist*pv):normalize()))
            if alp < 0 then
                alp = 0
            end

            pcolor = {math.floor(255*alp),0,math.floor(255*alp)}
        else
            pcolor = bgcolor(py)
        end
            pixel_array[px][py] = pcolor
    end
end

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
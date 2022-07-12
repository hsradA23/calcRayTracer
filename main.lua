local bmp = require('b2m') 


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

function sphere:new(a,b,c,rad)
    newObj = {x=a, y=b, z=c, r=rad}
    self.__index = self
    return setmetatable(newObj, self)
end


function sphere:intersects(v)
    --d = cross(v,vec:new(self.x, self.y, self.z)):magnitude()/v:magnitude()
    c = vec:new(-self.x, -self.y, -self.z) -- center of the sphere
    te = dot(c,v)
    vv = dot(v,v)
    d = te * te - vv * (dot(c,c) - self.r*self.r)
    if d > 0 then
        return -(2*te - math.sqrt(d))/(2*vv)
    else
        return -1
    end
end


function bgcolor(h)
    v = (212-h)/212

    return {
        math.floor(149*v + 255*(1-v)),
        math.floor(188*v + 255*(1-v)),
        math.floor(245*v + 255*(1-v)),}
    
end


s = sphere:new(0,0,600,50)
t = vec:new(159,106,0)


local b = Bitmap:new(318, 212)                  -- Remove for calculator
b:clear({255,255,255})                          -- Remove for calculator
for px = 0, 318 do
    for py=0, 212 do
        pv = vec:new(px,py,400)

        dist = s:intersects(pv-t)
        if  dist ~= -1 then
            pcolor = {255,0,255}
            
            --gc:setColorRGB(unpack(pcolor))
        else
            pcolor = bgcolor(py)
            --gc:setColorRGB(unpack(pcolor))
        end
        --gc:drawRect(px,py,0,0)
        b:set(px,py,pcolor)                     -- Remove for calculator
    end
end

b:savePPM('p6.ppm')                             -- Remove for calculator
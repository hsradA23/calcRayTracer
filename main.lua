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
    d = cross(v,vec:new(self.x, self.y, self.z)):magnitude()/v:magnitude()
    if d < self.r then
        return true
    else
        return false
    end
end


s = sphere:new(0,0,600,30)
t = vec:new(159,106,0)


local b = Bitmap:new(318, 212)
b:clear({255,255,255})
for px = 0, 318 do
    for py=0, 212 do
        pv = vec:new(px,py,400)
        if s:intersects(pv-t) then
            pcolor = {255,255,255}
            --gc:setColorRGB(unpack(pcolor))
        else
            pcolor = {0,0,0}
            --gc:setColorRGB(unpack(pcolor))
        end
        --gc:drawRect(px,py,0,0)
        b:set(px,py,pcolor)
    end
end

b:savePPM('p6.ppm')
#include "math.lua"

function GetBodies(min, max, requirements)
	QueryRequire(require and require or "")
	return QueryAabbBodies(min and min or VEC_MIN, 
    max and max or VEC_MAX)
end

function GetBodyCount(min, max, requirements)
	QueryRequire(require and require or "")
	return #GetBodies(min, max, requirements)
end

function GetShapes(min, max, require)
    QueryRequire(require and require or "")
	return QueryAabbShapes(min and min or VEC_MIN, 
    max and max or VEC_MAX)
end

function GetShapeCount(min, max, requirements)
	return #GetShapes(min, max, requirements)
end

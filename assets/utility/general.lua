-- UMF
#include "../umf/umf_utils.lua"

local VEC_MAX = Vec(math.huge, math.huge, math.huge)
local VEC_MIN = Vec(-math.huge, -math.huge, -math.huge)

function Count(elements)
  local count = 0
  for _ in pairs(elements) do count = count + 1 end
  return count
end
function Contains(elements, element)
	for index = 1, #elements do
		if elements[index] == element then return true end
	end
end
function Merge(first, second)
	for k,v in pairs(second) do first[k] = v end
	return first
end
function Concat(first, second)
    for index = 1, #second do
        first[#first + 1] = second[index]
    end
    return first
end
function Clone(object)
	return util.unserialize(util.serialize(object))
end
function IndexElements(elements)
	local indexed = {}

	for index = 1, #elements do
		indexed[elements[index]] = elements[index]
	end

	return indexed
end

function GetBodies(min, max, require)
	QueryRequire(require and require or "")
	return QueryAabbBodies(min and min or VEC_MIN, max and max or VEC_MAX)
end
function GetBodyCount(min, max, require)
	QueryRequire(require and require or "")
	return #QueryAabbBodies(min and min or VEC_MIN, max and max or VEC_MAX)
end

function GetShapes(min, max, require)
	return QueryAabbShapes(min and min or VEC_MIN, max and max or VEC_MAX)
end
function GetShapeCount(min, max, require)
	return #QueryAabbShapes(min and min or VEC_MIN, max and max or VEC_MAX)
end
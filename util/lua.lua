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
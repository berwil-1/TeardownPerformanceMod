function Max(values)
	local max = -math.huge
	for index = 1, #values do
		max = math.max(max, values[index])
	end
	return max
end

function Min(values)
	local min = math.huge
	for index = 1, #values do
		min = math.min(min, values[index])
	end
	return min
end

function Average(values)
	local average = 0
	for index = 1, #values do
		average = average + values[index]
	end
	return average / math.max(#values, 1)
end

function MaxMinAverage(values)
	local max = -math.huge
	local min = math.huge
	local average = 0
	for index = 1, #values do
		max = math.max(max, values[index])
		min = math.min(min, values[index])
		average = average + values[index]
	end

	return max, min, average / math.max(#values, 1)
end

function Round(value, decimals, overflow)
	decimals = decimals or 0
	overflow = overflow or 0.5 / 10 ^ decimals
	return math.floor((value + overflow) * 10 ^ decimals) / 10 ^ decimals
end

function Clamp(value, from, to)
	return math.min(math.max(value, from), to)
end

function Lerp(from, to, time)
	return from + (to - from) * time
end

function Random(min, max)
	return math.random(1000) / 1000 * (max - min) + min
end

function RandomVec(scale)
	return Vec(Random(-scale, scale), Random(-scale, scale), Random(-scale, scale))
end
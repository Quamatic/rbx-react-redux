local function shallowEqual(a: any, b: any)
	if a == b then
		return true
	end

	if typeof(a) ~= "table" and typeof(b) ~= "table" then
		return false
	end

	if #a ~= #b then
		return false
	end

	for key, value in a do
		if b[key] ~= value then
			return false
		end
	end

	return true
end

return shallowEqual

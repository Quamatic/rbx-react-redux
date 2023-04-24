local defaultNoopBatch = function(callback: () -> ())
	callback()
end

local batch = defaultNoopBatch

local function getBatch()
	return batch
end

local function setBatch(newBatch: typeof(defaultNoopBatch))
	batch = newBatch
	return batch
end

return {
	getBatch = getBatch,
	setBatch = setBatch,
}

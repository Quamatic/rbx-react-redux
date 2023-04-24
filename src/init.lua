local batch = require(script.utils.batch)
local reactBatchedUpdates = require(script.utils.reactBatchedUpdates)

batch.setBatch(reactBatchedUpdates)

return {
	batch = reactBatchedUpdates,
}

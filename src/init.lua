local batch = require(script.utils.batch)
local reactBatchedUpdates = require(script.utils.reactBatchedUpdates)

local useDispatch = require(script.hooks.useDispatch)
local useStore = require(script.hooks.useStore)
local useSelector = require(script.hooks.useSelector)

-- Set our batch to use React's batched updates.
batch.setBatch(reactBatchedUpdates)

return {
	batch = reactBatchedUpdates,

	Provider = require(script.components.Provider),
	ReactReduxContext = require(script.components.Context),

	useDispatch = useDispatch.useDispatch,
	createDispatchHook = useDispatch.createDispatchHook,

	useSelector = useSelector.useSelector,
	createSelectorHook = useSelector.createSelectorHook,

	useStore = useStore.useStore,
	createStoreHook = useStore.createStoreHook,

	shallowEqual = require(script.utils.shallowEqual),
}

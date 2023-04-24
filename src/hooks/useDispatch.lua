local useStore_ = require(script.Parent.useStore)
local useDefaultStore = useStore_.useStore
local createStoreHook = useStore_.createStoreHook

local ReactReduxContext = require(script.Parent.Parent.components.Context)

local function createDispatchHook<S, A>(context)
	context = context or ReactReduxContext

	local useStore = if context == ReactReduxContext then useDefaultStore else createStoreHook(context)

	return function<State, Action>()
		local store = useStore()
		return store.dispatch
	end
end

return {
	createDispatchHook = createDispatchHook,
	useDispatch = createDispatchHook(),
}

local React = require(script.Parent.Parent.Parent.React)
local Redux = require(script.Parent.Parent.Parent.Redux)

local useDefaultReduxContext = require(script.Parent.useReduxContext)
local ReactReduxContext = require(script.Parent.Parent.components.Context)

local function createStoreHook<S, A>(context)
	context = context or ReactReduxContext

	local useReduxContext = if context == ReactReduxContext
		then useDefaultReduxContext
		else function()
			return React.useContext(context)
		end

	return function<State, Action>()
		local store = useReduxContext().store
		return store :: Redux.Store<State, Action, {}>
	end
end

return {
	createStoreHook = createStoreHook,
	useStore = createStoreHook(),
}

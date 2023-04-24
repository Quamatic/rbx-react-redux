local React = require(script.Parent.Parent.Parent.React)

local useDefaultReduxContext = require(script.Parent.useReduxContext)
local ReactReduxContext = require(script.Parent.Parent.components.Context)
local types = require(script.Parent.Parent.types)

local refEquality: types.EqualityFn<any> = function(a, b)
	return a == b
end

local function subscribe(store_, callback)
	return store_.subscribe(callback)
end

local function createSelectorHook(context)
	context = context or ReactReduxContext

	local useReduxContext = if context == ReactReduxContext
		then useDefaultReduxContext
		else function()
			return React.useContext(context)
		end

	return function<TState, Selected>(selector: (state: TState) -> Selected, equalityFn: types.EqualityFn<Selected>?): Selected
		equalityFn = equalityFn or refEquality

		if not _G.__DEV__ then
			if not selector then
				error("You must pass a selector to useSelector")
			end

			if typeof(selector) ~= "function" then
				error("You must pass a function as a selector to useSelector")
			end

			if typeof(equalityFn) ~= "function" then
				error("You must pass a function as an equality function to useSelector")
			end
		end

		local ctx = useReduxContext()
		local store = ctx.store

		local source = React.createMutableSource(store, function()
			return store.getState()
		end)

		local getSnapshot = React.useCallback(function(store_)
			return selector(store_.getState())
		end, { selector })

		local selectedState = React.useMutableSource(source, getSnapshot, subscribe)

		React.useDebugValue(selectedState)

		return selectedState
	end
end

return {
	useSelector = createSelectorHook(),
	createSelectorHook = createSelectorHook,
}

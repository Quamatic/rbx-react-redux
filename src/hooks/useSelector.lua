local React = require(script.Parent.Parent.Parent.React)

local useDefaultReduxContext = require(script.Parent.useReduxContext)
local ReactReduxContext = require(script.Parent.Parent.components.Context)
local types = require(script.Parent.Parent.types)

local refEquality: types.EqualityFn<any> = function(a, b)
	return a == b
end

local function is(x, y)
	return x == y and (x ~= 0 or 1 / x == 1 / y) or x ~= x and y ~= y
end

local function createSelectorHook(context)
	context = context or ReactReduxContext

	local useReduxContext = if context == ReactReduxContext
		then useDefaultReduxContext
		else function()
			return React.useContext(context)
		end

	return function<TState, Selected>(selector: (state: TState) -> Selected, isEqual: types.EqualityFn<Selected>?): Selected
		isEqual = isEqual or refEquality

		if not _G.__DEV__ then
			if not selector then
				error("You must pass a selector to useSelector")
			end

			if typeof(selector) ~= "function" then
				error("You must pass a function as a selector to useSelector")
			end

			if typeof(isEqual) ~= "function" then
				error("You must pass a function as an equality function to useSelector")
			end
		end

		local instRef = React.useRef(nil)
		local hasMemo = React.useRef(false)
		local memoizedSnapshot = React.useRef(nil)
		local memoizedSelection = React.useRef(nil)

		local inst
		if instRef.current == nil then
			inst = { hasValue = false }
			instRef.current = inst
		else
			inst = instRef.current
		end

		local ctx = useReduxContext()
		local store = ctx.store

		local source = React.createMutableSource(store, function()
			return store.getState()
		end)

		local getSnapshot = React.useCallback(function(store_)
			local nextSnapshot = store_.getState()

			if not hasMemo.current then
				hasMemo.current = true
				memoizedSelection.current = nextSnapshot

				local nextSelection = selector(nextSnapshot)
				if inst.hasValue then
					local currentSelection = inst.value
					if isEqual(currentSelection, nextSelection) then
						return currentSelection
					end

					memoizedSelection = nextSelection
					return nextSelection
				end
			end

			local prevSnapshot = memoizedSnapshot.current
			local prevSelection = memoizedSelection.current

			if is(prevSnapshot, nextSnapshot) then
				return prevSelection
			end

			local nextSelection = selector(nextSnapshot)

			if isEqual(prevSelection, nextSelection) then
				return prevSelection
			end

			memoizedSnapshot.current = nextSnapshot
			memoizedSelection.current = nextSelection

			return nextSelection
		end, { selector })

		local subscribe = React.useCallback(function(_, callback)
			return ctx.subscription:addNestedSub(callback)
		end, {})

		local selectedState = React.useMutableSource(source, getSnapshot, subscribe)

		React.useEffect(function()
			inst.hasValue = true
			inst.value = selectedState
		end, { selectedState })

		React.useDebugValue(selectedState)

		return selectedState
	end
end

return {
	useSelector = createSelectorHook(),
	createSelectorHook = createSelectorHook,
}

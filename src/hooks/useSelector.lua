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

-- This is written akin to useSyncExternalStoreWithSelector.
-- However, only React 18 has useSyncExternalStore, so since we are on React 17,
-- we have to use useMutableStore.

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

		local inst
		if instRef.current == nil then
			inst = { hasValue = false }
			instRef.current = inst
		else
			inst = instRef.current
		end

		local ctx = useReduxContext()
		local store = ctx.store

		local source = React.useMemo(function()
			return React.createMutableSource(store, function()
				return store.getState()
			end)
		end, { store })

		local getSnapshot = React.useMemo(function()
			local hasMemo = false
			local memoizedSnapshot
			local memoizedSelection: Selection

			local function memoizedSelector(nextSnapshot: TState)
				-- nextSnapshot is just the store
				nextSnapshot = nextSnapshot.getState()

				if not hasMemo then
					hasMemo = true
					memoizedSnapshot = nextSnapshot
					local nextSelection = selector(nextSnapshot)
					if inst.hasValue then
						local currentSelection = inst.value
						if isEqual(currentSelection, nextSelection) then
							memoizedSelection = currentSelection
							return currentSelection
						end
					end
					memoizedSelection = nextSelection
					return nextSelection
				end

				local prevSnapshot: TState = memoizedSnapshot
				local prevSelection: Selection = memoizedSelection

				if is(prevSnapshot, nextSnapshot) then
					return prevSelection
				end

				local nextSelection = selector(nextSnapshot)

				if isEqual(prevSelection, nextSelection) then
					return prevSelection
				end

				memoizedSnapshot = nextSnapshot
				memoizedSelection = nextSelection

				return nextSelection
			end

			return memoizedSelector
		end, { selector, isEqual })

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

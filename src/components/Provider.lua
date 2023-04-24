local React = require(script.Parent.Parent.Parent.React)

local ReactReduxContext = require(script.Parent.Parent.components.Context)

export type ProviderProps<A, S> = {
	store: any,
	context: any?,
	children: React.React_Node,
}

local function Provider<A, S>(props: ProviderProps<A, S>)
	local store = props.store

	local contextValue = React.useMemo(function()
		local subscription = {}
		return {
			store = store,
			subscription = subscription,
		}
	end, { store })

	local previousState = React.useMemo(function()
		return store.getState()
	end, { store })

	React.useLayoutEffect(function()
		local subscription = contextValue.subscription

		subscription.onStateChange = subscription.notifyNestedSubs
		subscription.trySubscribe()

		if previousState ~= store.getState() then
			subscription.notifyNestedSubs()
		end

		return function()
			subscription.tryUnsubscribe()
			subscription.onStateChange = nil
		end
	end, { contextValue, previousState })

	local Context = props.context or ReactReduxContext

	return React.createElement(Context.Provider, {
		value = contextValue,
	}, props.children)
end

return Provider

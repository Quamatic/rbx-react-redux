local React = require(script.Parent.Parent.Parent.React)
local Redux = require(script.Parent.Parent.Parent.Redux)

export type ReactReduxContextValue<SS = any, A = Redux.AnyAction> = {
	store: Redux.Store<SS, A, {}>,
	subscription: any,
}

local ReactReduxContext = React.createContext(nil :: any) :: React.ReactContext<ReactReduxContextValue<any, any>>

export type ReactReduxContextInstance = typeof(ReactReduxContext)

return ReactReduxContext

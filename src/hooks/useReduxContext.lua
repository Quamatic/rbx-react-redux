local React = require(script.Parent.Parent.Parent.React)
local ReactReduxContext = require(script.Parent.Parent.components.Context)

local function useReduxContext(): ReactReduxContext.ReactReduxContextValue<any, any>?
	local contextValue = React.useContext(ReactReduxContext)

	if _G.__DEV__ and not contextValue then
		error("could not find react-redux context value; please ensure the component is wrapped in a <Provider>")
	end

	return contextValue
end

return useReduxContext

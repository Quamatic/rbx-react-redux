local ReplicatedStorage = game:GetService("ReplicatedStorage")

local React = require(ReplicatedStorage.React)
local ReactRoblox = require(ReplicatedStorage.ReactRoblox)
local Redux = require(ReplicatedStorage.Redux)
local ReactRedux = require(ReplicatedStorage.ReactRedux)

local e = React.createElement

local counterSlice = Redux.createSlice({
	name = "counter",
	initialState = { value = 0, someOtherValue = 0 },
	reducers = {
		increment = function(state)
			state = table.clone(state)
			state.value += 1
			return state
		end,
		decrement = function(state)
			state = table.clone(state)
			state.value -= 1
			return state
		end,
	},
})

local increment, decrement = counterSlice.actions.increment, counterSlice.actions.decrement

local store = Redux.configureStore({
	reducer = {
		counter = counterSlice.reducer,
	},
})

local function Demo()
	local count = ReactRedux.useSelector(function(state)
		return state.counter.value
	end)

	local someOtherValue = ReactRedux.useSelector(function(state)
		return state.counter.someOtherValue
	end)

	local dispatch = ReactRedux.useDispatch()

	return e("TextButton", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(250, 100),
		Text = `Counter: {count}\nSomeOtherValue: {someOtherValue}`,

		[React.Event.Activated] = function()
			dispatch(increment())
		end,

		[React.Event.MouseButton2Click] = function()
			dispatch(decrement())
		end,
	})
end

return function(target: Frame)
	local root = ReactRoblox.createRoot(Instance.new("Folder"))

	root:render(ReactRoblox.createPortal({
		App = e(ReactRedux.Provider, {
			store = store,
		}, e(Demo)),
	}, target))

	return function()
		root:unmount()
	end
end

# rbx-react-redux
Performant React bindings for `rbx-redux`
 
# Installation
Add this to your `wally.toml` file:
```console
ReactRedux = "quamatic/rbx-react-redux@1.0.0"
```

# Usage Guide
## Passing a Store
```lua
-- App.lua
local React = require(Path.To.React)
local ReactRedux = require(Path.To.ReactRedux)

local store = require(Path.To.Your.Redux.Store)

local SomeRandomElement = ...

local function App()
    return React.createElement(ReactRedux.Provider, {
        store = store,
    }, React.createElement(SomeRandomElement))
end

-- OR --

-- Using another component for the sake of readability
local function StoreConsumers()
    return e(React.Fragment, nil, {
        SomeRandomElement = React.createElement(SomeRandomElement)
    })
end

local function App()
    return React.createElement(ReactRedux.Provider, {
        store = store,
    }, e(StoreConsumers))
end
```

## Basic Counter Example
```lua
-- Counter.lua
local React = require(Path.To.React)
local ReactRedux = require(Path.To.ReactRedux)

local counterActions = require(Path.To.Some.Slice.With.Actions)

local function Counter()
    local count = ReactRedux.useSelector(function(state)
        -- State start as { counter = 0 } for example purposes.
        return state.counter.value
    end)

    local dispatch = ReactRedux.useDispatch()

    return React.createElement("TextLabel", {
        Text = `Counter: {count}`,

        [React.Event.Activated] = function()
            -- Increment counter
            dispatch(counterActions.increment())
        end,

        [React.Event.MouseButton2Click] = function()
            -- Decrement counter
            dispatch(counterActions.decrement())
        end,
    })
end
```

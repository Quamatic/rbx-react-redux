local ListenerCollection = require(script.ListenerCollection)

local nullListeners = ListenerCollection.new()

local Subscription = {}
Subscription.__index = Subscription

function Subscription.new(store, parentSub)
	return setmetatable({
		_store = store,
		_parentSub = parentSub :: Subscription?,
		_unsubscribe = nil :: () -> ()?,
		_listeners = nullListeners,
	}, Subscription)
end

function Subscription:addNestedSub(listener: () -> ())
	self:trySubscribe()
	return self._listeners:subscribe(listener)
end

function Subscription:notifyNestedSubs()
	self._listeners:notify()
end

function Subscription:isSubscribed()
	return not not self._unsubscribe
end

function Subscription:getListeners()
	return self._listeners
end

function Subscription:trySubscribe()
	if self._unsubscribe == nil then
		local function handleChangeWrapper()
			if self.onStateChange then
				self.onStateChange()
			end
		end

		self._unsubscribe = if self._parentSub
			then self._parentSub:addNestedSub(handleChangeWrapper)
			else self._store.subscribe(handleChangeWrapper)

		self._listeners = ListenerCollection.new()
	end
end

function Subscription:tryUnsubscribe()
	if self._unsubscribe ~= nil then
		self._unsubscribe()
		self._unsubscribe = nil

		self._listeners:clear()
		self._listeners = nullListeners
	end
end

export type Subscription = typeof(Subscription.new())

return Subscription

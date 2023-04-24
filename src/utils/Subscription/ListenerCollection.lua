local batch = require(script.Parent.Parent.batch)

local ListenerCollection = {}
ListenerCollection.__index = ListenerCollection

function ListenerCollection.new()
	return setmetatable({
		_batch = batch.getBatch(),
		_first = nil,
		_last = nil,
	}, ListenerCollection)
end

function ListenerCollection:clear()
	self._first = nil
	self._last = nil
end

function ListenerCollection:notify()
	self._batch(function()
		local listener = self._first
		while listener do
			listener.callback()
			listener = listener.next
		end
	end)
end

function ListenerCollection:get()
	local listeners: { Listener } = {}
	local listener: Listener? = self._first

	while listener do
		table.insert(listeners, listener)
		listener = listener.next
	end

	return listeners
end

function ListenerCollection:subscribe(callback: () -> ())
	local isSubscribed = true

	self._last = {
		callback = callback,
		next = nil,
		prev = self._last,
	}

	local listener: Listener = self._last

	if listener.prev then
		listener.prev.next = listener
	else
		self._first = listener
	end

	return function()
		if not isSubscribed or self._first == nil then
			return
		end

		isSubscribed = false

		if listener.next then
			listener.next.prev = listener.prev
		else
			self._last = listener.prev
		end

		if listener.prev then
			listener.prev.next = listener.next
		else
			self._first = listener.next
		end
	end
end

export type Listener = {
	callback: () -> (),
	next: Listener?,
	prev: Listener?,
}

export type ListenerCollection = typeof(ListenerCollection.new())

return ListenerCollection

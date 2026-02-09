-- Credit to: https://github.com/Jyouya/Ashita-Stuff/blob/master/addons/libs/event.lua

local Event, EventProxy = {}, {}

function Event.new()
	local self = setmetatable({
		handlers = {},
		once_handlers = {},
	}, { __index = EventProxy })
	return self
end

function EventProxy:Connect(fn)
	self.handlers[fn] = fn

	return function()
		self.handlers[fn] = nil
	end
end

function EventProxy:Once(fn)
	self.once_handlers[fn] = fn

	return function()
		self.once_handlers[fn] = nil
	end
end

function EventProxy:Fire(...)
	for _, fn in pairs(self.handlers) do
		fn(...)
	end

	for _, fn in pairs(self.once_handlers) do
		fn(...)
		self.once_handlers[fn] = nil
	end
end

return Event

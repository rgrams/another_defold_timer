
--####################  Another Timer Module for Defold  ####################
-- Gives full control over timers stored in individual scripts, to accomodate pausing and slow-motion. (like go.animate())

-- • This requires a tiny bit of extra setup, but means pausing/slow motion will automatically work.
-- • Timer data is stored in a 'self' property, with the key defined below (line 21)

-- Requirements For Use:
-- • call M.init(self) on init()
-- • call M.update(self, dt) on update()
--
-- • Then use M.new and M.delay as desired to create persistent timers and one-off delays
-- • Start, pause, stop, change callback, set current time, etc. at runtime by accessing the timer's properties.
--Example:
--		self.myTimer = timer.new(...)
--		self.myTimer:pause()
--		self.myTimer.t = 1.5 (timers count down from dur to 0)

local M = {}

local key = "timer module key" -- name of key property added to 'self'. Presumably you won't overwrite this.

--########################################  Private Functions  ########################################
-- All properties of timers (not of delays). 

local function start(self, fromStart) -- start/resume the timer
	-- if fromStart then the timer plays from the beginning, even if it was previously paused partway
	fromStart = fromStart or false
	self.paused = false
	if self.t <= 0 or fromStart then
		self.t = self.dur
	end
end

local function pause(self)
	self.paused = true
end

local function stop(self)
	self.paused = true
	self.t = 0
end


--########################################  Public Functions  ########################################

function M.init(self) -- adds 'key' property to self & initializes the object's timer table
	self[key] = {}
end

function M.new(self, dur, cb, repeating, startNow) -- create a new, persistent timer, repeating or non-.
	repeating = repeating or false
	startNow = startNow or false
	local timer = {
		persist = true,
		dur = dur,
		cb = cb,
		repeating = repeating,
		t = startNow and dur or 0,
		paused = false,
		start = start,
		pause = pause,
		stop = stop
	}
	table.insert(self[key], timer)
	return timer
end

function M.delay(self, dur, cb) -- creates a simplified, single-use timer to delay a function call
	local timer = {dur = dur, cb = cb, t = dur}
	table.insert(self[key], timer)
	return timer
end

function M.update(self, dt) -- update timers for the 'self' object
	for i, v in ipairs(self[key]) do
		if not v.paused and v.t > 0 then
			v.t = v.t - dt
			if v.t <= 0 then
				if v.repeating then
					v.t = v.t + v.dur
				else
					v.t = 0
				end
				if v.cb then v.cb() end
				if not v.persist then table.remove(self[key], i) end
			end
		elseif not v.persist then
			v = nil
		end
	end
end

return M

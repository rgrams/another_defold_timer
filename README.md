#  Another Timer Module for Defold
_Designed to accomodate pausing and give full control of your timers._

This is yet another simple timer module for Defold. It doesn't have either the same ease-of-use or presumably the performance of Britzl's timer native extension, but it's designed to accomodate pausing and slow-motion (like go.animate) and to give you full control at any time.

## Basic Setup & Usage

You need to add three lines of code to your script to use this module.

First you have to require it.

```
local timer = require "timer.timer"
```

Then you must call `timer.init(self)` in your script's init function. This will create a property in `self` to store all the timer data for that script instance.

The third required line is `timer.update(self, dt)` in your script's update function. You are free to _not_ call this function (or call it with dt=0) if you want to pause all the timers for this object, and this will happen automatically if you pause the collection proxy that the script is in (with `msg.post("#proxy", "set_time_step", {factor = 0, mode = 0})`).

That's all the setup required. Then you can use timer.new() and timer.delay() as desired to create persistent timers and one-off delays. Timers can be started, paused, resumed and modified at runtime via their properties (see below).

#### function timer.new(self, dur, cb, [repeating], [startNow])

This will create a new, persistent timer. Returns the timer object, which you probably want to keep somewhere.

* dur <kbd>number</kbd> -- The duration of the timer in seconds.
* cb <kbd>function</kbd> -- The timer's callback---the function that will be called when it ends (or every time it loops). Can be `nil`.
* repeating <kbd>bool</kbd> -- [optional] Whether the timer should repeat forever or stop when its time reaches zero. False (non-repeating) by default.
* startNow <kbd>bool</kbd> -- [optional] Whether the timer should start immediately or not. False by default (it will do nothing until you call its `start` function).


#### function timer.delay(self, dur, cb)

Creates a simplified, single-use timer to delay a function call. Delays are affected by the `dt` in timer.update(), but otherwise can't be paused or delayed. They start immediately and fire their callback and are deleted when their time runs out. `timer.delay()` returns the timer object. 

## Timer Properties

Each timer is just a table with a handful of properties. You _can_ modify any of these properties at runtime, though some of them you probably shouldn't.

* dur <kbd>number</kbd> -- The full duration of the timer (in seconds). Feel free to modify.
* t <kbd>number</kbd> -- The current time remaining on the timer (in seconds). Timers count down from `dur` to 0. Feel free to modify. If you set it to zero or less, the timer will fire its callback next update(). It can also be useful to get this property and use it for time-based calculations.
* cb <kbd>function</kbd> -- The timer's callback function (or `nil`). Called whenever `t` hits 0.
* persist <kbd>bool</kbd> -- Whether the timer should be deleted when it finishes or not.
* repeating <kbd>bool</kbd> -- Whether the timer should restart when it finishes or not.
* paused <kbd>bool</kbd> -- Whether the timer is paused or not. Feel free to access this to see if the timer is running, but it's better to use the `start`, `stop`, and `pause` functions rather than modify it directly.

#### Function Properties

These properties are functions. Use them, but don't modify them unless you want to break stuff. Call them with a colon (i.e. `self.myTimer:pause()`).

* start(self, [fromStart]) - Start/resume the timer.
    * fromStart <kbd>bool</kbd> -- [optional] If `true`, the timer will reset its time to its full duration. Otherwise it will resume where it left off (resetting the time if it's already at 0). `False` by default.

* pause(self) - Pause the timer

* stop(self) - Stop the timer. (Pauses and resets timer to its full duration.)

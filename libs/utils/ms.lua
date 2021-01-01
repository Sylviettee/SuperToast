--- module Utility for managing time
---@class ms
local ms = {}

local s = 1000
local m = s * 60
local h = m * 60
local d = h * 24
local w = d * 7
local y = d * 365.25

--- Get the amount of milliseconds in x years
---@param years number
---@return number
function ms.years(years)
   return years * y
end

--- Get the amount of milliseconds in x weeks
---@param weeks number
---@return number
function ms.weeks(weeks)
   return weeks * w
end

--- Get the amount of milliseconds in x days
---@param days number
---@return number
function ms.days(days)
   return days * d
end

--- Get the amount of milliseconds in x hours
---@param hours number
---@return number
function ms.hours(hours)
   return hours * h
end

--- Get the amount of milliseconds in x minutes
---@param minutes number
---@return number
function ms.minutes(minutes)
   return minutes * m
end

--- Get the amount of milliseconds in x seconds
---@param seconds number
---@return number
function ms.seconds(seconds)
   return seconds * s
end

--- Format the milliseconds in a long way eg 10 seconds
---@param milliseconds number
---@return string
function ms.formatLong(milliseconds)
   local msAbs = math.abs(milliseconds)

   if msAbs >= d then
      return ms.plural(milliseconds, msAbs, d, 'day')
   end
   if msAbs >= h then
      return ms.plural(milliseconds, msAbs, h, 'hour')
   end
   if msAbs >= m then
      return ms.plural(milliseconds, msAbs, m, 'minute')
   end
   if msAbs >= s then
      return ms.plural(milliseconds, msAbs, s, 'second')
   end

   return tostring(milliseconds) .. ' ms'
end

--- Pluralize an amount of time
---@param mili number
---@param msAbs number
---@param n number
---@param name string
---@return string
function ms.plural(mili, msAbs, n, name)
   local isPlural = (msAbs >= n * 1.5)

   return tostring(math.floor((mili / n) + 0.5)) .. ' ' .. tostring(name) .. tostring((isPlural and 's') or '')
end

return ms

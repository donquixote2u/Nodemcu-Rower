-- Rowing timer via ESP8266 and hall effect sensor on flywheel magnets
--manifest: Rower,menu, settings, screen, ide, WifiConnect, wificredentials
-- Constants
wifiTrys     = 0      -- reset counter of trys to connect to wifi
NUMWIFITRYS  = 20    -- Maximum number of WIFI Testings while waiting for connection
function init_rower()
dofile("Rower.lua")
initTimeout=3000       -- // timer in ms
initTimer:alarm(initTimeout,tmr.ALARM_SINGLE,function() checkConnection(init_wifi) end) 

end
initTimeout=5000       -- // timer in ms
initTimer=tmr.create()  -- // start timer
initTimer:alarm(initTimeout,tmr.ALARM_SINGLE,init_rower) 
require("wificredentials")
require("WifiConnect")
function init_wifi()
dofile("ide.lua")
end


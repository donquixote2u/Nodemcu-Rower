--[[  Rower Mk 3 - by Bruce Woolmore 7/4/2017
  This version for Wemos D1 Mini (ESP8266 dev bd) running Nodemcu lua env 
  vsn 1.5.4.1 custom compile with math,ucglib 
  
 18/6/15 note stroke timeout of 700 too high - skips on fast pulls
 counts all Hi to Lo state changes in the Hall effect sensor
Hall Effect sensor sense pin to Digital 1 (gpio 4 )
ILI9341 screen driven by SPI ;
D0	0	RST
D5	5	SCK
D6	6	MISO
D7	7	MOSI
3v3		VCC,LED (+200ohm)
GND		GND
D8	8	CS
D4	4	D/C
D3	3	
D2	2	
D1	1	Sense
--]]

 -- on interrupt from Hall Effect Sensor pin, calc elapsed time since last int
function CalcSpeed()
pulseOn=true 
print("\r\ninterrupt triggered")
msNow=tmr.now()
if (msLast ~= 0) then
    local Period = msNow-msLast
    if (Period > 250000) then -- if period not > 1/4 sec, bogus or hurricane!
     msElapsed=Period
     print("ms="..msElapsed.."\r\n")
     msLast=msNow -- save reading as Last
   end
else -- last is 0 so initialise
   msLast=msNow -- save reading as Last
end  -- end comparison against last 
end 

--enable interrupts
function enInt()     
    gpio.mode(SENSEPIN,gpio.INT)
    gpio.trig(SENSEPIN,'down',CalcSpeed)
end

--disable interrupts
function disInt()
     gpio.mode(SENSEPIN, gpio.INPUT)
end
  
-- start here ; intit constants, variables, set up sensor pin interrupts
sessionTimeout=5000     --// timeout in ms to detect end of session
strokeTimeout=500   --// timeout in ms to detect end of stroke
pulseDistance=20.0  --// distance travelled in cm between each pulse
dofile("screen.lua")
init_display() -- set up display screen ready to show data
--init state variables:
msLast = 0
msElapsed = 0
pulseOn=false
lastPulse = 0      -- previous sensor timestamp 
strokeElapsed = 0  -- ms since end of last stroke
strokeCount=0 
pulseCount=0
totDistance=0
totTime=0
kmDistance=0
kmHour=0
strokesMinute=0
SENSEPIN = 1
enInt()         -- turn sensor interrupt on D1 (gpio4) on
tmr.alarm( 1, 500, 1,  function() waitloop() end)

function waitloop()
 msNow=tmr.now()
 if (lastPulse == 0) then --// first time thru since start/reset
     startTime=msNow
     lastPulse=msNow 
  end   
 pulseElapsed=msNow-lastPulse 
 if(pulseElapsed>sessionTimeout) then sessionEnd() 
 else   -- in session
   if(pulseElapsed>strokeTimeout) then  strokeEnd() end 
   -- if the state has changed and change is to LOW, update display
   if (pulseOn) then 
     updateData()
     pulseOn=false
     lastPulse=msNow -- reset time since last pulse to now
   end --pulseOn
  end --session
end -- function  

 function updateData() 
    pulseCount=pulseCount+1
   strokeElapsed=strokeElapsed+pulseElapsed
   totDistance=totDistance+(pulseDistance/100) -- distance in metres
   totTime=totTime+(pulseElapsed / 1000.0)   -- time in seconds
   pulseElapsed=0
   lastPulse=msNow
 end

 function strokeEnd() 
   if (pulseCount > 0) then strokeCount=strokeCount+1 end
   if(strokeElapsed > 0) then  
	-- display stroke stats  
	kmDistance=totDistance/1000.0 -- metres to km
	kmHour=(kmDistance/(msNow-startTime)/3600000.0)
	strokesMinute=60000.0/strokeElapsed
    Scrxpos=10 -- current position on screen - x coordinate
    Scrypos=20 -- current position on screen - y coordinate
    --disp:setColor(255, 168, 0) orange
    disp:setColor(0, 255, 0)-- green
	print(" strokeElapsed="..strokeElapsed)
	dprint(1,strokeCount)
	dprint(1," | ")
	dprint(1,totDistance)
	dprint(1,"M | ")
	dprint(1,totTime)   -- print the number of seconds since reset:
	dprintl(1,"s     ")
    disp:setColor(20, 240, 240) -- lt blue
	dprint(1,strokesMinute) -- print calcs done at stroke end
	dprint(1,"s/m | ") 
	dprint(1,kmHour)
	dprint(1,"k/h   ") 
	pulseElapsed=0      -- reset stroke-end detect timer
	pulseCount=0
	strokeElapsed=0
   end
 end

function sessionEnd() 
 -- display session stats
 strokeEnd()
 lastPulse=0
 strokeCount=0
 totDistance=0.0
 totTime=0.0
 end

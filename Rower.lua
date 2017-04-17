--[[  Rower Mk 3 - by Bruce Woolmore 7/4/2017
  This version for Wemos D1 Mini (ESP8266 dev bd) running Nodemcu lua env 
  vsn 1.5.4.1 custom compile with math,ucglib 
 counts all Hi to Lo state changes in the Hall effect sensor
ILI9341 screen driven by SPI ; board pin map as follows:
D0/lua0->screen RST,D5/lua5->SCK,D6/lua6->MISO,D7/lua7->MOSI
D8/lua8->CS, D4/lua4->D/C,3v3->VCC,LED(via pot), bd GND-> screen GND,
other connections:
pgm switches (to be added) D3/lua3->PGM1 D2/lua2->PGM2
D1/lua1->Hall effect sensor pin  (pulled up via 4k7 resistor to 3v3
--]]
function CalcSpeed()
-- print("\r\ninterrupt triggered")
 -- on interrupt from Hall Effect Sensor pin, calc elapsed time since last int
msNow=tmr.now()
if (lastPulse ~= 0) then -- ignore first pulse in stroke
   pulseElapsed=msNow-lastPulse -- calc period between pulses
end   
lastPulse=msNow -- save reading as Last
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
strokeTimeout=1500   --// timeout in ms to detect end of stroke
pulseDistance=20.0  --// distance travelled in cm between each pulse
dofile("screen.lua")
init_display() -- set up display screen ready to show data
--init state variables:
pulseElapsed=0
lastPulse = 0      -- previous sensor timestamp 
strokeElapsed = 0  -- ms since end of last stroke
strokeCount=0 
pulseCount=0
totDistance=0
totTime=0
startTime=0
SENSEPIN = 1
enInt()         -- turn sensor interrupt on D1 (gpio4) on
tmr.alarm( 1, 500, 1,  function() waitloop() end)

function waitloop() -- runs every 500ms
 msNow=tmr.now()
 if(startTime==0) then  startTime=msNow end  -- capture start
 if(lastPulse~=0) then timeElapsed=msNow-lastPulse
 else timeElapsed=0 end 
 if(pulseElapsed>0) then
   updateData() -- process last pulse period 
 end  
 if(timeElapsed>sessionTimeout) then sessionEnd() 
 else   -- in session
   if(timeElapsed>strokeTimeout) then  strokeEnd() end 
 end -- timeouts
end -- function  

 function updateData()
   print("ms="..pulseElapsed.."\r\n")
   pulseCount=pulseCount+1
   strokeElapsed=strokeElapsed+pulseElapsed
   totDistance=totDistance+(pulseDistance/100) -- distance in metres
   totTime=totTime+(pulseElapsed / 1000.0)   -- time in seconds
   pulseElapsed=0
 end

 function strokeEnd() 
   disInt()     -- disable interrupt
   print(" strokeElapsed="..strokeElapsed)
   if(strokeElapsed > 0) then  
    strokeCount=strokeCount+1
	-- display stroke stats  
	kmDistance=totDistance/1000.0 -- metres to km
	kmHour=math.floor((kmDistance/(msNow-startTime)/3600000.0))
	strokesMinute=math.floor(60000.0/strokeElapsed)
    Scrxpos=10 -- current position on screen - x coordinate
    Scrypos=100 -- current position on screen - y coordinate
    --disp:setColor(255, 168, 0) orange
    disp:setColor(20, 240, 240) -- lt blue
    dprintl(1,"Strokes   |   Metres   | Seconds")
    disp:setColor(0, 255, 0)-- green
	dprint(2,strokeCount.." | "..string.format("%04.1f",totDistance).."M | ")
	dprintl(2,string.format("%04.1f",totTime).."s     ")   -- print the number of seconds since reset:
    disp:setColor(20, 240, 240) -- lt blue
    dprintl(1,"Strokes/Min | Km/Hr")
    disp:setColor(0, 255, 0)-- green
	dprint(2,strokesMinute) -- print calcs done at stroke end
	dprint(2," | "..kmHour.."km/h   ") 
	pulseElapsed=0      -- reset stroke-end detect timer
	pulseCount=0
	strokeElapsed=0
   end
   lastPulse=msNow -- save reading as Last
   enInt()
 end

function sessionEnd() 
 -- display session stats
 strokeEnd()
 lastPulse=0
 strokeCount=0
 totDistance=0.0
 totTime=0.0
 end

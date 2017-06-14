--[[  Rower Mk 3 - by Bruce Woolmore 7/4/2017
This version for Wemos D1 Mini (ESP8266 dev bd) running Nodemcu vsn 1.5.4.1 custom compile with math,ucglib 
 counts all Hi to Lo state changes in the Hall effect sensor
 ILI9341 screen driven by SPI ; board pin map as follows:
   D0/lua0->screen RST,D5/lua5->SCK,D6/lua6->MISO,D7/lua7->MOSI
   D8/lua8->CS, D4/lua4->D/C,3v3->VCC,LED(via pot), bd GND-> screen GND,
other connections:
pgm switches (to be added) D4/gpio3->PGM1 D3/gpio2->PGM2
D1/lua1->Hall effect sensor pin  (pulled up via 4k7 resistor to 3v3
--]]

function CalcSpeed()
 -- on interrupt from Hall Effect Sensor pin, calc elapsed time since last int
msNow=tmr.now()
pulseCount=pulseCount+1
if (pulseCount > 1) then -- ignore first pulse in stroke
   pulseElapsed=msNow-lastPulse -- calc period between pulses
   strokeElapsed=strokeElapsed+pulseElapsed
   totDistance=totDistance+(pulseDistance/100) -- distance in metres
   -- totTime=totTime+(pulseElapsed / 1000000.0)   -- time in seconds
end
lastPulse=msNow -- save reading as Last
if(startTime==0) then -- new session
    startTime=msNow   -- start time for time/distance calcs
end
tmr.start(strokeTimer) -- set timer for end-of-stroke detection
tmr.start(sessionTimer) -- set timer for end-of-session detection
end 

--enable interrupts
function EnInt()     
    gpio.mode(SENSEPIN,gpio.INT)
    gpio.trig(SENSEPIN,'down',CalcSpeed)
end

--disable interrupts
function DisInt()
     gpio.mode(SENSEPIN, gpio.INPUT)
end

function ResetCounts() 
--init state variables:
  pulseElapsed=0
  lastPulse = 0      -- previous sensor timestamp 
  strokeElapsed = 0  -- ms since end of last stroke
  strokeCount=0 
  pulseCount=0
  totDistance=0
  totTime=0
  startTime=0
end  

 function StrokeEnd() 
   tmr.stop(strokeTimer) -- set timer for end-of-stroke detection
   tmr.stop(sessionTimer) -- set timer for end-of-session detection
   DisInt()     -- disable interrupt
   print("pulse count ="..pulseCount.." strokeElapsed="..strokeElapsed)
   if(pulseCount > 1) then  -- must have 2+ pulses for  stroke
    strokeCount=strokeCount+1
    -- add distance coasted during stroke return
    totDistance=(strokeTimeout*K1/pulseElapsed)*(pulseDistance/100)
	print(" totDistance="..totDistance)
	-- display stroke stats  
	kmDistance=totDistance/1000.0 -- metres to km
    totTime=((msNow-startTime)/M1) 
	kmHour=((kmDistance * 3600)/totTime)
	strokesMinute=math.floor(strokeCount*60/totTime)
    Scrxpos=10 -- current position on screen - x coordinate
    Scrypos=50 -- current position on screen - y coordinate
    --disp:setColor(255, 168, 0) orange
    disp:setColor(20, 240, 240) -- lt blue
    dprintl(1,"Strokes   |   Metres   | Seconds")
    disp:setColor(0, 255, 0)-- green
	dprint(2,strokeCount.." | "..string.format("%4.1f",totDistance).."M | "..string.format("%4.1f",totTime).."s")   -- print the number of seconds since reset:
    Scrxpos=10 -- current position on screen - x coordinate
    Scrypos=120 -- current position on screen - y coordinate
    disp:setColor(20, 240, 240) -- lt blue
    dprintl(1,"Strokes/Min  |  Km/Hr")
    disp:setColor(0, 255, 0)-- green
	dprint(2,strokesMinute.."   |  "..string.format("%4.1f",kmHour).."km/h   ") 
	pulseElapsed=0      -- reset stroke-end detect timer
	pulseCount=0
	strokeElapsed=0
    tmr.start(sessionTimer) -- restart end-of-session detection timer
   end              -- end of stroke processing (not 0)
   lastPulse=msNow -- save reading as Last
   EnInt()
 end

function SessionEnd() 
 -- display session stats
 print("Session end")
 ResetCounts()
 end

-- start here ; intit constants, variables, set up sensor pin interrupts
sessionTimeout=5000     --// timeout in ms to detect end of session
strokeTimeout=2000   --// timeout in ms to detect end of stroke
pulseDistance=20.0  --// distance travelled in cm between each pulse
K1=1000;M1=1000000          -- // numeric constants
SENSEPIN = 1
dofile("screen.lua")
strokeTimer=tmr.create()  -- // end of stroke detected by timeout on pulse
tmr.register(strokeTimer,strokeTimeout,tmr.ALARM_SEMI,StrokeEnd)
sessionTimer=tmr.create()  -- // end of session is timeout on stroke
tmr.register(sessionTimer,sessionTimeout,tmr.ALARM_SEMI,SessionEnd)
init_display() -- set up display screen ready to show data
EnInt()         -- turn sensor interrupt on D1 (gpio4) on
ResetCounts()

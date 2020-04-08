--[[  Rower Mk 3 - by Bruce Woolmore 7/4/2017
This version for Wemos D1 Mini (ESP8266 dev bd) running Nodemcu vsn 1.5.4.1 custom compile with math,ucglib 
 counts all Hi to Lo state changes in the Hall effect sensor for magnet on flywheel
 Rowing session starts with first pulse sensed (stroke)
 ILI9341 screen driven by SPI ; board pin map as follows:
   D0/lua0->screen RST,D5/lua5->SCK,D6/lua6->MISO,D7/lua7->MOSI
   D8/lua8->CS, D4/lua4->D/C,3v3->VCC,LED(via pot), bd GND-> screen GND,
other connections:
pgm switches  D3/gpio0->Button2 D2/gpio4->Button1
D1/lua1->Hall effect sensor pin  (pulled up via 4k7 resistor to 3v3
--]]

function CalcSpeed()
 -- on interrupt from Hall Effect Sensor pin, store time, increment pulse count
pulseCount=pulseCount+1
if (pulseCount > 1) then -- ignore first pulse in stroke
   totDistance=totDistance+(pulseDistance/100) -- distance in metres
end
if(startTime==0) then -- new session
    startTime=tmr.now()   -- start time for time/distance calcs
end
tmr.start(strokeTimer) -- set/reset timer for end-of-stroke detection
-- tmr.start(sessionTimer) -- set/reset timer for end-of-session detection
end 

--enable flywheel timer interrupts
function EnTint()     
    gpio.mode(SENSEPIN,gpio.INT)
    gpio.trig(SENSEPIN,'down',CalcSpeed)
end

--disable flywheel timer interrupts
function DisTint()
     gpio.mode(SENSEPIN, gpio.INPUT)
end

function ResetCounts() 
--init state variables:
  lastPulse = 0      -- previous sensor timestamp 
  lastStrokeTime = 0
  strokeCount=0 
  pulseCount=0
  totDistance=0
  totTime=0
  startTime=0
end  

 function StrokeEnd() 
   tmr.stop(strokeTimer) -- set timer for end-of-stroke detection
   tmr.stop(sessionTimer) -- set timer for end-of-session detection
   DisTint()     -- disable interrupt
   if(menuActive) then -- clear screen of menu
     disp:clearScreen()
     menuActive=false
   end
   if(pulseCount > 1) then  -- must have 2+ pulses for  stroke
    msNow=tmr.now()
    strokeCount=strokeCount+1
    if(lastStrokeTime==0) then
       lastStrokeTime=startTime
       currStrokeRate=0
    else
       currStrokeRate=(M1*60)/(msNow-lastStrokeTime) 
       lastStrokeTime=msNow 
    end
     -- add distance coasted during stroke return
    local coastDistance=((currStrokeRate/10)*(pulseDistance/100))
	totDistance=totDistance+coastDistance
	-- display stroke stats  
	kmDistance=totDistance/1000.0 -- metres to km
    totTime=((msNow-startTime)/M1) 
	kmHour=((kmDistance * 3600)/totTime)
	strokesMinute=math.floor(strokeCount*60/totTime)
    Scrxpos=10 -- cursor x coord
    Scrypos=50 -- cursor y coord
    disp:setColor(0, 255, 0)-- green
	dprint(2,strokeCount.."  | "..string.format("%4.1f",totDistance).."M | "..string.format("%4.1f",totTime).."s")  
    Scrxpos=10 -- cursor x coord
    Scrypos=120 -- cursor y coord
	dprint(2,strokesMinute.."s/m   |  "..string.format("%4.1f",kmHour).."km/h   ") 
    Scrxpos=10
    Scrypos=180
    dprint(2,"Last Rate = "..string.format("%4.1f",currStrokeRate).."s/m")
	pulseElapsed=0      -- reset stroke-end detect timer
	pulseCount=0
    tmr.start(sessionTimer) -- restart end-of-session detection timer
   end              -- end of stroke processing (not 0)
   EnTint()
 end
 
function SessionEnd() 
  print("Session End")
 ResetCounts()
 end

-- start here ; intit constants, variables, set up sensor pin interrupts
sessionTimeout=5000     --// timeout in ms to detect end of session
strokeTimeout=800   --// timeout in ms to detect end of stroke
pulseDistance=40.0  --// distance travelled in cm between each pulse
K1=1000;M1=1000000          -- // numeric constants
Stroke=8            -- // arbitrary # of pulses per stroke for pgmd distance
SENSEPIN = 1
-- next two variables now set in settings.lua
-- Duration=500        --// default distance for session in metres
-- Rate=10             -- // pgm dft rate in strokes/min
dofile("settings.lua")
dofile("screen.lua")
strokeTimer=tmr.create()  -- // end of stroke detected by timeout on pulse
tmr.register(strokeTimer,strokeTimeout,tmr.ALARM_SEMI,StrokeEnd)
sessionTimer=tmr.create()  -- // end of session is timeout on stroke
tmr.register(sessionTimer,sessionTimeout,tmr.ALARM_SEMI,SessionEnd)
init_display() -- set up display screen ready to show data
EnTint()         -- turn sensor interrupt on D1 (gpio4) on
-- dofile("menu.lua")   bypass for now
menuActive=false
ResetCounts()

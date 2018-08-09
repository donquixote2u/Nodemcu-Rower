--[[  Rower Mk 3 - by Bruce Woolmore 7/4/2017
This version for Wemos D1 Mini (ESP8266 dev bd) running Nodemcu vsn 1.5.4.1 custom compile with math,ucglib 
 counts all Hi to Lo state changes in the Hall effect sensor
 ILI9341 screen driven by SPI ; board pin map as follows:
   D0/lua0->screen RST,D5/lua5->SCK,D6/lua6->MISO,D7/lua7->MOSI
   D8/lua8->CS, D4/lua4->D/C,3v3->VCC,LED(via pot), bd GND-> screen GND,
other connections:
pgm switches  D3/gpio3->Button1 D2/gpio2->Button2
D1/lua1->Hall effect sensor pin  (pulled up via 4k7 resistor to 3v3
--]]

function CalcSpeed()
 -- on interrupt from Hall Effect Sensor pin, calc elapsed time since last int
msNow=tmr.now()
pulseCount=pulseCount+1
if (pulseCount > 1) then -- ignore first pulse in stroke
   pulseElapsed=msNow-lastPulse -- calc period between pulses
   totDistance=totDistance+(pulseDistance/100) -- distance in metres
end
lastPulse=msNow -- save reading as Last
if(startTime==0) then -- new session
    startTime=msNow   -- start time for time/distance calcs
    disp:clearScreen()
end
tmr.start(strokeTimer) -- set/reset timer for end-of-stroke detection
tmr.start(sessionTimer) -- set/reset timer for end-of-session detection
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
  strokeCount=0 
  pulseCount=0
  totDistance=0
  totTime=0
  startTime=0
end  

 function StrokeEnd() 
   if(menuActive) then -- clear screen of menu
     disp.clearScreen()
     menuActive=false
     end
   tmr.stop(strokeTimer) -- set timer for end-of-stroke detection
   tmr.stop(sessionTimer) -- set timer for end-of-session detection
   DisInt()     -- disable interrupt
   -- debug    print("pulse count ="..pulseCount)
   if(pulseCount > 1) then  -- must have 2+ pulses for  stroke
    strokeCount=strokeCount+1
    -- add distance coasted during stroke return
    local coastDistance=((strokeTimeout*K1/(2*pulseElapsed))*(pulseDistance/100))
    local sd=((pulseCount-1)*pulseDistance/100)
    -- debug print("stroke distance="..sd.." coast distance="..coastDistance)
	totDistance=totDistance+coastDistance
	-- debug print(" totDistance="..totDistance)
	-- display stroke stats  
	kmDistance=totDistance/1000.0 -- metres to km
    totTime=((msNow-startTime)/M1) 
	kmHour=((kmDistance * 3600)/totTime)
	strokesMinute=math.floor(strokeCount*60/totTime)
    Scrxpos=10 -- current position on screen - x coordinate
    Scrypos=50 -- current position on screen - y coordinate
    --disp:setColor(255, 168, 0) orange
    --disp:setColor(20, 240, 240) -- lt blue
    --dprintl(1,"Strokes   |   Metres   | Seconds")
    disp:setColor(0, 255, 0)-- green
	dprint(2,strokeCount.."  | "..string.format("%4.1f",totDistance).."M | "..string.format("%4.1f",totTime).."s")   -- print the number of seconds since reset:
    Scrxpos=10 -- current position on screen - x coordinate
    Scrypos=120 -- current position on screen - y coordinate
    --disp:setColor(20, 240, 240) -- lt blue
    --dprintl(1,"Strokes/Min  |  Km/Hr")
    --disp:setColor(0, 255, 0)-- green
	dprint(2,strokesMinute.."s/m   |  "..string.format("%4.1f",kmHour).."km/h   ") 
    Scrxpos=10
    Scrypos=180
    if(totDistance<Duration) then
        DrawStatus()        -- show position relative to pgmd pace and finish 
	else dprintl(2,"FINISHED!")
	    return
    end
	pulseElapsed=0      -- reset stroke-end detect timer
	pulseCount=0
    tmr.start(sessionTimer) -- restart end-of-session detection timer
   end              -- end of stroke processing (not 0)
   EnInt()
 end

function DrawStatus() -- // show distance to finish
  -- myPos is rowers progress, pgmPos is where they should be  
  local myPos=totDistance/Duration
  local myScrPos=math.floor(myPos * 20)
  local pgmPos=((totTime/60)*(pulseDistance/100)*Stroke*Rate)/Duration
  if(pgmPos>1) then pgmPos=1 end -- avoid overshoot!
  local pgmScrPos=math.floor(pgmPos * 20)
  -- debug print("myPos="..myPos.." pPos="..pgmPos)
  disp:setColor(20, 240, 240) -- lt blue
  Scrxpos=10+pgmScrPos
  dprintl(1,"X")
  if(pgmPos>myPos) then
    disp:setColor(255, 0, 0) -- red if you behind
  else
    disp:setColor(0, 255, 0) -- green if you ahead 
  end 
  Scrxpos=10+myScrPos
  dprintl(1,"X")    
  --disp:drawBox(myScrPos,200,20,10)
end
 
function SessionEnd() 
  print("Session End")
 ResetCounts()
 end

function Menu() 
  ResetCounts()
  MenuDisplay()
 end
 
-- start here ; intit constants, variables, set up sensor pin interrupts
sessionTimeout=5000     --// timeout in ms to detect end of session
strokeTimeout=1000   --// timeout in ms to detect end of stroke
pulseDistance=40.0  --// distance travelled in cm between each pulse
K1=1000;M1=1000000          -- // numeric constants
Duration=500        --// default distance for session in metres
Rate=10             -- // pgm dft rate in strokes/min
Stroke=8            -- // arbitrary # of pulses per stroke for pgmd distance
SENSEPIN = 1
dofile("screen.lua")
strokeTimer=tmr.create()  -- // end of stroke detected by timeout on pulse
tmr.register(strokeTimer,strokeTimeout,tmr.ALARM_SEMI,StrokeEnd)
sessionTimer=tmr.create()  -- // end of session is timeout on stroke
tmr.register(sessionTimer,sessionTimeout,tmr.ALARM_SEMI,SessionEnd)
init_display() -- set up display screen ready to show data
EnInt()         -- turn sensor interrupt on D1 (gpio4) on
dofile("menu.lua")
ResetCounts()

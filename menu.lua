function MenuNext()
   -- print("skip to next menu item)
   Selected=Selected+2
   if (Selected>#CurrentMenu) then
      Selected=2
   end   
   MenuDisplay(CurrentMenu)       -- menu  
end 
 
function MenuDisplay(Menu)
 menuActive=true
 disp:clearScreen()
 Scrxpos=10 
 Scrypos=50
 disp:setColor(255, 168, 0) --orange
 dprintl(2,Menu[1])
 local x
 for x=2,#Menu,2 do 
       if(x==Selected) then    -- highlight default
         disp:setColor(20, 240, 240) -- lt blue
       else
         disp:setColor(10, 120, 120) -- dk blue 
       end
   dprintl(1,Menu[x])
  end                   -- end ipairs loop  
end

function MenuSelect()  
    -- debug   print("item selected")
    Option=Selected+1   -- get option part of menu entry
    if(type(CurrentMenu[Option])=="table") then-- entry is a submenu table so display it
	CurrentMenu=CurrentMenu[Option]
   else					-- entry is an option/command, so action it
     -- debug  print("action="..CurrentMenu[Option])
	 local f=loadstring(CurrentMenu[Option])
	 f()
     SaveSettings() 
	 CurrentMenu=menu
   end		-- Selected
   Selected=2
   MenuDisplay(CurrentMenu)
end

function MenuButton() -- print("button pressed") 
 local Time=tmr.now()
 if(gpio.read(BUTTON1)==0) then
    PressStart=Time
 else   -- button press has ended, test for spurious/short/long
    local buttonPulse=Time-PressStart
    -- debug print("pulse="..pulse)
    if (buttonPulse<ShortPress) then  -- press < threshold = noise?
        return
    end
    if (buttonPulse>LongPress) then -- long press = Set
        MenuSelect()
    else                            -- short press = Next
        MenuNext()
    end        
 end
end 

function ResetButton() -- print("button pressed") 
 local Time=tmr.now()
 if(gpio.read(BUTTON2)==0) then
    ResetStart=Time
 else   -- button press has ended, if not spurious, reset    
 local buttonPulse=Time-ResetStart
    if (buttonPulse>ShortPress) then 
        node.restart()
    end        
 end
end

 function tdump(t)  -- debug use only 
  local k,v
  for k,v in pairs(t) do
    if(type(v)=="table") then
        print(k.."=")
        tdump(v)
    else  
        print(k.."="..v)
    end
  end
 end
  
 function SaveSettings() 
  if(file.open("settings.lua","w")) then
     file.writeline("Duration="..Duration)
     file.writeline("Rate="..Rate)
     file.close()
  end   
 end
 
  
-- menu array structure: n*{menu title, [key]=menu entry description, value=menu entry action } (recurse for levels)
menu={"Main","Duration",{"Distance(m)","500m","Duration=500","1000m","Duration=1000","1500m","Duration=1500"},"Pace",{"Strokes/Min","10","Rate=10","20","Rate=20","30","Rate=30"}}
BUTTON1=2   -- // link button 1 to gpio2 pin D4
BUTTON2=3   -- // link button 2 to gpio0 pin D3
ShortPress=100000     -- // timer in us for button short press
LongPress=700000     -- // timer in us for button long press
gpio.mode(BUTTON1,gpio.INT)  -- set button1 as menu/select
gpio.mode(BUTTON2,gpio.INT)  -- set button2 as reset
gpio.trig(BUTTON1,'both',MenuButton)
gpio.trig(BUTTON2,'both',ResetButton)
CurrentMenu=menu
-- DEBUG tdump(CurrentMenu) 
-- DEBUG MenuDisplay(CurrentMenu)
Selected=next(CurrentMenu,1)  
menuActive=false


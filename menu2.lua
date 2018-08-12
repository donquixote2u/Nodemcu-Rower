function MenuInit() 
-- menu array structure: n*{menu title, [key]=menu entry description, value=menu entry action } (recurse for levels)
  menu={"Main",["Duration(m)"]={"Distance",["500m"]="Distance=500",["1000m"]="Distance=1000",["1500m"]="Distance=1500"},["Pace"]={"Strokes/Min",["10"]="Rate=10",["20"]="Rate=20",["30"]="Rate=30"}}
  CurrentMenu=menu
  tdump(CurrentMenu) 
  Selected=CurrentMenu[2]   
end

function tdump(t)
  for k,v in pairs(t) do
    if(type(v)=="table") then
        tdump(v)
    else  
        print(k.."="..v)
    end
  end
end     


function MenuNext()
  if(bounceOn) then
    return 
  else
   tmr.start(bounceTimer) 
   bounceOn=true -- turned off by bounce timer
   -- print("Menu button 2")
   if(Selected) then
     Selected=next(CurrentMenu)
   else
     Selected=next(CurrentMenu,1)  
     MenuDisplay(CurrentMenu)       -- menu  
   end              -- end Selected
  end               -- end bounceon off        
end 
 
function MenuDisplay(Menu)
 disp:clearScreen()
 Scrxpos=10 
 Scrypos=50
 dprintl(2,Menu[1])
 for k,v in ipairs(Menu) do 
    if(k==1) then
       disp:setColor(255, 168, 0) --orange
   else    
       if(k==Selected) then    -- highlight default
         disp:setColor(20, 240, 240) -- lt blue
       else
         disp:setColor(10, 120, 120) -- dk blue 
       end
   end    
   dprintl(1,k)
 end                   -- end ipairs loop  
end

function MenuSelect() 
  if(bounceOn) then
    return 
  else
    tmr.start(bounceTimer)  
    bounceOn=true -- turned off by bounce timer
    -- print("Menu button 1")
      if(type(CurrentMenu[Selected])=="table") then-- entry is a submenu table so display it
		    CurrentMenu=CurrentMenu[Selected]
            Selected=next(CurrentMenu,1)
		    MenuDisplay(CurrentMenu)
	  else					-- entry is an option/command, so action it
            print("action="..CurrentMenu[Selected])
		    local f=loadstring(CurrentMenu[Selected])
		    f() 
	  end		-- #v
  end             -- bounceOn false
end

function BounceCancel() 
   bounceOn=false -- set timer for end-of-stroke detection
 end
  
MenuInit()
Selected=2
BUTTON1=2   -- // link button 1 to gpio pin D3
BUTTON2=3   -- // link button 2 to gpio pin D4
bounceTimeout=200     -- // timer in ms for bounce cancel
gpio.mode(BUTTON1,gpio.INT)  -- set button1 as menu/select
gpio.trig(BUTTON1,'down',MenuSelect)
gpio.mode(BUTTON2,gpio.INT)  -- set button2 as move down
gpio.trig(BUTTON2,'down',MenuNext)
bounceTimer=tmr.create()  -- // detect button bounce
tmr.register(bounceTimer,bounceTimeout,tmr.ALARM_SEMI,BounceCancel)


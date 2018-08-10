function MenuInit() 
-- menu array structure: n*{menu title, [key]=menu entry description, value=menu entry action } (recurse for levels)
  menu={"Main",["Duration(m)"]={"Distance",["500m"]="Distance=500",["1000m"]="Distance=1000",["1500m"]="Distance=1500"},["Pace"]={"Strokes/Min",["10"]="Rate=10",["20"]="Rate=20",["30"]="Rate=30"}}
  menuIndex=0
end

function MenuNext()
  if(bounceOn) then
    return 
  else
   tmr.start(bounceTimer) 
   bounceOn=true -- turned off by bounce timer
   print("Menu button 2")
   Selected=Selected+1   -- next menu option 
   if(Selected>#CurrentMenu) then
     Selected=2
   end  
   MenuDisplay(CurrentMenu)       -- menu  
  end        
end 
 
function MenuDisplay(Menu)
 disp:clearScreen()
 Scrxpos=10 
 Scrypos=50
 disp:setColor(255, 168, 0) --orange
 dprintl(2,Struct[1])
     for y=2,#Menu do
       if(y==Selected) then    -- highlight default
         disp:setColor(20, 240, 240) -- lt blue
       else
         disp:setColor(10, 120, 120) -- dk blue 
       end
       k,v=next(Menu)
     dprintl(1,k)
     end                   -- end y loop  
end

function MenuSelect() 
  if(bounceOn) then
    return 
  else
   tmr.start(bounceTimer)  
   bounceOn=true -- turned off by bounce timer
   for i,v in pairs(CurrentMenu) do	-- traverse menu
      if(i==Selected) then
        if(type(v)=="table") then-- entry is a submenu table so display it
		Selected=1
		CurrentMenu=v
		MenuDisplay(CurrentMenu)
	else					-- entry is an option/command, so action it
		local f=loadstring(v)
		f() 
	end		-- #v
     end		-- i
  end		-- pairs
end

function BounceCancel() 
   bounceOn=false -- set timer for end-of-stroke detection
 end
  
MenuInit()
Selected=2
BUTTON1=2   -- // link button 1 to gpio pin D3
BUTTON2=3   -- // link button 2 to gpio pin D4
bounceTimeout=100     -- // timer in ms for bounce cancel
gpio.mode(BUTTON1,gpio.INT)  -- set button1 as menu/select
gpio.trig(BUTTON1,'down',MenuSelect)
gpio.mode(BUTTON2,gpio.INT)  -- set button2 as move down
gpio.trig(BUTTON2,'down',MenuNext)
bounceTimer=tmr.create()  -- // detect button bounce
tmr.register(bounceTimer,bounceTimeout,tmr.ALARM_SEMI,BounceCancel)


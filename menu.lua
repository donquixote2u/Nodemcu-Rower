function MenuInit() 
-- menu structure: {["menu key"]={["option1"]="option1=command1", .....}}
  menus={["Main"]={["Distance"]="MenuDisplay(\"Distance\(M\)\")",["Rate"]="MenuDisplay(\"Rate\")"},["Distance\(M\)"]={["500M"]="distance=500",["1000M"]="distance=1000",["1500M"]="distance=1500"},["Rate"]={["10"]="rate=10",["20"]="rate=20",["30"]="rate=30"}}
  menuIndex=0
end

function NextMenu() 
  if(bounce1On) then
    print("button 1 bounced")
    return 
  else
   bounce1On=true -- turned off by bounce timer
   tmr.start(bounceTimer)  
   if(menuIndex==0) then
     currentMenu=menus["Main"]
   end  
   menuIndex=menuIndex+1
   if(menuIndex>1) and (menuIndex>x) then -- if overshoot, reset
     menuIndex=1
   end  
   MenuDisplay() -- redisplay current menu with new select
  end
 end

function SelectIt()
  if(bounce2On) then
    print("button 2 bounced")
    return 
  else
   bounce2On=true -- turned off by bounce timer
   tmr.start(bounceTimer) 
   print("Menu button 2")
   f=loadstring(currentCommand) -- load last command selected from menu
   if(f) then f() end -- if command not null, execute
   menuIndex=0
   NextMenu()
  end        
end 

function BounceCancel() 
   print("bounce timer expired")
   bounce1On=false
   bounce2On=false 
 end
  
function MenuDisplay(menuKey) --  key of menu in menus array
 if(menuKey~=nil) then 
   print("new menu:"..menuKey)
   currentMenu=menus[menuKey]
 end  
 disp:clearScreen()
 Scrxpos=10 
 Scrypos=50
 disp:setColor(255, 168, 0) --orange
 x=0
 for key, option in pairs(currentMenu) do
       x=x+1
       if(menuIndex==x) then    -- highlight default
         disp:setColor(20, 240, 240) -- lt blue
         currentCommand=option
       else
         disp:setColor(10, 120, 120) -- dk blue 
       end
      dprintl(1,key)
      print(key)
 end                   -- end pairs loop  
end
 
MenuInit()
menuIndex=0
BUTTON1=2   -- // link button 1 to gpio pin D3
BUTTON2=3   -- // link button 2 to gpio pin D4
bounceTimeout=1000     -- // timer in ms for bounce cancel
gpio.mode(BUTTON1,gpio.INT)  -- set button1 as menu/select
gpio.trig(BUTTON1,'down',NextMenu)
gpio.mode(BUTTON2,gpio.INT)  -- set button2 as move down
gpio.trig(BUTTON2,'down',SelectIt)
bounceTimer=tmr.create()  -- // detect button bounce
tmr.register(bounceTimer,bounceTimeout,tmr.ALARM_SEMI,BounceCancel)

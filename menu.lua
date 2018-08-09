-- two-button menu system; Btn1=move Btn2=Select
-- menu called by MenuDisplay(menuname) from associative array
-- where (menumname) is the key to the menu array
-- all menu items are lua commands, submenus just call MenuDisplay
function MenuInit() 
-- menu structure: {["menu key"]={["option1"]="option1=command1", .....}}
  menus={["Main"]={["Distance"]="MenuDisplay(\"Distance\(M\)\")",["Rate"]="MenuDisplay(\"Rate\")"},["Distance\(M\)"]={["500M"]="Distance=500",["1000M"]="Distance=1000",["1500M"]="Distance=1500"},["Rate"]={["10"]="Rate=10",["20"]="Rate=20",["30"]="Rate=30"}}
  menuIndex=0
  currentCommand="file.list()"
end

function NextItem() -- highlights next item, redisplays
  if(bounce1On) then
    -- print("button 1 bounced")
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
    -- print("button 2 bounced")
    return 
  else
   bounce2On=true -- turned off by bounce timer
   tmr.start(bounceTimer) 
   menuIndex=0
   -- print("Menu button 2:"..currentCommand)
   f=loadstring(currentCommand) -- load last command selected from menu
   if(f) then 
      f() -- if command not null, execute
      if(string.find(currentCommand,"MenuDisplay")~=1) then -- if an option selected,
         dprintl(2,currentCommand)  
         SaveSettings()             --  save options
      end     
   end  -- end f 
  end   -- end no bounce     
end 

function BounceCancel() 
   -- print("bounce timer expired")
   bounce1On=false
   bounce2On=false 
 end

 function SaveSettings() 
  if(file.open("settings.lua","w")) then
     file.writeline("Duration="..Duration)
     file.writeline("Rate="..Rate)
     file.close()
  end   
 end
  
function MenuDisplay(menuKey) --  key of menu in menus array
 menuActive=true 
 if(menuKey~=nil) then      -- will be nil if stepping            
   -- debug    print("new menu:"..menuKey)
   currentMenu=menus[menuKey] -- load menu array using key
   menuIndex=1
 end  
 disp:clearScreen()
 Scrxpos=10 
 Scrypos=50
 disp:setColor(255, 168, 0) --orange
 x=0
 for key, option in pairs(currentMenu) do -- step thru menu items
       x=x+1
       if(menuIndex==x) then    -- highlight default
         disp:setColor(20, 240, 240) -- lt blue
         currentCommand=option
       else
         disp:setColor(10, 120, 120) -- dk blue 
       end
      dprintl(1,key)            -- display menu item
      print(key)
 end                   -- end pairs loop  
end
 
MenuInit()
BUTTON1=2   -- // link button 1 to gpio pin D2/GPIO4
BUTTON2=3   -- // link button 2 to gpio pin D3/GPIO0
bounceTimeout=1000     -- // timer in ms for bounce cancel
gpio.mode(BUTTON1,gpio.INT)  -- set button1 as menu/select
gpio.trig(BUTTON1,'down',NextItem)
gpio.mode(BUTTON2,gpio.INT)  -- set button2 as move down
gpio.trig(BUTTON2,'down',SelectIt)
bounceTimer=tmr.create()  -- // detect button bounce
tmr.register(bounceTimer,bounceTimeout,tmr.ALARM_SEMI,BounceCancel)

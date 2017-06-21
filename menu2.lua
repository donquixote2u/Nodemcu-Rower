function MenuInit() 
-- menu structure: n*{menu title,menu array}
  menu={"Main",{"Distance(M)",{"distance=50","distance=1000","distance=1500"}},{"Rate",{"rate=10","rate=20","rate=30"}}}
  menuIndex=0
end

function MenuMove()
  if(bounceOn) then
    return 
  else
   tmr.start(bounceTimer) 
   bounceOn=true -- turned off by bounce timer
   print("Menu button 2")
   menuIndex=menuIndex+1   -- next menu option 
   MenuDisplay(menu)       -- menu  
  end        
end 
 
function MenuDisplay(Struct)
 if(Level==0) then  print( "Menu button 1") end
 Level=Level+1 -- step down a level
 disp:clearScreen()
 Scrxpos=10 
 Scrypos=50
 disp:setColor(255, 168, 0) --orange
 if(Level==Selected) then  -- display this menu level
   print("level"..Level.." heading:"..Struct[1])
   dprintl(2,Struct[1])
   if(type(Struct[2])=="table") then -- display this level
     for y=2,#Struct do
       if(menuIndex>#Struct) then 
          menuIndex=1 -- loop on overflow
       end
       if(y==menuIndex) then    -- highlight default
         disp:setColor(20, 240, 240) -- lt blue
       else
         disp:setColor(10, 120, 120) -- dk blue 
       end
      dprintl(1,Struct[y][1])
      print(Struct[y][1])
      end                   -- end y loop  
   else                    -- not table, must be option 
    print("execute "..Struct[2]) 
    local f=loadstring(Struct[2])
    f()
    end 
  else                    -- not selected level
    submenu=Struct[2] -- so go to next level 
    MenuDisplay(submenu)
   end  
end

function Menu1() 
  if(bounceOn) then
    return 
  else
   tmr.start(bounceTimer)  
   bounceOn=true -- turned off by bounce timer
   Selected=Selected+1
   Level=0
   MenuDisplay(menu)
  end
 end

function BounceCancel() 
   bounceOn=false -- set timer for end-of-stroke detection
 end
  
MenuInit()
Level=0
Selected=0
BUTTON1=2   -- // link button 1 to gpio pin D3
BUTTON2=3   -- // link button 2 to gpio pin D4
bounceTimeout=100     -- // timer in ms for bounce cancel
gpio.mode(BUTTON1,gpio.INT)  -- set button1 as menu/select
gpio.trig(BUTTON1,'down',Menu1)
gpio.mode(BUTTON2,gpio.INT)  -- set button2 as move down
gpio.trig(BUTTON2,'down',MenuMove)
bounceTimer=tmr.create()  -- // detect button bounce
tmr.register(bounceTimer,bounceTimeout,tmr.ALARM_SEMI,BounceCancel)


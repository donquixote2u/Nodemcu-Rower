function MenuInit() 
-- menu structure: n*{menu title,menu array}
  menu={"Main",{"Distance(M)",{"distance=50","distance=1000","distance=1500"}},{"Rate",{"rate=10","rate=20","rate=30"}}}
  menuIndex=0
end

function MenuMove()
  menuIndex=menuIndex+1           -- next menu option 
  if(menuIndex>#Struct[2]) then 
    menuIndex=1 -- loop on overflow
  end
MenuDisplay()  
end 
 
function MenuDisplay(Struct)
 --if(menuIndex>0) then   -- default has been changed by moving
 --  level[3]=menuIndex    -- so save it
 --end  
 Level=Level+1 
 disp:clearScreen()
 Scrxpos=10 
 Scrypos=50
 disp:setColor(255, 168, 0) --orange
 if(Level==Selected) then  -- display this menu level
   print("level"..Level.." heading:"..Struct[1])
   dprintl(2,Struct[1])
   if(type(Struct[2])=="table") then -- display this level
     for y=1,#Struct do
       if(y==menuIndex) then
         disp:setColor(20, 240, 240) -- lt blue
       else
         disp:setColor(10, 120, 120) -- dk blue 
       end
      dprintl(1,Struct[y])
      print(Struct[y])
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
  Selected=Selected+1
  Level=0
  MenuDisplay(menu)
 end
 
MenuInit()
Selected=0
gpio.mode(BUTTON1,gpio.INT)  -- set button1 as menu/select
gpio.trig(BUTTON1,'down',Menu1)
gpio.mode(BUTTON2,gpio.INT)  -- set button2 as move down
gpio.trig(BUTTON2,'down',MenuMove)

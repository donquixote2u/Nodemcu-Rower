function MenuInit() 
-- menu struct: item,option array, deafult index
  menu={"Distance(M)",{50,1000,1500},2}
  menuIndex=0
end

function MenuMove()
  menuIndex=menu[3]+1           -- next menu option 
  if(menuIndex>#menu[2]) then 
    menuIndex=1 -- loop on overflow
  end
MenuDisplay()  
end 
 
function MenuDisplay()
 if(menuIndex>0) then   -- default has been changed by moving
   menu[3]=menuIndex    -- so save it
 end   
 disp:clearScreen()
 Scrxpos=10 
 Scrypos=50
 disp:setColor(255, 168, 0) --orange
 dprintl(2,menu[1])
 for y=1,#menu[2] do
   if(y==menu[3]) then
     disp:setColor(20, 240, 240) -- lt blue
   else
     disp:setColor(10, 120, 120) -- dk blue 
   end
   dprintl(1,menu[2][y])
 end
end

MenuInit()
gpio.mode(BUTTON1,gpio.INT)  -- set button1 as menu/select
gpio.trig(BUTTON1,'down',Menu)
gpio.mode(BUTTON2,gpio.INT)  -- set button2 as move down
gpio.trig(BUTTON2,'down',MenuMove)

function MenuInit()
  menu={["Distance(M)"]={50,1000,1500}}
end

function MenuDisplay()
 disp:clearScreen()
 Scrxpos=10 
 Scrypos=50
 for menuitem,options in ipairs(menu) do
    disp:setColor(255, 168, 0) --orange
     dprintl(2,menuitem)
     disp:setColor(20, 240, 240) -- lt blue
     for y=1,#options do
     dprintl(1,options[y])
     end
 end 
end


tmr.alarm( 1 , 2500 , 0 , function() dofile("Rower.lua") end )
-- Call main control pgm after timeout
-- Drop through here to let NodeMcu run

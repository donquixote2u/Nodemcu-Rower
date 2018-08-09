tmr.alarm( 1 , 5000 , 0 , function() dofile("Rower.lua") end )
-- Call main control pgm after timeout
-- Drop through here to let NodeMcu run

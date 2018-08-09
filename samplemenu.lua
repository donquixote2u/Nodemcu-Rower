    action = {
      [1] = function (x) print(1) end,
      [2] = function (x) z = 5 end,
      ["nop"] = function (x) print(math.random()) end,
      ["my name"] = function (x) print("fred") end,
    }

-- Usage (Note, that in the following example you can also pass parameters to the function called) :-

    action[case](params)


#include "../Console/extension.lua"

RegisterCommand("performance", "Command to interact with the performance mod.", "performance", {}, function(arguments)
	DebugPrint("This message is written from inside the performance mod, I hope you like it!")
end)

return RegisterMod("2419552682")
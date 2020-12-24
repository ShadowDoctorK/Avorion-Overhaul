local GenXsotan = include("SDKXsotanGenerator")

-- Load Custom plan, if it fails let the game generate...
function createShip(faction, name, plan, position, arrivalType)
	
	local Death = GenXsotan.Dreadnought(position) if not Death then
		Death = Sector():createShip(faction, name, plan, position, arrivalType)
	end
	
	return Death
end

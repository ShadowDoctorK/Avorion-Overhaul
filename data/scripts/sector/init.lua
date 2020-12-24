-- This is always the first script that is executed for a sector

-- Note: This script does not get attached to the Sector
-- Note: This script is called BEFORE any other scripts are initialized
-- Note: When loading from Database, other scripts attached to the Sector are available through Sector():hasScript() etc.
-- Note: When adding scripts to the sector from here with addScript() or addScriptOnce(),
--       the added scripts will NOT get initialized immediately,
--       their initialization order is not defined,
--       parameters passed in addition to the script name will be IGNORED and NOT passed to the script's initialize() function,
--       and the script will instead be treated as if loaded from database, with the _restoring variable set in its initialize() function

-- Note: Sectors without entities will not be saved to disk, but deleted. If you add a special script to a sector without entities, the script will be removed on reload.
--       Same goes for sector values.

if onServer() then

local sector = Sector()

sector:addScriptOnce("sector/SDKScrapyardExtension.lua")

end
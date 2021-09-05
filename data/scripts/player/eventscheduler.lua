-- Overwrite Events

local events =
{
    -- for best compatibility with previous saves, append to this list. Not appending doesn't break anything though.
    {schedule = random():getInt(45, 60) * 60,   localEvent = false, script = "events/convoidistresssignal", arguments = {true}, to = 560, centralFactor = 0.5, outerFactor = 1, noMansFactor = 1.2},
    {schedule = random():getInt(120, 150) * 60, localEvent = false, script = "events/fakedistresssignal", arguments = {true}, to = 560, centralFactor = 0.5, outerFactor = 1, noMansFactor = 1.2},
    {schedule = random():getInt(60, 80) * 60,   localEvent = true,  script = "events/sectoreventstarter", arguments = {"pirateattack.lua"}, to = 560, centralFactor = 0.5, outerFactor = 1, noMansFactor = 1.2},
    {schedule = random():getInt(60, 80) * 60,   localEvent = true,  script = "events/sectoreventstarter", arguments = {"traderattackedbypirates.lua"}, to = 560, centralFactor = 0.3, outerFactor = 1.3, noMansFactor = 1},
    {schedule = random():getInt(40, 50) * 60,   localEvent = true,  script = "events/SDKAlienAttack", arguments = {0}, minimum = 15 * 60, from = 0, to = 500, centralFactor = 0.7, outerFactor = 1, noMansFactor = 1.2},
    {schedule = random():getInt(45, 70) * 60,   localEvent = true,  script = "events/SDKAlienAttack", arguments = {1}, minimum = 25 * 60, to = 350, centralFactor = 0.7, outerFactor = 0.8, noMansFactor = 1.2},
    {schedule = random():getInt(60, 80) * 60,   localEvent = true,  script = "events/SDKAlienAttack", arguments = {2}, minimum = 60 * 60, to = 300, centralFactor = 0.7, outerFactor = 0.8, noMansFactor = 1.2},
    {schedule = random():getInt(100, 120) * 60, localEvent = true,  script = "events/SDKAlienAttack", arguments = {3}, minimum = 120 * 60, to = 250, centralFactor = 0.7, outerFactor = 0.8, noMansFactor = 1.2},
    {schedule = random():getInt(50, 70) * 60,   localEvent = true,  script = "events/spawntravellingmerchant", to = 520},
    {schedule = random():getInt(150, 170) * 60, localEvent = false, script = "data/scripts/player/missions/piratedelivery", to = 520, centralFactor = 0.3, outerFactor = 1.1, noMansFactor = 1.3},
    {schedule = random():getInt(90, 120) * 60,  localEvent = false, script = "data/scripts/player/missions/searchandrescue/searchandrescue.lua", from = 150, to = 520, centralFactor = 0.5, outerFactor = 1, noMansFactor = 1.2},
    {schedule = random():getInt(100, 140) * 60, localEvent = false, script = "events/passiveplayerattackstarter.lua"},
}
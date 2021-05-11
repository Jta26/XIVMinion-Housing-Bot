
local FayeHousing = {}
FayeHousing.open = true
FayeHousing.visible = true
FayeHousing.appEnabled = false
FayeHousing.appEnabledText = "Enable"
FayeHousing.lastRunTime = 0

function FayeHousing.Draw(event, ticks)
    if (FayeHousing.open) then
        GUI:SetWindowSize(250,250,GUI.SetCond_FirstUseEver)

        FayeHousing.visible, FayeHousing.open = GUI:Begin("FayeHousing", FayeHousing.open)

        if (FayeHousing.visible) then
            GUI:Text("Enable to search for houses on the hour every hour.")
            if (GUI:Button(FayeHousing.appEnabledText, 100, 25)) then
				FayeHousing.appEnabled = not FayeHousing.appEnabled
				FayeHousing.appEnabledText = (FayeHousing.appEnabled and 'Disable' or 'Enable')
			end
        end
        GUI:End()
    end
end

function FayeHousing.OnUpdateHandler(event,ticks) 
    -- if the app is enabled, the bot the player is not in combat,
    -- stop the bot and change the gbotmode to CheckHouses, then start the bot again
    -- record the previous bot mode, if it was started, and restart the bot after the bot is disabled after checking houses.
    if (FayeHousing.appEnabled) then
        -- taken from ffxiv_helpers.lua cause I dont need the entire date every time this function is called.
        local currentTimeMin = tonumber(os.date("!%M"))
        if (TimeSince(FayeHousing.lastRunTime) > 900000) then
            if (currentTimeMin == 00) then
                if (FFXIV_Common_BotRunning) then
                    if (not IsInCombat()) then
                        if (gBotMode ~= "CheckHousing") then
                            ml_global_information.ToggleRun()
                        end 
                        ffxivminion.SwitchMode('CheckHousing')
                        ml_global_information.ToggleRun()
                    end
                else
                    -- if the bot is currently stopped, then set the bot mode start the bot and call it a day
                    if (gBotMode ~= "CheckHousing") then
                        ffxivminion.SwitchMode('CheckHousing')
                    end
                    d("Starting FayeHousing cause it's on the hour")
                    FayeHousing.lastRunTime = Now()
                    ml_global_information.ToggleRun()
                end  
            end
        end
    end
end

-- checks if the current hour is at the top of the hour. i.e. 5:00
function FayeHousing.IsAtHour()



end

RegisterEventHandler("Gameloop.Draw", FayeHousing.Draw, "FayeHousing-Draw")
RegisterEventHandler("Gameloop.Update", FayeHousing.OnUpdateHandler)
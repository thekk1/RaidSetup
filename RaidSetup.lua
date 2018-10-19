-- RaidSetup, Classic WoW raid setup AddOn
-- by thekk
-- 19.10.2018

------------------------ Variablen --------------------------
------------------------ Variablen --------------------------

-------------------- help functions -----------------------
local function print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffcccc33INFO: |cffffff55" .. ( msg or "nil" ))
end

local function Answer(msg)
  SendChatMessage(msg, 'WHISPER', GetDefaultLanguage'player', ChatEdit_GetLastTellTarget(ChatFrameEditBox))
end

function Tprint(tbl, indent)
  if (type(tbl) ~= "table") then Answer(NO_TABLE); return end
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      Answer(formatting)
      Tprint(v, indent+1)
    elseif type(v) == 'boolean' then
      Answer(formatting .. tostring(v))      
    else
      Answer(formatting .. v)
    end
  end
end

-------------------- Register game event handlers ---------------------------
function RaidSetup_OnLoad()
    RaidSetupFrame:RegisterEvent("ADDON_LOADED")
end

-------------------- Event Handler ----------------------
function RaidSetup_OnEvent(event)
	if (event == "ADDON_LOADED") and (arg1 == "RaidSetup") then
		print("RaidSetup loaded")
	end
end
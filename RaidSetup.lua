-- RaidSetup, Classic WoW raid setup AddOn
-- by thekk
-- 19.10.2018

-- GetNumRaidMembers()
-- IsRaidLeader()
-- UnitInRaid("unit")
-- InviteUnit("name" or "unit")
-- UninviteUnit("name" [, "reason"])
-- SwapRaidSubgroup(index1, index2)
-- name, rank(0,1(assist),2(lead)), subgroup, level, class(local),
--    fileName(en class), zone, online = GetRaidRosterInfo(raidIndex);


------------------------ Variablen --------------------------
currentGroup={}
------------------------ Variablen --------------------------

-------------------- help functions -----------------------
local function print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffcccc33INFO: |cffffff55" .. ( msg or "nil" ))
end

--local function Answer(msg)
--  SendChatMessage(msg, 'WHISPER', GetDefaultLanguage'player', ChatEdit_GetLastTellTarget(ChatFrameEditBox))
--end

function Tparse(tbl, indent)
  if (type(tbl) ~= "table") then return NO_TABLE end
  if not indent then indent = 0 end
  local _table = ""
  for key, value in pairs(tbl) do
    formatting = string.rep("  ", indent) .. key .. ": "
    if type(value) == "table" then
      _table = _table .. "\n" .. formatting
      _table = _table .. Tparse(value, indent+1)
    elseif type(value) == 'boolean' then
      _table = _table .. "\n" .. formatting .. tostring(value)
    else
      _table = _table .. "\n" .. formatting .. value
    end
  end
  return _table
end

local function RS_UpdatePlayers()

end

function RaidSetup_OnUpdate()
  --toggle = not toggle;
  --if toggle then return end
    local _DBplayer = Tparse(RS_Players)

    for i=1, GetNumRaidMembers() do
        name,rank,subgroup,_,class,_,_,online = GetRaidRosterInfo(i);
        table.insert(currentGroup, {i,name,class,subgroup,rank})
    end

    local _currentGroup = Tparse(currentGroup)

  RaidSetupFrame_Text:SetText(_DBplayer)
    RaidSetupFrame:Show()
  --RaidSetupFrame:SetPoint("CENTER", UIParent, 0, 0)
  --RaidSetupFrame:SetWidth(RaidSetupFrame_Text:GetWidth()+4)
  --RaidSetupFrame:SetHeight(RaidSetupFrame_Text:GetHeight()+6)
end
-------------------- Register game event handlers ---------------------------
function RaidSetup_OnLoad()
  RaidSetupFrame:RegisterEvent("ADDON_LOADED")
  RaidSetupFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")

end

-------------------- Event Handler ----------------------
function RaidSetup_OnEvent(event)
	if (event == "ADDON_LOADED") and (arg1 == "RaidSetup") then
		print("RaidSetup loaded")
    end
  if (event == "PARTY_MEMBERS_CHANGED") then
    RS_UpdatePlayers()
  end
end
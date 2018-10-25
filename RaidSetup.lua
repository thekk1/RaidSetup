-- RaidSetup, Classic WoW raid setup AddOn
-- by thekk
-- 19.10.2018

-- GetNumRaidMembers()
-- IsRaidLeader()
-- UnitInRaid("unit")
-- InviteUnit("name" or "unit")
-- UninviteUnit("name" [, "reason"])
-- SwapRaidSubgroup(index1, index2)
-- SetRaidSubgroup(index, subgroup) (subgroup must not be full)
-- name, rank(0,1(assist),2(lead)), subgroup, level, class(local),
--    fileName(en class), zone, online = GetRaidRosterInfo(raidIndex);


------------------------ Variablen --------------------------
currentGroup={}
_classColor = {	PALADIN="|cffF58CBA",PRIEST="|cffffffff",DRUID="|cffFF7D0A",WARRIOR="|cffC79C6E",
		ROUGE="|cffFFF569",MAGE="|cff40C7EB",WARLOCK="|cff8787ED",HUNTER="|cffABD473",SHAMAN="|cff0070DE" }
------------------------ Variablen --------------------------

-------------------- help functions -----------------------
local function print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffcccc33INFO: |cffffff55" .. ( tostring(msg) or "nil" ))
end

local function ClassColor(value, classEN)
    if type(value) == "table" then
      _table = _table .. " " .. formatting
      _table = _table .. Tparse(value, indent+1)
    elseif type(value) == 'boolean' then
      _table = _table .. " " .. formatting .. tostring(value)
    else
      _table = _table .. " " .. formatting .. value
    end
end

local function GetClassRole(ClassEN)
    if(ClassEN == "PALADIN") then return HEAL
    elseif(ClassEN == "PRIEST") then return HEAL
    elseif(ClassEN == "DRUID") then return HEAL
    elseif(ClassEN == "WARRIOR") then return TANK
    elseif(ClassEN == "ROUGE") then return MELEE
    elseif(ClassEN == "MAGE") then return RANGE
    elseif(ClassEN == "WARLOCK") then return RANGE
    elseif(ClassEN == "HUNTER") then return RANGE
    elseif(ClassEN == "SHAMAN") then return HEAL
    end
end

function Tparse(tbl, indent)
  if (type(tbl) ~= "table") then return NO_TABLE end
  if not indent then indent = 0 end
  local _table = ""
  for key, value in pairs(tbl) do
    formatting = string.rep("  ", indent) .. key .. ": "
    if type(value) == "table" then
      _table = _table .. " " .. formatting
      _table = _table .. Tparse(value, indent+1)
    elseif type(value) == 'boolean' then
      _table = _table .. " " .. formatting .. tostring(value)
    else
      _table = _table .. " " .. formatting .. value
    end
  end
  return _table .. "\n"
end

local function UpdateDB()
    currentGroup={}
    for i=1, GetNumRaidMembers() do
        local name,rank,subgroup,_,class,ClassEN,_,online = GetRaidRosterInfo(i);
        local role = GetClassRole(ClassEN)
        if not (RS_PlayerDB[name]) then
            RS_PlayerDB[name]= {class,ClassEN}
        end
        if not (currentGroup[name]) then
            currentGroup[name]= {class,role,subgroup,i,rank }
        end
    end
end

function UpdateRaid()
  --toggle = not toggle;
  --if toggle then return end
    UpdateDB()
    local _currentGroup = Tparse(currentGroup)

  RaidSetupFrame_Text:SetText(_currentGroup)

  --RaidSetupFrame:SetPoint("CENTER", UIParent, 0, 0)
  --RaidSetupFrame:SetWidth(RaidSetupFrame_Text:GetWidth()+4)
  --RaidSetupFrame:SetHeight(RaidSetupFrame_Text:GetHeight()+6)
end
-------------------- Register game event handlers ---------------------------
function RaidSetup_OnLoad()
  RaidSetupFrame:RegisterEvent("ADDON_LOADED")
  RaidSetupFrame:RegisterEvent("RAID_ROSTER_UPDATE")
    RaidSetupFrame:RegisterEvent("UPDATE_INSTANCE_INFO")
end

-------------------- Event Handler ----------------------
function RaidSetup_OnEvent(event)
	if (event == "ADDON_LOADED") and (arg1 == "RaidSetup") then
		print("RaidSetup loaded")
    end
  if (event == "RAID_ROSTER_UPDATE") then
      UpdateRaid()
  end
    if (event == "UPDATE_INSTANCE_INFO") and (UnitInRaid("player")) then
        UpdateRaid()
        RaidSetupFrame:Show()
    end
end

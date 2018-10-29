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
-- select (n, ...)


------------------------ Variablen --------------------------
if not RS_PlayerDB then RS_PlayerDB = {} end
if not RS_SetupDB then RS_SetupDB = {} end

local currentGroup={}
local groupSetup={}

local classes={".ANY","----","PALADIN","PRIEST","DRUID","WARRIOR","ROGUE","MAGE","WARLOCK","HUNTER" }
if (UnitFactionGroup("player") == "Horde") then table.insert(classes,"SHAMAN") end
local roles={".ANY","----","TANK","HEAL","MELEE","RANGE","----",".CLOSED"}
------------------------ Variablen --------------------------

-------------------- help functions -----------------------
local function print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffcccc33INFO: |cffffff55" .. ( tostring(msg) or "nil" ))
end

local function GetNamesByRole(role)
    local _tmp = {}
    for k,v in RS_PlayerDB do
        if(v[2]==role) then
            table.insert(_tmp, k)
        end
    end
    table.sort(_tmp)
    return _tmp
end

local function GetNamesByClass(class)
    local _tmp = {}
    for k,v in RS_PlayerDB do
        if(v[1]==class) then
            table.insert(_tmp, k)
        end
    end
    table.sort(_tmp)
    return _tmp
end

local function GetRoleByName(name)
    if RS_PlayerDB[name] then
        return RS_PlayerDB[name][2]
    end
    return nil
end

local function GetRolesByClass(class)
    local _tmp = {}
    for _,v in RS_PlayerDB do
        if(v[1]==class) then
            _tmp[v[2]]="1"
        end
    end
    table.sort(_tmp)
    return _tmp
end

local function GetClassByName(name)
    if RS_PlayerDB[name] then
        return RS_PlayerDB[name][1]
    end
    return name
end

local function GetClassesByRole(role)
    local _tmp = {}
    for _,v in RS_PlayerDB do
        if(v[2]==role) then
            _tmp[v[1]]="1"
        end
    end
    if table.getn(_tmp) == 0 then
        return role
    end
    table.sort(_tmp)
    return _tmp
end

local function GetClassByClass(class)
    return class
end

local function GetClassColor(name)
    local ClassEN = GetClassByName(name)
    if(ClassEN == ".ANY") then return "|cff00FF00"
    elseif(ClassEN == ".CLOSED") then return "|cffFF0000"
    elseif(ClassEN == "PALADIN") then return "|cffF58CBA"
    elseif(ClassEN == "PRIEST") then return "|cffffffff"
    elseif(ClassEN == "DRUID") then return "|cffFF7D0A"
    elseif(ClassEN == "WARRIOR") then return "|cffC79C6E"
    elseif(ClassEN == "ROGUE") then return "|cffFFF569"
    elseif(ClassEN == "MAGE") then return "|cff40C7EB"
    elseif(ClassEN == "WARLOCK") then return "|cff8787ED"
    elseif(ClassEN == "HUNTER") then return "|cffABD473"
    elseif(ClassEN == "SHAMAN") then return "|cff0070DE"
    else return "|cffA5A5A5" end
end

local function GetClassRole(name)
    local ClassEN = GetClassByName(name) or name
    if(ClassEN == "PALADIN") then return "HEAL"
    elseif(ClassEN == "PRIEST") then return "HEAL"
    elseif(ClassEN == "DRUID") then return "HEAL"
    elseif(ClassEN == "WARRIOR") then return "TANK"
    elseif(ClassEN == "ROGUE") then return "MELEE"
    elseif(ClassEN == "MAGE") then return "RANGE"
    elseif(ClassEN == "WARLOCK") then return "RANGE"
    elseif(ClassEN == "HUNTER") then return "RANGE"
    elseif(ClassEN == "SHAMAN") then return "HEAL"
    else return "" end
end

function Tparse(tbl, indent)
  if (type(tbl) ~= "table") then return NO_TABLE end
  if not indent then indent = 0 end
  local _table = ""
  for key, value in ipairs(tbl) do
    local formatting =  GetClassColor(key) .. string.rep("  ", indent) .. key .. ": "
    if type(value) == "table" then
      _table = _table .. " " .. formatting
      _table = _table .. Tparse(value, indent+1)
    elseif type(value) == 'boolean' then
      _table = _table .. " " .. formatting .. tostring(value)
    elseif type(value) == 'userdata' then
        _table = _table .. " " .. formatting .. getglobal(value):GetName()
    else
      _table = _table .. " " .. formatting .. value
    end
  end
  return _table .. "\n"
end

local function Tsort(t)
    local tkeys = {}
    -- populate the table that holds the keys
    for k in pairs(t) do table.insert(tkeys, k) end
    -- sort the keys
    table.sort(tkeys)
    -- use the keys to retrieve the values in the sorted order
    local _table = ""
    for _, k in ipairs(tkeys) do _table = _table .. GetClassColor(GetClassByName(k)) .. k .. Tparse(t[k]) end
    return _table
end

local function UpdateDB()
    currentGroup = {}
    for i=1, GetNumRaidMembers() do
        local name,rank,subgroup,_,class,ClassEN,_,online = GetRaidRosterInfo(i);
        local role = GetClassRole(ClassEN)
        if not (RS_PlayerDB[name]) then
            RS_PlayerDB[name]= {ClassEN,role}
        end
        if not (currentGroup[name]) then
            currentGroup[name]= {class,role,subgroup,i,rank,online }
        end
    end
end

local function UpdateRaid()
    UpdateDB()
    currentGroup = RS_PlayerDB
end

function SaveSetup(Instance, Boss)
    if not RS_SetupDB[Instance] then
        RS_SetupDB[Instance] = {} end
    if not RS_SetupDB[Instance][Boss] then
        RS_SetupDB[Instance][Boss] = {GroupSetup = {}} end
    RS_SetupDB[Instance][Boss].GroupSetup = groupSetup
end

function LoadSetup(Instance, Boss)
    groupSetup = RS_SetupDB[Instance][Boss].GroupSetup
    for grp=1,8,1 do
        for player=1,5,1 do
            for set=1,3,1 do
                local button = getglobal("RaidSetupFrame_Grp"..grp.."_Btn"..player..set)
                UIDropDownMenu_SetSelectedValue(button, groupSetup[grp][player][set])
            end
        end
    end
    RaidSetupFrame:Hide()
    RaidSetupFrame:Show()
end

local function UpdateSetup()
    groupSetup = {}
    for grp=1,8,1 do
        table.insert(groupSetup, grp, {})
        for player=1,5,1 do
            table.insert(groupSetup[grp], player, {})
            for set=1,3,1 do
                local button = getglobal("RaidSetupFrame_Grp"..grp.."_Btn"..player..set)
                table.insert(groupSetup[grp][player], set, button.selectedValue)
            end
        end
    end
end

local function GetTypeList(arg1)
    local _,_,grp,_,btn,set = string.find(arg1:GetName(), "(%d)(.+)(%d)(%d)")
    local _frame = getglobal(string.gsub(arg1:GetName(), "(%d)(.+)(%d)(%d)", "%1%2%31"))
    if(set=="1") then
        return roles, GetClassesByRole
    elseif(set=="2") then
        if (UIDropDownMenu_GetSelectedValue(_frame)==".CLOSED") then
            return {".CLOSED"}, GetClassByName
        end
        return classes, GetClassByName
    elseif(set=="3") then
        if (UIDropDownMenu_GetSelectedValue(_frame)==".CLOSED") then
            return {".CLOSED"}, GetClassByName
        end
        local tkeys = {}
        for k in pairs(RS_PlayerDB) do table.insert(tkeys, k) if table.getn(tkeys) >= 30 then break end end
        table.sort(tkeys)
        table.insert(tkeys,1, ".ANY")
        table.insert(tkeys,2, "----")
        return tkeys, GetClassByName
    end
end

function RS_InstanceDropDown_Init()
    local info;
    local frame = getglobal(string.gsub(this:GetName() ,"Button",""));
    local list = {"Naxxramas"}
    for _,v in pairs(list) do
        info = {
            justifyH="LEFT";
            text = "|cffffffff"..v;
            func = RS_InstanceDropDown_OnClick;
            arg1=frame;
            value=v
        };
        if(v=="----")then info.notClickable="1" end;
        UIDropDownMenu_AddButton(info);
    end
    --print("Init(): "..getglobal(string.gsub(this:GetName() ,"Button","")):GetName())
end

function RS_BossDropDown_Init()
    local info;
    local frame = getglobal(string.gsub(this:GetName() ,"Button",""));
    local list = {"---- Spider_Wing","Anub_Rekhan","Grand_Widow_Faerlina","Maexxna","---- Plague_Wing","Noth_the_Plaguebringer","Haigen_the_Unclean","Loatheb","---- Deathknight_Wing","Instructor_Razuvious","Gothik_the_Harvester","Four_HM","---- Abomination_Wing","Patchwerk","Grobbulus","Gluth","Thaddius,""---- Frostwyrm_Lair","Sapphiron","Kel_Thuzad"}
    for _,v in pairs(list) do
        info = {
            justifyH="LEFT";
            text = "|cffffffff"..v;
            func = RS_BossDropDown_OnClick;
            arg1=frame;
            value=v
        };
        if(string.find(v,"----"))then info.notClickable="1" end;
        UIDropDownMenu_AddButton(info);
    end
    --print("Init(): "..getglobal(string.gsub(this:GetName() ,"Button","")):GetName())
end

function RS_PlayerDropDown_Init()
    local info;
    local frame = getglobal(string.gsub(this:GetName() ,"Button",""));
    local list, method = GetTypeList(frame)
    for _,v in pairs(list) do
        info = {
            justifyH="LEFT";
            text = GetClassColor(method(v))..v;
            func = RS_PlayerDropDown_OnClick;
            arg1=frame;
            value=v
        };
        if(v=="----")then info.notClickable="1" end;
        UIDropDownMenu_AddButton(info);
    end
    --print("Init(): "..getglobal(string.gsub(this:GetName() ,"Button","")):GetName())
end


function RS_PlayerDropDown_OnShow()
    if string.find(this:GetName(), "Instance") then
        UIDropDownMenu_Initialize(this, RS_InstanceDropDown_Init)
        UIDropDownMenu_SetSelectedValue(this, this.selectedValue)
    elseif string.find(this:GetName(), "Boss") then
        UIDropDownMenu_Initialize(this, RS_BossDropDown_Init)
        UIDropDownMenu_SetSelectedValue(this, this.selectedValue)
    else
        UIDropDownMenu_Initialize(this, RS_PlayerDropDown_Init)
        UIDropDownMenu_SetSelectedValue(this, this.selectedValue)
    end
end

function RS_InstanceDropDown_OnClick(button) -- button = RaidSetupFrame_GrpX_BtnYZ
    UIDropDownMenu_SetSelectedValue(button, this.value) -- this = DropDownList1Button[level]
end

function RS_BossDropDown_OnClick(button) -- button = RaidSetupFrame_GrpX_BtnYZ
    UIDropDownMenu_SetSelectedValue(button, this.value) -- this = DropDownList1Button[level]
end

function RS_PlayerDropDown_OnClick(button) -- button = RaidSetupFrame_GrpX_BtnYZ
    UIDropDownMenu_SetSelectedValue(button, this.value) -- this = DropDownList1Button[level]

    if(this.value == ".CLOSED") then
        local btn2 = getglobal(string.gsub(button:GetName(), "(%d)(.+)(%d)(%d)", "%1%2%32"))
        local btn3 = getglobal(string.gsub(button:GetName(), "(%d)(.+)(%d)(%d)", "%1%2%33"))
        --UIDropDownMenu_ClearAll(btn2)
        --UIDropDownMenu_ClearAll(btn2)
        UIDropDownMenu_SetSelectedValue(btn2, button.selectedValue)
        UIDropDownMenu_SetSelectedValue(btn3, button.selectedValue)
    end
    UpdateSetup()
end

function RaidSetup()
    RaidSetupFrame:Show()
end

-------------------- Register game event handlers ---------------------------
function RaidSetup_OnLoad()
    RaidSetupFrame:RegisterEvent("ADDON_LOADED")
    RaidSetupFrame:RegisterEvent("RAID_ROSTER_UPDATE")
    RaidSetupFrame:RegisterEvent("UPDATE_INSTANCE_INFO")
    getglobal("DropDownList1"):SetClampedToScreen( true )
    SLASH_RAIDSETUP_SLASH1 = '/RaidSetup'
    SlashCmdList['RAIDSETUP_SLASH'] = RaidSetup
end

-------------------- Event Handler ----------------------
function RaidSetup_OnEvent(event)
	if (event == "ADDON_LOADED") and (arg1 == "RaidSetup") then
		print("RaidSetup loaded")
        LoadSetup("Naxxramas", "Four_HM")
    end
    if (event == "RAID_ROSTER_UPDATE") then
        UpdateRaid()
    end
end

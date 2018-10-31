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
local currentGroup={}
local groupSetup={}

local classes={".ANY","----","PALADIN","PRIEST","DRUID","WARRIOR","ROGUE","MAGE","WARLOCK","HUNTER" }
if (UnitFactionGroup("player") == "Horde") then table.insert(classes,"SHAMAN") end
local roles={".ANY","----","TANK","HEAL","MEELE","RANGE","----",".CLOSED"}
------------------------ Variablen --------------------------

-------------------- help functions -----------------------
local function print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffcccc33RaidSetup: |cffffff55" .. ( tostring(msg) or "nil" ))
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

local function GetClassRoles(name)
    local ClassEN = GetClassByName(name) or name
    if(ClassEN == "PALADIN") then return {"HEAL","TANK","MEELE"}
    elseif(ClassEN == "PRIEST") then return {"HEAL","RANGE"}
    elseif(ClassEN == "DRUID") then return {"HEAL","MEELE","RANGE","TANK"}
    elseif(ClassEN == "WARRIOR") then return {"TANK","MEELE"}
    elseif(ClassEN == "ROGUE") then return {"MEELE"}
    elseif(ClassEN == "MAGE") then return {"RANGE"}
    elseif(ClassEN == "WARLOCK") then return {"RANGE"}
    elseif(ClassEN == "HUNTER") then return {"RANGE"}
    elseif(ClassEN == "SHAMAN") then return {"HEAL","MEELE","RANGE"}
    else return "" end
end

local function GetRolesByClass(name)
    if RS_PlayerDB[name] then
        return RS_PlayerDB[name][2]
    end
    return GetClassRoles(name)
end

local function GetRoleClasses(role)
    local list
    if(role == "HEAL") then list = {".ANY","----","PALADIN","PRIEST","DRUID"}
        if (UnitFactionGroup("player") == "Horde") then table.insert(list,"SHAMAN") end
    elseif(role == "TANK") then list = {".ANY","----","WARRIOR","DRUID","PALADIN"}
    elseif(role == "MEELE") then list = {".ANY","----","ROGUE","WARRIOR","DRUID","PALADIN" }
        if (UnitFactionGroup("player") == "Horde") then table.insert(list,"SHAMAN") end
    elseif(role == "RANGE") then list = {".ANY","----","MAGE","WARLOCK","HUNTER","DRUID","PRIEST" }
        if (UnitFactionGroup("player") == "Horde") then table.insert(list,"SHAMAN") end
    else assert(nil, "Role does not exists: " .. role)
    end
    return list
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

local function UpdateDB()
    currentGroup = {}
    for i=1, GetNumRaidMembers() do
        local name,rank,subgroup,_,class,ClassEN,_,online = GetRaidRosterInfo(i);
        local role = GetClassRoles(ClassEN)
        if not (RS_PlayerDB[name]) then
            RS_PlayerDB[name]= {ClassEN,role}
        end
        if not (currentGroup[name]) then
            currentGroup[name]= {class,role,subgroup,i,rank,online }
        end
    end
end

function SaveSetup(Instance, Boss)
    if not RS_SetupDB[Instance] then
        RS_SetupDB[Instance] = {} end
    if not RS_SetupDB[Instance][Boss] then
        RS_SetupDB[Instance][Boss] = {GroupSetup = {}} end
    RS_SetupDB[Instance][Boss].GroupSetup = groupSetup
end

function LoadSetup(Instance, Boss)
    UIDropDownMenu_SetSelectedValue(getglobal("RaidSetupFrame_Instance"), Instance)
    UIDropDownMenu_SetSelectedValue(getglobal("RaidSetupFrame_Boss"), Boss)
    groupSetup = assert(RS_SetupDB[Instance][Boss].GroupSetup, "No Setup for: " .. Instance .. "->"..Boss)
    for grp=1,8,1 do
        for player=1,5,1 do
            for set=1,3,1 do
                local button = assert(getglobal("RaidSetupFrame_Grp"..grp.."_Btn"..player..set), "Can't find: RaidSetupFrame_Grp"..grp.."_Btn"..player..set)
                if UIDropDownMenu_GetSelectedValue(button) ~= groupSetup[grp][player][set] then
                    UIDropDownMenu_SetSelectedValue(button, groupSetup[grp][player][set])
                    button:Hide()
                    button:Show()
                end
            end
        end
    end
end

local function UpdateRaid()
    UpdateDB()
    currentGroup = RS_PlayerDB
end

function ResetDB()
    RS_PlayerDB = RS_PlayerDB_Template
    RS_SetupDB = RS_SetupDB_Template
    LoadSetup("Naxxramas", "Maexxna")
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

function RS_InstanceDropDown_Init()
    local info
    local frame = getglobal(string.gsub(this:GetName() ,"Button",""))
    local list = {}
    for k in pairs(RS_SetupDB) do table.insert(list, k) if table.getn(list) >= 32 then break end end
    table.sort(list)
    for _,v in pairs(list) do
        info = {
            justifyH="LEFT",
            text = "|cffffffff"..v,
            func = RS_InstanceDropDown_OnClick,
            arg1=frame,
            value=v
        };
        if(string.find(v,"%p%p%p%p"))then info.notClickable="1" end
        UIDropDownMenu_AddButton(info)
    end
end

function RS_BossDropDown_Init()
    local info
    local frame = getglobal(string.gsub(this:GetName() ,"Button",""))
    local list = {}
    for k in pairs(RS_SetupDB[getglobal("RaidSetupFrame_Instance").selectedValue]) do table.insert(list, k) if table.getn(list) >= 32 then break end end
    table.sort(list)
    for _,v in pairs(list) do
        info = {
            justifyH="LEFT",
            text = "|cffffffff"..v,
            func = RS_BossDropDown_OnClick,
            arg1=frame,
            value=v
        };
        if(string.find(v,"%p%p%p%p"))then info.notClickable="1" end
        UIDropDownMenu_AddButton(info)
    end
end

local function GetTypeList(arg1)
    local _,_,grp,_,btn,set = string.find(arg1:GetName(), "(%d)(.+)(%d)(%d)")
    local button1 = getglobal(string.gsub(arg1:GetName(), "(%d)(.+)(%d)(%d)", "%1%2%31"))
    local button2 = getglobal(string.gsub(arg1:GetName(), "(%d)(.+)(%d)(%d)", "%1%2%32"))
    local button3 = getglobal(string.gsub(arg1:GetName(), "(%d)(.+)(%d)(%d)", "%1%2%33"))
    if(set=="1") then
        if (button1.selectedValue==".ANY"
        or button1.selectedValue==".CLOSED") then
            return roles, GetClassesByRole
        end
        return roles, GetClassesByRole
    elseif(set=="2") then
        if (button1.selectedValue==".CLOSED") then
            return {".CLOSED"}, GetClassByName
        end
        if (button1.selectedValue==".ANY") then
            return classes, GetClassByName
        end
        return GetRoleClasses(button1.selectedValue), GetClassByName
    elseif(set=="3") then
        local tkeys = {}
        if (button1.selectedValue==".CLOSED") then
            return {".CLOSED"}, GetClassByName
        elseif (button1.selectedValue~=".ANY") then
            for player,v in pairs(RS_PlayerDB) do
                for _,role in pairs(v[2]) do
                    if(role==button1.selectedValue) then
                        table.insert(tkeys, player)
                    end
                end
            end
        else
            for player,v in pairs(RS_PlayerDB) do
                table.insert(tkeys, player)
            end
        end
        local selectedPlayers = {}
        for grp=1,8,1 do -- get all selected players
            for p=1,5,1 do
                if getglobal("RaidSetupFrame_Grp"..grp.."_Btn"..p.."3") ~= button3 then
                    selectedPlayers[getglobal("RaidSetupFrame_Grp"..grp.."_Btn"..p.."3").selectedValue]="1"
                end
            end
        end
        if (button2.selectedValue~=".ANY") then
            for i=getn(tkeys),1,-1 do
                if(RS_PlayerDB[tkeys[i]][1]~=button2.selectedValue
                or selectedPlayers[tkeys[i]]) then
                    table.remove(tkeys, i)
                end
            end
        end
        for i=getn(tkeys),1,-1 do
            if(selectedPlayers[tkeys[i]]) then
                table.remove(tkeys, i)
            end
        end
        while table.getn(tkeys) >= 30 do
            table.remove(tkeys, table.getn(tkeys))
        end
        table.sort(tkeys)
        table.insert(tkeys,1, ".ANY")
        table.insert(tkeys,2, "----")
        return tkeys, GetClassByName
    end
end

function RS_PlayerDropDown_Init()
    local info
    local frame = getglobal(string.gsub(this:GetName() ,"Button",""))
    local list, method = GetTypeList(frame)
    for _,v in pairs(list) do
        info = {
            justifyH="LEFT",
            text = GetClassColor(method(v))..v,
            func = RS_PlayerDropDown_OnClick,
            arg1=frame,
            value=v
        };
        if(string.find(v,"%p%p%p%p"))then info.notClickable="1" end
        UIDropDownMenu_AddButton(info)
    end
end


function RS_DropDown_OnShow()
    if string.find(this:GetName(), "Instance") then
        UIDropDownMenu_Initialize(this, RS_InstanceDropDown_Init, "MENU")
        UIDropDownMenu_SetSelectedValue(this, this.selectedValue)
    elseif string.find(this:GetName(), "Boss") then
        UIDropDownMenu_Initialize(this, RS_BossDropDown_Init, "MENU")
        UIDropDownMenu_SetSelectedValue(this, this.selectedValue)
    else
        UIDropDownMenu_Initialize(this, RS_PlayerDropDown_Init)
        UIDropDownMenu_SetSelectedValue(this, this.selectedValue)
    end
end

local function GetValue(value) for k,v in pairs(RS_SetupDB[value]) do return k end end

function RS_InstanceDropDown_OnClick(button) -- button = RaidSetupFrame_Instance
    UIDropDownMenu_SetSelectedValue(button, this.value) -- this = DropDownList1Button[level]
    local bossButton = getglobal("RaidSetupFrame_Boss")
    UIDropDownMenu_SetSelectedValue(bossButton, GetValue(this.value))
    bossButton:Hide()
    bossButton:Show()
end

function RS_BossDropDown_OnClick(button) -- button = RaidSetupFrame_Boss
    UIDropDownMenu_SetSelectedValue(button, this.value) -- this = DropDownList1Button[level]
end

function RS_PlayerDropDown_OnClick(button) -- button = RaidSetupFrame_GrpX_BtnYZ
    UIDropDownMenu_SetSelectedValue(button, this.value) -- this = DropDownList1Button[level]

    local _,_,grp,_,btn,set = string.find(button:GetName(), "(%d)(.+)(%d)(%d)")
    local button1 = getglobal(string.gsub(button:GetName(), "(%d)(.+)(%d)(%d)", "%1%2%31"))
    local button2 = getglobal(string.gsub(button:GetName(), "(%d)(.+)(%d)(%d)", "%1%2%32"))
    local button3 = getglobal(string.gsub(button:GetName(), "(%d)(.+)(%d)(%d)", "%1%2%33"))

    if( set == "1" ) then
        if( this.value == ".CLOSED") then
            UIDropDownMenu_SetSelectedValue(button2, this.value)
            UIDropDownMenu_SetSelectedValue(button3, this.value)
        else
            UIDropDownMenu_SetSelectedValue(button2, ".ANY")
            UIDropDownMenu_SetSelectedValue(button3, ".ANY")
        end
    end

    if( set == "2" ) then
        UIDropDownMenu_SetSelectedValue(button3, ".ANY")
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
        if not RS_PlayerDB then RS_PlayerDB = RS_PlayerDB_Template end
        if not RS_SetupDB then RS_SetupDB = RS_SetupDB_Template end
        LoadSetup("Naxxramas", "Maexxna")
    end
    if (event == "RAID_ROSTER_UPDATE") then
        UpdateRaid()
    end
end

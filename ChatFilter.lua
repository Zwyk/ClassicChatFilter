--[[
		=== TODO ===
	- Fenetre config (+ slash ?)
]]--

defaultProfile =
{
	["show_player_messages"] = true,
	["show_player_mentions"] = false,
	["raids"] = {},
	["dungeons"] = {},
	["roles"] = {},
	["banned"] = {},
	["channels"] = {"world","LookingForGroup"},
}

exampleProfie =
{
	["show_player_messages"] = true,
	["raids"] = {
		"molten", -- [1]
		"mc", -- [2]
		"ony", -- [3]
	},
	["channels"] = {
		"world", -- [1]
		"LookingForGroup", -- [2]
		"testfilter", -- [3]
	},
	["show_player_mentions"] = true,
	["banned"] = {
		"WTS", -- [1]
		"www", -- [2]
	},
	["roles"] = {
		"tank", -- [1]
		"war", -- [2]
	},
	["dungeons"] = {
		"scholo", -- [1]
		"strat", -- [2]
		"ubrs", -- [3]
	},
}

savedGlobalDefault =
{
	["profiles"] = {
		["Example"] = exampleProfie,
		["Default"] = defaultProfile,
	},
}

savedCharDefault =
{
	["enabled"] = true,
	["profile"] = "Default"
}

local version = "1.0"

local cf = CreateFrame("Frame", addonName);
local pname, pserver = UnitName("player");

cf:RegisterEvent("VARIABLES_LOADED");
cf:RegisterEvent("ADDON_LOADED");

cf:SetScript("OnEvent", function(self, event, arg1) self[event](self, arg1) end);

function SlashHandler()
	InterfaceOptionsFrame_OpenToCategory("ChatFilter")
end

function cf:VARIABLES_LOADED()
	--InitSavedGlobal()
	--InitSavedChar()
end

function cf:ADDON_LOADED(addon)
    if (addon == "ChatFilter") then
		SlashCmdList["CHATFILTER"] = SlashHandler;
		SLASH_CHATFILTER1 = "/chatfilter";
		SLASH_CHATFILTER2 = "/cf";
		print("render")
		InitSavedGlobal()
		InitSavedChar()
		RenderOptions()
    end
end

function InitSavedGlobal()
    if(not SavedGlobal) then
        SavedGlobal = DeepCopy(savedGlobalDefault)
    else
	    -- copy defaults to conf if key not exists
	    for k, v in pairs(savedGlobalDefault) do
	        if(not SavedGlobal[k]) then
	            SavedGlobal[k] = DeepCopy(savedGlobalDefault[k]);
	        end
	    end

	    -- remove keys not in defaults anymore
	    for k, v in pairs(SavedGlobal) do
	        if(not savedGlobalDefault[k]) then
	            SavedGlobal[k] = nil;
	        end
	    end
    end
end

function InitSavedChar()
    if (not SavedChar) then
        SavedChar = DeepCopy(savedCharDefault)
    else
	    -- copy defaults to conf if key not exists
	    for k, v in pairs(savedCharDefault) do
	        if (not SavedChar[k]) then
	            SavedChar[k] = DeepCopy(savedCharDefault[k]);
	        end
	    end

	    -- remove keys not in defaults anymore
	    for k, v in pairs(SavedChar) do
	        if (not savedCharDefault[k]) then
	            SavedChar[k] = nil;
	        end
	    end
	end
end

StaticPopupDialogs["CHATFILTER_PROFILE_ADD"] = {
	text = "New profile",
	button1 = OKAY,
	button2 = CANCEL,
	OnShow = function(self)
		self.editBox:SetScript("OnEnterPressed", function()
			CreateProfile(self.editBox:GetText())
			StaticPopup_Hide("CHATFILTER_PROFILE_ADD")
		end)
		self.editBox:SetScript("OnEscapePressed", function()
			CreateProfile(self.editBox:GetText())
			StaticPopup_Hide("CHATFILTER_PROFILE_ADD")
		end)
	end,
	OnAccept = function(self)
		CreateProfile(self.editBox:GetText())
		StaticPopup_Hide("CHATFILTER_PROFILE_ADD")
	end,
	hasEditBox = true,
	timeout = 0,
	exclusive = 0,
	showAlert = 1,
	whileDead = 1,
	hideOnEscape = 1
}

StaticPopupDialogs["CHATFILTER_PROFILE_DELETE"] = {
	text = "Delete profile ?",
	button1 = DELETE,
	button2 = CANCEL,
	OnAccept = function(self)
		DeleteCurrentProfile()
		StaticPopup_Hide("CHATFILTER_PROFILE_DELETE")
	end,
	timeout = 0,
	exclusive = 0,
	showAlert = 1,
	whileDead = 1,
	hideOnEscape = 1
}

function RenderOptions()
	local leftMargin = 20
	local headerPos = -20
	local enabledPos = headerPos - 15
	local profilesPos = enabledPos - 50
	local pmessagesPos = profilesPos - 25
	local pmentionsPos = pmessagesPos - 20
	local channelsPos = pmentionsPos - 30
	local bannedPos = channelsPos - 50
	local rolesPos = bannedPos - 50
	local dungeonsPos = rolesPos - 50
	local raidsPos = dungeonsPos - 50

	local options = CreateFrame("FRAME","cf_options");
	options.name = "ChatFilter";
	options:SetScript("OnShow", function(self)
		RefreshValues()
	end);
	InterfaceOptions_AddCategory(options);

	local header = options:CreateFontString(nil, "ARTWORK","GameFontNormalLarge");
	header:SetPoint("TOPLEFT", leftMargin, headerPos);
	header:SetText("ChatFilter");
	local ver=options:CreateFontString(nil,"ARTWORK","GameFontNormalSmall");
	ver:SetPoint("BOTTOMLEFT",header,"BOTTOMRIGHT",1,0);
	ver:SetTextColor(0.5,0.5,0.5);
	ver:SetText("v"..version);

	local enabledButton = CreateFrame("CheckButton", "cf_enabledButton", options, "ChatConfigCheckButtonTemplate");
	enabledButton:SetPoint("TOPLEFT", leftMargin, enabledPos)
	enabledButton.tooltip = "Enable the ChatFilter addon.";
	_G[enabledButton:GetName().."Text"]:SetText("Enabled");
	enabledButton:SetChecked(SavedChar.enabled);
	enabledButton:SetScript("OnClick", function(self)
		SavedChar.enabled = self:GetChecked();
	end)

	local profilesDropDownText = options:CreateFontString(nil, "ARTWORK","GameFontNormal");
	profilesDropDownText:SetPoint("TOPLEFT", leftMargin, profilesPos);
	profilesDropDownText:SetText("Profile selection");
	profilesDropDown = L_Create_UIDropDownMenu("cf_profilesDropdown", options);
	profilesDropDown:SetPoint("LEFT", profilesDropDownText, "RIGHT", 5, -4)
	L_UIDropDownMenu_SetWidth(profilesDropDown, 150);
	L_UIDropDownMenu_SetButtonWidth(profilesDropDown, 124);
	L_UIDropDownMenu_JustifyText(profilesDropDown, "LEFT");
	profilesDropDownText.tooltip = "Select the profile to use on this character."

	local newProfileButton = CreateFrame("Button", "cf_newProfileButton", options, "OptionsButtonTemplate");
	newProfileButton:SetWidth(25)
	newProfileButton:SetPoint("LEFT", profilesDropDown, "RIGHT", 0, 2);
	newProfileButton.tooltip = "Create a new profile";
	newProfileButton:SetScript("OnClick", function(self)
		StaticPopup_Show("CHATFILTER_PROFILE_ADD")
	end);
	_G[newProfileButton:GetName().."Text"]:SetText("+");
	newProfileButton.alwaysShowTooltip = true
	newProfileButton.tooltipText = "Create a new profile."
	newProfileButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(newProfileButton, "ANCHOR_TOPLEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(self.tooltipText)
		GameTooltip:Show()
	end);
	
	deleteCurrentProfileButton = CreateFrame("Button", "cf_deleteCurrentProfileButton", options, "OptionsButtonTemplate");
	deleteCurrentProfileButton:SetWidth(25)
	deleteCurrentProfileButton:SetPoint("LEFT", newProfileButton, "RIGHT", 2, 0);
	deleteCurrentProfileButton.tooltip = "Delete current profile";
	deleteCurrentProfileButton:SetScript("OnClick", function(self)
		StaticPopup_Show("CHATFILTER_PROFILE_DELETE")
	end);
	_G[deleteCurrentProfileButton:GetName().."Text"]:SetText("-");
	deleteCurrentProfileButton.tooltipText = "Delete current profile."
	deleteCurrentProfileButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(deleteCurrentProfileButton, "ANCHOR_TOPLEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(self.tooltipText)
		GameTooltip:Show()
	end);

	pmessagesButton = CreateFrame("CheckButton", "cf_pmessagesButton", options, "ChatConfigCheckButtonTemplate");
	pmessagesButton:SetPoint("TOPLEFT", leftMargin, pmessagesPos)
	pmessagesButton.tooltip = "Always show your own messages.";
	_G[pmessagesButton:GetName().."Text"]:SetText("Always show player's messages");
	pmessagesButton:SetScript("OnClick", function(self)
		SetCurrentValue("show_player_messages", self:GetChecked());
	end)

	pmentionsButton = CreateFrame("CheckButton", "cf_pmentionsButton", options, "ChatConfigCheckButtonTemplate");
	pmentionsButton:SetPoint("TOPLEFT", leftMargin, pmentionsPos)
	pmentionsButton.tooltip = "Always show messages containing your character's name.";
	_G[pmentionsButton:GetName().."Text"]:SetText("Always show player mentions");
	pmentionsButton:SetScript("OnClick", function(self)
		SetCurrentValue("show_player_mentions", self:GetChecked());
	end)

	local channelsBoxText = options:CreateFontString(nil, "ARTWORK","GameFontWhite");
	channelsBoxText:SetPoint("TOPLEFT", leftMargin, channelsPos);
	channelsBoxText:SetText("Channels :");
	channelsBox = CreateFrame("editbox", "cf_channelsBox", options, "InputBoxTemplate")
	channelsBox:SetPoint("TOPLEFT", channelsBoxText, "BOTTOMLEFT", 0, 0);
	channelsBox:SetPoint("RIGHT", options, "RIGHT", -10, 0)
	channelsBox:SetHeight(25)
	channelsBox:SetAutoFocus(false)
	channelsBox:ClearFocus()
	channelsBox:SetScript("OnEscapePressed", function(self)
		SetCurrentValue("channels", StringToTable(self:GetText()))
		self:SetAutoFocus(false)
		self:ClearFocus()
	end)
	channelsBox:SetScript("OnEnterPressed", function(self)
		SetCurrentValue("channels", StringToTable(self:GetText()))
		self:SetAutoFocus(false)
		self:ClearFocus()
	end)
	channelsBox:SetScript("OnEditFocusLost", function(self)
		SetCurrentValue("channels", StringToTable(self:GetText()))
		self:SetAutoFocus(false)
		self:ClearFocus()
	end)
	channelsBox:SetScript("OnEditFocusGained", function(self)
		self:SetAutoFocus(true)
	end)
	local channelsHelp=options:CreateFontString(nil,"ARTWORK","GameFontNormalSmall");
	channelsHelp:SetPoint("BOTTOMRIGHT", channelsBox,"TOPRIGHT",0,0);
	channelsHelp:SetTextColor(0.5,0.5,0.5);
	channelsHelp:SetText("Channels you want to be filtered");

	local bannedBoxText = options:CreateFontString(nil, "ARTWORK","GameFontWhite");
	bannedBoxText:SetPoint("TOPLEFT", leftMargin, bannedPos);
	bannedBoxText:SetText("Banned :");
	bannedBox = CreateFrame("editbox", "cf_bannedBox", options, "InputBoxTemplate")
	bannedBox:SetPoint("TOPLEFT", bannedBoxText, "BOTTOMLEFT", 0, 0);
	bannedBox:SetPoint("RIGHT", options, "RIGHT", -10, 0)
	bannedBox:SetHeight(25)
	bannedBox:SetAutoFocus(false)
	bannedBox:ClearFocus()
	bannedBox:SetScript("OnEscapePressed", function(self)
		SetCurrentValue("banned", StringToTable(self:GetText()))
		self:SetAutoFocus(false)
		self:ClearFocus()
	end)
	bannedBox:SetScript("OnEnterPressed", function(self)
		SetCurrentValue("banned", StringToTable(self:GetText()))
		self:SetAutoFocus(false)
		self:ClearFocus()
	end)
	bannedBox:SetScript("OnEditFocusLost", function(self)
		SetCurrentValue("banned", StringToTable(self:GetText()))
		self:SetAutoFocus(false)
		self:ClearFocus()
	end)
	bannedBox:SetScript("OnEditFocusGained", function(self)
		self:SetAutoFocus(true)
	end)
	local bannedHelp=options:CreateFontString(nil,"ARTWORK","GameFontNormalSmall");
	bannedHelp:SetPoint("BOTTOMRIGHT", bannedBox,"TOPRIGHT",0,0);
	bannedHelp:SetTextColor(0.5,0.5,0.5);
	bannedHelp:SetText("Messages containing at least one of the following keywords won't show");

	local rolesBoxText = options:CreateFontString(nil, "ARTWORK","GameFontWhite");
	rolesBoxText:SetPoint("TOPLEFT", leftMargin, rolesPos);
	rolesBoxText:SetText("Roles :");
	rolesBox = CreateFrame("editbox", "cf_rolesBox", options, "InputBoxTemplate")
	rolesBox:SetPoint("TOPLEFT", rolesBoxText, "BOTTOMLEFT", 0, 0);
	rolesBox:SetPoint("RIGHT", options, "RIGHT", -10, 0)
	rolesBox:SetHeight(25)
	rolesBox:SetAutoFocus(false)
	rolesBox:ClearFocus()
	rolesBox:SetScript("OnEscapePressed", function(self)
		SetCurrentValue("roles", StringToTable(self:GetText()))
		self:SetAutoFocus(false)
		self:ClearFocus()
	end)
	rolesBox:SetScript("OnEnterPressed", function(self)
		SetCurrentValue("roles", StringToTable(self:GetText()))
		self:SetAutoFocus(false)
		self:ClearFocus()
	end)
	rolesBox:SetScript("OnEditFocusLost", function(self)
		SetCurrentValue("roles", StringToTable(self:GetText()))
		self:SetAutoFocus(false)
		self:ClearFocus()
	end)
	rolesBox:SetScript("OnEditFocusGained", function(self)
		self:SetAutoFocus(true)
	end)
	local rolesHelp=options:CreateFontString(nil,"ARTWORK","GameFontNormalSmall");
	rolesHelp:SetPoint("BOTTOMRIGHT", rolesBox,"TOPRIGHT",0,0);
	rolesHelp:SetTextColor(0.5,0.5,0.5);
	rolesHelp:SetText("Roles you want to see (if empty, filter won't be used)");

	local dungeonsBoxText = options:CreateFontString(nil, "ARTWORK","GameFontWhite");
	dungeonsBoxText:SetPoint("TOPLEFT", leftMargin, dungeonsPos);
	dungeonsBoxText:SetText("Dungeons : ");
	dungeonsBox = CreateFrame("editbox", "cf_dungeonsBox", options, "InputBoxTemplate")
	dungeonsBox:SetPoint("TOPLEFT", dungeonsBoxText, "BOTTOMLEFT", 0, 0);
	dungeonsBox:SetPoint("RIGHT", options, "RIGHT", -10, 0)
	dungeonsBox:SetHeight(25)
	dungeonsBox:SetAutoFocus(false)
	dungeonsBox:ClearFocus()
	dungeonsBox:SetScript("OnEscapePressed", function(self)
		SetCurrentValue("dungeons", StringToTable(self:GetText()))
		self:SetAutoFocus(false)
		self:ClearFocus()
	end)
	dungeonsBox:SetScript("OnEnterPressed", function(self)
		SetCurrentValue("dungeons", StringToTable(self:GetText()))
		self:SetAutoFocus(false)
		self:ClearFocus()
	end)
	dungeonsBox:SetScript("OnEditFocusLost", function(self)
		SetCurrentValue("dungeons", StringToTable(self:GetText()))
		self:SetAutoFocus(false)
		self:ClearFocus()
	end)
	dungeonsBox:SetScript("OnEditFocusGained", function(self)
		self:SetAutoFocus(true)
	end)
	local dungeonsHelp=options:CreateFontString(nil,"ARTWORK","GameFontNormalSmall");
	dungeonsHelp:SetPoint("BOTTOMRIGHT", dungeonsBox,"TOPRIGHT",0,0);
	dungeonsHelp:SetTextColor(0.5,0.5,0.5);
	dungeonsHelp:SetText("Dungeons you want to see (if empty, filter won't be used)");

	local raidsBoxText = options:CreateFontString(nil, "ARTWORK","GameFontWhite");
	raidsBoxText:SetPoint("TOPLEFT", leftMargin, raidsPos);
	raidsBoxText:SetText("Raids : ");
	raidsBox = CreateFrame("editbox", "cf_raidsBox", options, "InputBoxTemplate")
	raidsBox:SetPoint("TOPLEFT", raidsBoxText, "BOTTOMLEFT", 0, 0);
	raidsBox:SetPoint("RIGHT", options, "RIGHT", -10, 0)
	raidsBox:SetHeight(25)
	raidsBox:SetAutoFocus(false)
	raidsBox:ClearFocus()
	raidsBox:SetScript("OnEscapePressed", function(self)
		SetCurrentValue("raids", StringToTable(self:GetText()))
		self:SetAutoFocus(false)
		self:ClearFocus()
	end)
	raidsBox:SetScript("OnEnterPressed", function(self)
		SetCurrentValue("raids", StringToTable(self:GetText()))
		self:SetAutoFocus(false)
		self:ClearFocus()
	end)
	raidsBox:SetScript("OnEditFocusLost", function(self)
		SetCurrentValue("raids", StringToTable(self:GetText()))
		self:SetAutoFocus(false)
		self:ClearFocus()
	end)
	raidsBox:SetScript("OnEditFocusGained", function(self)
		self:SetAutoFocus(true)
	end)
	local raidsHelp=options:CreateFontString(nil,"ARTWORK","GameFontNormalSmall");
	raidsHelp:SetPoint("BOTTOMRIGHT", raidsBox,"TOPRIGHT",0,0);
	raidsHelp:SetTextColor(0.5,0.5,0.5);
	raidsHelp:SetText("Raids you want to see (if empty, filter won't be used)");

	local help=options:CreateFontString(nil,"ARTWORK","GameFontNormalSmall");
	help:SetPoint("BOTTOMLEFT", options,"BOTTOMLEFT", leftMargin , 20);
	help:SetTextColor(0.5,0.5,0.5);
	help:SetJustifyH("LEFT");
	help:SetWidth(590);
	local helpText = "Keywords have to be separated by a |cff7eff7ecomma|cff7e7e7e (|cff7eff7e,|cff7e7e7e)."
					.."\n\n|cffffffffRoles|cff7e7e7e and |cffffffffDungeons|cff7e7e7e filters are used in |cffff7e7ecombination|cff7e7e7e."
					.."\n|cffffffffRaids|cff7e7e7e filter |cffff7e7edoesn't combine|cff7e7e7e with |cffffffffRoles|cff7e7e7e."
					.."\n\nExample :"
					.."\n|cff7e7efftank|cff7e7e7e as |cffffffffRoles|cff7e7e7e, |cff7e7effscholo,strat|cff7e7e7e as |cffffffffDungeons|cff7e7e7e and |cff7e7effonyxia|cff7e7e7e as |cffffffffRaids|cff7e7e7e"
					.."\nwould only show messages mentioning |cff7e7effonyxia|cff7e7e7e |cff7eff7eor|cff7e7e7e (|cff7e7efftank|cff7e7e7e |cffff7e7eand|cff7e7e7e (|cff7e7effscholo|cff7e7e7e |cff7eff7eor|cff7e7e7e |cff7e7effstrat|cff7e7e7e))"
					.."\n\nChatFilter will later be updated to support custom advanced filters."
	help:SetText(helpText)

	channelsBox:SetScript("OnTabPressed", function(self)
		self:SetAutoFocus(false)
		self:ClearFocus()
		if(IsShiftKeyDown()) then
			raidsBox:SetAutoFocus(true)
		else
			bannedBox:SetAutoFocus(true)
		end
	end)
	bannedBox:SetScript("OnTabPressed", function(self)
		self:SetAutoFocus(false)
		self:ClearFocus()
		if(IsShiftKeyDown()) then
			channelsBox:SetAutoFocus(true)
		else
			rolesBox:SetAutoFocus(true)
		end
	end)
	rolesBox:SetScript("OnTabPressed", function(self)
		self:SetAutoFocus(false)
		self:ClearFocus()
		if(IsShiftKeyDown()) then
			bannedBox:SetAutoFocus(true)
		else
			dungeonsBox:SetAutoFocus(true)
		end
	end)
	dungeonsBox:SetScript("OnTabPressed", function(self)
		self:SetAutoFocus(false)
		self:ClearFocus()
		if(IsShiftKeyDown()) then
			rolesBox:SetAutoFocus(true)
		else
			raidsBox:SetAutoFocus(true)
		end
	end)
	raidsBox:SetScript("OnTabPressed", function(self)
		self:SetAutoFocus(false)
		self:ClearFocus()
		if(IsShiftKeyDown()) then
			dungeonsBox:SetAutoFocus(true)
		else
			channelsBox:SetAutoFocus(true)
		end
	end)

	SetProfile(SavedChar["profile"])
end

function CreateProfile(val)
	if(#val > 0 and not SavedGlobal["profiles"][val]) then
		SavedGlobal["profiles"][val] = DeepCopy(defaultProfile)
		SetProfile(val)
		RefreshValues()
	else
		print("Couldn't create profile")
	end
end

function DeleteCurrentProfile()
	SavedGlobal["profiles"][SavedChar["profile"]] = nil
	SetProfile("Default")
	RefreshValues()
end

function SetProfile(val,noinit)
	if(not noinit) then 
		L_UIDropDownMenu_Initialize(profilesDropDown, profilesDropdownInit);
	end
	SavedChar["profile"] = val;
	L_UIDropDownMenu_SetSelectedValue(profilesDropDown, val);
	if(val == "Default") then
		deleteCurrentProfileButton:Disable()
	else
		deleteCurrentProfileButton:Enable()
	end
end

function RefreshValues()
	pmessagesButton:SetChecked(GetCurrentValue("show_player_messages"));
	pmentionsButton:SetChecked(GetCurrentValue("show_player_mentions"));
	channelsBox:SetText(TableToString(GetCurrentValue("channels")));
	bannedBox:SetText(TableToString(GetCurrentValue("banned")));
	rolesBox:SetText(TableToString(GetCurrentValue("roles")));
	dungeonsBox:SetText(TableToString(GetCurrentValue("dungeons")));
	raidsBox:SetText(TableToString(GetCurrentValue("raids")));
end

function profilesDropdownInit(self, level)
	for key, value in pairs(SavedGlobal["profiles"]) do
		local info;
		info = L_UIDropDownMenu_CreateInfo();
		info.text = key;
		info.value = key;
		info.arg1 = key;
		info.func = function(self, arg1, arg2, checked) 
			SetProfile(self.value, true)
			RefreshValues()
		end
		L_UIDropDownMenu_AddButton(info, level);
	end
end

function Filter(self,event,msg,author,arg1,arg2,arg3,arg4,arg5,arg6,channel,...)
	if(SavedChar["enabled"]) then
		if(not CheckPlayerAuthor(author) and not CheckPlayerMention(msg) and CheckChannel(channel)) then
			if(CheckBanned(msg) or not CheckFilters(msg)) then
				return true
			end
		end
	end
	return false
end

function GetCurrentValue(key)
	return SavedGlobal["profiles"][SavedChar["profile"]][key]
end

function SetCurrentValue(key,val)
	SavedGlobal["profiles"][SavedChar["profile"]][key] = val
end

function HasValues(key)
	return #SavedGlobal["profiles"][SavedChar["profile"]][key] ~= 0
end

function CheckPlayerAuthor(author)
	return GetCurrentValue("show_player_messages") and CheckAuthor(author,pname)
end

function CheckPlayerMention(msg)
	return GetCurrentValue("show_player_mentions") and MatchStr(msg, pname)
end

function CheckAuthor(author,check)
	ind = string.find(author, "-")
	if(ind) then
		author = string.sub(author, 1, ind-1)
	end
	return author == check
end

function CheckChannel(channel)
	return HasValues("channels") and MatchAny(channel, GetCurrentValue("channels"))
end

function CheckBanned(msg)
	return HasValues("banned") and MatchAny(msg, GetCurrentValue("banned"))
end

function CheckFilters(msg)
	return (not HasValues("raids") or MatchAny(msg, GetCurrentValue("raids")))
		or ((not HasValues("roles") or MatchAny(msg, GetCurrentValue("roles")))
			and (not HasValues("dungeons") or MatchAny(msg, GetCurrentValue("dungeons"))))
end

function MatchAny(source,testlist)
	for _,test in pairs(testlist) do
		if(MatchStr(source,test)) then
			return true
		end
	end
	return false
end

function MatchStr(source,test)
	return string.lower(source):find(string.lower(test))
end

function DeepCopy(orig)
	local copy
    if(type(orig) == "table") then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[DeepCopy(orig_key)] = DeepCopy(orig_value)
        end
        setmetatable(copy, DeepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function TableToString(val,sep)
	return table.concat(val, sep or ",")
end

function StringToTable(val,sep)
   local sep, fields = sep or ",", {}
   local pattern = string.format("([^%s]+)", sep)
   string.gsub(val, pattern, function(c) fields[#fields+1] = c end)
   return fields
end

for type in next,getmetatable(ChatTypeInfo).__index do
	ChatFrame_AddMessageEventFilter("CHAT_MSG_"..type,Filter);
end
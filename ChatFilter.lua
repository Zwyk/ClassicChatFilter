defaultProfile =
{
	["show_player_messages"] = true,
	["show_player_mentions"] = true,
	["channels"] = {"world","LookingForGroup"},
	["banned"] = {},
	["dungeons"] = {},
	["dungeons_roles"] = {},
	["raids"] = {},
	["raids_roles"] = {},
	["other"] = {},
}

exampleProfie =
{
	["show_player_messages"] = true,
	["show_player_mentions"] = true,
	["channels"] = {
		"world", -- [1]
		"LookingForGroup", -- [2]
	},
	["banned"] = {
		"WTS", -- [1]
		"www", -- [2]
	},
	["dungeons"] = {
		"scholo", -- [1]
		"strat", -- [2]
	},
	["dungeons_roles"] = {
		"tank", -- [1]
	},
	["raids"] = {
		"onyxia", -- [3]
	},
	["raids_roles"] = {
		"tank", -- [1]
		"dps", -- [2]
	},
	["other"] = {
		"thunderfury", -- [1]
		"help", -- [2]
	},
}

savedGlobalDefault =
{
	["profiles"] = {
		["Default"] = defaultProfile,
		["Example"] = exampleProfie,
	},
}

savedCharDefault =
{
	["enabled"] = true,
	["profile"] = "Default"
}

local version = "1.0"
local addonStr = "|cff009674ChatFilter|cffffffff"

local cf = CreateFrame("Frame", addonName);
local pname, pserver = UnitName("player");

cf:RegisterEvent("VARIABLES_LOADED");
cf:RegisterEvent("ADDON_LOADED");

cf:SetScript("OnEvent", function(self, event, arg1) self[event](self, arg1) end);

function SlashHandler(arg)
	if(arg == "help") then
		print(addonStr.." available commands :")
		print("/cf or /chatfilter to open the configuration panel.")
		print("/cf disable to temporarily disable the addon.")
		print("/cf enable to re-enable the addon.")
		print("/cf toggle to toggle between enable and disable (useful for macros).")
	elseif(arg == "enable") then
		SavedChar.enabled = true
		RefreshValues()
		print(addonStr.." has been re-enabled.")
	elseif(arg == "disable") then
		SavedChar.enabled = true
		RefreshValues()
		print(addonStr.." has been temporarily disabled.")
	elseif(arg == "toggle") then
		SavedChar.enabled = not SavedChar.enabled
		RefreshValues()
		print(addonStr.." has been toggled "..((SavedChar.enabled and "ON") or "OFF"))
	else
		InterfaceOptionsFrame_OpenToCategory("ChatFilter")
		InterfaceOptionsFrame_OpenToCategory("ChatFilter")
		InterfaceOptionsFrame_OpenToCategory("ChatFilter")
	end
end

function cf:VARIABLES_LOADED()
	--InitSavedGlobal()
	--InitSavedChar()
end

function cf:ADDON_LOADED(addon)
    if(addon == "ChatFilter") then
		SlashCmdList["CHATFILTER"] = SlashHandler;
		SLASH_CHATFILTER1 = "/chatfilter";
		SLASH_CHATFILTER2 = "/cf";
		InitSavedGlobal()
		InitSavedChar()
		CheckDefault()
		CheckProfile()
		RenderOptions()
		print("|cff009674ChatFilter v"..version.." loaded. |cffffffffType /cf to configure.")
    end
end

function CheckProfile()
	if(not SavedGlobal["profiles"][SavedChar["profile"]]) then
		SavedChar["profile"] = "Default"
	end
end

function CheckDefault()
	if(not SavedGlobal["profiles"]["Default"]) then
		SavedGlobal["profiles"]["Default"] = defaultProfile
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

StaticPopupDialogs["CHATFILTER_PROFILE_RENAME"] = {
	text = "Rename profile",
	button1 = OKAY,
	button2 = CANCEL,
	OnShow = function(self)
		self.editBox:SetScript("OnEnterPressed", function()
			RenameProfile(self.editBox:GetText())
			StaticPopup_Hide("CHATFILTER_PROFILE_RENAME")
		end)
		self.editBox:SetScript("OnEscapePressed", function()
			StaticPopup_Hide("CHATFILTER_PROFILE_RENAME")
		end)
	end,
	OnAccept = function(self)
		RenameProfile(self.editBox:GetText())
		StaticPopup_Hide("CHATFILTER_PROFILE_RENAME")
	end,
	hasEditBox = true,
	timeout = 0,
	exclusive = 0,
	showAlert = 1,
	whileDead = 1,
	hideOnEscape = 1
}

StaticPopupDialogs["CHATFILTER_PROFILE_COPY"] = {
	text = "New copied profile",
	button1 = OKAY,
	button2 = CANCEL,
	OnShow = function(self)
		self.editBox:SetScript("OnEnterPressed", function()
			CopyProfile(self.editBox:GetText())
			StaticPopup_Hide("CHATFILTER_PROFILE_COPY")
		end)
		self.editBox:SetScript("OnEscapePressed", function()
			StaticPopup_Hide("CHATFILTER_PROFILE_COPY")
		end)
	end,
	OnAccept = function(self)
		CopyProfile(self.editBox:GetText())
		StaticPopup_Hide("CHATFILTER_PROFILE_COPY")
	end,
	hasEditBox = true,
	timeout = 0,
	exclusive = 0,
	showAlert = 1,
	whileDead = 1,
	hideOnEscape = 1
}

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
	local topMargin = -20

	local options = CreateFrame("FRAME","cf_options");
	options.name = "ChatFilter";
	options:SetScript("OnShow", function(self)
		RefreshValues()
	end);
	InterfaceOptions_AddCategory(options);

	local header = options:CreateFontString(nil, "ARTWORK","GameFontNormalLarge");
	header:SetPoint("TOPLEFT", leftMargin, topMargin);
	header:SetText("ChatFilter");
	local ver=options:CreateFontString(nil,"ARTWORK","GameFontNormalSmall");
	ver:SetPoint("BOTTOMLEFT",header,"BOTTOMRIGHT",1,0);
	ver:SetTextColor(0.7,0.7,0.7);
	ver:SetText("v"..version);

	enabledButton = CreateFrame("CheckButton", "cf_enabledButton", options, "ChatConfigCheckButtonTemplate");
	enabledButton:SetPoint("LEFT", ver, "RIGHT", 5, 0)
	enabledButton.tooltip = "Enable the ChatFilter addon.";
	_G[enabledButton:GetName().."Text"]:SetText("Enabled");
	enabledButton:SetScript("OnClick", function(self)
		SavedChar.enabled = self:GetChecked();
	end)

	local welcomeText=options:CreateFontString(nil,"ARTWORK","GameFontNormalSmall");
	welcomeText:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -5);
	welcomeText:SetTextColor(0.7,0.7,0.7);
	welcomeText:SetJustifyH("LEFT");
	welcomeText:SetWidth(590);
	welcomeText:SetText("|cff939393Welcome"
						.."\nblabla"
						.."\n|cff939393An example setup is available by selecting the |cffffffffExample|cff939393 profile.")

	local profilesDropDownText = options:CreateFontString(nil, "ARTWORK","GameFontNormal");
	profilesDropDownText:SetPoint("TOPLEFT", welcomeText, "BOTTOMLEFT", 0, -20);
	profilesDropDownText:SetText("Profile selection");
	profilesDropDown = L_Create_UIDropDownMenu("cf_profilesDropdown", options);
	profilesDropDown:SetPoint("LEFT", profilesDropDownText, "RIGHT", 5, -4)
	L_UIDropDownMenu_SetWidth(profilesDropDown, 150);
	L_UIDropDownMenu_SetButtonWidth(profilesDropDown, 124);
	L_UIDropDownMenu_JustifyText(profilesDropDown, "LEFT");
	profilesDropDownText.tooltip = "Select the profile to use on this character."

	renameProfileButton = CreateFrame("Button", "cf_renameProfileButton", options, "OptionsButtonTemplate");
	renameProfileButton:SetWidth(25)
	renameProfileButton:SetPoint("LEFT", profilesDropDown, "RIGHT", 0, 2);
	renameProfileButton.tooltipText = "Rename this profile.";
	renameProfileButton:SetScript("OnClick", function(self)
		StaticPopup_Show("CHATFILTER_PROFILE_RENAME")
	end);
	_G[renameProfileButton:GetName().."Text"]:SetText("R");
	renameProfileButton.alwaysShowTooltip = true
	renameProfileButton.tooltipText = "Rename this profile."
	renameProfileButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(renameProfileButton, "ANCHOR_TOPLEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(self.tooltipText)
		GameTooltip:Show()
	end);

	copyProfileButton = CreateFrame("Button", "cf_copyProfileButton", options, "OptionsButtonTemplate");
	copyProfileButton:SetWidth(25)
	copyProfileButton:SetPoint("LEFT", renameProfileButton, "RIGHT", 2, 0);
	copyProfileButton.tooltipText = "Rename this profile.";
	copyProfileButton:SetScript("OnClick", function(self)
		StaticPopup_Show("CHATFILTER_PROFILE_COPY")
	end);
	_G[copyProfileButton:GetName().."Text"]:SetText("C");
	copyProfileButton.alwaysShowTooltip = true
	copyProfileButton.tooltipText = "Copy this profile to a new one."
	copyProfileButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(copyProfileButton, "ANCHOR_TOPLEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(self.tooltipText)
		GameTooltip:Show()
	end);

	newProfileButton = CreateFrame("Button", "cf_newProfileButton", options, "OptionsButtonTemplate");
	newProfileButton:SetWidth(25)
	newProfileButton:SetPoint("LEFT", copyProfileButton, "RIGHT", 2, 0);
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
	
	deleteProfileButton = CreateFrame("Button", "cf_deleteProfileButton", options, "OptionsButtonTemplate");
	deleteProfileButton:SetWidth(25)
	deleteProfileButton:SetPoint("LEFT", newProfileButton, "RIGHT", 2, 0);
	deleteProfileButton:SetScript("OnClick", function(self)
		StaticPopup_Show("CHATFILTER_PROFILE_DELETE")
	end);
	_G[deleteProfileButton:GetName().."Text"]:SetText("-");
	deleteProfileButton.tooltipText = "Delete this profile."
	deleteProfileButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(deleteProfileButton, "ANCHOR_TOPLEFT")
		GameTooltip:ClearLines()
		GameTooltip:AddLine(self.tooltipText)
		GameTooltip:Show()
	end);

	pmessagesButton = CreateFrame("CheckButton", "cf_pmessagesButton", options, "ChatConfigCheckButtonTemplate");
	pmessagesButton:SetPoint("TOPLEFT", profilesDropDownText, "BOTTOMLEFT", 0, -20)
	pmessagesButton.tooltip = "Always show your own messages.";
	_G[pmessagesButton:GetName().."Text"]:SetText("Always show player's messages");
	pmessagesButton:SetScript("OnClick", function(self)
		SetCurrentValue("show_player_messages", self:GetChecked());
	end)

	pmentionsButton = CreateFrame("CheckButton", "cf_pmentionsButton", options, "ChatConfigCheckButtonTemplate");
	pmentionsButton:SetPoint("TOPLEFT", pmessagesButton, "BOTTOMLEFT", 0, 0)
	pmentionsButton.tooltip = "Always show messages containing your character's name.";
	_G[pmentionsButton:GetName().."Text"]:SetText("Always show player mentions");
	pmentionsButton:SetScript("OnClick", function(self)
		SetCurrentValue("show_player_mentions", self:GetChecked());
	end)

	local helpText1=options:CreateFontString(nil,"ARTWORK","GameFontNormalSmall");
	helpText1:SetPoint("TOPLEFT", pmentionsButton, "BOTTOMLEFT", 0, -5);
	helpText1:SetTextColor(0.7,0.7,0.7);
	helpText1:SetJustifyH("LEFT");
	helpText1:SetWidth(590);
	helpText1:SetText("|cff939393Keywords have to be separated by a |cff93ff93comma|cff939393 (|cff93ff93,|cff939393).")

	local channelsBoxText = options:CreateFontString(nil, "ARTWORK","GameFontWhite");
	channelsBoxText:SetPoint("TOPLEFT", helpText1, "BOTTOMLEFT", 0, -10);
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
	channelsHelp:SetTextColor(0.7,0.7,0.7);
	channelsHelp:SetText("Channels the filters will be applied to");
	local channelsTip=options:CreateFontString(nil,"ARTWORK","GameFontNormal");
	channelsTip:SetPoint("LEFT", channelsBox,"LEFT",0,0);
	channelsTip:SetTextColor(1,1,1);

	local bannedBoxText = options:CreateFontString(nil, "ARTWORK","GameFontWhite");
	bannedBoxText:SetPoint("TOPLEFT", channelsBox, "BOTTOMLEFT", 0, -5);
	bannedBoxText:SetText("Blacklisted keywords :");
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
	bannedHelp:SetTextColor(0.7,0.7,0.7);
	bannedHelp:SetText("Blacklisted keywords will be always hidden");
	local bannedTip=options:CreateFontString(nil,"ARTWORK","GameFontNormal");
	bannedTip:SetPoint("LEFT", bannedBox,"LEFT",0,0);
	bannedTip:SetTextColor(1,1,1);

	local dungeonsBoxText = options:CreateFontString(nil, "ARTWORK","GameFontWhite");
	dungeonsBoxText:SetPoint("TOPLEFT", bannedBox, "BOTTOMLEFT", 0, -5);
	dungeonsBoxText:SetText("Dungeons whitelist : ");
	dungeonsBox = CreateFrame("editbox", "cf_dungeonsBox", options, "InputBoxTemplate")
	dungeonsBox:SetPoint("TOPLEFT", dungeonsBoxText, "BOTTOMLEFT", 0, 0);
	dungeonsBox:SetHeight(25)
	dungeonsBox:SetWidth(250)
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
	dungeonsHelp:SetTextColor(0.7,0.7,0.7);
	dungeonsHelp:SetText("");
	local dungeonsTip=options:CreateFontString(nil,"ARTWORK","GameFontNormal");
	dungeonsTip:SetPoint("LEFT", dungeonsBox,"LEFT",0,0);
	dungeonsTip:SetTextColor(1,1,1);
	local dungeonsAnd=options:CreateFontString(nil,"ARTWORK","GameFontNormalSmall");
	dungeonsAnd:SetPoint("LEFT", dungeonsBox,"RIGHT", 2, 0);
	dungeonsAnd:SetTextColor(0.7,0.7,0.7);
	dungeonsAnd:SetText("|cffff9393and|cff939393");

	local dungeonsRolesBoxText = options:CreateFontString(nil, "ARTWORK","GameFontWhite");
	dungeonsRolesBoxText:SetPoint("BOTTOMLEFT", dungeonsBox, "TOPRIGHT", 30, 0);
	dungeonsRolesBoxText:SetText("Dungeon roles whitelist :");
	dungeonsRolesBox = CreateFrame("editbox", "cf_dungeonsRolesBox", options, "InputBoxTemplate")
	dungeonsRolesBox:SetPoint("TOPLEFT", dungeonsRolesBoxText, "BOTTOMLEFT", 0, 0);
	dungeonsRolesBox:SetPoint("RIGHT", options, "RIGHT", -10, 0)
	dungeonsRolesBox:SetHeight(25)
	dungeonsRolesBox:SetAutoFocus(false)
	dungeonsRolesBox:ClearFocus()
	dungeonsRolesBox:SetScript("OnEscapePressed", function(self)
		SetCurrentValue("dungeons_roles", StringToTable(self:GetText()))
		self:SetAutoFocus(false)
		self:ClearFocus()
	end)
	dungeonsRolesBox:SetScript("OnEnterPressed", function(self)
		SetCurrentValue("dungeons_roles", StringToTable(self:GetText()))
		self:SetAutoFocus(false)
		self:ClearFocus()
	end)
	dungeonsRolesBox:SetScript("OnEditFocusLost", function(self)
		SetCurrentValue("dungeons_roles", StringToTable(self:GetText()))
		self:SetAutoFocus(false)
		self:ClearFocus()
	end)
	dungeonsRolesBox:SetScript("OnEditFocusGained", function(self)
		self:SetAutoFocus(true)
	end)
	local dungeonsRolesHelp=options:CreateFontString(nil,"ARTWORK","GameFontNormalSmall");
	dungeonsRolesHelp:SetPoint("BOTTOMRIGHT", dungeonsRolesBox,"TOPRIGHT",0,0);
	dungeonsRolesHelp:SetTextColor(0.7,0.7,0.7);
	dungeonsRolesHelp:SetText("");
	local dungeonsRolesTip=options:CreateFontString(nil,"ARTWORK","GameFontNormal");
	dungeonsRolesTip:SetPoint("LEFT", dungeonsRolesBox,"LEFT",0,0);
	dungeonsRolesTip:SetTextColor(1,1,1);

	local raidsBoxText = options:CreateFontString(nil, "ARTWORK","GameFontWhite");
	raidsBoxText:SetPoint("TOPLEFT", dungeonsBox, "BOTTOMLEFT", 0, -5);
	raidsBoxText:SetText("Raids whitelist : ");
	raidsBox = CreateFrame("editbox", "cf_raidsBox", options, "InputBoxTemplate")
	raidsBox:SetPoint("TOPLEFT", raidsBoxText, "BOTTOMLEFT", 0, 0);
	raidsBox:SetHeight(25)
	raidsBox:SetWidth(250)
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
	raidsHelp:SetTextColor(0.7,0.7,0.7);
	raidsHelp:SetText("");
	local raidsTip=options:CreateFontString(nil,"ARTWORK","GameFontNormal");
	raidsTip:SetPoint("LEFT", raidsBox,"LEFT",0,0);
	raidsTip:SetTextColor(1,1,1);
	local raidsAnd=options:CreateFontString(nil,"ARTWORK","GameFontNormalSmall");
	raidsAnd:SetPoint("LEFT", raidsBox,"RIGHT", 2, 0);
	raidsAnd:SetTextColor(0.7,0.7,0.7);
	raidsAnd:SetText("|cffff9393and|cff939393");

	local raidsRolesBoxText = options:CreateFontString(nil, "ARTWORK","GameFontWhite");
	raidsRolesBoxText:SetPoint("BOTTOMLEFT", raidsBox, "TOPRIGHT", 30, 0);
	raidsRolesBoxText:SetText("Raid roles whitelist :");
	raidsRolesBox = CreateFrame("editbox", "cf_raidsRolesBox", options, "InputBoxTemplate")
	raidsRolesBox:SetPoint("TOPLEFT", raidsRolesBoxText, "BOTTOMLEFT", 0, 0);
	raidsRolesBox:SetPoint("RIGHT", options, "RIGHT", -10, 0)
	raidsRolesBox:SetHeight(25)
	raidsRolesBox:SetAutoFocus(false)
	raidsRolesBox:ClearFocus()
	raidsRolesBox:SetScript("OnEscapePressed", function(self)
		SetCurrentValue("raids_roles", StringToTable(self:GetText()))
		self:SetAutoFocus(false)
		self:ClearFocus()
	end)
	raidsRolesBox:SetScript("OnEnterPressed", function(self)
		SetCurrentValue("raids_roles", StringToTable(self:GetText()))
		self:SetAutoFocus(false)
		self:ClearFocus()
	end)
	raidsRolesBox:SetScript("OnEditFocusLost", function(self)
		SetCurrentValue("raids_roles", StringToTable(self:GetText()))
		self:SetAutoFocus(false)
		self:ClearFocus()
	end)
	raidsRolesBox:SetScript("OnEditFocusGained", function(self)
		self:SetAutoFocus(true)
	end)
	local raidsRolesHelp=options:CreateFontString(nil,"ARTWORK","GameFontNormalSmall");
	raidsRolesHelp:SetPoint("BOTTOMRIGHT", raidsRolesBox,"TOPRIGHT",0,0);
	raidsRolesHelp:SetTextColor(0.7,0.7,0.7);
	raidsRolesHelp:SetText("");
	local raidsRolesTip=options:CreateFontString(nil,"ARTWORK","GameFontNormal");
	raidsRolesTip:SetPoint("LEFT", raidsRolesBox,"LEFT",0,0);
	raidsRolesTip:SetTextColor(1,1,1);

	local otherBoxText = options:CreateFontString(nil, "ARTWORK","GameFontWhite");
	otherBoxText:SetPoint("TOPLEFT", raidsBox, "BOTTOMLEFT", 0, -5);
	otherBoxText:SetText("Other whitelisted keywords :");
	otherBox = CreateFrame("editbox", "cf_otherBox", options, "InputBoxTemplate")
	otherBox:SetPoint("TOPLEFT", otherBoxText, "BOTTOMLEFT", 0, 0);
	otherBox:SetPoint("RIGHT", options, "RIGHT", -10, 0)
	otherBox:SetHeight(25)
	otherBox:SetAutoFocus(false)
	otherBox:ClearFocus()
	otherBox:SetScript("OnEscapePressed", function(self)
		SetCurrentValue("other", StringToTable(self:GetText()))
		self:SetAutoFocus(false)
		self:ClearFocus()
	end)
	otherBox:SetScript("OnEnterPressed", function(self)
		SetCurrentValue("other", StringToTable(self:GetText()))
		self:SetAutoFocus(false)
		self:ClearFocus()
	end)
	otherBox:SetScript("OnEditFocusLost", function(self)
		SetCurrentValue("other", StringToTable(self:GetText()))
		self:SetAutoFocus(false)
		self:ClearFocus()
	end)
	otherBox:SetScript("OnEditFocusGained", function(self)
		self:SetAutoFocus(true)
	end)
	local otherHelp=options:CreateFontString(nil,"ARTWORK","GameFontNormalSmall");
	otherHelp:SetPoint("BOTTOMRIGHT", otherBox,"TOPRIGHT",0,0);
	otherHelp:SetTextColor(0.7,0.7,0.7);
	otherHelp:SetText("");
	local otherTip=options:CreateFontString(nil,"ARTWORK","GameFontNormal");
	otherTip:SetPoint("LEFT", otherBox,"LEFT",0,0);
	otherTip:SetTextColor(1,1,1);

	local bottomText=options:CreateFontString(nil,"ARTWORK","GameFontNormalSmall");
	bottomText:SetPoint("BOTTOMLEFT", options,"BOTTOMLEFT", leftMargin , 20);
	bottomText:SetTextColor(0.7,0.7,0.7);
	bottomText:SetJustifyH("LEFT");
	bottomText:SetWidth(590);
	bottomText:SetText("ChatFilter will later be updated to support custom advanced filters.")

	channelsBox:SetScript("OnTabPressed", function(self)
		self:SetAutoFocus(false)
		self:ClearFocus()
		if(IsShiftKeyDown()) then
			raidsBox:SetAutoFocus(true)
		else
			bannedBox:SetAutoFocus(true)
		end
	end)
	channelsBox:SetScript("OnTextChanged", function(self)
		if(self:GetText() == "") then
			channelsTip:SetText("none")
		else
			channelsTip:SetText("")
		end
	end)
	bannedBox:SetScript("OnTabPressed", function(self)
		self:SetAutoFocus(false)
		self:ClearFocus()
		if(IsShiftKeyDown()) then
			channelsBox:SetAutoFocus(true)
		else
			dungeonsRolesBox:SetAutoFocus(true)
		end
	end)
	bannedBox:SetScript("OnTextChanged", function(self)
		if(self:GetText() == "") then
			bannedTip:SetText("none")
		else
			bannedTip:SetText("")
		end
	end)
	dungeonsBox:SetScript("OnTabPressed", function(self)
		self:SetAutoFocus(false)
		self:ClearFocus()
		if(IsShiftKeyDown()) then
			bannedBox:SetAutoFocus(true)
		else
			dungeonsRolesBox:SetAutoFocus(true)
		end
	end)
	dungeonsBox:SetScript("OnTextChanged", function(self)
		if(self:GetText() == "" and dungeonsRolesBox:GetText() == "") then
			dungeonsTip:SetText("disabled")
			dungeonsRolesTip:SetText("disabled")
		elseif(self:GetText() == "") then
			dungeonsTip:SetText("any")
		else
			dungeonsTip:SetText("")
			if(dungeonsRolesBox:GetText() == "") then
				dungeonsRolesTip:SetText("any")
			end
		end
	end)
	dungeonsRolesBox:SetScript("OnTabPressed", function(self)
		self:SetAutoFocus(false)
		self:ClearFocus()
		if(IsShiftKeyDown()) then
			dungeonsBox:SetAutoFocus(true)
		else
			raidsBox:SetAutoFocus(true)
		end
	end)
	dungeonsRolesBox:SetScript("OnTextChanged", function(self)
		if(self:GetText() == "" and dungeonsBox:GetText() == "") then
			dungeonsTip:SetText("disabled")
			dungeonsRolesTip:SetText("disabled")
		elseif(self:GetText() == "") then
			dungeonsRolesTip:SetText("any")
		else
			dungeonsRolesTip:SetText("")
			if(dungeonsBox:GetText() == "") then
				dungeonsTip:SetText("any")
			end
		end
	end)
	raidsBox:SetScript("OnTabPressed", function(self)
		self:SetAutoFocus(false)
		self:ClearFocus()
		if(IsShiftKeyDown()) then
			dungeonsBox:SetAutoFocus(true)
		else
			raidsRolesBox:SetAutoFocus(true)
		end
	end)
	raidsBox:SetScript("OnTextChanged", function(self)
		if(self:GetText() == "" and raidsRolesBox:GetText() == "") then
			raidsTip:SetText("disabled")
			raidsRolesTip:SetText("disabled")
		elseif(self:GetText() == "") then
			raidsTip:SetText("any")
		else
			raidsTip:SetText("")
			if(raidsRolesBox:GetText() == "") then
				raidsRolesTip:SetText("any")
			end
		end
	end)
	raidsRolesBox:SetScript("OnTabPressed", function(self)
		self:SetAutoFocus(false)
		self:ClearFocus()
		if(IsShiftKeyDown()) then
			raidsBox:SetAutoFocus(true)
		else
			otherBox:SetAutoFocus(true)
		end
	end)
	raidsRolesBox:SetScript("OnTextChanged", function(self)
		if(self:GetText() == "" and raidsBox:GetText() == "") then
			raidsTip:SetText("disabled")
			raidsRolesTip:SetText("disabled")
		elseif(self:GetText() == "") then
			raidsRolesTip:SetText("any")
		else
			raidsRolesTip:SetText("")
			if(raidsBox:GetText() == "") then
				raidsTip:SetText("any")
			end
		end
	end)
	otherBox:SetScript("OnTabPressed", function(self)
		self:SetAutoFocus(false)
		self:ClearFocus()
		if(IsShiftKeyDown()) then
			raidsRolesBox:SetAutoFocus(true)
		else
			channelsBox:SetAutoFocus(true)
		end
	end)
	otherBox:SetScript("OnTextChanged", function(self)
		if(self:GetText() == "") then
			otherTip:SetText("disabled")
		else
			otherTip:SetText("")
		end
	end)

	SetProfile(SavedChar["profile"])
end

function RenameProfile(val)
	if(#val > 0 and not SavedGlobal["profiles"][val]) then
		SavedGlobal["profiles"][val] = DeepCopy(SavedGlobal["profiles"][SavedChar["profile"]])
		SavedGlobal["profiles"][SavedChar["profile"]] = nil
		SetProfile(val)
		RefreshValues()
	else
		print(addonStr.." : couldn't rename profile")
	end
end

function CopyProfile(val)
	if(#val > 0 and not SavedGlobal["profiles"][val]) then
		SavedGlobal["profiles"][val] = DeepCopy(SavedGlobal["profiles"][SavedChar["profile"]])
		SetProfile(val)
		RefreshValues()
	else
		print(addonStr.." : couldn't copy profile")
	end
end

function CreateProfile(val)
	if(#val > 0 and not SavedGlobal["profiles"][val]) then
		SavedGlobal["profiles"][val] = DeepCopy(defaultProfile)
		SetProfile(val)
		RefreshValues()
	else
		print(addonStr.." : couldn't create profile")
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
		renameProfileButton:Disable()
		deleteProfileButton:Disable()
	else
		renameProfileButton:Enable()
		deleteProfileButton:Enable()
	end
end

function RefreshValues()
	enabledButton:SetChecked(SavedChar.enabled);
	pmessagesButton:SetChecked(GetCurrentValue("show_player_messages"));
	pmentionsButton:SetChecked(GetCurrentValue("show_player_mentions"));
	channelsBox:SetText(TableToString(GetCurrentValue("channels")));
	bannedBox:SetText(TableToString(GetCurrentValue("banned")));
	dungeonsBox:SetText(TableToString(GetCurrentValue("dungeons")));
	dungeonsRolesBox:SetText(TableToString(GetCurrentValue("dungeons_roles")));
	raidsBox:SetText(TableToString(GetCurrentValue("raids")));
	raidsRolesBox:SetText(TableToString(GetCurrentValue("raids_roles")));
	otherBox:SetText(TableToString(GetCurrentValue("other")));
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
		if(CheckChannel(channel)) then
			if(CheckPlayerAuthor(author) or CheckPlayerMention(msg)) then
				return false
			elseif(CheckBanned(msg)) then
				return true
			elseif(AtLeastOneFilter() and (CheckDungeons(msg) or CheckRaids(msg) or CheckOther(msg))) then
				return false
			else
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

function AtLeastOneFilter()
	return HasValues("raids") or HasValues("raids_roles") or HasValues("dungeons") or HasValues("dungeons_roles") or HasValues("other")
end

function CheckChannel(channel)
	return HasValues("channels") and MatchAny(channel, GetCurrentValue("channels"))
end

function CheckBanned(msg)
	return HasValues("banned") and MatchAny(msg, GetCurrentValue("banned"))
end

function CheckDungeons(msg)
	return (HasValues("dungeons_roles") or HasValues("dungeons")) and
			((not HasValues("dungeons_roles") or MatchAny(msg, GetCurrentValue("dungeons_roles")))
			and (not HasValues("dungeons") or MatchAny(msg, GetCurrentValue("dungeons"))))
end

function CheckRaids(msg)
	return (HasValues("raids_roles") or HasValues("raids")) and
			((not HasValues("raids_roles") or MatchAny(msg, GetCurrentValue("raids_roles")))
			and (not HasValues("raids") or MatchAny(msg, GetCurrentValue("raids"))))
end

function CheckOther(msg)
	return HasValues("other") and MatchAny(msg, GetCurrentValue("other"))
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
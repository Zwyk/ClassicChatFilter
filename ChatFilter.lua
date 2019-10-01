function Print(msg)
	DEFAULT_CHAT_FRAME:AddMessage("TEST : "..msg)
end

local required = {"ZF","zul"}
local banned = {"mona","cath","armu","bibli"}
local channels = {"testfilter","world","LookingForGroup"}


function ChatFilter_OnLoad(self, unit, frame)
	ChatFilter_SavedGlobal = {"test"}
end

local function Filter(self,event,msg,author,arg1,arg2,arg3,arg4,arg5,arg6,channel,...)
	if(MatchAny(channel,channels)) then
		if(MatchAny(msg,banned) or not MatchAny(msg,required)) then
			return true
		end
	end
	return false
end


function MatchAny(source,totest)
	for _,test in pairs(totest) do
		if(string.lower(source):find(string.lower(test))) then
			return true
		end
	end
	return false
end

for type in next,getmetatable(ChatTypeInfo).__index do
	ChatFrame_AddMessageEventFilter("CHAT_MSG_"..type,Filter);
end
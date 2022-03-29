local name, addon = ...
local events = {
	-- "CHAT_MSG_SAY",
	-- "CHAT_MSG_YELL",
	"CHAT_MSG_CHANNEL",
	-- "CHAT_MSG_TEXT_EMOTE",
	-- "CHAT_MSG_WHISPER",
	--"CHAT_MSG_GUILD",
	--"CHAT_MSG_PARTY",
	--"CHAT_MSG_PARTY_LEADER",
	--"CHAT_MSG_RAID",
	--"CHAT_MSG_RAID_LEADER",
	--"CHAT_MSG_INSTANCE_CHAT",
	--"CHAT_MSG_INSTANCE_CHAT_LEADER",
}

local ChatDedupeCache = addon.lru.new(10000)
local handled = addon.lru.new(100)

local function ChatDedupeFilter(self, event, msg, sender, ...)
    local lineID = select(9, ...)
    local h = handled:get(lineID)
    if h then
        return h == 1
    end
    data = msg
    local now, t = time(), ChatDedupeCache:get(data)
    if t and now - t <= 300 then
        handled:set(lineID, 1)
        return true
    end
    handled:set(lineID, 0)
    ChatDedupeCache:set(data, now)
end

local f = CreateFrame("Frame")

f:SetScript("OnEvent", function(_, _, arg1)
    if arg1 == name then
        for _, v in pairs(events) do
            ChatFrame_AddMessageEventFilter(v, ChatDedupeFilter)
        end
    end
end)
f:RegisterEvent("ADDON_LOADED");

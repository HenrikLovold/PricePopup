local DATA = require("main")
local FRAME_NAME = "PricePopupFrame"


local frame = CreateFrame("Frame", FRAME_NAME, UIParent, "BasicFrameTemplate")
frame:SetSize(350, 250) -- Made the frame slightly larger to fit more text
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:Hide() 


if frame.TitleText then
    frame.TitleText:SetText("PricePopup Alert: Chat Detected!")
end

local mainLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
mainLabel:SetPoint("TOP", 0, -40)
mainLabel:SetText("|cffffcc00A chat message containing bidding was intercepted!|r")

local descriptionLabel = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
descriptionLabel:SetPoint("TOP", mainLabel, "BOTTOM", 0, -20)
descriptionLabel:SetWidth(300)
descriptionLabel:SetJustifyH("CENTER")
descriptionLabel:SetText("This window is now triggered. You can customize the contents, size, and function of this addon frame.")
descriptionLabel:SetTextColor(0.7, 0.7, 0.7)

if frame.CloseButton then
    frame.CloseButton:SetScript("OnClick", function(self)
        self:GetParent():Hide()
    end)
end

local function extract_first_itemID(message)
    return string.match(message, "|Hitem:(%d+):")
end

local function on_chat_message(self, event, msg, author, ...)
    local lowerMsg = string.lower(msg)  
    local item = DATA.get_item_info_from_id({}, item_id)
    local iName, iLink, iRarity, iLevel, iMinLevel, iType, iSubType, iStackCount, iSlot, iText = GetItemInfo(itemID)

    if string.find(lowerMsg, "hello") then
        local item_id = ExtractFirstItemID(msg)
        descriptionLabel:SetText("Item", iLink)
        _G[FRAME_NAME]:Show()
    end
end

local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("CHAT_MSG_SAY")
eventFrame:RegisterEvent("CHAT_MSG_YELL")
eventFrame:RegisterEvent("CHAT_MSG_WHISPER")
eventFrame:RegisterEvent("CHAT_MSG_GUILD")
eventFrame:RegisterEvent("CHAT_MSG_PARTY")
eventFrame:RegisterEvent("CHAT_MSG_RAID")
eventFrame:RegisterEvent("CHAT_MSG_OFFICER")

eventFrame:SetScript("OnEvent", on_chat_message)

print("|cff33ff99PricePopup|r: Addon loaded and listening for 'Hello' in chat.")

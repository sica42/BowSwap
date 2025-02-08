local BowSwap = {};

function BowSwap.Equip(args)
    BowSwap.stored = false

    PickupContainerItem(BowSwap.bag, BowSwap.slot)
    PickupInventoryItem(18)

    if args ~= 'nowarn' then 
        BowSwap.Alert( BowSwap.bowType ..' equipped!')
    end
end

function BowSwap.Unequip(args)    
    local itemLink = GetInventoryItemLink("player", 18)
    if not itemLink then return end

    BowSwap.stored = true
    BowSwap.bow = BowSwap.GetItemNameFromLink( itemLink )
    
    for b=0,4 do 
        for s=1,GetContainerNumSlots(b) do 
            if not GetContainerItemLink(b,s) then
                BowSwap.bag = b
                BowSwap.slot = s
                break;
            end
        end 
    end

    PickupInventoryItem(18)
    PickupContainerItem(BowSwap.bag, BowSwap.slot)

    if args ~= 'nowarn' then
        local itemId = BowSwap.GetItemIdFromLink( itemLink )
        local _, _, _, _, _, sType = GetItemInfo( itemId )

        BowSwap.bowType = string.sub(sType, 1, -2)
        BowSwap.Alert( BowSwap.bowType..' unequipped!')
    end
end

function BowSwap.Alert(msg)
    local messageFrame = CreateFrame("Frame", nil, UIParent)
    messageFrame:SetWidth(400)
    messageFrame:SetHeight(100)
    messageFrame:SetPoint("CENTER", 0, 100)

    local messageText = messageFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    messageText:SetPoint("CENTER", 0, 0)
    messageText:SetText(msg)
    messageText:SetTextColor(1, 0, 0, 1)

    local elapsed = 0
    local visibleDuration = 0.8
    local fadeDuration = 0.6

    messageFrame:SetScript("OnUpdate", function(self, delta)
        elapsed = elapsed + arg1            
        if elapsed < (visibleDuration + fadeDuration) then
            local alpha = 1 - ((elapsed - visibleDuration) / fadeDuration)
            messageText:SetTextColor(1, 0, 0, alpha) 
        else
            messageText:SetText("")
            messageFrame:SetScript("OnUpdate", nil)
        end
    end)
end

function BowSwap.OnLoad()    
    DEFAULT_CHAT_FRAME:AddMessage("BowSwap Loaded")

    SLASH_bowswap1 = "/bowswap"
    SlashCmdList["bowswap"] = function(args)
        if BowSwap.stored then
            BowSwap.Equip(args)
        else
	        BowSwap.Unequip(args)
        end
    end
end

function BowSwap.eventHandler()
    if event == "ADDON_LOADED" then
        if arg1 == "BowSwap" then
            BowSwap.OnLoad()
        end
    end
end

function BowSwap.GetItemNameFromLink(itemLink)
    return itemLink and string.match(itemLink, "%[(.+)%]")
end

function BowSwap.GetItemIdFromLink(itemLink)
    return itemLink and string.match(itemLink, "item:(%d+)")
end

BowSwap.Frame = CreateFrame("FRAME")
BowSwap.Frame:RegisterEvent("ADDON_LOADED")
BowSwap.Frame:SetScript("OnEvent", BowSwap.eventHandler)
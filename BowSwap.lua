local BowSwap = {}

function BowSwap.Equip(args)
  if BowSwap.bag and BowSwap.slot then
    BowSwap.stored = false

    PickupContainerItem(BowSwap.bag, BowSwap.slot)
    PickupInventoryItem(18)

    if args ~= 'nowarn' then
      BowSwap.Alert( BowSwap.bowType ..' equipped!', 'green')
    end
  end
end

function BowSwap.Unequip(args)
  local itemLink = GetInventoryItemLink("player", 18)
  if not itemLink then return end
  
  local bag, slot = BowSwap.FindEmptyNormalBagSlot()
  if bag and slot then
    BowSwap.stored = true
    BowSwap.bag = bag
    BowSwap.slot = slot
  
    PickupInventoryItem(18)
    PickupContainerItem(BowSwap.bag, BowSwap.slot)

    if args ~= 'nowarn' then
      local itemId = BowSwap.GetItemIdFromLink( itemLink )
      local _, _, _, _, _, sType = GetItemInfo( itemId )

      BowSwap.bowType = string.sub(sType, 1, -2)
      BowSwap.Alert( BowSwap.bowType..' unequipped!')
    end
  else
    DEFAULT_CHAT_FRAME:AddMessage("|cffff0000WARN: No empty inventory slot!|r")
  end
end

function BowSwap.Alert(msg, color)
  if not BowSwap.messageFrame then
    BowSwap.messageFrame = CreateFrame("Frame", nil, UIParent)
    BowSwap.messageText = BowSwap.messageFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
  end

  local messageFrame = BowSwap.messageFrame  
  messageFrame:SetWidth(400)
  messageFrame:SetHeight(100)
  messageFrame:SetPoint("CENTER", 0, 100)

  local messageText = BowSwap.messageText
  messageText:SetPoint("CENTER", 0, 0)
  if color == 'green' then
    messageText:SetText("|cff00ff00" .. msg .. "|r")
  else
    messageText:SetText("|cffff0000" .. msg .. "|r")
  end

  local elapsed = 0
  local visibleDuration = 0.8
  local fadeDuration = 0.6

  messageFrame:SetScript("OnUpdate", function(self, delta)
    elapsed = elapsed + arg1
    if elapsed < (visibleDuration + fadeDuration) then
      local alpha = 1 - ((elapsed - visibleDuration) / fadeDuration)
      messageText:SetTextColor(0, 0, 0, alpha)
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

function BowSwap.GetItemIdFromLink(itemLink)
  return itemLink and string.match(itemLink, "item:(%d+)")
end

function BowSwap.FindEmptyNormalBagSlot()
  for bag = 0, 4 do
    local bagName = GetBagName(bag)
    if bagName and not string.find(bagName, "Quiver") and not string.find(bagName, "Pouch") and not string.find(bagName, "Soul") then      
      for slot = 1, GetContainerNumSlots( bag ) do
        if not GetContainerItemLink( bag, slot ) then
          return bag, slot
        end
      end
    end
  end
  return nil, nil
end

BowSwap.Frame = CreateFrame("FRAME")
BowSwap.Frame:RegisterEvent("ADDON_LOADED")
BowSwap.Frame:SetScript("OnEvent", BowSwap.eventHandler)
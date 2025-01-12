-- ClassicBestiary originally by Urbit @ Benediction, forked by yesmey

local DB = _G["ClassicBestiary"]
local Spell = Spell

CB = {}
CB.mechanicMap = {
  [1] = "Charms",
  [2] = "Disorients",
  [3] = "Disarms",
  [5] = "Fears",
  [7] = "Roots",
  [9] = "Silences",
  [10] = "Sleeps",
  [11] = "Snares",
  [12] = "Stuns",
  [13] = "Freezes",
  [14] = "Incapacitates",
  [15] = "Bleed",
  [17] = "Polymorph",
  [18] = "Banishes",
  [19] = "Shield",
  [25] = "Invulnerable",
  [26] = "Interrupts"
};

function CB:onTooltip()
  local name, unitID = GameTooltip:GetUnit()
  if not unitID then return end

  local unitGUID = UnitGUID(unitID)
  if not unitGUID then return end

  local unitType, _, _, _, _, npcIDStr = strsplit("-", unitGUID or "")
  
  -- Return if it's not a Creature
  if unitType ~= "Creature" or not npcIDStr then return end
  
  -- Return if it's not neutral or hostile
  local reaction = UnitReaction("player", unitID)
  if reaction and reaction >= 5 then return end

  if IsControlKeyDown() then
    local mainSpeed, offSpeed = UnitAttackSpeed(unitID)
    if mainSpeed < 2 or offSpeed then
      GameTooltip:AddLine("Fast Attack Speed", 1, 0.3, 0.3)
    end
  end

  local abilities = DB.npcSpells[tonumber(npcIDStr)]
  if not abilities then return end

  for _, spellId in ipairs(abilities) do
    CB:addSpellToTooltip(spellId)
  end
  
  if not IsControlKeyDown() then
    GameTooltip:AddLine("(Ctrl for details)", 0.8, 0.8, 0.8)
  end
end

function CB:addSpellToTooltip(spellId)
  local spellName = GetSpellInfo(spellId)
  if not spellName then return end

  local mechanic = DB.spellMechanic[spellId]
  local r, g, b
  local mechanicText = ""
  if mechanic then
    r, g, b = 0.9, 0.4, 0.4
    mechanicText = " (" .. CB.mechanicMap[mechanic] .. ")"
  else
    r, g, b = 0.7, 0.7, 0.7
  end

  local iconTexture = GetSpellTexture(spellId)
  local icon = iconTexture and "|T" .. iconTexture .. ":0|t " or ""

  if IsControlKeyDown() then
    local spell = Spell:CreateFromSpellID(spellId)
    spell:ContinueOnSpellLoad(function()
      local description = spell:GetSpellDescription()
      if not description or string.len(description) <= 1 then return end
	  
      GameTooltip:AddLine(icon .. spellName .. mechanicText, r, g, b)
      GameTooltip:AddLine("- " .. description, 0.7, 0.7, 0.7, true)
      GameTooltip:Show()
    end)
  else
      GameTooltip:AddLine(icon .. spellName .. mechanicText, r, g, b)
  end
end

local frame = CreateFrame("Frame", "ClassicBestiaryEvents")
frame:SetScript("OnEvent", function(self, event, ...)
  if event == "PLAYER_ENTERING_WORLD" then
    GameTooltip:HookScript("OnTooltipSetUnit", function(...) CB:onTooltip(...) end)
  self:UnregisterEvent("PLAYER_ENTERING_WORLD")
  elseif event == "MODIFIER_STATE_CHANGED" then
    if UnitExists("mouseover") then
      GameTooltip:SetUnit("mouseover")
    end
  end
end)

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("MODIFIER_STATE_CHANGED")
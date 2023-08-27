-- ClassicBestiary originally by Urbit @ Benediction, forked by yesmey

local DB = _G["ClassicBestiary"]
local Spell = Spell

local function onTooltip()
  local name, id = GameTooltip:GetUnit()
  local _, _, _, _, _, npcIDStr = strsplit("-", UnitGUID(id))
  if not npcIDStr then
    return
  end

  local npc_id = tonumber(npcIDStr)
  local abilities = DB.map[npc_id]
  if not abilities then
    return
  end

  for _, spellID in ipairs(abilities) do
    local spellName, _rank, _icon, _castTime, minRange, maxRange = GetSpellInfo(spellID);
    if spellName then
      local icon = "";
      local texture = GetSpellTexture(spellID);
      if (texture ~= nil) then
        icon = "|T" .. texture .. ":0|t";
      end
      
      local range = ""

      if maxRange and maxRange > 0 and maxRange < 50 then
        if (minRange and minRange > 0) then
          range = "(" .. tostring(minRange) .. " - " .. tostring(maxRange) .. " yd)"
        else
          range = "(" .. tostring(maxRange) .. " yd)"
        end
      end
  
      GameTooltip:AddLine(icon .. " " .. spellName .. " " .. range)
      if IsControlKeyDown() then
        local spell = Spell:CreateFromSpellID(spellID)
        spell:ContinueOnSpellLoad(function()
          GameTooltip:AddLine(spell:GetSpellDescription(), 0.8, 0.8, 0.8, true)
          if GameTooltip:GetWidth() > 700 then
            GameTooltip:SetWidth(700)
          end
        end)
        -- GameTooltip:AddLine(tip, 0.8, 0.8, 0.8, true)
      end
    end
  end
  
  if not IsControlKeyDown() then
    GameTooltip:AddLine("(Ctrl for details)", 0.8, 0.8, 0.8)
  end
  
  if GameTooltip:GetWidth() > 700 then
    GameTooltip:SetWidth(700)
  end
  end
  
  local frame = CreateFrame("Frame", "ClassicBestiaryEvents")
  frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
      GameTooltip:HookScript("OnTooltipSetUnit", onTooltip)
      self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    elseif event == "MODIFIER_STATE_CHANGED" then
      if UnitExists("mouseover") then
        GameTooltip:SetUnit("mouseover");
      end
    end
  end)

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("MODIFIER_STATE_CHANGED")

-- ClassicBestiary originally by Urbit @ Benediction, forked by yesmey

local DB = _G["ClassicBestiary"]
local Spell = Spell

local function onTooltip()
  local name, id = GameTooltip:GetUnit()
  local unitType, _, _, _, _, npcIDStr = strsplit("-", UnitGUID(id))

  -- Return if its not a Creature
  if not npcIDStr or unitType ~= "Creature" then
    return
  end
  
  -- Return if its not neutral or hostile
  local reaction = UnitReaction("player", id)
  if reaction and reaction >= 5 then
    return
  end

  if IsControlKeyDown() then
    mainSpeed, offSpeed = UnitAttackSpeed(id);
    if mainSpeed < 2 or offSpeed ~= nil then
      GameTooltip:AddLine("Fast Attack", 1, 0.3, 0.3);
    elseif mainSpeed > 2 then
      GameTooltip:AddLine("Slow Attack", 0.2, 1, 0.5);
    end
    else then
      GameTooltip:AddLine("Normal Attack", 0.2, 1, 0.5);
    end
  end

  local abilities = DB.map[tonumber(npcIDStr)]
  if not abilities then
    return
  end

  for _, spellID in ipairs(abilities) do
    local spellName, _, _, _, _, _ = GetSpellInfo(spellID);
    if spellName then
      local icon = "";
      local texture = GetSpellTexture(spellID);
      if (texture ~= nil) then
        icon = "|T" .. texture .. ":0|t";
      end
	  
      if IsControlKeyDown() then
        local spell = Spell:CreateFromSpellID(spellID);
        spell:ContinueOnSpellLoad(function()
		  GameTooltip:AddLine(icon .. " " .. spellName)
          GameTooltip:AddLine(spell:GetSpellDescription(), 0.7, 0.7, 0.7, true);
          if GameTooltip:GetWidth() > 700 then
            GameTooltip:SetWidth(700);
          end
          GameTooltip:Show();
        end);
      end
    end
  end
  
  if not IsControlKeyDown() then
    GameTooltip:AddLine("(Ctrl for details)", 0.8, 0.8, 0.8);
  end
  
  if GameTooltip:GetWidth() > 700 then
    GameTooltip:SetWidth(700);
  end
end

local frame = CreateFrame("Frame", "ClassicBestiaryEvents");
frame:SetScript("OnEvent", function(self, event, ...)
  if event == "PLAYER_ENTERING_WORLD" then
    GameTooltip:HookScript("OnTooltipSetUnit", onTooltip);
    self:UnregisterEvent("PLAYER_ENTERING_WORLD");
  elseif event == "MODIFIER_STATE_CHANGED" then
    if UnitExists("mouseover") then
  	  GameTooltip:SetUnit("mouseover");
    end
  end
end);

frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("MODIFIER_STATE_CHANGED");
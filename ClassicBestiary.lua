-- ClassicBestiary originally by Urbit @ Benediction, forked by yesmey

local DB = _G["ClassicBestiary"]

local hook_installed = false

local function on_tooltip_set_unit()
  local name, id = GameTooltip:GetUnit()
  local _, _, _, _, _, npcIDStr = strsplit("-", UnitGUID(id))
  if not npcIDStr then return end

  local npc_id = tonumber(npcIDStr)
  local abilities = DB.map[npc_id]

  if abilities ~= nil then
    for _, spell_id in ipairs(abilities) do
      local name, _rank, _icon, _castTime, _, maxRange = GetSpellInfo(spell_id);
      if name ~= nil then
        local icon = "";
        local texture = GetSpellTexture(spell_id);
        if (texture ~= nil) then
          icon = "|T" .. texture .. ":0|t";
        end
        
        local tip = GetSpellDescription(spell_id)
        local range = ""

        if maxRange and maxRange > 0 and maxRange < 50 then
            range = "(" .. tostring(maxRange) .. " yd)"
        end

        GameTooltip:AddLine(icon .. " " .. name .. " " .. range)
        if IsControlKeyDown() then
          GameTooltip:AddLine(tip, 0.8, 0.8, 0.8, true)
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

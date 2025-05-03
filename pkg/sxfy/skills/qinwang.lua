local qinwang = fk.CreateSkill {
  name = "sxfy__qinwang",
  tags = { Skill.Lord },
}

Fk:loadTranslationTable{
  ["sxfy__qinwang"] = "勤王",
  [":sxfy__qinwang"] = "主公技，当你需打出【杀】时，其他蜀势力角色可以弃置一张基本牌，视为你打出一张【杀】。",

  ["#sxfy__qinwang"] = "勤王：令其他蜀势力角色选择是否弃置一张基本牌，视为你打出一张【杀】",
  ["#sxfy__qinwang-ask"] = "勤王：是否弃置一张基本牌，视为 %src 打出一张【杀】？",
}

qinwang:addEffect("active", {
  anim_type = "defensive",
  pattern = "slash",
  prompt = "#sxfy__qinwang",
  card_filter = Util.FalseFunc,
  before_use = function(self, player, use)
    local room = player.room
    local yes = false
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if p.kingdom == "shu" then
        local card = room:askToDiscard(p, {
          min_num = 1,
          max_num = 1,
          include_equip = false,
          skill_name = qinwang.name,
          cancelable = true,
          pattern = ".|.|.|.|.|basic",
          prompt = "#sxfy__qinwang-ask:"..player.id,
        })
        if #card > 0 then
          yes = true
          break
        end
      end
    end
    if not yes then
      room:setPlayerMark(player, "sxfy__qinwang_failed-phase", 1)
      room.logic:getCurrentEvent():addCleaner(function()
        room:setPlayerMark(player, "sxfy__qinwang_failed-phase", 0)
      end)
      return qinwang.name
    end
  end,
  view_as = function(self, player, cards)
    local card = Fk:cloneCard("slash")
    card.skillName = qinwang.name
    return card
  end,
  enabled_at_play = Util.FalseFunc,
  enabled_at_response = function(self, player, response)
    return response and player:getMark("sxfy__qinwang_failed-phase") == 0 and
      table.find(Fk:currentRoom().alive_players, function(p)
        return p ~= player and p.kingdom == "shu" and not p:isKongcheng()
      end)
  end,
})

return qinwang

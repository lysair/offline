local jvyi = fk.CreateSkill {
  name = "ofl_shiji__jvyi",
  tags = { Skill.Lord },
}

Fk:loadTranslationTable{
  ["ofl_shiji__jvyi"] = "据益",
  [":ofl_shiji__jvyi"] = "主公技，其他群势力角色弃牌阶段开始时，其可以将一张手牌置入<a href='RenPile_href'>“仁”区</a>，然后若“仁”区溢出，"..
  "你获得因此溢出的牌。",

  ["#ofl_shiji__jvyi-ask"] = "据益：你可以将一张手牌置入仁区，若因此溢出（仁区超过6张牌会溢出），%src 获得溢出的牌",
}

local U = require "packages/utility/utility"

jvyi:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(jvyi.name) and target.phase == Player.Discard and
      target ~= player and target.kingdom == "qun" and not target.dead and not target:isKongcheng()
  end,
  on_cost = function (self, event, target, player, data)
    local card = player.room:askToCards(target, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = jvyi.name,
      cancelable = true,
      prompt = "#ofl_shiji__jvyi-ask:"..player.id,
    })
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function (self, event, target, player, data)
    U.AddToRenPile(target, event:getCostData(self).cards, jvyi.name)
  end,
})

jvyi:addEffect(fk.AfterCardsMove, {
  mute = true,
  is_delay_effect = true,
  can_trigger = function (self, event, target, player, data)
    if player:usedSkillTimes(jvyi.name, Player.HistoryPhase) > 0 and not player.dead then
      local e = player.room.logic:getCurrentEvent().parent
      while e do
        if e.event == GameEvent.SkillEffect and e.data.skill.name == jvyi.name then
          local ids = {}
          for _, move in ipairs(data) do
            if move.toArea == Card.DiscardPile and move.skillName == "ren_overflow" then
              for _, info in ipairs(move.moveInfo) do
                if table.contains(player.room.discard_pile, info.cardId) then
                  table.insertIfNeed(ids, info.cardId)
                end
              end
            end
          end
          if #ids > 0 then
            event:setCostData(self, {cards = ids})
            return true
          end
        end
        e = e.parent
      end
    end
  end,
  on_use = function (self, event, target, player, data)
    player.room:moveCardTo(event:getCostData(self).cards, Card.PlayerHand, player, fk.ReasonJustMove, jvyi.name, nil, true, player)
  end,
})

return jvyi

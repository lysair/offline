local quwu = fk.CreateSkill {
  name = "ofl__quwu",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl__quwu"] = "曲误",
  [":ofl__quwu"] = "锁定技，你不能使用或打出“杂音”花色的牌，“杂音”花色的牌对你无效。",
}

quwu:addEffect(fk.TargetConfirmed, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(quwu.name) and
      table.find(player:getPile("ofl__shiyin_pile"), function (id)
        return Fk:getCardById(id):compareSuitWith(data.card)
      end)
  end,
  on_use = function(self, event, target, player, data)
    data.nullified = true
  end,
})

quwu:addEffect("prohibit", {
  prohibit_use = function (self, player, card)
    return card and
      table.find(player:getPile("ofl__shiyin_pile"), function (id)
        return table.find(Card:getIdList(card), function (id2)
          return Fk:getCardById(id):compareSuitWith(Fk:getCardById(id2))
        end) ~= nil
      end)
  end,
  prohibit_response = function (self, player, card)
    return card and
      table.find(player:getPile("ofl__shiyin_pile"), function (id)
        return table.find(Card:getIdList(card), function (id2)
          return Fk:getCardById(id):compareSuitWith(Fk:getCardById(id2))
        end) ~= nil
      end)
  end,
})

return quwu
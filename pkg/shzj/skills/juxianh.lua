local juxianh = fk.CreateSkill {
  name = "shzj_juedai__juxianh",
}

Fk:loadTranslationTable{
  ["shzj_juedai__juxianh"] = "据险",
  [":shzj_juedai__juxianh"] = "当你失去牌时，你可以失去1点体力防止之；当你受到伤害时，若你的手牌数为1，防止此伤害。",

  ["#shzj_juedai__juxianh-invoke"] = "据险：是否失去1点体力，防止你失去牌？",
}

juxianh:addEffect(fk.BeforeCardsMove, {
  anim_type = "defensive",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(juxianh.name) and player.hp > 0 then
      for _, move in ipairs(data) do
        if move.from == player then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
              return true
            end
          end
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    return player.room:askToSkillInvoke(player, {
      skill_name = juxianh.name,
      prompt = "#shzj_juedai__juxianh-invoke",
    })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local ids = {}
    for _, move in ipairs(data) do
        if move.from == player then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand or info.fromArea == Card.PlayerEquip then
            table.insert(ids, info.cardId)
          end
        end
      end
    end
    room:cancelMove(data, ids)
    room:loseHp(player, 1, juxianh.name)
  end,
})

juxianh:addEffect(fk.DetermineDamageInflicted, {
  anim_type = "defensive",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(juxianh.name) and player:getHandcardNum() == 1
  end,
  on_cost = Util.TrueFunc,
  on_use = function (self, event, target, player, data)
    data:preventDamage()
  end,
})

return juxianh
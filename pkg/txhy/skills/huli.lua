local huli = fk.CreateSkill{
  name = "ofl_tx__huli",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__huli"] = "狐俪",
  [":ofl_tx__huli"] = "锁定技，当你受到其他角色造成的伤害后，伤害来源需选择一项：1.交给你X张牌（X为你与其体力值之差，至多为5）；"..
  "2.你对其造成等量伤害。",

  ["#ofl_tx__huli-give"] = "狐俪：交给 %src %arg张牌，否则你受到%arg2点伤害",
}

huli:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function (self, event, target, player, data)
    return target == player and player:hasSkill(huli.name) and
      data.from and data.from ~= player and not data.from.dead
  end,
  on_cost = function (self, event, target, player, data)
    event:setCostData(self, {tos = {data.from}})
    return true
  end,
  on_use = function (self, event, target, player, data)
    local room = player.room
    local n = math.min(5, math.abs(player.hp - data.from.hp))
    local card = room:askToCards(data.from, {
      min_num = n,
      max_num = n,
      include_equip = false,
      skill_name = huli.name,
      cancelable = true,
      prompt = "#ofl_tx__huli-give:"..player.id.."::"..n..":"..data.damage,
    })
    if #card == n then
      if n > 0 then
        room:moveCardTo(card, Player.Hand, player, fk.ReasonGive, huli.name, nil, false, data.from)
      end
    else
      room:damage{
        from = player,
        to = data.from,
        damage = data.damage,
        skillName = huli.name,
      }
    end
  end
})

return huli

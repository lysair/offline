local fangtong = fk.CreateSkill {
  name = "ofl__fangtong",
}

Fk:loadTranslationTable{
  ["ofl__fangtong"] = "方统",
  [":ofl__fangtong"] = "出牌阶段结束时，若有“方”，你可以重铸一张手牌，若你重铸的牌与你的任意“方”点数之和为36，你可以将对应的“方”置入弃牌堆，"..
  "然后对一名其他角色造成3点雷电伤害。",

  ["#ofl__fangtong-invoke"] = "方统：你可以重铸一张手牌，然后移去与此牌点数之和为36的“方”，对一名角色造成3点雷电伤害！",
  ["#ofl__fangtong-damage"] = "方统：移去点数之和为%arg的“方”，对一名角色造成3点雷电伤害！",

  ["$ofl__fangtong1"] = "三十六方，雷电烁。",
  ["$ofl__fangtong2"] = "合方三十六统，散太平大道。",
}

fangtong:addEffect(fk.EventPhaseEnd, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(fangtong.name) and player.phase == Player.Play and
      #player:getPile("ofl__godzhangliang_fang") > 0 and not player:isKongcheng()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = fangtong.name,
      cancelable = true,
      prompt = "#ofl__fangtong-invoke",
    })
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = 36 - Fk:getCardById(event:getCostData(self).cards[1]).number
    room:recastCard(event:getCostData(self).cards, player, fangtong.name)
    if player.dead or #player:getPile("ofl__godzhangliang_fang") == 0 then return end
    local success, dat = room:askToUseActiveSkill(player, {
      skill_name = "ofl__fangtong_active",
      prompt = "#ofl__fangtong-damage:::"..n,
      cancelable = true,
      no_indicate = false,
      extra_data = {
        num = n,
      },
    })
    if success and dat then
      room:moveCardTo(dat.cards, Card.DiscardPile, nil, fk.ReasonPutIntoDiscardPile, fangtong.name, nil, true, player)
      local to = dat.targets[1]
      if not to.dead then
        room:damage {
          from = player,
          to = to,
          damage = 3,
          damageType = fk.ThunderDamage,
          skillName = fangtong.name,
        }
      end
    end
  end,
})

return fangtong

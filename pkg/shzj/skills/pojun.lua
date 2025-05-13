local pojun = fk.CreateSkill {
  name = "shzj_guansuo__pojun",
}

Fk:loadTranslationTable{
  ["shzj_guansuo__pojun"] = "破军",
  [":shzj_guansuo__pojun"] = "当你使用【杀】指定目标后，你可以观看其至多X张牌并将之移出游戏直到回合结束（X为其体力值）：若其中有装备牌，"..
  "你弃置其中一张；若其中有锦囊牌，你摸一张牌。你使用的【杀】对手牌与装备区内牌数皆不大于你的角色造成的伤害+1。",

  ["#shzj_guansuo__pojun-invoke"] = "破军：你可以观看并扣置 %dest 至多%arg张牌",
  ["#shzj_guansuo__pojun-discard"] = "破军：弃置其中一张装备牌",
  ["$shzj_guansuo__pojun"] = "破军",

  ["$shzj_guansuo__pojun1"] = "战将临阵，斩关刈城！",
  ["$shzj_guansuo__pojun2"] = "区区数百魏军，看我一击灭之！",
  ["$shzj_guansuo__pojun3"] = "今疑兵之计，以挫敌兵心胆，其安敢侵进！",
  ["$shzj_guansuo__pojun4"] = "敌军色厉内荏，可筑假城以退敌！",
  ["$shzj_guansuo__pojun5"] = "嗬！！！",
}

local U = require "packages/utility/utility"

pojun:addEffect(fk.TargetSpecified, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(pojun.name) and data.card.trueName == "slash" and
      player.phase == Player.Play and not data.to.dead and data.to.hp > 0 and not data.to:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    if player.room:askToSkillInvoke(player, {
      skill_name = pojun.name,
      prompt = "#shzj_guansuo__pojun-invoke::"..data.to.id..":"..data.to.hp,
    }) then
      event:setCostData(self, {tos = {data.to}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = room:askToChooseCards(player, {
      skill_name = pojun.name,
      target = data.to,
      flag = "he",
      min = 1,
      max = data.to.hp,
    })
    U.viewCards(player, cards, pojun.name)
    data.to:addToPile("$shzj_guansuo__pojun", cards, false, pojun.name, player)
    if player.dead or data.to.dead then return end
    local equips = table.filter(cards, function (id)
      return Fk:getCardById(id).type == Card.TypeEquip
    end)
    if #equips > 0 then
      local card = room:askToChooseCard(player, {
        target = data.to,
        flag = { card_data = { { pojun.name, equips } }},
        skill_name = pojun.name,
        prompt = "#shzj_guansuo__pojun-discard",
      })
      room:throwCard(card, pojun.name, data.to, player)
    end
    if table.find(cards, function (id)
      return Fk:getCardById(id).type == Card.TypeTrick
    end) and not player.dead then
      player:drawCards(1, pojun.name)
    end
  end,
})

pojun:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return data.from == player and player:hasSkill(pojun.name) and
      data.card and data.card.trueName == "slash" and
      player:getHandcardNum() >= data.to:getHandcardNum() and
      #player:getCardIds("e") >= #data.to:getCardIds("e")
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    data:changeDamage(1)
  end,
})

pojun:addEffect(fk.TurnEnd, {
  is_delay_effect = true,
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return not player.dead and #player:getPile("$shzj_guansuo__pojun") > 0
  end,
  on_use = function(self, event, target, player, data)
    player.room:moveCardTo(player:getPile("$shzj_guansuo__pojun"), Player.Hand, player, fk.ReasonJustMove, pojun.name)
  end,
})

return pojun

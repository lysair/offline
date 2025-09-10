local caozhaoh = fk.CreateSkill {
  name = "ofl__caozhaoh",
}

Fk:loadTranslationTable{
  ["ofl__caozhaoh"] = "草诏",
  [":ofl__caozhaoh"] = "每轮限一次，体力值不大于你的其他角色出牌阶段开始时，你可以展示其一张手牌并声明一种未以此法声明过的基本牌或"..
  "普通锦囊牌，令其选择一项：1.将此牌当你声明的牌使用；2.失去1点体力。",

  ["#ofl__caozhaoh-invoke"] = "草诏：你可以展示 %dest 一张手牌并声明牌名，其将展示牌当声明牌使用或失去体力",
  ["#ofl__caozhaoh-choice"] = "草诏：声明一种牌名，%dest 将展示牌当声明牌使用或失去体力",
  ["#ofl__caozhaoh-use"] = "草诏：请将展示牌当【%arg】使用，否则失去1点体力",

  ["$ofl__caozhaoh1"] = "拟写草诏，群臣必从。",
  ["$ofl__caozhaoh2"] = "伏读草诏，讯诸执事。",
}

local U = require "packages/utility/utility"

caozhaoh:addEffect(fk.EventPhaseStart, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(caozhaoh.name) and target.phase == Player.Play and
      not target:isKongcheng() and target.hp <= player.hp and
      player:usedSkillTimes(caozhaoh.name, Player.HistoryRound) == 0
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    if room:askToSkillInvoke(player, {
      skill_name = caozhaoh.name,
      prompt = "#ofl__caozhaoh-invoke::"..target.id,
    }) then
      event:setCostData(self, {tos = {target}})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToChooseCard(player, {
      target = target,
      flag = "h",
      skill_name = caozhaoh.name,
    })
    target:showCards(card)
    if player.dead or target.dead or #player:getTableMark(caozhaoh.name) == 0 then return end
    local choice = U.askForChooseCardNames(room, player, player:getTableMark(caozhaoh.name), 1, 1, caozhaoh.name,
      "#ofl__caozhaoh-choice::"..target.id, Fk:getAllCardNames("bt"), false)[1]
    room:sendLog{
      type = "#Choice",
      from = player.id,
      arg = choice,
      toast = true,
    }
    room:removeTableMark(player, caozhaoh.name, choice)
    if not room:askToUseVirtualCard(target, {
      name = choice,
      skill_name = caozhaoh.name,
      prompt = "#ofl__caozhaoh-use:::"..choice,
      cancelable = true,
      extra_data = {
        bypass_times = true,
        extraUse = true,
      },
      card_filter = {
        n = 1,
        cards = {card},
      },
    }) then
      room:loseHp(target, 1, caozhaoh.name)
    end
  end,
})

caozhaoh:addAcquireEffect(function (self, player, is_start)
  player.room:setPlayerMark(player, caozhaoh.name, Fk:getAllCardNames("bt"))
end)

return caozhaoh

local lianxiang = fk.CreateSkill {
  name = "lianxiang",
}

Fk:loadTranslationTable{
  ["lianxiang"] = "连降",
  [":lianxiang"] = "当你成为其他角色使用牌的目标时，你可以弃置一张牌，然后令一名手牌数最多的角色摸一张牌。",

  ["#lianxiang-invoke"] = "连降：你可以弃一张牌，然后令一名手牌数最多的角色摸一张牌",
  ["#lianxiang-choose"] = "连降：令一名手牌数最多的角色摸一张牌",
}

lianxiang:addEffect(fk.TargetConfirming, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(lianxiang.name) and
      data.from ~= player and not player:isNude()
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local card = room:askToDiscard(player, {
      min_num = 1,
      max_num = 1,
      include_equip = true,
      skill_name = lianxiang.name,
      cancelable = true,
      prompt = "#lianxiang-invoke",
      skip = true,
    })
    if #card > 0 then
      event:setCostData(self, {cards = card})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:throwCard(event:getCostData(self).cards, lianxiang.name, player, player)
    if player.dead then return end
    local targets = table.filter(room.alive_players, function (p)
      return table.every(room.alive_players, function (q)
        return p:getHandcardNum() >= q:getHandcardNum()
      end)
    end)
    local to = room:askToChoosePlayers(player, {
      min_num = 1,
      max_num = 1,
      targets = targets,
      skill_name = lianxiang.name,
      prompt = "#lianxiang-choose",
      cancelable = false,
    })[1]
    to:drawCards(1, lianxiang.name)
  end,
})

return lianxiang

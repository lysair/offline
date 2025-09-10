local zhenglian = fk.CreateSkill {
  name = "rom__zhenglian",
}

Fk:loadTranslationTable{
  ["rom__zhenglian"] = "征敛",
  [":rom__zhenglian"] = "准备阶段，你可以令所有其他角色依次选择是否交给你一张牌。所有角色选择完毕后，你可以令一名选择否的角色弃置X张牌"..
  "（X为选择否的角色数）。",

  ["#rom__zhenglian-ask"] = "征敛：交给 %src 一张牌，否则其可以令你弃牌",
  ["#rom__zhenglian-discard"] = "征敛：你可以令一名选择否的角色弃置%arg张牌",
}

zhenglian:addEffect(fk.EventPhaseStart, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zhenglian.name) and player.phase == Player.Start and
      table.find(player.room:getOtherPlayers(player, false), function (p)
        return not p:isNude()
      end)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local targets = room:getOtherPlayers(player)
    room:doIndicate(player, targets)
    local tos = {}
    for _, p in ipairs(targets) do
      if player.dead then return end
      if not p.dead then
        local card = room:askToCards(p, {
          min_num = 1,
          max_num = 1,
          skill_name = zhenglian.name,
          cancelable = true,
          prompt = "#rom__zhenglian-ask:" .. player.id,
        })
        if #card > 0 then
          room:moveCardTo(card, Card.PlayerHand, player, fk.ReasonGive, zhenglian.name, nil, false, player)
        else
          table.insert(tos, p)
        end
      end
    end
    if player.dead then return end
    tos = table.filter(tos, function (p)
      return not p:isNude() and not p.dead
    end)
    if #tos == 0 then return end
    local num = #tos
    local to = room:askToChoosePlayers(player, {
      targets = tos,
      min_num = 1,
      max_num = 1,
      prompt = "#rom__zhenglian-discard:::" .. num,
      skill_name = zhenglian.name,
    })
    if #to > 0 then
      room:askToDiscard(to[1], {
        min_num = num,
        max_num = num,
        include_equip = true,
        skill_name = zhenglian.name,
        cancelable = false,
      })
    end
  end
})

return zhenglian

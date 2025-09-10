
local zongji = fk.CreateSkill {
  name = "sxfy__zongji",
}

Fk:loadTranslationTable{
  ["sxfy__zongji"] = "纵计",
  [":sxfy__zongji"] = "当一名角色受到【杀】或【决斗】造成的伤害后，你可以弃置其与伤害来源各一张牌。",

  ["#sxfy__zongji1-invoke"] = "纵计：是否弃置 %src 一张牌？",
  ["#sxfy__zongji2-invoke"] = "纵计：是否弃置 %src 和 %dest 各一张牌？",
  ["#sxfy__zongji-discard"] = "纵计：弃置 %dest 一张牌",
}

zongji:addEffect(fk.Damaged, {
  anim_type = "control",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(zongji.name) and
      data.card and (data.card.trueName == "slash" or data.card.trueName == "duel") and
      ((not data.to.dead and not data.to:isNude()) or (data.from and not data.from.dead and not data.from:isNude()))
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = {}
    if not data.to.dead and not data.to:isNude() then
      if data.to == player then
        if table.find(player:getCardIds("he"), function (id)
          return not player:prohibitDiscard(id)
        end) then
          table.insertIfNeed(targets, player)
        end
      else
        table.insertIfNeed(targets, data.to)
      end
    end
    if data.from and not data.from.dead and not data.from:isNude() then
      if data.from == player then
        if table.find(player:getCardIds("he"), function (id)
          return not player:prohibitDiscard(id)
        end) then
          table.insertIfNeed(targets, player)
        end
      else
        table.insertIfNeed(targets, data.from)
      end
    end
    if #targets == 0 then
      room:askToCards(player, {
        min_num = 1,
        max_num = 1,
        include_equip = false,
        skill_name = zongji.name,
        pattern = "false",
        cancelable = true,
      })
    end
    room:sortByAction(targets)
    local prompt = "#sxfy__zongji1-invoke:"..targets[1].id
    if #targets > 1 then
      prompt = "#sxfy__zongji2-invoke:"..targets[1].id..":"..targets[2].id
    end
    if room:askToSkillInvoke(player, {
      skill_name = zongji.name,
      prompt = prompt,
    }) then
      event:setCostData(self, {tos = targets})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, p in ipairs(event:getCostData(self).tos) do
      if player.dead then return end
      if not p.dead and not p:isNude() then
        if p == player then
          room:askToDiscard(player, {
            min_num = 1,
            max_num = 1,
            include_equip = true,
            skill_name = zongji.name,
            cancelable = false,
            "#sxfy__zongji-discard::"..player.id,
          })
        else
          local card = room:askToChooseCard(player, {
            target = p,
            flag = "he",
            skill_name = zongji.name,
            "#sxfy__zongji-discard::"..p.id,
          })
          room:throwCard(card, zongji.name, p, player)
        end
      end
    end
  end,
})

return zongji

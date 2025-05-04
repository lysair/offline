local zuici = fk.CreateSkill {
  name = "ofl_shiji__zuici",
}

Fk:loadTranslationTable{
  ["ofl_shiji__zuici"] = "罪辞",
  [":ofl_shiji__zuici"] = "当你受到伤害后，你可以获得一名角色的“定仪”牌，然后你从额外牌堆选择一张智囊牌令其获得。",

  ["#ofl_shiji__zuici-choose"] = "罪辞：获得一名角色的“定仪”牌，令其从额外牌堆获得一张智囊牌",
  ["#ofl_shiji__zuici-give"] = "罪辞：选择一张智囊牌令 %dest 获得",

  ["$ofl_shiji__zuici1"] = "无争权柄之事，只望臣宰一心。",
  ["$ofl_shiji__zuici2"] = "折堕己名而得朝臣向主，邵无怨也。",
}

local U = require "packages/offline/ofl_util"

zuici:addEffect(fk.Damaged, {
  anim_type = "masochism",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(zuici.name) and
      table.find(player.room.alive_players, function(p)
        return #p:getPile("ofl_shiji__dingyi") > 0
      end)
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local targets = table.filter(room.alive_players, function(p)
      return #p:getPile("ofl_shiji__dingyi") > 0
    end)
    local to = room:askToChoosePlayers(player, {
      targets = targets,
      min_num = 1,
      max_num = 1,
      prompt = "#ofl_shiji__zuici-choose",
      skill_name = zuici.name,
    })
    if #to > 0 then
      event:setCostData(self, {tos = to})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local to = event:getCostData(self).tos[1]
    room:moveCardTo(to:getPile("ofl_shiji__dingyi"), Card.PlayerHand, player, fk.ReasonJustMove, zuici.name, nil, true, player)
    if player.dead or to.dead then return end
    local cards = table.filter(player.room:getBanner("@$fhyx_extra_pile"), function(id)
      return table.contains(room:getBanner("Zhinang") or {"ex_nihilo", "dismantlement", "nullification"}, Fk:getCardById(id).name)
    end)
    if #cards == 0 then return end
    local card = room:askToCards(player, {
      min_num = 1,
      max_num = 1,
      include_equip = false,
      skill_name = zuici.name,
      pattern = tostring(Exppattern{ id = cards }),
      prompt = "#ofl_shiji__zuici-give::" .. to.id,
      cancelable = false,
      expand_pile = cards,
    })
    room:moveCardTo(card, Card.PlayerHand, to, fk.ReasonJustMove, zuici.name, nil, true, player)
  end,
})

zuici:addAcquireEffect(function (self, player, is_start)
  U.PrepareExtraPile(player.room)
end)

return zuici

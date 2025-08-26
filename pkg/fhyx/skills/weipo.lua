local weipo = fk.CreateSkill {
  name = "ofl_shiji__weipo",
}

Fk:loadTranslationTable{
  ["ofl_shiji__weipo"] = "危迫",
  [":ofl_shiji__weipo"] = "出牌阶段限一次，你可以选择一名其他角色，弃置其每个区域各一张牌（无牌则不弃），然后从额外牌堆选择一张"..
  "<a href=':enemy_at_the_gates'>【兵临城下】</a>或一张<a href='bag_of_tricks'>智囊</a>令其获得。",

  ["#ofl_shiji__weipo"] = "危迫：弃置一名角色每个区域各一张牌，令其获得一张【兵临城下】或智囊",
  ["#ofl_shiji__weipo-give"] = "危迫：选择令 %dest 获得的牌",

  ["$ofl_shiji__weipo1"] = "形势危急，将军不可不先图啊。",
  ["$ofl_shiji__weipo2"] = "如今之势，唯献冀州于袁公耳！",
}

local U = require "packages/utility/utility"
local Ut = require "packages/offline/ofl_util"

weipo:addEffect("active", {
  anim_type = "control",
  prompt = "#ofl_shiji__weipo",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(weipo.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, player, to_select, selected)
    return #selected == 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    if not target:isAllNude() then
      local disable_ids = {}
      if player == target then
        disable_ids = table.filter(player:getCardIds("he"), function (id)
          return player:prohibitDiscard(id)
        end)
      end
      local cards = U.askforCardsChosenFromAreas(player, target, "hej", weipo.name, nil, disable_ids, false)
      if #cards > 0 then
        room:throwCard(cards, weipo.name, target, player)
      end
      if target.dead then return end
    end
    local names = room:getBanner("Zhinang") or {"dismantlement", "nullification", "ex_nihilo"}
    table.insert(names, 1, "enemy_at_the_gates")
    local cards = table.filter(room:getBanner("@$fhyx_extra_pile"), function(id)
      return table.contains(names, Fk:getCardById(id).trueName)
    end)
    if #cards > 0 then
      local card = room:askToChooseCard(player, {
        target = target,
        flag = { card_data = {{ weipo.name, cards }} },
        skill_name = weipo.name,
        prompt = "#ofl_shiji__weipo-give::" .. target.id,
      })
      room:moveCardTo(card, Card.PlayerHand, target, fk.ReasonJustMove, weipo.name, nil, true, player, MarkEnum.DestructIntoDiscard)
    end
  end,
})

weipo:addAcquireEffect(function (self, player, is_start)
  local room = player.room
  Ut.PrepareExtraPile(room)
  local cards = room:getBanner("fhyx_extra_pile")
  if not table.find(cards, function (id)
    return Fk:getCardById(id).name == "enemy_at_the_gates"
  end) then
    local id = room:printCard("enemy_at_the_gates", Card.Spade, 7).id
    table.insert(cards, id)
    room:setCardMark(Fk:getCardById(id), MarkEnum.DestructIntoDiscard, 1)
    room:setBanner("fhyx_extra_pile", cards)
    room:setBanner("@$fhyx_extra_pile", table.simpleClone(cards))
  end
end)

return weipo

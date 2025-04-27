local quanji = fk.CreateSkill {
  name = "ofl__quanji",
}

Fk:loadTranslationTable{
  ["ofl__quanji"] = "权计",
  [":ofl__quanji"] = "当你受到后，或当你使用牌对唯一目标造成伤害后，你可以摸一张牌，然后将一张牌置于武将牌上，称为“权”；"..
  "每有一张“权”，你的手牌上限便+1。",

  ["zhonghui_quan"] = "权",
  ["#ofl__quanji-ask"] = "权计：将一张手牌置为“权”",
}

local spec = {
  on_use = function(self, event, target, player, data)
    local room = player.room
    player:drawCards(1, quanji.name)
    if player:isNude() or player.dead then return end
    local card = room:askToCards(player, {
      skill_name = quanji.name,
      include_equip = true,
      min_num = 1,
      max_num = 1,
      prompt = "#ofl__quanji-ask",
      cancelable = false,
    })
    player:addToPile("zhonghui_quan", card, true, quanji.name)
  end,
}

quanji:addEffect(fk.Damaged, {
  anim_type = "masochism",
  derived_piles = "zhonghui_quan",
  on_use = spec.on_use,
})
quanji:addEffect(fk.Damage, {
  anim_type = "drawcard",
  can_trigger = function (self, event, target, player, data)
    if target == player and player:hasSkill(quanji.name) and data.card then
      local use_event = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      return use_event and #use_event.data.tos == 1
    end
  end,
  on_use = spec.on_use,
})

quanji:addEffect("maxcards", {
  correct_func = function(self, player)
    if player:hasSkill(quanji.name) then
      return #player:getPile("zhonghui_quan")
    end
  end,
})

return quanji

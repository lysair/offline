local ofl_shiji__dinghan = fk.CreateSkill {
  name = "ofl_shiji__dinghan"
}

Fk:loadTranslationTable{
  ['ofl_shiji__dinghan'] = '定汉',
  ['#ofl_shiji__dinghan-invoke'] = '定汉：你可以修改一张本局游戏的智囊牌牌名',
  ['#ofl_shiji__dinghan-remove'] = '定汉：选择要移除的智囊牌',
  ['#ofl_shiji__dinghan-add'] = '定汉：选择要增加的智囊牌',
  ['@$ofl_shiji__dinghan'] = '智囊',
  [':ofl_shiji__dinghan'] = '准备阶段，你可以移除一张智囊牌的记录，然后重新记录一张智囊牌（初始为【无中生有】【过河拆桥】【无懈可击】）。',
}

ofl_shiji__dinghan:addEffect(fk.EventPhaseStart, {
  anim_type = "special",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(ofl_shiji__dinghan) and player.phase == Player.Start
  end,
  on_cost = function(self, event, target, player, data)
    return player.room:askToSkillInvoke(player, { skill_name = ofl_shiji__dinghan.name, prompt = "#ofl_shiji__dinghan-invoke" })
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local zhinang = room:getTag("Zhinang")
    if zhinang then
      zhinang = table.simpleClone(zhinang)
    else
      zhinang = {"ex_nihilo", "dismantlement", "nullification"}
    end
    local choice = room:askToChoice(player, { choices = room:getTag("Zhinang"), skill_name = ofl_shiji__dinghan.name, prompt = "#ofl_shiji__dinghan-remove" })
    table.removeOne(zhinang, choice)
    local choices = table.simpleClone(room:getTag("TrickNames"))
    for _, name in ipairs(zhinang) do
      table.removeOne(choices, name)
    end
    choice = room:askToChoice(player, { choices = choices, skill_name = ofl_shiji__dinghan.name, prompt = "#ofl_shiji__dinghan-add", all_choices = room:getTag("TrickNames") })
    table.insert(zhinang, choice)
    room:setTag("Zhinang", zhinang)
    room:setPlayerMark(player, "@$ofl_shiji__dinghan", room:getTag("Zhinang"))
  end,
})

ofl_shiji__dinghan:addEffect(fk.GameStart, {
  can_refresh = function(self, event, target, player, data)
    return player:hasSkill(ofl_shiji__dinghan, true)
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local TrickNames = room:getTag("TrickNames")
    if not TrickNames then
      local names = {}
      for _, id in ipairs(Fk:getAllCardIds()) do
        local card = Fk:getCardById(id)
        if card:isCommonTrick() and not card.is_derived then
          table.insertIfNeed(names, card.name)
        end
      end
      room:setTag("TrickNames", names)
    end
    local Zhinang = room:getTag("Zhinang")
    if not Zhinang then
      room:setTag("Zhinang", {"ex_nihilo", "dismantlement", "nullification"})
      room:setPlayerMark(player, "@$ofl_shiji__dinghan", room:getTag("Zhinang"))
    end
  end,
})

return ofl_shiji__dinghan

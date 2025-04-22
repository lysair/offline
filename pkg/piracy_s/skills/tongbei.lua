local tongbei = fk.CreateSkill {
  name = "ofl__tongbei",
}

Fk:loadTranslationTable{
  ["ofl__tongbei"] = "统北",
  [":ofl__tongbei"] = "你对非魏势力角色造成伤害时，你可以声明一种牌的类别，令其选择一项：1.此伤害+1；2.交给你一张此类别的牌。",

  ["#ofl__tongbei-choice"] = "统北：声明一种牌的类别，%dest 选择交给你一张此类别的牌或伤害+1",
  ["#ofl__tongbei-give"] = "统北：交给 %src 一张%arg，否则此伤害+1",
}

tongbei:addEffect(fk.DamageCaused, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(tongbei.name) and data.to.kingdom ~= "wei"
  end,
  on_cost = function(self, event, target, player, data)
    local room = player.room
    local choice = room:askToChoice(player, {
      choices = {"basic", "equip", "trick", "Cancel"},
      skill_name = tongbei.name,
      prompt = "#ofl__tongbei-choice::"..data.to.id..":"..data.card:toLogString()
    })
    if choice ~= "Cancel" then
      event:setCostData(self, {tos = {data.to}, choice = choice})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if not data.to:isNude() then
      local type = event:getCostData(self).choice
      local card = room:askToCards(data.to, {
        min_num = 1,
        max_num = 1,
        include_equip = true,
        skill_name = tongbei.name,
        cancelable = true,
        pattern = ".|.|.|.|.|"..type,
        prompt = "#tongbei-give:"..player.id.."::"..type,
      })
      if #card > 0 then
        room:obtainCard(player, card, true, fk.ReasonGive, data.to, tongbei.name)
        return
      end
    end
    data:changeDamage(1)
  end,
})

return tongbei

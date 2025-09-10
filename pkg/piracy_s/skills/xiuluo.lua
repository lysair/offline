local xiuluo = fk.CreateSkill {
  name = "ofl__xiuluo",
}

Fk:loadTranslationTable{
  ["ofl__xiuluo"] = "修罗",
  [":ofl__xiuluo"] = "当你杀死一名角色后，你可以减1点体力上限，修改〖无双〗。",

  ["#ofl__xiuluo-invoke"] = "修罗：是否减1点体力上限修改“无双”？",
}

xiuluo:addEffect(fk.Deathed, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(xiuluo.name) and data.killer == player and
      player:hasSkill("ofl__wushuang", true) and player:getMark("ofl__wushuang") < 2
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:addPlayerMark(player, "ofl__wushuang", 1)
    room:changeMaxHp(player, -1)
  end,
})

return xiuluo

local jiang = fk.CreateSkill {
  name = "ofl_tx__jiang",
  tags = { Skill.Spirited },
}

Fk:loadTranslationTable{
  ["ofl_tx__jiang"] = "激昂",
  [":ofl_tx__jiang"] = "<a href='#SpiritedSkillDesc'>昂扬技</a>，当你使用牌指定其他角色为目标时或成为其他角色使用牌的目标时，"..
  "若你手牌数小于其，你将手牌摸至与其相同。<a href='#SpiritedSkillDesc'>激昂</a>：受到伤害后或对其他角色造成伤害后。",

  ["@@ofl_tx__jiang"] = "激昂",
}

jiang:addEffect(fk.TargetSpecifying, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiang.name) and
      data.to:getHandcardNum() > player:getHandcardNum()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@ofl_tx__jiang", 1)
    player:drawCards(data.to:getHandcardNum() - player:getHandcardNum(), jiang.name)
  end
})

jiang:addEffect(fk.TargetConfirming, {
  anim_type = "offensive",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(jiang.name) and
      data.from:getHandcardNum() > player:getHandcardNum()
  end,
  on_cost = Util.TrueFunc,
  on_use = function(self, event, target, player, data)
    local room = player.room
    room:setPlayerMark(player, "@@ofl_tx__jiang", 1)
    player:drawCards(data.from:getHandcardNum() - player:getHandcardNum(), jiang.name)
  end
})

jiang:addEffect(fk.Damage, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@ofl_tx__jiang") > 0 and data.to ~= player
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@ofl_tx__jiang", 0)
  end,
})

jiang:addEffect(fk.Damaged, {
  can_refresh = function(self, event, target, player, data)
    return target == player and player:getMark("@@ofl_tx__jiang") > 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@@ofl_tx__jiang", 0)
  end,
})

jiang:addEffect("invalidity", {
  invalidity_func = function (self, from, skill)
    return from:getMark("@@ofl_tx__jiang") > 0 and skill.name == jiang.name
  end,
})

jiang:addLoseEffect(function (self, player, is_death)
  player.room:setPlayerMark(player, "@@ofl_tx__jiang", 0)
end)

return jiang

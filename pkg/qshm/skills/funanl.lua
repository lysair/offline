local funanl = fk.CreateSkill {
  name = "funanl",
  tags = { Skill.Lord },
}

Fk:loadTranslationTable{
  ["funanl"] = "赴难",
  [":funanl"] = "主公技，每回合限一次，你可以发动〖激将〗，若没有角色响应，你失去1点体力并摸两张牌。",

  ["#funanl"] = "赴难：发动“激将”，若没有角色响应，你失去1点体力并摸两张牌",
}

funanl:addEffect("viewas", {
  anim_type = "offensive",
  mute_card = true,
  pattern = "slash",
  prompt = "#funanl",
  card_filter = Util.FalseFunc,
  view_as = function(self, player, cards)
    if #cards ~= 0 then return end
    local c = Fk:cloneCard("slash")
    c.skillName = funanl.name
    return c
  end,
  before_use = function(self, player, use)
    local room = player.room
    if use.tos and not use.noIndicate then
      room:doIndicate(player, use.tos)
    end

    for _, p in ipairs(room:getOtherPlayers(player)) do
      if p.kingdom == "shu" then
        local respond = room:askToResponse(p, {
          skill_name = funanl.name,
          pattern = "slash",
          prompt = "#jijiang-ask:"..player.id,
          cancelable = true,
        })
        if respond then
          respond.skipDrop = true
          room:responseCard(respond)

          use.card = respond.card
          return
        end
      end
    end

    room:loseHp(player, 1, funanl.name)
    if not player.dead then
      player:drawCards(2, funanl.name)
    end
    return funanl.name
  end,
  enabled_at_play = function(self, player)
    return player:usedSkillTimes(funanl.name, Player.HistoryTurn) == 0
  end,
  enabled_at_response = function(self, player)
    return player:usedSkillTimes(funanl.name, Player.HistoryTurn) == 0
  end,
})

return funanl

local zhuicui = fk.CreateSkill {
  name = "ofl_tx__zhuicui",
  tags = { Skill.Compulsory },
}

Fk:loadTranslationTable{
  ["ofl_tx__zhuicui"] = "追催",
  [":ofl_tx__zhuicui"] = "锁定技，当你参与拼点结算结束后，你对拼点没赢的其他角色各造成1点伤害。",
}

zhuicui:addEffect(fk.PindianFinished, {
  anim_type = "offensive",
  can_trigger = function (self, event, target, player, data)
    if player:hasSkill(zhuicui.name) then
      if data.from == player then
        for p, v in pairs(data.results) do
          if v.winner ~= p and not p.dead then
            return true
          end
        end
      elseif table.contains(data.tos, player) then
        if data.from ~= data.results[player].winner then
          if not data.from.dead then
            return true
          end
        else
          for p, v in pairs(data.results) do
            if v.winner ~= p and not p.dead and p ~= player then
              return true
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    for _, to in ipairs(room:getOtherPlayers(player)) do
      if to == data.from and not to.dead then
        local yes = false
        for p, v in pairs(data.results) do
          if v.winner ~= to then
            yes = true
            break
          end
        end
        if yes then
          room:damage{
            from = player,
            to = to,
            damage = 1,
            skillName = zhuicui.name,
          }
        end
      elseif data.results[to] and data.results[to].winner ~= to and not to.dead then
        room:damage{
          from = player,
          to = to,
          damage = 1,
          skillName = zhuicui.name,
        }
      end
    end
  end,
})

return zhuicui

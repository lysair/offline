local feisheng = fk.CreateSkill {
  name = "sgsh__feisheng",
  tags = { Skill.DeputyPlace },
}

Fk:loadTranslationTable{
  ["sgsh__feisheng"] = "飞升",
  [":sgsh__feisheng"] = "副将技，当此武将牌被移除时，你可以回复1点体力或摸两张牌。",

  ["$sgsh__feisheng"] = "蕴气修德，其理易现，容吾为君讲解一二。",
}

local U = require "packages/offline/ofl_util"

feisheng:addEffect(U.SgshLoseDeputy, {
  anim_type = "support",
  can_trigger = function(self, event, target, player, data)
    return target == player and data.general == "sgsh__nanhualaoxian" and self:isEffectable(player)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {"draw2"}
    if player:isWounded() then
      table.insert(choices, "recover")
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = feisheng.name,
    })
    if choice == "draw2" then
      player:drawCards(2, feisheng.name)
    else
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = feisheng.name,
      }
    end
  end,
})

return feisheng

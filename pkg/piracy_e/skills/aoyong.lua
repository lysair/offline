local aoyong = fk.CreateSkill {
  name = "aoyong",
  tags = { Skill.Permanent },
}

Fk:loadTranslationTable{
  ["aoyong"] = "鏖勇",
  [":aoyong"] = "持恒技，当你不因〖鏖勇〗获得牌时，你可以选择一项：1.摸一张牌；2.回复1点体力；3.使用一张牌；背水：减1点体力上限。",

  ["aoyong_use"] = "使用一张牌",
  ["aoyong_beishui"] = "背水：减1点体力上限",
  ["#aoyong-use"] = "鏖勇：你可以使用一张牌",
}

aoyong:addEffect(fk.AfterCardsMove, {
  anim_type = "drawcard",
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(aoyong.name) then
      for _, move in ipairs(data) do
        if move.to == player and move.toArea == Player.Hand and move.skillName ~= aoyong.name then
          return true
        end
      end
    end
  end,
  on_cost = function (self, event, target, player, data)
    local room = player.room
    local all_choices = {"draw1", "recover", "aoyong_use", "aoyong_beishui", "Cancel"}
    local choices = table.simpleClone(all_choices)
    if not player:isWounded() then
      table.remove(choices, 2)
    end
    local choice = room:askToChoice(player, {
      choices = choices,
      skill_name = aoyong.name,
      all_choices = all_choices,
    })
    if choice ~= "Cancel" then
      event:setCostData(self, {choice = choice})
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choice = event:getCostData(self).choice
    if choice == "draw1" or choice == "aoyong_beishui" then
      player:drawCards(1, aoyong.name)
      if player.dead then return end
    end
    if player:isWounded() and (choice == "recover" or choice == "aoyong_beishui") then
      room:recover{
        who = player,
        num = 1,
        recoverBy = player,
        skillName = aoyong.name,
      }
      if player.dead then return end
    end
    if choice == "aoyong_use" or choice == "aoyong_beishui" then
      room:askToPlayCard(player, {
        skill_name = aoyong.name,
        prompt = "#aoyong-use",
        cancelable = true,
        extra_data = {
          bypass_times = true,
          extraUse = true,
        },
      })
      if player.dead then return end
    end
    if choice == "aoyong_beishui" then
      room:changeMaxHp(player, -1)
    end
  end,
})

return aoyong

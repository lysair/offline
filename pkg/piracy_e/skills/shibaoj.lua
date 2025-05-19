local shibaoj = fk.CreateSkill {
  name = "shibaoj",
}

Fk:loadTranslationTable{
  ["shibaoj"] = "尸暴",
  [":shibaoj"] = "出牌阶段，你可以令一名丧尸失去所有体力，然后你对其上家和下家各造成1点伤害。",

  ["#shibaoj"] = "尸暴：令一名丧尸失去所有体力，对其上家和下家各造成1点伤害！",
}

shibaoj:addEffect("active", {
  anim_type = "offensive",
  prompt = "#shibaoj",
  card_num = 0,
  target_num = 1,
  target_filter = function (self, player, to_select, selected, selected_cards)
    return #selected == 0 and (to_select.general == "ofl__zombie" or to_select.deputyGeneral == "ofl__zombie") and to_select.hp > 0
  end,
  on_use = function(self, room, effect)
    local player = effect.from
    local target = effect.tos[1]
    local targets = {target:getLastAlive(), target:getNextAlive()}
    room:loseHp(target, target.hp, shibaoj.name)
    for _, p in ipairs(targets) do
      if not p.dead then
        room:damage{
          from = player,
          to = p,
          damage = 1,
          skillName = shibaoj.name,
        }
      end
    end
  end,
})

return shibaoj

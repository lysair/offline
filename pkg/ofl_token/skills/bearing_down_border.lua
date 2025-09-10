local skill = fk.CreateSkill {
  name = "bearing_down_border_skill",
}

Fk:loadTranslationTable{
  ["#bearing_down_border-slash"] = "你可以将一张牌当【杀】对 %dest 使用",
}

skill:addEffect("cardskill", {
  prompt = "#bearing_down_border_skill",
  target_num = 1,
  mod_target_filter = Util.TrueFunc,
  target_filter = Util.CardTargetFilter,
  on_effect = function(self, room, effect)
    local target = effect.to
    for _, p in ipairs(room:getOtherPlayers(target)) do
      if target.dead then return end
      room:askToUseVirtualCard(p, {
        name = "slash",
        skill_name = skill.name,
        prompt = "#bearing_down_border-slash::"..target.id,
        cancelable = true,
        extra_data = {
          bypass_distances = true,
          bypass_times = true,
          extraUse = true,
          exclusive_targets = {target.id},
        },
        card_filter = {
          n = 1,
        },
      })
    end
  end,
})

return skill

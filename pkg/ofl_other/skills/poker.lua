local skill = fk.CreateSkill {
  name = "poker_skill",
}

skill:addEffect("cardskill", {
  can_use = Util.FalseFunc,
})

return skill

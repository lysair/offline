local xiaolu = fk.CreateSkill {
  name = "ofl__xiaolu"
}

Fk:loadTranslationTable{
  ['ofl__xiaolu'] = '宵赂',
  ['ofl__xiaolu&'] = '宵赂',
  [':ofl__xiaolu'] = '每名其他角色的出牌阶段限一次，其可以交给你一张牌，然后其视为对另一名角色使用一张仅指定该角色为目标的普通锦囊牌。',
  ['$ofl__xiaolu1'] = '咱家上下打点，自是要费些银子。',
  ['$ofl__xiaolu2'] = '切！宁享短福，莫为汝等庸奴！',
}

xiaolu:addEffect(fk.TargetRequested, {
  attached_skill_name = xiaolu.name .. "&",
})

return xiaolu

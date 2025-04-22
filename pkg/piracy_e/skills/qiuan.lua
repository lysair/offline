local qiuan = fk.CreateSkill {
  name = "ofl__qiuan",
}

Fk:loadTranslationTable{
  ["ofl__qiuan"] = "求安",
  [":ofl__qiuan"] = "当你受到伤害时，若没有“函”，你可以防止此伤害，并将造成此伤害的牌置于武将牌上，称为“函”。",

  ["ofl__mengda_letter"] = "函",

  ["$ofl__qiuan1"] = "明公神文圣武，吾自当举城来降。",
  ["$ofl__qiuan2"] = "臣心不自安，乃君之过也。",
}

qiuan:addEffect(fk.DamageInflicted, {
  mute = true,
  derived_piles = "ofl__mengda_letter",
  can_trigger = function(self, event, target, player, data)
    return target == player and player:hasSkill(qiuan.name) and
      data.card and #player:getPile("ofl__mengda_letter") == 0 and
      player.room:getCardArea(data.card) == Card.Processing
  end,
  on_use = function(self, event, target, player, data)
    player:broadcastSkillInvoke("ld__qiuan")
    player.room:notifySkillInvoked(player, qiuan.name, "defensive")
    data:preventDamage()
    player:addToPile("ofl__mengda_letter", data.card, true, qiuan.name)
  end,
})

return qiuan

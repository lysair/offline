local linzhen = fk.CreateSkill {
  name = "ofl__linzhen$"
}

Fk:loadTranslationTable{ }

linzhen:addEffect('atkrange', {
  within_func = function(self, from, to)
    return to:hasSkill(linzhen.name) and from.kingdom == "qun" and from ~= to
  end,
})

return linzhen

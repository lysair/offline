local extension = Package:new("feihongyinxue")
extension.extensionName = "offline"

extension:loadSkillSkelsByPath("./packages/offline/pkg/fhyx/skills")

Fk:loadTranslationTable{
  ["feihongyinxue"] = "线下-飞鸿映雪",
  ["fhyx"] = "线下",
  ["fhyx_ex"] = "线下界",
  ["ofl_shiji"] = "线下始计篇",
}

return extension

local extension = Package:new("espionage_beta")
extension.extensionName = "offline"

extension:loadSkillSkelsByPath("./packages/offline/pkg/espionage_beta/skills")

Fk:loadTranslationTable{
  ["espionage_beta"] = "线下-用间beta",
  ["es"] = "用间",
}

return extension

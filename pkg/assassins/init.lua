local extension = Package:new("assassins")
extension.extensionName = "offline"

extension:loadSkillSkelsByPath("./packages/offline/pkg/assassins/skills")

Fk:loadTranslationTable{
  ["assassins"] = "线下-铜雀台",
  ["tqt"] = "铜雀台",
}

General:new(extension, "tqt__fuwan", "qun", 3):addSkills { "fengyin", "chizhong" }
Fk:loadTranslationTable{
  ["#tqt__fuwan"] = "沉毅的国丈",
  ["tqt__fuwan"] = "伏完",
  ["designer:tqt__fuwan"] = "凌天翼",
  ["cv:tqt__fuwan"] = "KEVIN",
  ["illustrator:tqt__fuwan"] = "LiuHeng",

  ["~tqt__fuwan"] = "曹孟德，何相逼至此？",
}

General:new(extension, "tqt__jiping", "qun", 3):addSkills { "duyi", "duanzhi" }
Fk:loadTranslationTable{
  ["tqt__jiping"] = "吉本",
  ["#tqt__jiping"] = "誓死除奸恶",
  ["designer:tqt__jiping"] = "凌天翼",
  ["illustrator:tqt__jiping"] = "Aimer彩三",
}

General:new(extension, "tqt__fuhuanghou", "qun", 3, 3, General.Female):addSkills { "mixin", "cangni" }
Fk:loadTranslationTable{
  ["tqt__fuhuanghou"] = "伏皇后",
  ["#tqt__fuhuanghou"] = "与世不侵",
  ["designer:tqt__fuhuanghou"] = "凌天翼",
  ["illustrator:tqt__fuhuanghou"] = "G.G.G.",
}

return extension

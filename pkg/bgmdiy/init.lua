local extension = Package:new("bgmdiy")
extension.extensionName = "offline"

extension:loadSkillSkelsByPath("./packages/offline/pkg/bgmdiy/skills")

Fk:loadTranslationTable{
  ["bgmdiy"] = "桌游志贴纸",
  ["bgm"] = "桌游志",
}

General:new(extension, "bgm__simazhao", "wei", 3):addSkills { "bgm__zhaoxin", "langgu" }
Fk:loadTranslationTable{
  ["bgm__simazhao"] = "司马昭",
  ["#bgm__simazhao"] = "狼子野心",
  ["designer:bgm__simazhao"] = "尹昭晨",
  ["illustrator:bgm__simazhao"] = "YellowKiss",
}

General:new(extension, "bgm__wangyuanji", "wei", 3, 3, General.Female):addSkills { "fuluan", "shude" }
Fk:loadTranslationTable{
  ["bgm__wangyuanji"] = "王元姬",
  ["#bgm__wangyuanji"] = "文明皇后",
  ["designer:bgm__wangyuanji"] = "尹昭晨",
  ["illustrator:bgm__wangyuanji"] = "YellowKiss",
}

General:new(extension, "bgm__gongsunzan", "qun", 4):addSkills { "bgm__yicong", "tuqi" }
Fk:loadTranslationTable{
  ["bgm__gongsunzan"] = "公孙瓒",
  ["#bgm__gongsunzan"] = "白马将军",
  ["designer:bgm__gongsunzan"] = "爱放泡的鱼",
  ["illustrator:bgm__gongsunzan"] = "XXX",
}

local liuxie = General:new(extension, "bgm__liuxie", "qun", 4)
liuxie:addSkills { "huangen", "hantong" }
liuxie:addRelatedSkills { "hujia", "jijiang", "jiuyuan", "xueyi" }
Fk:loadTranslationTable{
  ["bgm__liuxie"] = "刘协",
  ["#bgm__liuxie"] = "汉献帝",
  ["designer:bgm__liuxie"] = "姚以轩",
  ["illustrator:bgm__liuxie"] = "XXX",
}

return extension

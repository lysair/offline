local extension = Package:new("espionage_beta")
extension.extensionName = "offline"

extension:loadSkillSkelsByPath("./packages/offline/pkg/espionage_beta/skills")

Fk:loadTranslationTable{
  ["espionage_beta"] = "线下-用间beta",
  ["es"] = "用间",
}

General:new(extension, "es__caoang", "wei", 4):addSkills { "xuepin" }
Fk:loadTranslationTable{
  ["es__caoang"] = "曹昂",
  ["#es__caoang"] = "悍不畏死",
  ["illustrator:es__caoang"] = "木美人",
}

General:new(extension, "es__caohong", "wei", 4):addSkills { "lifengs" }
Fk:loadTranslationTable{
  ["es__caohong"] = "曹洪",
  ["#es__caohong"] = "忠烈为心",
  ["illustrator:es__caohong"] = "李秀森",
}

General:new(extension, "es__zhangfei", "shu", 4):addSkills { "mangji" }
Fk:loadTranslationTable{
  ["es__zhangfei"] = "张飞",
  ["#es__zhangfei"] = "万人敌",
  ["illustrator:es__zhangfei"] = "秋呆呆",
}

General:new(extension, "es__chendao", "shu", 4):addSkills { "jianglie" }
Fk:loadTranslationTable{
  ["es__chendao"] = "陈到",
  ["#es__chendao"] = "白毦护军",
  ["illustrator:es__chendao"] = "石婵",
}

General:new(extension, "es__ganning", "wu", 4):addSkills { "jielve" }
Fk:loadTranslationTable{
  ["es__ganning"] = "甘宁",
  ["#es__ganning"] = "锦帆贼",
  ["illustrator:es__ganning"] = "黑山老妖",
}

local sunluban = General:new(extension, "es__sunluban", "wu", 3, 3, General.Female)
sunluban.hidden = true
sunluban:addSkills { "jiaozong", "chouyou" }
Fk:loadTranslationTable{
  ["es__sunluban"] = "孙鲁班",
  ["#es__sunluban"] = "为虎作伥",
  ["illustrator:es__sunluban"] = "FOOLTOWN",
}

General:new(extension, "es__dongzhuo", "qun", 7):addSkills { "tuicheng", "yaoling", "shicha", "yongquan" }
Fk:loadTranslationTable{
  ["es__dongzhuo"] = "董卓",
  ["#es__dongzhuo"] = "乱世的魔王",
  ["illustrator:es__dongzhuo"] = "天龙",
}

--General:new(extension, "es__liru", "qun", 3):addSkills { "dumou", "weiquan", "es__renwang" }
Fk:loadTranslationTable{
  ["es__liru"] = "李儒",
  ["#es__liru"] = "绝策的毒士",
  ["illustrator:es__liru"] = "孟迭",
  ["weiquan"] = "威权",
  [":weiquan"] = "限定技，出牌阶段，你可以选择至多X名角色（X为游戏轮数），这些角色依次将一张手牌交给你选择的另一名角色，然后若该角色手牌数"..
  "大于体力值，其执行一个额外的弃牌阶段。",
  ["es__renwang"] = "人望",
  [":es__renwang"] = "出牌阶段限一次，你可以选择弃牌堆中一张黑色基本牌，令一名角色获得之。",
}

return extension

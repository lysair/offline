local extension = Package:new("qingshihanmo")
extension.extensionName = "offline"

extension:loadSkillSkelsByPath("./packages/offline/pkg/qshm/skills")

Fk:loadTranslationTable{
  ["qingshihanmo"] = "线下-青史翰墨",
  ["qshm"] = "线下",
}

--五专属
General:new(extension, "chenshou", "shu", 3):addSkills { "chenzhi", "dianmo", "zaibi" }
Fk:loadTranslationTable{
  ["chenshou"] = "陈寿",
  ["#chenshou"] = "婉而成章",
  ["illustrator:chenshou"] = "小罗没想好",
}
local poker = fk.CreateCard{
  name = "&poker",
  type = Card.TypeBasic,
  skill = "poker_skill",
  is_passive = true,
}
extension:loadCardSkels{poker}
extension:addCardSpec("poker")

General:new(extension, "caohuan", "wei", 3):addSkills { "junweic", "moran" }
Fk:loadTranslationTable{
  ["caohuan"] = "曹奂",
  ["#caohuan"] = "陈留王",
  ["illustrator:caohuan"] = "小罗没想好",
}

General:new(extension, "liuxuan", "shu", 4):addSkills { "sifen", "funanl" }
Fk:loadTranslationTable{
  ["liuxuan"] = "刘璿",
  ["#liuxuan"] = "暗渊龙吟",
  ["illustrator:liuxuan"] = "荆芥",
}

General:new(extension, "qshm__sunhao", "wu", 5):addSkills { "shezuo" }
Fk:loadTranslationTable{
  ["qshm__sunhao"] = "孙皓",
  ["#qshm__sunhao"] = "归命侯",
  ["illustrator:qshm__sunhao"] = "小罗没想好",
}

General:new(extension, "qshm__liuxie", "qun", 3):addSkills { "jixul", "youchong" }
Fk:loadTranslationTable{
  ["qshm__liuxie"] = "刘协",
  ["#qshm__liuxie"] = "山阳公",
  ["illustrator:qshm__liuxie"] = "荆芥",
}

General:new(extension, "qshm__simashi", "wei", 3):addSkills { "qshm__sanshi", "zhenrao", "qshm__chenlue" }
Fk:loadTranslationTable{
  ["qshm__simashi"] = "谋司马师",
  ["#qshm__simashi"] = "唯几成务",
  ["illustrator:qshm__simashi"] = "君桓文化",

  ["$zhenrao_qshm__simashi1"] = "敌将趁夜袭营，奈何孤患疾在身。",
  ["$zhenrao_qshm__simashi2"] = "众将何在？务必挡下袭营之人。",
  ["~qshm__simashi"] = "父兄未竟之业，万望子上珍之重之。",
}

General:new(extension, "qshm__godzhangjiao", "god", 3):addSkills { "qshm__yizhao", "sanshou", "qshm__sijun", "qshm__tianjie" }
Fk:loadTranslationTable{
  ["qshm__godzhangjiao"] = "神张角",
  ["#qshm__godzhangjiao"] = "末世的起首",
  ["illustrator:qshm__godzhangjiao"] = "六道目",

  ["$sanshou_qshm__godzhangjiao1"] = "贫道所求之道，匪富贵，匪长生，唯愿天下太平。",
  ["$sanshou_qshm__godzhangjiao2"] = "诸君刀利，可斩百头、万头，然可绝太平于人间否？",
  ["~qshm__godzhangjiao"] = "书中皆记王侯事，青史不载人间名。",
}

--神姜维 手杀成济

General:new(extension, "qshm__zhaoxiang", "shu", 4, 4, General.Female):addSkills { "ty__fanghun", "qshm__fuhan" }
Fk:loadTranslationTable{
  ["qshm__zhaoxiang"] = "赵襄",
  ["#qshm__zhaoxiang"] = "拾梅鹊影",
  ["illustrator:qshm__zhaoxiang"] = "疾速K",
}

local sunshangxiang = General:new(extension, "qshm__sunshangxiang", "shu", 4, 4, General.Female)
sunshangxiang:addSkills { "liangzhu", "qshm__fanxiang" }
sunshangxiang:addRelatedSkill("xiaoji")
Fk:loadTranslationTable{
  ["qshm__sunshangxiang"] = "孙尚香",
  ["#qshm__sunshangxiang"] = "梦醉良缘",
  ["illustrator:qshm__sunshangxiang"] = "木美人",
}

local pangtong = General:new(extension, "qshm__pangtong", "wu", 3)
pangtong:addSkills { "qshm__guolun", "qshm__songsang" }
pangtong:addRelatedSkill("zhanji")
Fk:loadTranslationTable{
  ["qshm__pangtong"] = "庞统",
  ["#qshm__pangtong"] = "南州士冠",
  ["illustrator:qshm__pangtong"] = "梦想君",
}

General:new(extension, "qshm__buzhi", "wu", 3):addSkills { "qshm__hongde", "dingpan" }
Fk:loadTranslationTable{
  ["qshm__buzhi"] = "步骘",
  ["#qshm__buzhi"] = "积跬靖边",
  ["illustrator:qshm__buzhi"] = "凡果",
}

General:new(extension, "qshm__yanjun", "wu", 3):addSkills { "qshm__guanchao", "xunxian" }
Fk:loadTranslationTable{
  ["qshm__yanjun"] = "严畯",
  ["#qshm__yanjun"] = "志存补益",
  ["illustrator:qshm__yanjun"] = "铁杵文化",
}

General:new(extension, "qshm__zumao", "wu", 4):addSkills { "qshm__yinbing", "juedi" }
Fk:loadTranslationTable{
  ["qshm__zumao"] = "祖茂",
  ["#qshm__zumao"] = "碧血染赤帻",
  ["illustrator:qshm__zumao"] = "zoo",
}

General:new(extension, "qshm__dingfeng", "wu", 4):addSkills { "ol__duanbing", "qshm__fenxun" }
Fk:loadTranslationTable{
  ["qshm__dingfeng"] = "丁奉",
  ["#qshm__dingfeng"] = "清侧重臣",
  ["illustrator:qshm__dingfeng"] = "鬼画府",
}

return extension

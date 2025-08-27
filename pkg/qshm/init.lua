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

for _, suit in ipairs {"spade", "club", "heart", "diamond" } do
  for i = 1, 13 do
    local name = ("%s%d__poker"):format(suit, i)
    Fk:loadTranslationTable { [name] = "扑克", [":" .. name] = "只是一张扑克而已" }
    local poker = fk.CreateCard{
      name = "&" .. name,
      type = Card.TypeBasic,
      skill = "poker_skill",
      is_passive = true,
    }
    extension:loadCardSkels{ poker }
    extension:addCardSpec(name)
  end
end

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

--神姜维

General:new(extension, "qshm__chengjiw", "wei", 4):addSkills { "qshm__kuangli", "xiongsi" }
Fk:loadTranslationTable{
  ["qshm__chengjiw"] = "成济",
  ["#qshm__chengjiw"] = "劣犬良弓",
  ["illustrator:qshm__chengjiw"] = "凝聚永恒",
}

General:new(extension, "qshm__zhaoxiang", "shu", 4, 4, General.Female):addSkills { "ty__fanghun", "qshm__fuhan" }
Fk:loadTranslationTable{
  ["qshm__zhaoxiang"] = "赵襄",
  ["#qshm__zhaoxiang"] = "拾梅鹊影",
  ["illustrator:qshm__zhaoxiang"] = "疾速K",

  ["$ty__fanghun_qshm__zhaoxiang1"] = "凝傲雪之梅为魄，英魂长存，独耀山河万古明！",
  ["$ty__fanghun_qshm__zhaoxiang2"] = "铸凌霜之寒成剑，青锋出鞘，斩尽天下不臣贼！",
  ["~qshm__zhaoxiang"] = "世受国恩，今当以身殉国。",
}

local sunshangxiang = General:new(extension, "qshm__sunshangxiang", "shu", 4, 4, General.Female)
sunshangxiang:addSkills { "liangzhu", "qshm__fanxiang" }
sunshangxiang:addRelatedSkill("xiaoji")
Fk:loadTranslationTable{
  ["qshm__sunshangxiang"] = "孙尚香",
  ["#qshm__sunshangxiang"] = "梦醉良缘",
  ["illustrator:qshm__sunshangxiang"] = "木美人",

  ["$liangzhu_qshm__sunshangxiang1"] = "呵呵，结发为夫妻，恩爱两不移！",
  ["$liangzhu_qshm__sunshangxiang2"] = "望君更上一层楼。",
  ["$xiaoji_qshm__sunshangxiang1"] = "如果不坚强，懦弱给谁看！",
  ["$xiaoji_qshm__sunshangxiang2"] = "待本姑娘再换把兵器！",
  ["~qshm__sunshangxiang"] = "一缕香魂散，空留枭姬祠。",
}

local pangtong = General:new(extension, "qshm__pangtong", "wu", 3)
pangtong:addSkills { "qshm__guolun", "qshm__songsang" }
pangtong:addRelatedSkill("zhanji")
Fk:loadTranslationTable{
  ["qshm__pangtong"] = "庞统",
  ["#qshm__pangtong"] = "南州士冠",
  ["illustrator:qshm__pangtong"] = "梦想君",

  ["$zhanji_qshm__pangtong1"] = "伴奂尔游矣，优游尔休矣。",
  ["$zhanji_qshm__pangtong2"] = "才华得现，放手一搏。",
  ["~qshm__pangtong"] = "言多必有失……",
}

General:new(extension, "qshm__buzhi", "wu", 3):addSkills { "qshm__hongde", "dingpan" }
Fk:loadTranslationTable{
  ["qshm__buzhi"] = "步骘",
  ["#qshm__buzhi"] = "积跬靖边",
  ["illustrator:qshm__buzhi"] = "凡果",

  ["$dingpan_qshm__buzhi1"] = "平定叛乱，乃为臣之职。",
  ["$dingpan_qshm__buzhi2"] = "武陵百越蠢蠢欲动，骘定当平定其乱。",
  ["~qshm__buzhi"] = "交州叛军尚存，望陛下留心。",
}

General:new(extension, "qshm__yanjun", "wu", 3):addSkills { "qshm__guanchao", "xunxian" }
Fk:loadTranslationTable{
  ["qshm__yanjun"] = "严畯",
  ["#qshm__yanjun"] = "志存补益",
  ["illustrator:qshm__yanjun"] = "铁杵文化",

  ["$xunxian_qshm__yanjun1"] = "吾文治略胜一筹，子明武功远胜于我。",
  ["$xunxian_qshm__yanjun2"] = "人，才各有异，各处其宜，国乃兴矣。",
  ["~qshm__yanjun"] = "著作已成，再无憾矣……",
}

General:new(extension, "qshm__zumao", "wu", 4):addSkills { "qshm__yinbing", "juedi" }
Fk:loadTranslationTable{
  ["qshm__zumao"] = "祖茂",
  ["#qshm__zumao"] = "碧血染赤帻",
  ["illustrator:qshm__zumao"] = "zoo",

  ["$juedi_qshm__zumao1"] = "",
  ["$juedi_qshm__zumao2"] = "",
  ["~qshm__zumao"] = "",
}

General:new(extension, "qshm__dingfeng", "wu", 4):addSkills { "ol__duanbing", "qshm__fenxun" }
Fk:loadTranslationTable{
  ["qshm__dingfeng"] = "丁奉",
  ["#qshm__dingfeng"] = "清侧重臣",
  ["illustrator:qshm__dingfeng"] = "鬼画府",

  ["$ol__duanbing_qshm__dingfeng1"] = "置鱼肠短匕，击渊潭蛟龙，寸险寸强！",
  ["$ol__duanbing_qshm__dingfeng2"] = "操三尺之桨，可驭十丈龙舟，劈波斩浪！",
  ["~qshm__dingfeng"] = "竟有人比我快！",
}

return extension

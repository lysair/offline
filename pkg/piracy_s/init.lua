local extension = Package:new("piracy_s")
extension.extensionName = "offline"

extension:loadSkillSkelsByPath("./packages/offline/pkg/piracy_s/skills")

Fk:loadTranslationTable{
  ["piracy_s"] = "官盗S系列",
}

--官盗S1竞技标准版S1061：吕布 董卓

--官盗S1058三国杀空城计 诸葛亮
General:new(extension, "ofl__zhugeliang", "shu", 3):addSkills { "kongcheng", "ofl__qixingz" }
Fk:loadTranslationTable{
  ["ofl__zhugeliang"] = "诸葛亮",
  ["#ofl__zhugeliang"] = "空城退敌",
  ["illustrator:ofl__zhugeliang"] = "聚一工作室",
}

--官盗S1059乱世奇佐 郭嘉
General:new(extension, "ofl__guojia", "wei", 3):addSkills { "tiandu", "ofl__qizuo" }
Fk:loadTranslationTable{
  ["ofl__guojia"] = "郭嘉",
  ["#ofl__guojia"] = "乱世奇佐",
  ["illustrator:ofl__guojia"] = "小牛",
}

--官盗S1062少年英姿 周瑜
General:new(extension, "ofl2__zhouyu", "wu", 3):addSkills { "yingzi", "ofl__shiyin" }
Fk:loadTranslationTable{
  ["ofl2__zhouyu"] = "周瑜",
  ["#ofl2__zhouyu"] = "少年英姿",
  ["illustrator:ofl2__zhouyu"] = "木美人",
}

--官盗S1066控魂驱魄 贾诩
General:new(extension, "ofl__jiaxu", "qun", 3):addSkills { "wansha", "ofl__qupo", "ofl__baoquan" }
Fk:loadTranslationTable{
  ["ofl__jiaxu"] = "贾诩",
  ["#ofl__jiaxu"] = "控魂驱魄",
  ["illustrator:ofl__jiaxu"] = "光域",
}

--官盗S1067鹰视狼顾 司马懿
General:new(extension, "ofl2__simayi", "jin", 3):addSkills { "yingshis", "ofl__quanyi" }
Fk:loadTranslationTable{
  ["ofl2__simayi"] = "司马懿",
  ["#ofl2__simayi"] = "鹰视狼顾",
  ["illustrator:ofl2__simayi"] = "绘聚艺堂",
}

--官盗S1074过关斩将：双势力关羽

--官盗S2武将传贾诩S2079

--官盗S7幽燕烽火：曹叡 司马懿 公孙渊 公孙瓒 袁绍 文丑
General:new(extension, "ofl__caorui", "wei", 3):addSkills { "ofl__huituo", "ofl__mingjian", "xingshuai" }
Fk:loadTranslationTable{
  ["ofl__caorui"] = "曹叡",
  ["#ofl__caorui"] = "魏明帝",
  ["illustrator:ofl__caorui"] = "第七个桔子",
}

General:new(extension, "ofl__simayi", "wei", 4):addSkills { "ofl__yanggu", "ofl__zuifu" }
Fk:loadTranslationTable{
  ["ofl__simayi"] = "司马懿",
  ["#ofl__simayi"] = "总齐八荒",
  ["illustrator:ofl__simayi"] = "木美人",
}

General:new(extension, "ofl__gongsunyuan", "qun", 4):addSkills { "ofl__xuanshi", "ofl__xiongye" }
Fk:loadTranslationTable{
  ["ofl__gongsunyuan"] = "公孙渊",
  ["#ofl__gongsunyuan"] = "无节燕主",
  ["illustrator:ofl__gongsunyuan"] = "第七个桔子",
}

General:new(extension, "ofl__gongsunzan", "qun", 4):addSkills { "ofl__qizhen", "yicong", "ofl__mujun" }
Fk:loadTranslationTable{
  ["ofl__gongsunzan"] = "公孙瓒",
  ["#ofl__gongsunzan"] = "白马将军",
  ["illustrator:ofl__gongsunzan"] = "沉睡千年",
}

General:new(extension, "ofl__yuanshao", "qun", 4):addSkills { "ofl__sudi", "ofl__qishe", "ofl__linzhen" }
Fk:loadTranslationTable{
  ["ofl__yuanshao"] = "袁绍",
  ["#ofl__yuanshao"] = "一往无前",
  ["illustrator:ofl__yuanshao"] = "铁杵文化",
}

General:new(extension, "ofl__wenchou", "qun", 4):addSkills { "ofl__xuezhan", "ofl__lizhen" }
Fk:loadTranslationTable{
  ["ofl__wenchou"] = "文丑",
  ["#ofl__wenchou"] = "一夫之勇",
  ["illustrator:ofl__wenchou"] = "错落宇宙",
}

--官盗S7荆扬对垒：张昭 鲁肃 诸葛亮 黄盖 周瑜 曹操 曹仁 庞统
General:new(extension, "ofl__zhangzhao", "wu", 3):addSkills { "ofl__boyan", "ofl__jianshi" }
Fk:loadTranslationTable{
  ["ofl__zhangzhao"] = "张昭",
  ["#ofl__zhangzhao"] = "直言劝谏",
  ["illustrator:ofl__zhangzhao"] = "鬼画府",
}

General:new(extension, "ofl__lusu", "wu", 3):addSkills { "ofl__dimeng", "ofl__zhoujil" }
Fk:loadTranslationTable{
  ["ofl__lusu"] = "鲁肃",
  ["#ofl__lusu"] = "独断的外交家",
  ["illustrator:ofl__lusu"] = "NOVART",
}

General:new(extension, "ofl2__zhugeliang", "shu", 3, 4):addSkills { "ofl__qibian", "ofl__cailve" }
Fk:loadTranslationTable{
  ["ofl2__zhugeliang"] = "诸葛亮",
  ["#ofl2__zhugeliang"] = "舌战群儒",
  ["illustrator:ofl2__zhugeliang"] = "枭瞳",
}

General:new(extension, "ofl__huanggai", "wu", 4, 5):addSkills { "ofl__liezhou", "ofl__zhaxiang" }
Fk:loadTranslationTable{
  ["ofl__huanggai"] = "黄盖",
  ["#ofl__huanggai"] = "火神的先驱",
  ["illustrator:ofl__huanggai"] = "铁杵文化",
}

General:new(extension, "ofl3__zhouyu", "wu", 3):addSkills { "ofl__sashuang", "ofl__huoce" }
Fk:loadTranslationTable{
  ["ofl3__zhouyu"] = "周瑜",
  ["#ofl3__zhouyu"] = "红莲耀世",
  ["illustrator:ofl3__zhouyu"] = "橙子z君",
}

General:new(extension, "ofl__caocao", "wei", 4):addSkills { "ofl__lijunc", "ofl__tongbei" }
Fk:loadTranslationTable{
  ["ofl__caocao"] = "曹操",
  ["#ofl__caocao"] = "鲸吞江东",
  ["illustrator:ofl__caocao"] = "云涯",
}

General:new(extension, "ofl__caoren", "wei", 4):addSkills { "ofl__beirong", "ofl__yujun" }
Fk:loadTranslationTable{
  ["ofl__caoren"] = "曹仁",
  ["#ofl__caoren"] = "镇守南郡",
  ["illustrator:ofl__caoren"] = "biou09",
}

local pangtong = General:new(extension, "ofl__pangtong", "wei", 3)
pangtong.subkingdom = "wu"
pangtong:addSkills { "ofl__lianhuan", "ofl__suozhou", "ofl__yuhuop" }
Fk:loadTranslationTable{
  ["ofl__pangtong"] = "庞统",
  ["#ofl__pangtong"] = "铁索连舟",
  ["illustrator:ofl__pangtong"] = "DH",
}

return extension

local extension = Package:new("piracy_s")
extension.extensionName = "offline"

extension:loadSkillSkelsByPath("./packages/offline/pkg/piracy_s/skills")

Fk:loadTranslationTable{
  ["piracy_s"] = "官盗S系列",
}

--官盗S0-004神威九伐 神将篇：神马超
--General:new(extension, "ofl2__godmachao", "god", 4):addSkills { "ofl2__shouli", "ofl2__hengwu" }
Fk:loadTranslationTable{
  ["ofl2__godmachao"] = "神马超",
  ["#ofl2__godmachao"] = "神威天将军",
  ["illustrator:ofl2__godmachao"] = "",

  ["ofl2__shouli"] = "狩骊",
  [":ofl2__shouli"] = "锁定技，游戏开始时，所有角色依次选择一项：1。使用一张坐骑牌，然后摸一张牌；2.随机从游戏外使用一张坐骑牌。你可以将场上的一张进攻坐骑当【杀】（无次数限制）、防御马当【闪】使用或打出，"..
  "以此法失去坐骑的其他角色本回合非锁定技失效，你与其本回合受到的伤害+1且改为雷电伤害。",
  ["ofl2__hengwu"] = "横骛",
  [":ofl2__hengwu"] = "当你使用或打出牌时，若场上有与之花色相同的装备牌，你可以弃置任意张与之花色相同的手牌，然后摸X张牌(X为你以此法弃置的牌数与场上该花色的装备牌数之和)",
}

--官盗S1068主公杀：吕布 董卓
--General:new(extension, "ofl__lvbu", "qun", 4):addSkills { "wushuang", "ofl__sheji" }
Fk:loadTranslationTable{
  ["ofl__lvbu"] = "吕布",
  ["#ofl__lvbu"] = "武的化身",
  ["illustrator:ofl__lvbu"] = "7点Game",

  ["ofl__sheji"] = "射戟",
  [":ofl__sheji"] = "出牌阶段限一次，你可以将所有手牌当一张无距离限制的【杀】使用，若对目标角色造成伤害，你获得其装备区的武器和坐骑牌。",
}

--General:new(extension, "ofl__dongzhuo", "qun", 4):addSkills { "ofl__hengzheng" }
Fk:loadTranslationTable{
  ["ofl__dongzhuo"] = "董卓",
  ["#ofl__dongzhuo"] = "魔王",
  ["illustrator:ofl__dongzhuo"] = "巴萨小马",

  ["ofl__hengzheng"] = "横征",
  [":ofl__hengzheng"] = "回合开始时，若你没有手牌或体力值为1，你可以获得所有角色区域内各一张牌。",
}

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

--官盗S2079武将传 乱武天下贾诩
--General:new(extension, "ofl2__jiaxu", "qun", 3):addSkills { "ofl__yice", "luanwu" }
Fk:loadTranslationTable{
  ["ofl2__jiaxu"] = "贾诩",
  ["#ofl2__jiaxu"] = "乱武天下",
  ["illustrator:ofl2__jiaxu"] = "木美人",
}

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

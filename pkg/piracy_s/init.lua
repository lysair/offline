local extension = Package:new("piracy_s")
extension.extensionName = "offline"

extension:loadSkillSkelsByPath("./packages/offline/pkg/piracy_s/skills")

Fk:loadTranslationTable{
  ["piracy_s"] = "线下-官盗S系列",
}

--官盗S1074过关斩将：双势力关羽

--S2063赵子龙传
General:new(extension, "ofl__zhaoyun", "shu", 4):addSkills { "ofl__qijin", "ofl__qichu", "ofl__longxin" }
Fk:loadTranslationTable{
  ["ofl__zhaoyun"] = "赵云",
  ["#ofl__zhaoyun"] = "寒光凛然",
  ["illustrator:ofl__zhaoyun"] = "木碗Rae",
}

--S2065关云长传
General:new(extension, "ofl__guanyu", "shu", 4):addSkills { "wusheng", "ofl__zhonghun", "nuzhan" }
Fk:loadTranslationTable{
  ["ofl__guanyu"] = "关羽",
  ["#ofl__guanyu"] = "神武绝伦",
  ["illustrator:ofl__guanyu"] = "木美人",
}

--S2066武将传 卧龙诸葛亮
General:new(extension, "ofl__wolong", "shu", 3):addSkills { "ofl__zhijiz", "ofl__jiefeng", "kongcheng" }
Fk:loadTranslationTable{
  ["ofl__wolong"] = "卧龙诸葛亮",
  ["#ofl__wolong"] = "谋定天下",
  ["illustrator:ofl__wolong"] = "第七个桔子",
}

--S2067武将传 武神赵子龙
General:new(extension, "ofl2__zhaoyun", "shu", 4):addSkills { "longdan", "ofl__huiqiang", "ofl__huntu" }
Fk:loadTranslationTable{
  ["ofl2__zhaoyun"] = "赵云",
  ["#ofl2__zhaoyun"] = "单骑救主",
  ["illustrator:ofl2__zhaoyun"] = "天空之城",
}

--S2068武将传 大军师司马懿
General:new(extension, "ofl3__simayi", "wei", 3):addSkills { "ex__fankui", "ex__guicai", "ofl__zhonghu" }
Fk:loadTranslationTable{
  ["ofl3__simayi"] = "司马懿",
  ["#ofl3__simayi"] = "大军师",
  ["illustrator:ofl3__simayi"] = "DH",
}

--S2069武将传 西凉雄狮马超
General:new(extension, "ofl__machao", "shu", 4):addSkills { "mashu", "tieqi", "ofl__weihou" }
Fk:loadTranslationTable{
  ["ofl__machao"] = "马超",
  ["#ofl__machao"] = "西凉雄狮",
  ["illustrator:ofl__machao"] = "depp",
}

--S2070武将传 旷世奇才郭嘉
General:new(extension, "ofl2__guojia", "wei", 3):addSkills { "yiji", "ofl__quanmou" }
Fk:loadTranslationTable{
  ["ofl2__guojia"] = "郭嘉",
  ["#ofl2__guojia"] = "旷世奇才",
  ["illustrator:ofl2__guojia"] = "木美人",
}

--S2073虎啸龙吟
General:new(extension, "ofl4__simayi", "wei", 3):addSkills { "ex__guicai", "ofl__huxiao" }
Fk:loadTranslationTable{
  ["ofl4__simayi"] = "司马懿",
  ["#ofl4__simayi"] = "冢虎",
  ["illustrator:ofl4__simayi"] = "木美人",
}

General:new(extension, "ofl2__wolong", "shu", 3):addSkills { "ofl__guanxing", "ofl__longyin" }
Fk:loadTranslationTable{
  ["ofl2__wolong"] = "卧龙诸葛亮",
  ["#ofl2__wolong"] = "卧龙",
  ["illustrator:ofl2__wolong"] = "biou09",
}

--S2075武将传 霸业天子曹丕
General:new(extension, "ofl__caopi", "wei", 3):addSkills { "ofl__jianwei", "fangzhu", "songwei" }
Fk:loadTranslationTable{
  ["ofl__caopi"] = "曹丕",
  ["#ofl__caopi"] = "霸业天子",
  ["illustrator:ofl__caopi"] = "biou09",
}

--S2076武将传 血修罗吕布
General:new(extension, "ofl3__lvbu", "qun", 5):addSkills { "ofl__wushuang", "ofl__xiuluo" }
Fk:loadTranslationTable{
  ["ofl3__lvbu"] = "吕布",
  ["#ofl3__lvbu"] = "血修罗",
  ["illustrator:ofl3__lvbu"] = "干橘子",
}

--S2079武将传 乱武天下贾诩
General:new(extension, "ofl2__jiaxu", "qun", 3):addSkills { "ofl__yice", "luanwu" }
Fk:loadTranslationTable{
  ["ofl2__jiaxu"] = "贾诩",
  ["#ofl2__jiaxu"] = "乱武天下",
  ["illustrator:ofl2__jiaxu"] = "木美人",
}

--S2080武将传 英才盖世周瑜
General:new(extension, "ofl4__zhouyu", "wu", 3):addSkills { "ofl4__shiyin", "ofl__quwu", "ofl__liaozou" }
Fk:loadTranslationTable{
  ["ofl4__zhouyu"] = "周瑜",
  ["#ofl4__zhouyu"] = "英才盖世",
  ["illustrator:ofl4__zhouyu"] = "种风彦",
}

--S2081武将传 陈思王曹植
General:new(extension, "ofl__caozhi", "wei", 3):addSkills { "liushang", "qibu" }
Fk:loadTranslationTable{
  ["ofl__caozhi"] = "曹植",
  ["#ofl__caozhi"] = "陈思王",
  ["illustrator:ofl__caozhi"] = "兴游",
}

--S0-004神威九伐 神将篇
General:new(extension, "ofl2__godmachao", "god", 4):addSkills { "ofl2__shouli", "ofl2__hengwu" }
Fk:loadTranslationTable{
  ["ofl2__godmachao"] = "神马超",
  ["#ofl2__godmachao"] = "神威天将军",
  ["illustrator:ofl2__godmachao"] = "biou09",

  ["~ofl2__godmachao"] = "七情难掩，六欲难消，何谓之神？",
}

General:new(extension, "ofl__godjiangwei", "god", 4):addSkills { "tianren", "ofl__jiufa", "ofl__pingxiang" }
Fk:loadTranslationTable{
  ["ofl__godjiangwei"] = "神姜维",
  ["#ofl__godjiangwei"] = "怒麟布武",
  ["illustrator:ofl__godjiangwei"] = "错落宇宙",

  ["$tianren_ofl__godjiangwei1"] = "残兵盘据雄关险，独梁力支大厦倾！",
  ["$tianren_ofl__godjiangwei2"] = "雄关高岭壮英姿，一腔热血谱汉风。",
  ["~ofl__godjiangwei"] = "残阳晦月映秋霜，天命不再计成空。",
}

--S1058三国杀空城计 诸葛亮
General:new(extension, "ofl__zhugeliang", "shu", 3):addSkills { "kongcheng", "ofl__qixingz" }
Fk:loadTranslationTable{
  ["ofl__zhugeliang"] = "诸葛亮",
  ["#ofl__zhugeliang"] = "空城退敌",
  ["illustrator:ofl__zhugeliang"] = "聚一工作室",
}

--S1059乱世奇佐 郭嘉
General:new(extension, "ofl__guojia", "wei", 3):addSkills { "tiandu", "ofl__qizuo" }
Fk:loadTranslationTable{
  ["ofl__guojia"] = "郭嘉",
  ["#ofl__guojia"] = "乱世奇佐",
  ["illustrator:ofl__guojia"] = "小牛",
}

--S1061竞技标准版：吕布 董卓
General:new(extension, "ofl__lvbu", "qun", 4):addSkills { "wushuang", "ofl__sheji" }
Fk:loadTranslationTable{
  ["ofl__lvbu"] = "吕布",
  ["#ofl__lvbu"] = "武的化身",
  ["illustrator:ofl__lvbu"] = "7点Game",
}

General:new(extension, "ofl__dongzhuo", "qun", 4):addSkills { "ofl__hengzheng" }
Fk:loadTranslationTable{
  ["ofl__dongzhuo"] = "董卓",
  ["#ofl__dongzhuo"] = "魔王",
  ["illustrator:ofl__dongzhuo"] = "巴萨小马",
}

--S1062少年英姿 周瑜
General:new(extension, "ofl2__zhouyu", "wu", 3):addSkills { "yingzi", "ofl__shiyin" }
Fk:loadTranslationTable{
  ["ofl2__zhouyu"] = "周瑜",
  ["#ofl2__zhouyu"] = "少年英姿",
  ["illustrator:ofl2__zhouyu"] = "木美人",
}

--S1066控魂驱魄 贾诩
General:new(extension, "ofl__jiaxu", "qun", 3):addSkills { "wansha", "ofl__qupo", "ofl__baoquan" }
Fk:loadTranslationTable{
  ["ofl__jiaxu"] = "贾诩",
  ["#ofl__jiaxu"] = "控魂驱魄",
  ["illustrator:ofl__jiaxu"] = "光域",
}

--S1067鹰视狼顾 司马懿
General:new(extension, "ofl2__simayi", "jin", 3):addSkills { "yingshis", "ofl__quanyi" }
Fk:loadTranslationTable{
  ["ofl2__simayi"] = "司马懿",
  ["#ofl2__simayi"] = "鹰视狼顾",
  ["illustrator:ofl2__simayi"] = "绘聚艺堂",
}

--SX015天书乱斗
General:new(extension, "peachchan", "qun", 4, 4, General.Female):addSkills { "ofl__taoyan", "ofl__yanli" }
Fk:loadTranslationTable{
  ["peachchan"] = "小桃",
  ["#peachchan"] = "虚拟偶像",
  ["illustrator:peachchan"] = "匠人绘",
}

General:new(extension, "jinkchan", "qun", 4, 4, General.Female):addSkills { "ofl__shanwu", "ofl__xianli" }
Fk:loadTranslationTable{
  ["jinkchan"] = "小闪",
  ["#jinkchan"] = "虚拟偶像",
  ["illustrator:jinkchan"] = "匠人绘",
}

General:new(extension, "slashchan", "qun", 4, 4, General.Female):addSkills { "ofl__guisha", "ofl__shuli" }
Fk:loadTranslationTable{
  ["slashchan"] = "小杀",
  ["#slashchan"] = "虚拟偶像",
  ["illustrator:slashchan"] = "匠人绘",
}

General:new(extension, "analepticchan", "qun", 4, 4, General.Female):addSkills { "ofl__meiniang", "ofl__yaoli" }
Fk:loadTranslationTable{
  ["analepticchan"] = "小酒",
  ["#analepticchan"] = "虚拟偶像",
  ["illustrator:analepticchan"] = "匠人绘",
}

General:new(extension, "indulgencechan", "qun", 4, 4, General.Female):addSkills { "ofl__leyu", "ofl__yuanli" }
Fk:loadTranslationTable{
  ["indulgencechan"] = "小乐",
  ["#indulgencechan"] = "虚拟偶像",
  ["illustrator:indulgencechan"] = "匠人绘",
}

--白起 旱魃 少昊 夸父 玄女 青龙 白虎 朱雀 玄武共工 祝融

--S4028用间篇
--贾诩 甄姬 诸葛诞 官渡许攸 用间甘宁
General:new(extension, "es__zhenji", "wei", 3, 3, General.Female):addSkills { "es__luoshen", "qingguo" }
Fk:loadTranslationTable{
  ["es__zhenji"] = "甄姬",
  ["#es__zhenji"] = "薄幸的美人",
  ["illustrator:es__zhenji"] = "石婵",
}

--S7001幽燕烽火
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

--S7002荆扬对垒
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
  ["illustrator:ofl__caocao"] = "三叠纪",
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

--S7003徐兖纵横
General:new(extension, "ofl__caosong", "wei", 4):addSkills { "ofl__lilu", "yizhengc" }
Fk:loadTranslationTable{
  ["ofl__caosong"] = "曹嵩",
  ["#ofl__caosong"] = "醉梦折冲",
  ["illustrator:ofl__caosong"] = "MUMU",
}

--General:new(extension, "ofl__chengyu", "wei", 3):addSkills { "ofl__liaofu", "ofl__jinshou" }
Fk:loadTranslationTable{
  ["ofl__chengyu"] = "程昱",
  ["#ofl__chengyu"] = "腹藉千军",
  ["illustrator:ofl__chengyu"] = "biou09",

  ["ofl__liaofu"] = "燎伏",
  [":ofl__liaofu"] = "出牌阶段限一次，你可以扣置一张未以此法扣置过的类别的【杀】，其他角色于你的回合外使用【杀】时，"..
  "你可以移去一张相同的【杀】，对其造成1点此【杀】属性的伤害。",
  ["ofl__jinshou"] = "烬守",
  [":ofl__jinshou"] = "结束阶段，若你本回合体力值未变化过，你可以弃置所有手牌并失去1点体力，若如此做，直到你下回合开始，"..
  "其他角色使用的仅指定你为目标的伤害牌无效。",
}

General:new(extension, "ofl4__caocao", "wei", 4):addSkills { "ofl__jingju", "ofl__sitong" }
Fk:loadTranslationTable{
  ["ofl4__caocao"] = "曹操",
  ["#ofl4__caocao"] = "兴兵血仇",
  ["illustrator:ofl4__caocao"] = "墨心绘意",
}

General:new(extension, "ofl__xunyu", "wei", 3):addSkills { "ofl__jianjing", "ofl__dishou" }
Fk:loadTranslationTable{
  ["ofl__xunyu"] = "荀彧",
  ["#ofl__xunyu"] = "令君劝战",
  ["illustrator:ofl__xunyu"] = "墨心绘意",
}

General:new(extension, "ofl__chengong", "qun", 3):addSkills { "ty_ex__mingce", "ofl__jiaozheng" }
Fk:loadTranslationTable{
  ["ofl__chengong"] = "陈宫",
  ["#ofl__chengong"] = "刚直壮烈",
  ["illustrator:ofl__chengong"] = "墨心绘意",
}

General:new(extension, "ofl__zhangkai", "qun", 4):addSkills { "ofl__qingjin" }
Fk:loadTranslationTable{
  ["ofl__zhangkai"] = "张闿",
  ["#ofl__zhangkai"] = "财靡欲壑",
  ["illustrator:ofl__zhangkai"] = "墨心绘意",
}

--General:new(extension, "ofl4__lvbu", "qun", 5):addSkills { "ty_ex__mingce", "ofl__jiaozheng" }
Fk:loadTranslationTable{
  ["ofl4__lvbu"] = "吕布",
  ["#ofl4__lvbu"] = "",
  ["illustrator:ofl4__lvbu"] = "第七个桔子",
  ["ofl__xiaoxi"] = "虓袭",
  [":ofl__xiaoxi"] = "游戏开始时，你获得7个标记。摸牌阶段，你改为摸标记数的牌，然后移去一个标记。",
  ["ofl__fenqi"] = "焚骑",
  [":ofl__fenqi"] = "出牌阶段限一次，你可以移去一个标记，获得一张【一鼓作气】。",
}

local zhangmiao = General:new(extension, "ofl__zhangmiao", "qun", 4)
zhangmiao:addSkills { "ofl__mouni", "ofl__zongfan" }
zhangmiao:addRelatedSkill("ofl__zhangu")
Fk:loadTranslationTable{
  ["ofl__zhangmiao"] = "张邈",
  ["#ofl__zhangmiao"] = "据兖以观",
  ["illustrator:ofl__zhangmiao"] = "凝聚永恒",
}

return extension

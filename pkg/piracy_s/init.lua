local extension = Package:new("piracy_s")
extension.extensionName = "offline"

extension:loadSkillSkelsByPath("./packages/offline/pkg/piracy_s/skills")

Fk:loadTranslationTable{
  ["piracy_s"] = "线下-官盗S系列",
}

local generals = {}  --绕过变量上限的东西

--官盗S1074过关斩将：双势力关羽

generals.ofl__zhaoyun = General:new(extension, "ofl__zhaoyun", "shu", 4)
generals.ofl__zhaoyun:addSkills { "ofl__qijin", "ofl__qichu", "ofl__longxin" }
generals.ofl__zhaoyun.headnote = "S2063赵子龙传"
Fk:loadTranslationTable{
  ["ofl__zhaoyun"] = "赵云",
  ["#ofl__zhaoyun"] = "寒光凛然",
  ["illustrator:ofl__zhaoyun"] = "木碗Rae",
}

generals.ofl__guanyu = General:new(extension, "ofl__guanyu", "shu", 4)
generals.ofl__guanyu:addSkills { "wusheng", "ofl__zhonghun", "nuzhan" }
generals.ofl__guanyu.headnote = "S2065关云长传"
Fk:loadTranslationTable{
  ["ofl__guanyu"] = "关羽",
  ["#ofl__guanyu"] = "神武绝伦",
  ["illustrator:ofl__guanyu"] = "木美人",
}

generals.ofl__wolong = General:new(extension, "ofl__wolong", "shu", 3)
generals.ofl__wolong:addSkills { "ofl__zhijiz", "ofl__jiefeng", "kongcheng" }
generals.ofl__wolong.headnote = "S2066武将传之卧龙诸葛亮"
Fk:loadTranslationTable{
  ["ofl__wolong"] = "卧龙诸葛亮",
  ["#ofl__wolong"] = "谋定天下",
  ["illustrator:ofl__wolong"] = "第七个桔子",
}

generals.ofl2__zhaoyun = General:new(extension, "ofl2__zhaoyun", "shu", 4)
generals.ofl2__zhaoyun:addSkills { "longdan", "ofl__huiqiang", "ofl__huntu" }
generals.ofl2__zhaoyun.headnote = "S2067武将传之武神赵子龙"
Fk:loadTranslationTable{
  ["ofl2__zhaoyun"] = "赵云",
  ["#ofl2__zhaoyun"] = "单骑救主",
  ["illustrator:ofl2__zhaoyun"] = "天空之城",
}

generals.ofl3__simayi = General:new(extension, "ofl3__simayi", "wei", 3)
generals.ofl3__simayi:addSkills { "ex__fankui", "ex__guicai", "ofl__zhonghu" }
generals.ofl3__simayi.headnote = "S2068武将传之大军师司马懿"
Fk:loadTranslationTable{
  ["ofl3__simayi"] = "司马懿",
  ["#ofl3__simayi"] = "大军师",
  ["illustrator:ofl3__simayi"] = "DH",
}

generals.ofl__machao = General:new(extension, "ofl__machao", "shu", 4)
generals.ofl__machao:addSkills { "mashu", "tieqi", "ofl__weihou" }
generals.ofl__machao.headnote = "S2069武将传之西凉雄狮马超"
Fk:loadTranslationTable{
  ["ofl__machao"] = "马超",
  ["#ofl__machao"] = "西凉雄狮",
  ["illustrator:ofl__machao"] = "depp",
}

generals.ofl2__guojia = General:new(extension, "ofl2__guojia", "wei", 3)
generals.ofl2__guojia:addSkills { "yiji", "ofl__quanmou" }
generals.ofl2__guojia.headnote = "S2070武将传之旷世奇才郭嘉"
Fk:loadTranslationTable{
  ["ofl2__guojia"] = "郭嘉",
  ["#ofl2__guojia"] = "旷世奇才",
  ["illustrator:ofl2__guojia"] = "木美人",
}

generals.ofl4__simayi = General:new(extension, "ofl4__simayi", "wei", 3)
generals.ofl4__simayi:addSkills { "ex__guicai", "ofl__huxiao" }
generals.ofl4__simayi.headnote = "S2073虎啸龙吟"
Fk:loadTranslationTable{
  ["ofl4__simayi"] = "司马懿",
  ["#ofl4__simayi"] = "冢虎",
  ["illustrator:ofl4__simayi"] = "木美人",
}

generals.ofl2__wolong = General:new(extension, "ofl2__wolong", "shu", 3)
generals.ofl2__wolong:addSkills { "ofl__guanxing", "ofl__longyin" }
generals.ofl2__wolong.headnote = "S2073虎啸龙吟"
Fk:loadTranslationTable{
  ["ofl2__wolong"] = "卧龙诸葛亮",
  ["#ofl2__wolong"] = "卧龙",
  ["illustrator:ofl2__wolong"] = "biou09",
}

generals.ofl__caopi = General:new(extension, "ofl__caopi", "wei", 3)
generals.ofl__caopi:addSkills { "ofl__jianwei", "fangzhu", "songwei" }
generals.ofl__caopi.headnote = "S2075武将传之霸业天子曹丕"
Fk:loadTranslationTable{
  ["ofl__caopi"] = "曹丕",
  ["#ofl__caopi"] = "霸业天子",
  ["illustrator:ofl__caopi"] = "biou09",
}

generals.ofl3__lvbu = General:new(extension, "ofl3__lvbu", "qun", 5)
generals.ofl3__lvbu:addSkills { "ofl__wushuang", "ofl__xiuluo" }
generals.ofl3__lvbu.headnote = "S2076武将传之血修罗吕布"
Fk:loadTranslationTable{
  ["ofl3__lvbu"] = "吕布",
  ["#ofl3__lvbu"] = "血修罗",
  ["illustrator:ofl3__lvbu"] = "干橘子",
}

generals.ofl2__jiaxu = General:new(extension, "ofl2__jiaxu", "qun", 3)
generals.ofl2__jiaxu:addSkills { "ofl__yice", "luanwu" }
generals.ofl2__jiaxu.headnote = "S2079武将传之乱武天下贾诩"
Fk:loadTranslationTable{
  ["ofl2__jiaxu"] = "贾诩",
  ["#ofl2__jiaxu"] = "乱武天下",
  ["illustrator:ofl2__jiaxu"] = "木美人",
}

generals.ofl4__zhouyu = General:new(extension, "ofl4__zhouyu", "wu", 3)
generals.ofl4__zhouyu:addSkills { "ofl4__shiyin", "ofl__quwu", "ofl__liaozou" }
generals.ofl4__zhouyu.headnote = "S2080武将传之英才盖世周瑜"
Fk:loadTranslationTable{
  ["ofl4__zhouyu"] = "周瑜",
  ["#ofl4__zhouyu"] = "英才盖世",
  ["illustrator:ofl4__zhouyu"] = "种风彦",
}

generals.ofl__caozhi = General:new(extension, "ofl__caozhi", "wei", 3)
generals.ofl__caozhi:addSkills { "liushang", "qibu" }
generals.ofl__caozhi.headnote = "S2081武将传之陈思王曹植"
Fk:loadTranslationTable{
  ["ofl__caozhi"] = "曹植",
  ["#ofl__caozhi"] = "陈思王",
  ["illustrator:ofl__caozhi"] = "兴游",
}

generals.ofl2__godmachao = General:new(extension, "ofl2__godmachao", "god", 4)
generals.ofl2__godmachao:addSkills { "ofl2__shouli", "ofl2__hengwu" }
generals.ofl2__godmachao.headnote = "S0-004神威九伐 神将篇"
Fk:loadTranslationTable{
  ["ofl2__godmachao"] = "神马超",
  ["#ofl2__godmachao"] = "神威天将军",
  ["illustrator:ofl2__godmachao"] = "biou09",

  ["~ofl2__godmachao"] = "七情难掩，六欲难消，何谓之神？",
}

generals.ofl__godjiangwei = General:new(extension, "ofl__godjiangwei", "god", 4)
generals.ofl__godjiangwei:addSkills { "tianren", "ofl__jiufa", "ofl__pingxiang" }
generals.ofl__godjiangwei.headnote = "S0-004神威九伐 神将篇"
Fk:loadTranslationTable{
  ["ofl__godjiangwei"] = "神姜维",
  ["#ofl__godjiangwei"] = "怒麟布武",
  ["illustrator:ofl__godjiangwei"] = "错落宇宙",

  ["$tianren_ofl__godjiangwei1"] = "残兵盘据雄关险，独梁力支大厦倾！",
  ["$tianren_ofl__godjiangwei2"] = "雄关高岭壮英姿，一腔热血谱汉风。",
  ["~ofl__godjiangwei"] = "残阳晦月映秋霜，天命不再计成空。",
}

generals.ofl__zhugeliang = General:new(extension, "ofl__zhugeliang", "shu", 3)
generals.ofl__zhugeliang:addSkills { "kongcheng", "ofl__qixingz" }
generals.ofl__zhugeliang.headnote = "S1058三国杀空城计 诸葛亮"
Fk:loadTranslationTable{
  ["ofl__zhugeliang"] = "诸葛亮",
  ["#ofl__zhugeliang"] = "空城退敌",
  ["illustrator:ofl__zhugeliang"] = "聚一工作室",
}

generals.ofl__guojia = General:new(extension, "ofl__guojia", "wei", 3)
generals.ofl__guojia:addSkills { "tiandu", "ofl__qizuo" }
generals.ofl__guojia.headnote = "S1059乱世奇佐 郭嘉"
Fk:loadTranslationTable{
  ["ofl__guojia"] = "郭嘉",
  ["#ofl__guojia"] = "乱世奇佐",
  ["illustrator:ofl__guojia"] = "小牛",
}

generals.ofl__lvbu = General:new(extension, "ofl__lvbu", "qun", 4)
generals.ofl__lvbu:addSkills { "wushuang", "ofl__sheji" }
generals.ofl__lvbu.headnote = "S1061竞技标准版"
Fk:loadTranslationTable{
  ["ofl__lvbu"] = "吕布",
  ["#ofl__lvbu"] = "武的化身",
  ["illustrator:ofl__lvbu"] = "7点Game",
}

generals.ofl__dongzhuo = General:new(extension, "ofl__dongzhuo", "qun", 4)
generals.ofl__dongzhuo:addSkills { "ofl__hengzheng" }
generals.ofl__dongzhuo.headnote = "S1061竞技标准版"
Fk:loadTranslationTable{
  ["ofl__dongzhuo"] = "董卓",
  ["#ofl__dongzhuo"] = "魔王",
  ["illustrator:ofl__dongzhuo"] = "巴萨小马",
}

generals.ofl2__zhouyu = General:new(extension, "ofl2__zhouyu", "wu", 3)
generals.ofl2__zhouyu:addSkills { "yingzi", "ofl__shiyin" }
generals.ofl2__zhouyu.headnote = "S1062少年英姿 周瑜"
Fk:loadTranslationTable{
  ["ofl2__zhouyu"] = "周瑜",
  ["#ofl2__zhouyu"] = "少年英姿",
  ["illustrator:ofl2__zhouyu"] = "木美人",
}

generals.ofl__jiaxu = General:new(extension, "ofl__jiaxu", "qun", 3)
generals.ofl__jiaxu:addSkills { "wansha", "ofl__qupo", "ofl__baoquan" }
generals.ofl__jiaxu.headnote = "S1066控魂驱魄 贾诩"
Fk:loadTranslationTable{
  ["ofl__jiaxu"] = "贾诩",
  ["#ofl__jiaxu"] = "控魂驱魄",
  ["illustrator:ofl__jiaxu"] = "光域",
}

generals.ofl2__simayi = General:new(extension, "ofl2__simayi", "jin", 3)
generals.ofl2__simayi:addSkills { "yingshis", "ofl__quanyi" }
generals.ofl2__simayi.headnote = "S1067鹰视狼顾 司马懿"
Fk:loadTranslationTable{
  ["ofl2__simayi"] = "司马懿",
  ["#ofl2__simayi"] = "鹰视狼顾",
  ["illustrator:ofl2__simayi"] = "绘聚艺堂",
}

generals.peachchan = General:new(extension, "peachchan", "qun", 4, 4, General.Female)
generals.peachchan:addSkills { "ofl__taoyan", "ofl__yanli" }
generals.peachchan.headnote = "SX015天书乱斗"
Fk:loadTranslationTable{
  ["peachchan"] = "小桃",
  ["#peachchan"] = "虚拟偶像",
  ["illustrator:peachchan"] = "匠人绘",
}

generals.jinkchan = General:new(extension, "jinkchan", "qun", 4, 4, General.Female)
generals.jinkchan:addSkills { "ofl__shanwu", "ofl__xianli" }
generals.jinkchan.headnote = "SX015天书乱斗"
Fk:loadTranslationTable{
  ["jinkchan"] = "小闪",
  ["#jinkchan"] = "虚拟偶像",
  ["illustrator:jinkchan"] = "匠人绘",
}

generals.slashchan = General:new(extension, "slashchan", "qun", 4, 4, General.Female)
generals.slashchan:addSkills { "ofl__guisha", "ofl__shuli" }
generals.slashchan.headnote = "SX015天书乱斗"
Fk:loadTranslationTable{
  ["slashchan"] = "小杀",
  ["#slashchan"] = "虚拟偶像",
  ["illustrator:slashchan"] = "匠人绘",
}

generals.analepticchan = General:new(extension, "analepticchan", "qun", 4, 4, General.Female)
generals.analepticchan:addSkills { "ofl__meiniang", "ofl__yaoli" }
generals.analepticchan.headnote = "SX015天书乱斗"
Fk:loadTranslationTable{
  ["analepticchan"] = "小酒",
  ["#analepticchan"] = "虚拟偶像",
  ["illustrator:analepticchan"] = "匠人绘",
}

generals.indulgencechan = General:new(extension, "indulgencechan", "qun", 4, 4, General.Female)
generals.indulgencechan:addSkills { "ofl__leyu", "ofl__yuanli" }
generals.indulgencechan.headnote = "SX015天书乱斗"
Fk:loadTranslationTable{
  ["indulgencechan"] = "小乐",
  ["#indulgencechan"] = "虚拟偶像",
  ["illustrator:indulgencechan"] = "匠人绘",
}

--白起 旱魃 少昊 夸父 玄女 青龙 白虎 朱雀 玄武共工 祝融

--S4028用间篇
--贾诩 甄姬 诸葛诞 官渡许攸 用间甘宁
generals.es__zhenji = General:new(extension, "es__zhenji", "wei", 3, 3, General.Female)
generals.es__zhenji:addSkills { "es__luoshen", "qingguo" }
generals.es__zhenji.headnote = "S4028用间篇"
Fk:loadTranslationTable{
  ["es__zhenji"] = "甄姬",
  ["#es__zhenji"] = "薄幸的美人",
  ["illustrator:es__zhenji"] = "石婵",
}

generals.ofl__caorui = General:new(extension, "ofl__caorui", "wei", 3)
generals.ofl__caorui:addSkills { "ofl__huituo", "ofl__mingjian", "xingshuai" }
generals.ofl__caorui.headnote = "S7001幽燕烽火"
Fk:loadTranslationTable{
  ["ofl__caorui"] = "曹叡",
  ["#ofl__caorui"] = "魏明帝",
  ["illustrator:ofl__caorui"] = "第七个桔子",
}

generals.ofl__simayi = General:new(extension, "ofl__simayi", "wei", 4)
generals.ofl__simayi:addSkills { "ofl__yanggu", "ofl__zuifu" }
generals.ofl__simayi.headnote = "S7001幽燕烽火"
Fk:loadTranslationTable{
  ["ofl__simayi"] = "司马懿",
  ["#ofl__simayi"] = "总齐八荒",
  ["illustrator:ofl__simayi"] = "木美人",
}

generals.ofl__gongsunyuan = General:new(extension, "ofl__gongsunyuan", "qun", 4)
generals.ofl__gongsunyuan:addSkills { "ofl__xuanshi", "ofl__xiongye" }
generals.ofl__gongsunyuan.headnote = "S7001幽燕烽火"
Fk:loadTranslationTable{
  ["ofl__gongsunyuan"] = "公孙渊",
  ["#ofl__gongsunyuan"] = "无节燕主",
  ["illustrator:ofl__gongsunyuan"] = "第七个桔子",
}

generals.ofl__gongsunzan = General:new(extension, "ofl__gongsunzan", "qun", 4)
generals.ofl__gongsunzan:addSkills { "ofl__qizhen", "yicong", "ofl__mujun" }
generals.ofl__gongsunzan.headnote = "S7001幽燕烽火"
Fk:loadTranslationTable{
  ["ofl__gongsunzan"] = "公孙瓒",
  ["#ofl__gongsunzan"] = "白马将军",
  ["illustrator:ofl__gongsunzan"] = "沉睡千年",
}

generals.ofl__yuanshao = General:new(extension, "ofl__yuanshao", "qun", 4)
generals.ofl__yuanshao:addSkills { "ofl__sudi", "ofl__qishe", "ofl__linzhen" }
generals.ofl__yuanshao.headnote = "S7001幽燕烽火"
Fk:loadTranslationTable{
  ["ofl__yuanshao"] = "袁绍",
  ["#ofl__yuanshao"] = "一往无前",
  ["illustrator:ofl__yuanshao"] = "铁杵文化",
}

generals.ofl__wenchou = General:new(extension, "ofl__wenchou", "qun", 4)
generals.ofl__wenchou:addSkills { "ofl__xuezhan", "ofl__lizhen" }
generals.ofl__wenchou.headnote = "S7001幽燕烽火"
Fk:loadTranslationTable{
  ["ofl__wenchou"] = "文丑",
  ["#ofl__wenchou"] = "一夫之勇",
  ["illustrator:ofl__wenchou"] = "错落宇宙",
}

generals.ofl__zhangzhao = General:new(extension, "ofl__zhangzhao", "wu", 3)
generals.ofl__zhangzhao:addSkills { "ofl__boyan", "ofl__jianshi" }
generals.ofl__zhangzhao.headnote = "S7002荆扬对垒"
Fk:loadTranslationTable{
  ["ofl__zhangzhao"] = "张昭",
  ["#ofl__zhangzhao"] = "直言劝谏",
  ["illustrator:ofl__zhangzhao"] = "鬼画府",
}

generals.ofl__lusu = General:new(extension, "ofl__lusu", "wu", 3)
generals.ofl__lusu:addSkills { "ofl__dimeng", "ofl__zhoujil" }
generals.ofl__lusu.headnote = "S7002荆扬对垒"
Fk:loadTranslationTable{
  ["ofl__lusu"] = "鲁肃",
  ["#ofl__lusu"] = "独断的外交家",
  ["illustrator:ofl__lusu"] = "NOVART",
}

generals.ofl2__zhugeliang = General:new(extension, "ofl2__zhugeliang", "shu", 3, 4)
generals.ofl2__zhugeliang:addSkills { "ofl__qibian", "ofl__cailve" }
generals.ofl2__zhugeliang.headnote = "S7002荆扬对垒"
Fk:loadTranslationTable{
  ["ofl2__zhugeliang"] = "诸葛亮",
  ["#ofl2__zhugeliang"] = "舌战群儒",
  ["illustrator:ofl2__zhugeliang"] = "枭瞳",
}

generals.ofl__huanggai = General:new(extension, "ofl__huanggai", "wu", 4, 5)
generals.ofl__huanggai:addSkills { "ofl__liezhou", "ofl__zhaxiang" }
generals.ofl__huanggai.headnote = "S7002荆扬对垒"
Fk:loadTranslationTable{
  ["ofl__huanggai"] = "黄盖",
  ["#ofl__huanggai"] = "火神的先驱",
  ["illustrator:ofl__huanggai"] = "铁杵文化",
}

generals.ofl3__zhouyu = General:new(extension, "ofl3__zhouyu", "wu", 3)
generals.ofl3__zhouyu:addSkills { "ofl__sashuang", "ofl__huoce" }
generals.ofl3__zhouyu.headnote = "S7002荆扬对垒"
Fk:loadTranslationTable{
  ["ofl3__zhouyu"] = "周瑜",
  ["#ofl3__zhouyu"] = "红莲耀世",
  ["illustrator:ofl3__zhouyu"] = "橙子z君",
}

generals.ofl__caocao = General:new(extension, "ofl__caocao", "wei", 4)
generals.ofl__caocao:addSkills { "ofl__lijunc", "ofl__tongbei" }
generals.ofl__caocao.headnote = "S7002荆扬对垒"
Fk:loadTranslationTable{
  ["ofl__caocao"] = "曹操",
  ["#ofl__caocao"] = "鲸吞江东",
  ["illustrator:ofl__caocao"] = "三叠纪",
}

generals.ofl__caoren = General:new(extension, "ofl__caoren", "wei", 4)
generals.ofl__caoren:addSkills { "ofl__beirong", "ofl__yujun" }
generals.ofl__caoren.headnote = "S7002荆扬对垒"
Fk:loadTranslationTable{
  ["ofl__caoren"] = "曹仁",
  ["#ofl__caoren"] = "镇守南郡",
  ["illustrator:ofl__caoren"] = "biou09",
}

generals.ofl__pangtong = General:new(extension, "ofl__pangtong", "wei", 3)
generals.ofl__pangtong.subkingdom = "wu"
generals.ofl__pangtong:addSkills { "ofl__lianhuan", "ofl__suozhou", "ofl__yuhuop" }
generals.ofl__pangtong.headnote = "S7002荆扬对垒"
Fk:loadTranslationTable{
  ["ofl__pangtong"] = "庞统",
  ["#ofl__pangtong"] = "铁索连舟",
  ["illustrator:ofl__pangtong"] = "DH",
}

generals.ofl__caosong = General:new(extension, "ofl__caosong", "wei", 4)
generals.ofl__caosong:addSkills { "ofl__lilu", "yizhengc" }
generals.ofl__caosong.headnote = "S7003徐兖纵横"
Fk:loadTranslationTable{
  ["ofl__caosong"] = "曹嵩",
  ["#ofl__caosong"] = "醉梦折冲",
  ["illustrator:ofl__caosong"] = "MUMU",
}

generals.ofl__chengyu = General:new(extension, "ofl__chengyu", "wei", 3)
generals.ofl__chengyu:addSkills { "ofl__liaofu", "ofl__jinshou" }
generals.ofl__chengyu.headnote = "S7003徐兖纵横"
Fk:loadTranslationTable{
  ["ofl__chengyu"] = "程昱",
  ["#ofl__chengyu"] = "腹藉千军",
  ["illustrator:ofl__chengyu"] = "Jarvis",
}

generals.ofl4__caocao = General:new(extension, "ofl4__caocao", "wei", 4)
generals.ofl4__caocao:addSkills { "ofl__jingju", "ofl__sitong" }
generals.ofl4__caocao.headnote = "S7003徐兖纵横"
Fk:loadTranslationTable{
  ["ofl4__caocao"] = "曹操",
  ["#ofl4__caocao"] = "兴兵血仇",
  ["illustrator:ofl4__caocao"] = "墨心绘意",
}

generals.ofl__xunyu = General:new(extension, "ofl__xunyu", "wei", 3)
generals.ofl__xunyu:addSkills { "ofl__jianjing", "ofl__dishou" }
generals.ofl__xunyu.headnote = "S7003徐兖纵横"
Fk:loadTranslationTable{
  ["ofl__xunyu"] = "荀彧",
  ["#ofl__xunyu"] = "令君劝战",
  ["illustrator:ofl__xunyu"] = "墨心绘意",
}

generals.ofl__chengong = General:new(extension, "ofl__chengong", "qun", 3)
generals.ofl__chengong:addSkills { "ty_ex__mingce", "ofl__jiaozheng" }
generals.ofl__chengong.headnote = "S7003徐兖纵横"
Fk:loadTranslationTable{
  ["ofl__chengong"] = "陈宫",
  ["#ofl__chengong"] = "刚直壮烈",
  ["illustrator:ofl__chengong"] = "墨心绘意",
}

generals.ofl__zhangkai = General:new(extension, "ofl__zhangkai", "qun", 4)
generals.ofl__zhangkai:addSkills { "ofl__qingjin" }
generals.ofl__zhangkai.headnote = "S7003徐兖纵横"
Fk:loadTranslationTable{
  ["ofl__zhangkai"] = "张闿",
  ["#ofl__zhangkai"] = "财靡欲壑",
  ["illustrator:ofl__zhangkai"] = "墨心绘意",
}

--General:new(extension, "ofl4__lvbu", "qun", 5):addSkills { "ofl__xiaoxi", "ofl__fenqi" }
Fk:loadTranslationTable{
  ["ofl4__lvbu"] = "吕布",
  ["#ofl4__lvbu"] = "",
  ["illustrator:ofl4__lvbu"] = "第七个桔子",
  ["ofl__xiaoxi"] = "虓袭",
  [":ofl__xiaoxi"] = "游戏开始时，你获得7个标记。摸牌阶段，你改为摸标记数的牌，然后移去一个标记。",
  ["ofl__fenqi"] = "焚骑",
  [":ofl__fenqi"] = "出牌阶段限一次，你可以移去一个标记，获得一张【一鼓作气】。",
}

generals.ofl__zhangmiao = General:new(extension, "ofl__zhangmiao", "qun", 4)
generals.ofl__zhangmiao:addSkills { "ofl__mouni", "ofl__zongfan" }
generals.ofl__zhangmiao:addRelatedSkill("ofl__zhangu")
generals.ofl__zhangmiao.headnote = "S7003徐兖纵横"
Fk:loadTranslationTable{
  ["ofl__zhangmiao"] = "张邈",
  ["#ofl__zhangmiao"] = "据兖以观",
  ["illustrator:ofl__zhangmiao"] = "凝聚永恒",
}

return extension

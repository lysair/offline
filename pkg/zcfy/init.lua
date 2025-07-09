local extension = Package:new("zcfy")
extension.extensionName = "offline"

extension:loadSkillSkelsByPath("./packages/offline/pkg/zcfy/skills")

Fk:loadTranslationTable{
  ["zcfy"] = "线下-珍藏封印",
}

General:new(extension, "sxfy__zhangyao", "wu", 3, 3, General.Female):addSkills { "lianrong", "yuanzhuo" }
Fk:loadTranslationTable{
  ["sxfy__zhangyao"] = "张美人",
  ["#sxfy__zhangyao"] = "琼楼孤蒂",
  ["illustrator:sxfy__zhangyao"] = "绘绘子酱",
}

General:new(extension, "panglin", "shu", 3):addSkills { "zhuying", "zhongshi" }
Fk:loadTranslationTable{
  ["panglin"] = "庞林",
  ["#panglin"] = "随军御敌",
  ["illustrator:panglin"] = "绘绘子酱",
}

General:new(extension, "maohuanghou", "wei", 3, 3, General.Female):addSkills { "dechong", "yinzu" }
Fk:loadTranslationTable{
  ["maohuanghou"] = "毛皇后",
  ["#maohuanghou"] = "明悼皇后",
  ["illustrator:maohuanghou"] = "绘绘子酱",
}

General:new(extension, "huangchong", "shu", 3):addSkills { "juxianh", "lijunh" }
Fk:loadTranslationTable{
  ["huangchong"] = "黄崇",
  ["#huangchong"] = "星陨绵竹",
  ["illustrator:huangchong"] = "绘绘子酱",
}

General:new(extension, "caoxiong", "wei", 3):addSkills { "wuweic", "leiruo" }
Fk:loadTranslationTable{
  ["caoxiong"] = "曹熊",
  ["#caoxiong"] = "萧怀侯",
  ["illustrator:caoxiong"] = "绘绘子酱",
}

General:new(extension, "zhengcong", "qun", 4, 4, General.Female):addSkills { "qiyue", "jieji" }
Fk:loadTranslationTable{
  ["zhengcong"] = "郑聦",
  ["#zhengcong"] = "莽绽凶蛇",
  ["illustrator:zhengcong"] = "绘绘子酱",
}

General:new(extension, "jiangjie", "qun", 3, 3, General.Female):addSkills { "fengzhan", "ruixi" }
Fk:loadTranslationTable{
  ["jiangjie"] = "姜婕",
  ["#jiangjie"] = "率然藏艳",
  ["illustrator:jiangjie"] = "绘绘子酱",
}

General:new(extension, "wangfuren", "wu", 3, 3, General.Female):addSkills { "bizun", "qiangong" }
Fk:loadTranslationTable{
  ["wangfuren"] = "王夫人",
  ["#wangfuren"] = "敬怀皇后",
  ["illustrator:wangfuren"] = "绘绘子酱",
}

--张春华× 王异× 曹冲× 雷铜√ 伊籍× 诸葛诞× 蔡文姬√ 樊稠√ 赵统赵广× 诸葛果√ 吴班× 陈震× 张昌蒲× 沙摩柯√ 牛金× 韩遂× 张星彩×
General:new(extension, "sxfy__leitong", "shu", 4):addSkills { "sxfy__kuiji" }
Fk:loadTranslationTable{
  ["sxfy__leitong"] = "雷铜",
  ["#sxfy__leitong"] = "石铠之鼋",
  ["illustrator:sxfy__leitong"] = "小牛",
}
General:new(extension, "sxfy__caiwenji", "wei", 3, 3, General.Female):addSkills { "sxfy__mozhi" }
Fk:loadTranslationTable{
  ["sxfy__caiwenji"] = "蔡文姬",
  ["#sxfy__caiwenji"] = "金璧之才",
  ["illustrator:sxfy__caiwenji"] = "漫想族",
}

General:new(extension, "sxfy__fanchou", "qun", 4):addSkills { "sxfy__xingluan" }
Fk:loadTranslationTable{
  ["sxfy__fanchou"] = "樊稠",
  ["#sxfy__fanchou"] = "庸生变难",
  ["illustrator:sxfy__fanchou"] = "心中一凛",
}

General:new(extension, "sxfy__zhugeguo", "shu", 3, 3, General.Female):addSkills { "sxfy__qirang", "sxfy__yuhua" }
Fk:loadTranslationTable{
  ["sxfy__zhugeguo"] = "诸葛果",
  ["#sxfy__zhugeguo"] = "凤阁乘烟",
  ["illustrator:sxfy__zhugeguo"] = "任玉帝",
}

General:new(extension, "sxfy__shamoke", "shu", 4):addSkills { "sxfy__jilis" }
Fk:loadTranslationTable{
  ["sxfy__shamoke"] = "沙摩柯",
  ["#sxfy__shamoke"] = "五溪蛮王",
  ["illustrator:sxfy__shamoke"] = "鱼仔",
}

--许靖× 傅肜√ 阎柔× 苏飞× 鲁芝× 胡班× 刘辟× 王祥× 阮慧× 轲比能× 杜预√ 吴景√ 高览× 蔡贞姬× 阎象√ 王凌√ 蒋钦√ 周不疑√ 王双×
General:new(extension, "sxfy__furong", "shu", 4):addSkills { "sxfy__xiaosi" }
Fk:loadTranslationTable{
  ["sxfy__furong"] = "傅肜",
  ["#sxfy__furong"] = "矢忠不二",
  ["illustrator:sxfy__furong"] = "凡果",
}

local duyu = General:new(extension, "sxfy__duyu", "qun", 4)
duyu.subkingdom = "jin"
duyu:addSkills { "sxfy__sanchen" }
duyu:addRelatedSkill("sxfy__miewu")
Fk:loadTranslationTable{
  ["sxfy__duyu"] = "杜预",
  ["#sxfy__duyu"] = "文成武德",
  ["illustrator:sxfy__duyu"] = "丸点科技",
}

General:new(extension, "sxfy__wujing", "wu", 4):addSkills { "sxfy__heji" }
Fk:loadTranslationTable{
  ["sxfy__wujing"] = "吴景",
  ["#sxfy__wujing"] = "助吴征战",
  ["illustrator:sxfy__wujing"] = "RalphR",
}

General:new(extension, "sxfy__yanxiang", "qun", 3):addSkills { "sxfy__kujian", "sxfy__ruilian" }
Fk:loadTranslationTable{
  ["sxfy__yanxiang"] = "阎象",
  ["#sxfy__yanxiang"] = "明尚夙达",
  ["illustrator:sxfy__yanxiang"] = "聚一",
}

General:new(extension, "sxfy__wangling", "wei", 4):addSkills { "sxfy__xingqi" }
Fk:loadTranslationTable{
  ["sxfy__wangling"] = "王凌",
  ["#sxfy__wangling"] = "风节格尚",
  ["illustrator:sxfy__wangling"] = "六道目",
}

General:new(extension, "sxfy__jiangqin", "wu", 4):addSkills { "sxfy__shangyi" }
Fk:loadTranslationTable{
  ["sxfy__jiangqin"] = "蒋钦",
  ["#sxfy__jiangqin"] = "折节尚义",
  ["illustrator:sxfy__jiangqin"] = "付玉",
}

General:new(extension, "sxfy__zhoubuyi", "wei", 3):addSkills { "sxfy__huiyao", "sxfy__quesong" }
Fk:loadTranslationTable{
  ["sxfy__zhoubuyi"] = "周不疑",
  ["#sxfy__zhoubuyi"] = "稚雀清声",
  ["illustrator:sxfy__zhoubuyi"] = "匠人绘",
}

--清河公主× 高干√ 贾充× 成济√ 郭图√ 胡金定√ 张让× 范疆张达 马元义√ 曹纯√ 马日磾× 孙弘 王匡× 刘磐
General:new(extension, "sxfy__gaogan", "qun", 4):addSkills { "sxfy__juguan" }
Fk:loadTranslationTable{
  ["sxfy__gaogan"] = "高干",
  ["#sxfy__gaogan"] = "才志弘邈",
  ["illustrator:sxfy__gaogan"] = "梦回唐朝",
}

General:new(extension, "sxfy__chengjiw", "wei", 4):addSkills { "sxfy__kuangli", "xiongsi" }
Fk:loadTranslationTable{
  ["sxfy__chengjiw"] = "成济",
  ["#sxfy__chengjiw"] = "劣犬良弓",
  ["illustrator:sxfy__chengjiw"] = "RalphR",
}

General:new(extension, "sxfy__guotu", "qun", 3):addSkills { "sxfy__qushi", "sxfy__weijie" }
Fk:loadTranslationTable{
  ["sxfy__guotu"] = "郭图",
  ["#sxfy__guotu"] = "凶臣",
  ["illustrator:sxfy__guotu"] = "厦门塔普",
}

General:new(extension, "sxfy__hujinding", "shu", 3, 3, General.Female):addSkills { "sxfy__qingyuan", "sxfy__chongshen" }
Fk:loadTranslationTable{
  ["sxfy__hujinding"] = "胡金定",
  ["#sxfy__hujinding"] = "怀子求怜",
  ["illustrator:sxfy__hujinding"] = "李敏然",
}

General:new(extension, "sxfy__mayuanyi", "qun", 4):addSkills { "sxfy__jibing", "binghuo" }
Fk:loadTranslationTable{
  ["sxfy__mayuanyi"] = "马元义",
  ["#sxfy__mayuanyi"] = "血动黄帆",
  ["illustrator:sxfy__mayuanyi"] = "撒呀酱",
}

General:new(extension, "sxfy__caochun", "wei", 4):addSkills { "sxfy__shanjia" }
Fk:loadTranslationTable{
  ["sxfy__caochun"] = "曹纯",
  ["#sxfy__caochun"] = "虎豹骑首",
  ["illustrator:sxfy__caochun"] = "biou09",
}

--陈式 王荣 段煨 忙牙长× 穆顺√ 卞喜√ 童渊 张宁 邢道荣× 李丰 吕岱× 张虎√ 乐綝√ 张勋√ 张闿√ 向朗√ 臧霸× 花鬘√ 陈琳√ 丘力居√ 曹安民√ 孙綝√ 
General:new(extension, "sxfy__mushun", "qun", 4):addSkills { "sxfy__jinjianm", "sxfy__shizhao" }
Fk:loadTranslationTable{
  ["sxfy__mushun"] = "穆顺",
  ["#sxfy__mushun"] = "疾风劲草",
  ["illustrator:sxfy__mushun"] = "鬼画府",
}

General:new(extension, "sxfy__bianxi", "wei", 4):addSkills { "sxfy__dunxi" }
Fk:loadTranslationTable{
  ["sxfy__bianxi"] = "卞喜",
  ["#sxfy__bianxi"] = "伏龛蛇影",
  ["illustrator:sxfy__bianxi"] = "游歌",
}

General:new(extension, "sxfy__zhanghu", "wei", 4):addSkills { "sxfy__cuijian" }
Fk:loadTranslationTable{
  ["sxfy__zhanghu"] = "张虎",
  ["#sxfy__zhanghu"] = "晋阳侯",
  ["illustrator:sxfy__zhanghu"] = "君桓文化",
}

General:new(extension, "sxfy__yuechen", "wei", 4):addSkills { "sxfy__porui" }
Fk:loadTranslationTable{
  ["sxfy__yuechen"] = "乐綝",
  ["#sxfy__yuechen"] = "广昌亭侯",
  ["illustrator:sxfy__yuechen"] = "错落宇宙",
}

General:new(extension, "sxfy__zhangxun", "qun", 4):addSkills { "sxfy__yongdiz" }
Fk:loadTranslationTable{
  ["sxfy__zhangxun"] = "张勋",
  ["#sxfy__zhangxun"] = "仲家将军",
  ["illustrator:sxfy__zhangxun"] = "一意动漫",
}

General:new(extension, "sxfy__zhangkai", "qun", 4):addSkills { "sxfy__xiangshuz" }
Fk:loadTranslationTable{
  ["sxfy__zhangkai"] = "张闿",
  ["#sxfy__zhangkai"] = "无餍狍鸮",
  ["illustrator:sxfy__zhangkai"] = "白夜",
}

General:new(extension, "sxfy__xianglang", "shu", 3):addSkills { "sxfy__kanji", "sxfy__qianzheng" }
Fk:loadTranslationTable{
  ["sxfy__xianglang"] = "向朗",
  ["#sxfy__xianglang"] = "校书翾翻",
  ["illustrator:sxfy__xianglang"] = "尼乐小丑",
}

General:new(extension, "sxfy__huaman", "shu", 3, 3, General.Female):addSkills { "sxfy__manyi", "sxfy__mansi" }
Fk:loadTranslationTable{
  ["sxfy__huaman"] = "花鬘",
  ["#sxfy__huaman"] = "芳踪载馨",
  ["illustrator:sxfy__huaman"] = "匠人绘",
}

General:new(extension, "sxfy__chenlin", "wei", 3):addSkills { "sxfy__bifa", "sxfy__songci" }
Fk:loadTranslationTable{
  ["sxfy__chenlin"] = "陈琳",
  ["#sxfy__chenlin"] = "破竹之咒",
  ["illustrator:sxfy__chenlin"] = "biou09",
}

General:new(extension, "sxfy__qiuliju", "qun", 4, 6):addSkills { "sxfy__koulue", "sxfy__suirenq" }
Fk:loadTranslationTable{
  ["sxfy__qiuliju"] = "丘力居",
  ["#sxfy__qiuliju"] = "乌丸王",
  ["illustrator:sxfy__qiuliju"] = "匠人绘",
}

General:new(extension, "sxfy__caoanmin", "wei", 4):addSkills { "sxfy__xianwei" }
Fk:loadTranslationTable{
  ["sxfy__caoanmin"] = "曹安民",
  ["#sxfy__caoanmin"] = "履薄临深",
  ["illustrator:sxfy__caoanmin"] = "猎枭",
}

General:new(extension, "sxfy__sunchen", "wu", 4):addSkills { "sxfy__zigu" }
Fk:loadTranslationTable{
  ["sxfy__sunchen"] = "孙綝",
  ["#sxfy__sunchen"] = "凶竖盈溢",
  ["illustrator:sxfy__sunchen"] = "游歌",
}

--神典韦 神贾诩 神郭嘉√ 神荀彧√ 神孙策 神太史慈 神鲁肃 神华佗 神貂蝉× 神姜维 神马超 神许褚
local godguojia = General:new(extension, "sxfy__godguojia", "god", 3)
godguojia:addSkills { "sxfy__huishi", "sxfy__tianyi" }
godguojia:addRelatedSkill("sxfy__zuoxing")
Fk:loadTranslationTable{
  ["sxfy__godguojia"] = "神郭嘉",
  ["#sxfy__godguojia"] = "星月奇佐",
}

General:new(extension, "sxfy__godxunyu", "god", 3):addSkills { "tianzuo", "sxfy__dinghan" }
Fk:loadTranslationTable{
  ["sxfy__godxunyu"] = "神荀彧",
  ["#sxfy__godxunyu"] = "洞心先识",
  ["illustrator:sxfy__godxunyu"] = "JJGG",
}


return extension

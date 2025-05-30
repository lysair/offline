local extension = Package:new("feihongyinxue")
extension.extensionName = "offline"

extension:loadSkillSkelsByPath("./packages/offline/pkg/fhyx/skills")

Fk:loadTranslationTable{
  ["feihongyinxue"] = "线下-飞鸿映雪",
  ["fhyx"] = "线下",
  ["fhyx_ex"] = "线下界",
  ["ofl_shiji"] = "线下始计篇",
}

General:new(extension, "fhyx_ex__yanliangwenchou", "qun", 4):addSkills { "fhyx_ex__shuangxiong", "fhyx_ex__xiayong" }
Fk:loadTranslationTable{
  ["fhyx_ex__yanliangwenchou"] = "界颜良文丑",
  ["#fhyx_ex__yanliangwenchou"] = "虎狼兄弟",
  ["illustrator:fhyx_ex__yanliangwenchou"] = "鬼画府",
}

local guanqiujian = General:new(extension, "fhyx__guanqiujian", "wei", 4)
guanqiujian:addSkills { "fhyx__zhengrong", "fhyx__hongju" }
guanqiujian:addRelatedSkill("fhyx__qingce")
Fk:loadTranslationTable{
  ["fhyx__guanqiujian"] = "毌丘俭",
  ["#fhyx__guanqiujian"] = "镌功铭征荣",
  ["illustrator:fhyx__guanqiujian"] = "鬼画府",
}

General:new(extension, "fhyx__liyans", "shu", 3):addSkills { "fhyx__duliang", "fhyx__fulin" }
Fk:loadTranslationTable{
  ["fhyx__liyans"] = "李严",
  ["#fhyx__liyans"] = "矜风流务",
  ["illustrator:fhyx__liyans"] = "梦回唐朝",

  ["~fhyx__liyans"] = "老臣，有愧圣恩……",
}

General:new(extension, "fhyx__caojie", "qun", 3, 3, General.Female):addSkills { "fhyx__shouxi", "fhyx__huimin" }
Fk:loadTranslationTable{
  ["fhyx__caojie"] = "曹节",
  ["#fhyx__caojie"] = "悬壶济世",
  ["illustrator:fhyx__caojie"] = "匠人绘·空山",
}

General:new(extension, "fhyx_ex__caiyong", "qun", 3):addSkills { "pizhuan", "fhyx__tongbo" }
Fk:loadTranslationTable{
  ["fhyx_ex__caiyong"] = "界蔡邕",
  ["#fhyx_ex__caiyong"] = "大鸿儒",
  ["illustrator:fhyx_ex__caiyong"] = "凝聚永恒",
}

General:new(extension, "ofl_shiji__bianfuren", "wei", 3, 3, General.Female):addSkills { "ofl_shiji__fuding", "ofl_shiji__yuejian" }
Fk:loadTranslationTable{
  ["ofl_shiji__bianfuren"] = "卞夫人",
  ["#ofl_shiji__bianfuren"] = "内助贤后",
  ["illustrator:ofl_shiji__bianfuren"] = "云涯",
}

General:new(extension, "ofl_shiji__chenzhen", "shu", 3):addSkills { "ofl_shiji__shameng" }
Fk:loadTranslationTable{
  ["ofl_shiji__chenzhen"] = "陈震",
  ["#ofl_shiji__chenzhen"] = "歃盟使节",
  ["illustrator:ofl_shiji__chenzhen"] = "君桓文化",
}

General:new(extension, "ofl_shiji__luotong", "wu", 4):addSkills { "ofl_shiji__minshi", "ofl_shiji__xianming" }
Fk:loadTranslationTable{
  ["ofl_shiji__luotong"] = "骆统",
  ["#ofl_shiji__luotong"] = "辨如悬河",
  ["illustrator:ofl_shiji__luotong"] = "凡果",
}

General:new(extension, "ofl_shiji__sunshao", "wu", 3):addSkills { "ofl_shiji__dingyi", "ofl_shiji__zuici" }
Fk:loadTranslationTable{
  ["ofl_shiji__sunshao"] = "孙邵",
  ["#ofl_shiji__sunshao"] = "清庙之器",
  ["illustrator:ofl_shiji__sunshao"] = "枭瞳",

  ["~ofl_shiji__sunshao"] = "若得望朝野清明，邵死亦无憾……",
}

local duyu = General:new(extension, "ofl_shiji__duyu", "qun", 4)
duyu.subkingdom = "jin"
duyu:addSkills { "ofl_shiji__wuku", "ofl_shiji__sanchen" }
duyu:addRelatedSkill("ofl_shiji__miewu")
Fk:loadTranslationTable{
  ["ofl_shiji__duyu"] = "杜预",
  ["#ofl_shiji__duyu"] = "弼朝博虬",
  ["illustrator:ofl_shiji__duyu"] = "枭瞳",

  ["~ofl_shiji__duyu"] = "此魂弃归泰山，永镇不轨之贼……",
}

General:new(extension, "ofl_shiji__xunchen", "qun", 3):addSkills { "ofl_shiji__weipo", "ofl_shiji__chenshi", "ofl_shiji__moushi" }
Fk:loadTranslationTable{
  ["ofl_shiji__xunchen"] = "荀谌",
  ["#ofl_shiji__xunchen"] = "谋刃略锋",
  ["illustrator:ofl_shiji__xunchen"] = "鬼画府",
}

local godguojia = General:new(extension, "ofl_shiji__godguojia", "god", 3)
godguojia:addSkills { "ofl_shiji__huishi", "ofl_shiji__tianyi", "ofl_shiji__huishig" }
godguojia:addRelatedSkill("zuoxing")
Fk:loadTranslationTable{
  ["ofl_shiji__godguojia"] = "神郭嘉",
  ["#ofl_shiji__godguojia"] = "倚星折月",
  ["illustrator:ofl_shiji__godguojia"] = "M云涯",

  ["$zuoxing_ofl_shiji__godguojia1"] = "且为明公巧借天时。",
  ["$zuoxing_ofl_shiji__godguojia2"] = "借天秘力，佐公之事，感有荣焉。",
  ["~ofl_shiji__godguojia"] = "未及引动天能，竟已要坠入轮回……",
}

General:new(extension, "ofl_shiji__godxunyu", "god", 3):addSkills { "ofl_shiji__lingce", "ofl_shiji__dinghan", "tianzuo" }
Fk:loadTranslationTable{
  ["ofl_shiji__godxunyu"] = "神荀彧",
  ["#ofl_shiji__godxunyu"] = "洞心先识",
  ["illustrator:ofl_shiji__godxunyu"] = "三三画画了么",

  ["$tianzuo_ofl_shiji__godxunyu1"] = "主公有此四胜，纵绍强亦可败之。",
  ["$tianzuo_ofl_shiji__godxunyu2"] = "主公以有道之师伐不义之徒，胜之必矣。",
  ["~ofl_shiji__godxunyu"] = "君本起义兵匡国，今怎可生此异心……",
}

local yanghu = General:new(extension, "ofl_shiji__yanghu", "qun", 3)
yanghu.subkingdom = "jin"
yanghu:addSkills { "ofl_shiji__mingfa", "ofl_shiji__rongbei" }
Fk:loadTranslationTable{
  ["ofl_shiji__yanghu"] = "羊祜",
  ["#ofl_shiji__yanghu"] = "鹤德璋声",
  ["illustrator:ofl_shiji__yanghu"] = "凡果",

  ["~ofl_shiji__yanghu"] = "吾身虽殒，名可垂于竹帛……",
}

General:new(extension, "ofl_shiji__xujing", "shu", 3):addSkills { "ofl_shiji__boming", "ofl_shiji__ejian" }
Fk:loadTranslationTable{
  ["ofl_shiji__xujing"] = "许靖",
  ["#ofl_shiji__xujing"] = "篡贤取良",
  ["illustrator:ofl_shiji__xujing"] = "铁杵文化",

  ["~ofl_shiji__xujing"] = "靖获虚誉而得用，唯以荐才报君恩……",
}

General:new(extension, "ofl_shiji__zhangwen", "wu", 3):addSkills { "ofl_shiji__songshu", "gebo" }
Fk:loadTranslationTable{
  ["ofl_shiji__zhangwen"] = "张温",
  ["#ofl_shiji__zhangwen"] = "炜晔曜世",
  ["illustrator:ofl_shiji__zhangwen"] = "zoo",

  ["$gebo_ofl_shiji__zhangwen1"] = "高宗守丧而兴殷，成王德治以太平。",
  ["$gebo_ofl_shiji__zhangwen2"] = "化干戈玉帛，共伐乱贼。",
  ["~ofl_shiji__zhangwen"] = "臣未挟异心，请陛下明鉴……",
}

local qiaogong = General:new(extension, "ofl_shiji__qiaogong", "wu", 3)
qiaogong:addSkills { "ofl_shiji__yizhu", "luanchou" }
qiaogong:addRelatedSkill("gonghuan")
Fk:loadTranslationTable{
  ["ofl_shiji__qiaogong"] = "桥公",
  ["#ofl_shiji__qiaogong"] = "高风硕望",
  ["illustrator:ofl_shiji__qiaogong"] = "君桓文化",

  ["$luanchou_ofl_shiji__qiaogong1"] = "金玉结同心，天作成良缘。",
  ["$luanchou_ofl_shiji__qiaogong2"] = "姻缘夙世成，和顺从今定。",
  ["$gonghuan_ofl_shiji__qiaogong1"] = "魏似猛虎，吴蜀如羊，当此时势，复何虑也。",
  ["$gonghuan_ofl_shiji__qiaogong2"] = "两国当以联姻之谊，共抗魏国之击。",
  ["~ofl_shiji__qiaogong"] = "得婿如此，夫复何求……",
}

General:new(extension, "ofl_shiji__liuzhang", "qun", 3):addSkills { "ofl_shiji__yinge", "ofl_shiji__shiren", "ofl_shiji__jvyi" }
Fk:loadTranslationTable{
  ["ofl_shiji__liuzhang"] = "刘璋",
  ["#ofl_shiji__liuzhang"] = "半圭黯暗",
  ["illustrator:ofl_shiji__liuzhang"] = "",
}

General:new(extension, "ofl_shiji__liuba", "shu", 3):addSkills { "ofl_shiji__duanbi", "ofl_shiji__tongdu" }
Fk:loadTranslationTable{
  ["ofl_shiji__liuba"] = "刘巴",
  ["#ofl_shiji__liuba"] = "撰科行律",
  ["illustrator:ofl_shiji__liuba"] = "匠人绘",

  ["~ofl_shiji__liuba"] = "唉，国之兴亡，岂能改之……",
}

General:new(extension, "fhyx__zhugeshang", "shu", 3):addSkills { "ofl__sangu", "yizu" }
Fk:loadTranslationTable{
  ["fhyx__zhugeshang"] = "诸葛尚",
  ["#fhyx__zhugeshang"] = "碧落玄鹄",
  ["designer:fhyx__zhugeshang"] = "叫什么啊你妹",
  ["illustrator:fhyx__zhugeshang"] = "鬼画府",

  ["$yizu_fhyx__zhugeshang1"] = "自幼家学渊源，岂会看不穿此等伎俩？",
  ["$yizu_fhyx__zhugeshang2"] = "祖父在上，孩儿定不负诸葛之名！",
  ["~fhyx__zhugeshang"] = "今父既死于敌，我又何能独活？",
}

return extension

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

--成济 张虎√ 乐綝√ 牛金× 张春华× 王异× 曹冲× 陈琳√ 蔡文姬 诸葛诞× 曹纯 鲁芝× 张昌蒲× 王双× 阎柔× 清河公主× 王凌 蔡贞姬× 胡班× 曹安民
--阮慧× 周不疑 卞喜 臧霸×
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

General:new(extension, "sxfy__chenlin", "wei", 3):addSkills { "sxfy__bifa", "sxfy__songci" }
Fk:loadTranslationTable{
  ["sxfy__chenlin"] = "陈琳",
  ["#sxfy__chenlin"] = "破竹之咒",
  ["illustrator:sxfy__chenlin"] = "biou09",
}

--陈式 沙摩柯 张星彩× 伊籍× 花鬘√ 许靖× 吴班× 李丰× 诸葛果 赵统赵广× 陈震× 胡金定 雷铜 傅肜 向朗√

General:new(extension, "sxfy__huaman", "shu", 3, 3, General.Female):addSkills { "sxfy__manyi", "sxfy__mansi" }
Fk:loadTranslationTable{
  ["sxfy__huaman"] = "花鬘",
  ["#sxfy__huaman"] = "芳踪载馨",
  ["illustrator:sxfy__huaman"] = "匠人绘",
}

General:new(extension, "sxfy__xianglang", "shu", 3):addSkills { "sxfy__kanji", "sxfy__qianzheng" }
Fk:loadTranslationTable{
  ["sxfy__xianglang"] = "向朗",
  ["#sxfy__xianglang"] = "校书翾翻",
  ["illustrator:sxfy__xianglang"] = "尼乐小丑",
}

--蒋钦 孙綝 吕岱 苏飞× 孙弘 吴景 范疆张达

--王荣 杜预 段煨 丘力居 穆顺 张宁 童渊 刘辟× 轲比能× 邢道荣× 张勋√ 张闿√ 马元义 阎象 贾充× 王匡× 刘磐 韩遂 张让 郭图 樊稠 忙牙长×
--高览× 高干 马日磾×

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

--王祥×

--神貂蝉× 神贾诩× 神华佗 神典韦× 神荀彧 神鲁肃 神郭嘉 神孙策 神太史慈 神马超 神许褚 神姜维

return extension

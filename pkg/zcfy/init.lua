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

return extension

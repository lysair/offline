local extension = Package:new("sixiangfengyin")
extension.extensionName = "offline"

extension:loadSkillSkelsByPath("./packages/offline/pkg/sxfy/skills")

Fk:loadTranslationTable{
  ["sixiangfengyin"] = "线下-四象封印",
  ["sxfy"] = "四象封印",
}

--少阴
General:new(extension, "sxfy__dengzhi", "shu", 3):addSkills { "sxfy__jimeng", "sxfy__hehe" }
Fk:loadTranslationTable{
  ["sxfy__dengzhi"] = "邓芝",
  ["#sxfy__dengzhi"] = "绝境的外交家",
  ["illustrator:sxfy__dengzhi"] = "小牛",
}

General:new(extension, "sxfy__wenyang", "wei", 4):addSkills { "sxfy__quedi" }
Fk:loadTranslationTable{
  ["sxfy__wenyang"] = "文鸯",
  ["#sxfy__wenyang"] = "独骑破军",
  ["illustrator:sxfy__wenyang"] = "biou09",
}

General:new(extension, "sxfy__chengpu", "wu", 4):addSkills { "sxfy__chunlao" }
Fk:loadTranslationTable{
  ["sxfy__chengpu"] = "程普",
  ["#sxfy__chengpu"] = "三朝虎臣",
  ["illustrator:sxfy__chengpu"] = "Zero",
}

General:new(extension, "sxfy__lijue", "qun", 5):addSkills { "sxfy__xiongsuan" }
Fk:loadTranslationTable{
  ["sxfy__lijue"] = "李傕",
  ["#sxfy__lijue"] = "奸谋恶勇",
  ["illustrator:sxfy__lijue"] = "XXX",
}

General:new(extension, "sxfy__feiyi", "shu", 3):addSkills { "sxfy__tiaohe", "sxfy__qiansu" }
Fk:loadTranslationTable{
  ["sxfy__feiyi"] = "费祎",
  ["#sxfy__feiyi"] = "洞世权相",
  ["illustrator:sxfy__feiyi"] = "木碗Rae",
}

General:new(extension, "sxfy__fanyufeng", "qun", 3, 3, General.Female):addSkills { "sxfy__bazhan", "sxfy__jiaoying" }
Fk:loadTranslationTable{
  ["sxfy__fanyufeng"] = "樊玉凤",
  ["#sxfy__fanyufeng"] = "红鸾寡宿",
  ["illustrator:sxfy__fanyufeng"] = "biou09",
}

General:new(extension, "sxfy__chengyu", "wei", 3):addSkills { "sxfy__shefu", "sxfy__yibing" }
Fk:loadTranslationTable{
  ["sxfy__chengyu"] = "程昱",
  ["#sxfy__chengyu"] = "泰山捧日",
  ["illustrator:sxfy__chengyu"] = "Mr_Sleeping",
}

General:new(extension, "sxfy__zhangyiy", "shu", 4):addSkills { "sxfy__zhiyi" }
Fk:loadTranslationTable{
  ["sxfy__zhangyiy"] = "张翼",
  ["#sxfy__zhangyiy"] = "亢锐怀忠",
  ["illustrator:sxfy__zhangyiy"] = "影紫C",
}

General:new(extension, "sxfy__jianggan", "wei", 3):addSkills { "sxfy__daoshu", "sxfy__daizui" }
Fk:loadTranslationTable{
  ["sxfy__jianggan"] = "蒋干",
  ["#sxfy__jianggan"] = "独步江淮",
  ["illustrator:sxfy__jianggan"] = "黑桃J",
}

General:new(extension, "sxfy__mayunlu", "shu", 4, 4, General.Female):addSkills { "sxfy__fengpo", "mashu" }
Fk:loadTranslationTable{
  ["sxfy__mayunlu"] = "马云騄",
  ["#sxfy__mayunlu"] = "剑胆琴心",
  ["illustrator:sxfy__mayunlu"] = "木美人",
}

General:new(extension, "sxfy__mateng", "qun", 4):addSkills { "sxfy__xiongyi", "mashu", "sxfy__youqi" }
Fk:loadTranslationTable{
  ["sxfy__mateng"] = "马腾",
  ["#sxfy__mateng"] = "勇冠西州",
  ["illustrator:sxfy__mateng"] = "峰雨同程",
}

General:new(extension, "sxfy__sunhao", "wu", 5):addSkills { "sxfy__canshi", "chouhai", "guiming" }
Fk:loadTranslationTable{
  ["sxfy__sunhao"] = "孙皓",
  ["#sxfy__sunhao"] = "时日曷丧",
  ["illustrator:sxfy__sunhao"] = "王立雄",
}

General:new(extension, "sxfy__luotong", "wu", 3):addSkills { "sxfy__jinjian", "sxfy__renzheng" }
Fk:loadTranslationTable{
  ["sxfy__luotong"] = "骆统",
  ["#sxfy__luotong"] = "蹇谔匪躬",
  ["illustrator:sxfy__luotong"] = "李敏然",
}

General:new(extension, "sxfy__yanghu", "wei", 4):addSkills { "sxfy__mingfa" }
Fk:loadTranslationTable{
  ["sxfy__yanghu"] = "羊祜",
  ["#sxfy__yanghu"] = "制紘同轨",
  ["illustrator:sxfy__yanghu"] = "芝芝不加糖",

  ["~sxfy__yanghu"] = "憾东吴尚存，天下未定也。",
}

General:new(extension, "sxfy__lvlingqi", "qun", 4, 4, General.Female):addSkills { "sxfy__huiji" }
Fk:loadTranslationTable{
  ["sxfy__lvlingqi"] = "吕玲绮",
  ["#sxfy__lvlingqi"] = "无双虓姬",
  ["illustrator:sxfy__lvlingqi"] = "木美人",
}

General:new(extension, "sxfy__zhouchu", "wu", 4):addSkills { "sxfy__xiongxia" }
Fk:loadTranslationTable{
  ["sxfy__zhouchu"] = "周处",
  ["#sxfy__zhouchu"] = "英情天逸",
  ["illustrator:sxfy__zhouchu"] = "西国红云&zoo",
}

--太阴
General:new(extension, "sxfy__xushu", "shu", 3):addSkills { "sxfy__wuyan", "sxfy__jujian" }
Fk:loadTranslationTable{
  ["sxfy__xushu"] = "徐庶",
  ["#sxfy__xushu"] = "身曹心汉",
  ["illustrator:sxfy__xushu"] = "Aimer彩三",
}

General:new(extension, "sxfy__wangyuanji", "wei", 3, 3, General.Female):addSkills { "sxfy__qianchong", "sxfy__shangjian" }
Fk:loadTranslationTable{
  ["sxfy__wangyuanji"] = "王元姬",
  ["#sxfy__wangyuanji"] = "清雅抑华",
  ["illustrator:sxfy__wangyuanji"] = "",
}

General:new(extension, "sxfy__maliang", "shu", 3):addSkills { "sxfy__xiemu", "sxfy__naman" }
Fk:loadTranslationTable{
  ["sxfy__maliang"] = "马良",
  ["#sxfy__maliang"] = "白眉智士",
  ["illustrator:sxfy__maliang"] = "biou09",
}

General:new(extension, "sxfy__jiangwan", "shu", 3):addSkills { "sxfy__beiwu", "sxfy__chengshi" }
Fk:loadTranslationTable{
  ["sxfy__jiangwan"] = "蒋琬",
  ["#sxfy__jiangwan"] = "方整威重",
  ["illustrator:sxfy__jiangwan"] = "depp",
}

General:new(extension, "sxfy__sunshao", "wu", 3):addSkills { "sxfy__dingyi", "sxfy__zuici" }
Fk:loadTranslationTable{
  ["sxfy__sunshao"] = "孙邵",
  ["#sxfy__sunshao"] = "创基扶政",
  ["illustrator:sxfy__sunshao"] = "君桓文化",
}

General:new(extension, "sxfy__zhonghui", "wei", 4):addSkills { "sxfy__xingfa" }
Fk:loadTranslationTable{
  ["sxfy__zhonghui"] = "钟会",
  ["#sxfy__zhonghui"] = "桀骜的野心家",
  ["illustrator:sxfy__zhonghui"] = "biou09",
}

local guanxing = General:new(extension, "sxfy__guanxings", "shu", 4)
guanxing:addSkills { "sxfy__wuyou" }
guanxing:addRelatedSkill("wusheng")
Fk:loadTranslationTable{
  ["sxfy__guanxings"] = "关兴",
  ["#sxfy__guanxings"] = "龙骧将军",
  ["illustrator:sxfy__guanxings"] = "峰雨同程",
}

General:new(extension, "sxfy__xuezong", "wu", 3):addSkills { "sxfy__funan", "sxfy__jiexun" }
Fk:loadTranslationTable{
  ["sxfy__xuezong"] = "薛综",
  ["#sxfy__xuezong"] = "彬彬之玊",
  ["illustrator:sxfy__xuezong"] = "凝聚永恒",
}

General:new(extension, "sxfy__cenhun", "wu", 3):addSkills { "sxfy__jishe", "sxfy__wudu" }
Fk:loadTranslationTable{
  ["sxfy__cenhun"] = "岑昏",
  ["#sxfy__cenhun"] = "伐梁倾瓴",
  ["illustrator:sxfy__cenhun"] = "depp",
}

General:new(extension, "sxfy__huaxin", "wei", 3):addSkills { "sxfy__yuanqing", "sxfy__shuchen" }
Fk:loadTranslationTable{
  ["sxfy__huaxin"] = "华歆",
  ["#sxfy__huaxin"] = "清素拂浊",
  ["illustrator:sxfy__huaxin"] = "凡果",
}

General:new(extension, "sxfy__wanglang", "wei", 3):addSkills { "sxfy__gushe", "sxfy__jici" }
Fk:loadTranslationTable{
  ["sxfy__wanglang"] = "王朗",
  ["#sxfy__wanglang"] = "凤鶥",
  ["illustrator:sxfy__wanglang"] = "小牛",
}

General:new(extension, "sxfy__liuzhang", "qun", 3):addSkills { "sxfy__yinge", "sxfy__shiren", "sxfy__juyi" }
Fk:loadTranslationTable{
  ["sxfy__liuzhang"] = "刘璋",
  ["#sxfy__liuzhang"] = "求仁失益",
  ["illustrator:sxfy__liuzhang"] = "HM",
}

General:new(extension, "sxfy__gongsunyuan", "qun", 4):addSkills { "sxfy__huaiyi", "sxfy__fengbai" }
Fk:loadTranslationTable{
  ["sxfy__gongsunyuan"] = "公孙渊",
  ["#sxfy__gongsunyuan"] = "狡徒悬海",
  ["illustrator:sxfy__gongsunyuan"] = "Zero",
}

General:new(extension, "sxfy__liubiao", "qun", 3):addSkills { "sxfy__zishou", "zongshi", "sxfy__jujing" }
Fk:loadTranslationTable{
  ["sxfy__liubiao"] = "刘表",
  ["#sxfy__liubiao"] = "跨蹈汉南",
  ["illustrator:sxfy__liubiao"] = "波子",
}

General:new(extension, "sxfy__simashi", "wei", 4):addSkills { "sxfy__jinglve" }
Fk:loadTranslationTable{
  ["sxfy__simashi"] = "司马师",
  ["#sxfy__simashi"] = "摧坚荡异",
  ["illustrator:sxfy__simashi"] = "M云涯",
}

General:new(extension, "sxfy__fuhuanghou", "qun", 3, 3, General.Female):addSkills { "sxfy__zhuikong", "sxfy__qiuyuan" }
Fk:loadTranslationTable{
  ["sxfy__fuhuanghou"] = "伏皇后",
  ["#sxfy__fuhuanghou"] = "孤注一掷",
  ["illustrator:sxfy__fuhuanghou"] = "鬼画府",
}

--少阳
General:new(extension, "sxfy__zhangbaos", "shu", 4):addSkills { "sxfy__juezhu", "sxfy__chengjiz" }
Fk:loadTranslationTable{
  ["sxfy__zhangbaos"] = "张苞",
  ["#sxfy__zhangbaos"] = "虎翼将军",
  ["illustrator:sxfy__zhangbaos"] = "DEEMO",
}

General:new(extension, "sxfy__liuchen", "shu", 4):addSkills { "sxfy__zhanjue", "sxfy__qinwang" }
Fk:loadTranslationTable{
  ["sxfy__liuchen"] = "刘谌",
  ["#sxfy__liuchen"] = "北地王",
  ["illustrator:sxfy__liuchen"] = "石蝉",
}

General:new(extension, "sxfy__dingfeng", "wu", 4):addSkills { "sxfy__duanbing", "sxfy__fenxun" }
Fk:loadTranslationTable{
  ["sxfy__dingfeng"] = "丁奉",
  ["#sxfy__dingfeng"] = "寸短寸险",
  ["illustrator:sxfy__dingfeng"] = "Zero",
}

General:new(extension, "sxfy__sunluban", "wu", 3, 3, General.Female):addSkills { "sxfy__zenhui", "sxfy__chuyi" }
Fk:loadTranslationTable{
  ["sxfy__sunluban"] = "孙鲁班",
  ["#sxfy__sunluban"] = "为虎作伥",
  ["illustrator:sxfy__sunluban"] = "F.源",
}

General:new(extension, "sxfy__liuzan", "wu", 4):addSkills { "sxfy__fenyin" }
Fk:loadTranslationTable{
  ["sxfy__liuzan"] = "留赞",
  ["#sxfy__liuzan"] = "啸天亢声",
  ["illustrator:sxfy__liuzan"] = "聚一",
}

General:new(extension, "sxfy__sunyi", "wu", 4):addSkills { "sxfy__zaoli" }
Fk:loadTranslationTable{
  ["sxfy__sunyi"] = "孙翊",
  ["#sxfy__sunyi"] = "骁悍激躁",
  ["illustrator:sxfy__sunyi"] = "simcity95",
}

General:new(extension, "sxfy__lvfan", "wu", 3):addSkills { "sxfy__diaodu", "sxfy__diancai" }
Fk:loadTranslationTable{
  ["sxfy__lvfan"] = "吕范",
  ["#sxfy__lvfan"] = "持筹廉悍",
  ["illustrator:sxfy__lvfan"] = "琛·美弟奇",
}

General:new(extension, "sxfy__xiahouba", "shu", 4):addSkills { "sxfy__baobian" }
Fk:loadTranslationTable{
  ["sxfy__xiahouba"] = "夏侯霸",
  ["#sxfy__xiahouba"] = "棘途壮志",
  ["illustrator:sxfy__xiahouba"] = "depp",
}

General:new(extension, "sxfy__taoqian", "qun", 4):addSkills { "sxfy__yirang" }
Fk:loadTranslationTable{
  ["sxfy__taoqian"] = "陶谦",
  ["#sxfy__taoqian"] = "三让徐州",
  ["illustrator:sxfy__taoqian"] = "红字虾",
}

General:new(extension, "sxfy__jiling", "qun", 4):addSkills { "sxfy__shuangren" }
Fk:loadTranslationTable{
  ["sxfy__jiling"] = "纪灵",
  ["#sxfy__jiling"] = "仲帝大将",
  ["illustrator:sxfy__jiling"] = "YanBai",
}

General:new(extension, "sxfy__liru", "qun", 3):addSkills { "sxfy__mieji", "sxfy__juece" }
Fk:loadTranslationTable{
  ["sxfy__liru"] = "李儒",
  ["#sxfy__liru"] = "魔仕",
  ["illustrator:sxfy__liru"] = "木美人",
}

General:new(extension, "sxfy__guohuanghou", "wei", 3, 3, General.Female):addSkills { "sxfy__jiaozhao", "sxfy__danxin" }
Fk:loadTranslationTable{
  ["sxfy__guohuanghou"] = "郭皇后",
  ["#sxfy__guohuanghou"] = "月华驱霾",
  ["illustrator:sxfy__guohuanghou"] = "alien",
}

General:new(extension, "sxfy__guansuo", "shu", 4):addSkills { "sxfy__zhengnan" }
Fk:loadTranslationTable{
  ["sxfy__guansuo"] = "关索",
  ["#sxfy__guansuo"] = "征南先锋",
  ["illustrator:sxfy__guansuo"] = "木美人",
}

General:new(extension, "sxfy__liuye", "wei", 3):addSkills { "sxfy__polu", "sxfy__choulve" }
Fk:loadTranslationTable{
  ["sxfy__liuye"] = "刘晔",
  ["#sxfy__liuye"] = "佐世之才",
  ["illustrator:sxfy__liuye"] = "影紫C",
}

General:new(extension, "sxfy__caorui", "wei", 3):addSkills { "sxfy__huituo", "sxfy__mingjian", "xingshuai" }
Fk:loadTranslationTable{
  ["sxfy__caorui"] = "曹叡",
  ["#sxfy__caorui"] = "天资的明君",
  ["illustrator:sxfy__caorui"] = "王立雄",
}

General:new(extension, "sxfy__wangyun", "qun", 3):addSkills { "sxfy__yunji", "sxfy__zongji" }
Fk:loadTranslationTable{
  ["sxfy__wangyun"] = "王允",
  ["#sxfy__wangyun"] = "忠魂不泯",
  ["illustrator:sxfy__wangyun"] = "L",
}

--太阳
General:new(extension, "sxfy__liuxie", "qun", 3):addSkills { "sxfy__tianming", "sxfy__mizhao", "sxfy__zhongyanl" }
Fk:loadTranslationTable{
  ["sxfy__liuxie"] = "刘协",
  ["#sxfy__liuxie"] = "汉末天子",
  ["illustrator:sxfy__liuxie"] = "DH",
}

General:new(extension, "sxfy__zhugeke", "wu", 3):addSkills { "sxfy__aocai", "sxfy__duwu" }
Fk:loadTranslationTable{
  ["sxfy__zhugeke"] = "诸葛恪",
  ["#sxfy__zhugeke"] = "兴家赤族",
  ["illustrator:sxfy__zhugeke"] = "小牛",
}

General:new(extension, "sxfy__jiakui", "wei", 3):addSkills { "sxfy__zhongzuo", "sxfy__wanlan" }
Fk:loadTranslationTable{
  ["sxfy__jiakui"] = "贾逵",
  ["#sxfy__jiakui"] = "肃齐万里",
  ["illustrator:sxfy__jiakui"] = "小强",
}

General:new(extension, "sxfy__mengda", "shu", 4):addSkills { "sxfy__zhuan" }
Fk:loadTranslationTable{
  ["sxfy__mengda"] = "孟达",
  ["#sxfy__mengda"] = "据国向己",
  ["illustrator:sxfy__mengda"] = "李敏然",
}

General:new(extension, "sxfy__guozhao", "wei", 3, 3, General.Female):addSkills { "sxfy__wufei", "sxfy__jiaochong" }
Fk:loadTranslationTable{
  ["sxfy__guozhao"] = "郭女王",
  ["#sxfy__guozhao"] = "文德皇后",
  ["illustrator:sxfy__guozhao"] = "撒呀酱",
}

General:new(extension, "sxfy__tianfeng", "qun", 3):addSkills { "sxfy__gangjian", "sxfy__guijie" }
Fk:loadTranslationTable{
  ["sxfy__tianfeng"] = "田丰",
  ["#sxfy__tianfeng"] = "天姿朅杰",
  ["illustrator:sxfy__tianfeng"] = "城与橙与程",
}

General:new(extension, "sxfy__yufan", "wu", 3):addSkills { "sxfy__zongxuan", "sxfy__zhiyan" }
Fk:loadTranslationTable{
  ["sxfy__yufan"] = "虞翻",
  ["#sxfy__yufan"] = "狂直之士",
  ["illustrator:sxfy__yufan"] = "李敏然",
}

General:new(extension, "sxfy__simazhao", "wei", 4):addSkills { "sxfy__zhaoxin" }
Fk:loadTranslationTable{
  ["sxfy__simazhao"] = "司马昭",
  ["#sxfy__simazhao"] = "四海威服",
  ["illustrator:sxfy__simazhao"] = "匪萌十月",
}

General:new(extension, "sxfy__dongyun", "shu", 3):addSkills { "sxfy__bingzheng", "sxfy__duliangd" }
Fk:loadTranslationTable{
  ["sxfy__dongyun"] = "董允",
  ["#sxfy__dongyun"] = "骨鲠良相",
  ["illustrator:sxfy__dongyun"] = "谭明",
}

General:new(extension, "sxfy__sunluyu", "wu", 3, 3, General.Female):addSkills { "sxfy__mumu", "sxfy__meibu" }
Fk:loadTranslationTable{
  ["sxfy__sunluyu"] = "孙鲁育",
  ["#sxfy__sunluyu"] = "舍身饲虎",
  ["illustrator:sxfy__sunluyu"] = "四零玖",
}

General:new(extension, "sxfy__baosanniang", "shu", 3, 3, General.Female):addSkills { "sxfy__zhennan", "sxfy__shuyong" }
Fk:loadTranslationTable{
  ["sxfy__baosanniang"] = "鲍三娘",
  ["#sxfy__baosanniang"] = "慕花之姝",
  ["illustrator:sxfy__baosanniang"] = "杨杨和夏季",
}

General:new(extension, "sxfy__zoushi", "qun", 3, 3, General.Female):addSkills { "sxfy__huoshui", "sxfy__qingcheng" }
Fk:loadTranslationTable{
  ["sxfy__zoushi"] = "邹氏",
  ["#sxfy__zoushi"] = "祸心之魅",
  ["illustrator:sxfy__zoushi"] = "天京",
}

General:new(extension, "sxfy__kongrong", "qun", 3):addSkills { "sxfy__lirang" }
Fk:loadTranslationTable{
  ["sxfy__kongrong"] = "孔融",
  ["#sxfy__kongrong"] = "建安文首",
  ["illustrator:sxfy__kongrong"] = "影紫C",
}

General:new(extension, "sxfy__liuba", "shu", 3):addSkills { "sxfy__duanbi" }
Fk:loadTranslationTable{
  ["sxfy__liuba"] = "刘巴",
  ["#sxfy__liuba"] = "撰科行律",
  ["illustrator:sxfy__liuba"] = "黯荧岛",
}

General:new(extension, "sxfy__caozhen", "wei", 4):addSkills { "sxfy__sidi" }
Fk:loadTranslationTable{
  ["sxfy__caozhen"] = "曹真",
  ["#sxfy__caozhen"] = "子丹佳人",
  ["illustrator:sxfy__caozhen"] = "瞎子Ghe",
}

General:new(extension, "sxfy__zhoufang", "wu", 3):addSkills { "sxfy__qijian", "sxfy__youdi" }
Fk:loadTranslationTable{
  ["sxfy__zhoufang"] = "周鲂",
  ["#sxfy__zhoufang"] = "下发载义",
  ["illustrator:sxfy__zhoufang"] = "匠人绘",
}

return extension

local extension = Package:new("piracy_e")
extension.extensionName = "offline"

extension:loadSkillSkelsByPath("./packages/offline/pkg/piracy_e/skills")

Fk:loadTranslationTable{
  ["piracy_e"] = "线下-官盗E系列",
}

local generals = {}  --绕过变量上限的东西

--E0026群雄逐鹿：
--黄巾之乱：神张梁 神张宝 神张角
--虎牢关之战：虎牢关吕布
--界桥之战：神袁绍 神文丑 神公孙瓒 神赵云
--长安之战（文和乱武）：神贾诩 樊稠 王允
generals.ofl2__godjiaxu = General:new(extension, "ofl2__godjiaxu", "god", 3)
generals.ofl2__godjiaxu:addSkills { "ofl__bishi", "ofl__jianbing", "weimu" }
generals.ofl2__godjiaxu.headnote = "E0026群雄逐鹿"
Fk:loadTranslationTable{
  ["ofl2__godjiaxu"] = "神贾诩",
  ["#ofl2__godjiaxu"] = "乱世之观者",
  ["illustrator:ofl2__godjiaxu"] = "小牛",
}

generals.ofl__wangyun = General:new(extension, "ofl__wangyun", "qun", 3)
generals.ofl__wangyun:addSkills { "ofl__lianji", "ofl__moucheng" }
generals.ofl__wangyun.headnote = "E0026群雄逐鹿"
Fk:loadTranslationTable{
  ["ofl__wangyun"] = "王允",
  ["#ofl__wangyun"] = "计随鞘出",
  ["illustrator:ofl__wangyun"] = "YanBai",
}

--E0033兵合一处
generals.es__caocao = General:new(extension, "es__caocao", "qun", 4)
generals.es__caocao:addSkills { "xiandao", "sancai", "yibing" }
generals.es__caocao.headnote = "E0033兵合一处"
Fk:loadTranslationTable{
  ["es__caocao"] = "曹操",
  ["#es__caocao"] = "谯水击蛟",
  ["illustrator:es__caocao"] = "墨心绘意",
}

generals.longyufei = General:new(extension, "longyufei", "shu", 3, 4, General.Female)
generals.longyufei:addSkills { "longyi", "zhenjue" }
generals.longyufei.headnote = "E0034暗金豪华版，S1044标准版·龙魂"
Fk:loadTranslationTable{
  ["longyufei"] = "龙羽飞",
  ["#longyufei"] = "将星之魂",
  ["illustrator:longyufei"] = "DH",
}

--E0035问鼎中原：
--宛城之战：神曹操 神典韦 曹安民
generals.ofl__caoanmin = General:new(extension, "ofl__caoanmin", "wei", 4)
generals.ofl__caoanmin:addSkills { "ofl__kuishe" }
generals.ofl__caoanmin.headnote = "E0035问鼎中原"
Fk:loadTranslationTable{
  ["ofl__caoanmin"] = "曹安民",
  ["#ofl__caoanmin"] = "瓢取祸水",
  ["illustrator:ofl__caoanmin"] = "柏桦",
}

--下邳之战：神吕布
--官渡之战：神淳于琼 神张郃 神袁绍
--赤壁之战：神周瑜 神诸葛亮 神曹操 郭嘉

--E0037三分天下：
--渭水之战：神马超 神许褚
--合肥之战：神张辽
generals.ofl__godzhangliao = General:new(extension, "ofl__godzhangliao", "god", 4)
generals.ofl__godzhangliao:addSkills { "ofl__tuji", "ofl__weizhen", "ofl__zhiti" }
generals.ofl__godzhangliao.headnote = "E0037三分天下"
Fk:loadTranslationTable{
  ["ofl__godzhangliao"] = "神张辽",
  ["#ofl__godzhangliao"] = "威震逍遥津",
  ["illustrator:ofl__godzhangliao"] = "Thinking",
}

--襄樊之战：神关羽 神于禁
--定军山之战：神法正 神黄忠 神张郃 神夏侯渊
--国战转身份：孟达
generals.ofl__mengda = General:new(extension, "ofl__mengda", "wei", 4)
generals.ofl__mengda.subkingdom = "shu"
generals.ofl__mengda:addSkills { "ofl__qiuan", "ofl__liangfan" }
generals.ofl__mengda.headnote = "E0037三分天下"
Fk:loadTranslationTable{
  ["ofl__mengda"] = "孟达",
  ["#ofl__mengda"] = "怠军反复",
  ["designer:ofl__mengda"] = "韩旭",
  ["illustrator:ofl__mengda"] = "张帅",

  ["~ofl__mengda"] = "吾一生寡信，今报应果然来矣……",
}

--E0041分久必合：
--夷陵之战
--南中平定战：一堆神孟获？
--五丈原之战：神诸葛亮 神司马懿
--天下一统：
generals.ofl__wenyang = General:new(extension, "ofl__wenyang", "wei", 4)
generals.ofl__wenyang.subkingdom = "wu"
generals.ofl__wenyang:addSkills { "quedi", "ofl__choujue", "ofl__chuifeng", "ofl__chongjian" }
generals.ofl__wenyang.headnote = "E0041分久必合"
Fk:loadTranslationTable{
  ["ofl__wenyang"] = "文鸯",
  ["#ofl__wenyang"] = "独骑破军",
  ["illustrator:ofl__wenyang"] = "biou09",
}

generals.ofl__wenqin = General:new(extension, "ofl__wenqin", "wei", 4)
generals.ofl__wenqin.subkingdom = "wu"
generals.ofl__wenqin:addSkills { "ofl__jinfa" }
generals.ofl__wenqin.headnote = "E0041分久必合"
Fk:loadTranslationTable{
  ["ofl__wenqin"] = "文钦",
  ["#ofl__wenqin"] = "勇而无算",
  ["designer:ofl__wenqin"] = "逍遥鱼叔",
  ["illustrator:ofl__wenqin"] = "匠人绘-零二",

  ["~ofl__wenqin"] = "公休，汝这是何意，呃……",
}

generals.ofl2__zhonghui = General:new(extension, "ofl2__zhonghui", "wei", 4)
generals.ofl2__zhonghui:addSkills { "ofl__quanji", "ofl__paiyi" }
generals.ofl2__zhonghui.headnote = "E0041分久必合"
Fk:loadTranslationTable{
  ["ofl2__zhonghui"] = "钟会",
  ["#ofl2__zhonghui"] = "桀骜的野心家",
  ["illustrator:ofl2__zhonghui"] = "磐蒲",

  ["~ofl2__zhonghui"] = "吾机关算尽，却还是棋错一着……",
}

generals.ofl__sunchen = General:new(extension, "ofl__sunchen", "wu", 4)
generals.ofl__sunchen:addSkills { "ofl__shilus", "ofl__xiongnve" }
generals.ofl__sunchen.headnote = "E0041分久必合"
Fk:loadTranslationTable{
  ["ofl__sunchen"] = "孙綝",
  ["#ofl__sunchen"] = "食髓的朝堂客",
  ["designer:ofl__sunchen"] = "逍遥鱼叔",
  ["illustrator:ofl__sunchen"] = "depp",

  ["~ofl__sunchen"] = "愿陛下念臣昔日之功，陛下？陛下！！",
}

--E0051尊享版2023：曹丕 李严 关银屏 马云騄 黄权 周泰 范疆张达
generals.ofl__duji = General:new(extension, "ofl__duji", "wei", 3)
generals.ofl__duji:addSkills { "ofl__yingshi", "ofl__andong" }
generals.ofl__duji.headnote = "E0051尊享版2023"
Fk:loadTranslationTable{
  ["ofl__duji"] = "杜畿",
  ["#ofl__duji"] = "卧镇京畿",
  ["illustrator:ofl__duji"] = "梦回唐朝_久吉",

  ["~ofl__duji"] = "先帝拔臣于微末，虽涉九死之地，亦不足相报。",
}

generals.ofl__xiahouxuan = General:new(extension, "ofl__xiahouxuan", "wei", 3)
generals.ofl__xiahouxuan:addSkills { "ofl__huanfu", "qingyix", "zeyue" }
generals.ofl__xiahouxuan.headnote = "E0051尊享版2023"
Fk:loadTranslationTable{
  ["ofl__xiahouxuan"] = "夏侯玄",
  ["#ofl__xiahouxuan"] = "明皎月影",
  ["illustrator:ofl__xiahouxuan"] = "MUMU",

  ["$qingyix_ofl__xiahouxuan1"] = "今大将军执政，各位何不各抒己见，以言其得失？",
  ["$qingyix_ofl__xiahouxuan2"] = "天下未定，诸位当为国而进忠言，不可缄默不语。",
  ["$zeyue_ofl__xiahouxuan1"] = "官才用人，国之柄也，岂可授予他人？",
  ["$zeyue_ofl__xiahouxuan2"] = "世家豪族把持朝政，实乃国之巨蠹！",
  ["~ofl__xiahouxuan"] = "吾岂苟存自客于寇虏乎？",
}

--E8002全武将大合集奢华版（神张飞盒）
generals.ofl__guozhao = General:new(extension, "ofl__guozhao", "wei", 3, 3, General.Female)
generals.ofl__guozhao:addSkills { "ofl__pianchong", "ofl__zunwei" }
generals.ofl__guozhao.headnote = "E8002全武将大合集奢华版"
Fk:loadTranslationTable{
  ["ofl__guozhao"] = "郭照",
  ["#ofl__guozhao"] = "碧海青天",
  ["illustrator:ofl__guozhao"] = "张晓溪",

  ["~ofl__guozhao"] = "红袖揾烟雨，泪尽垂青花。",
}

generals.zhouji = General:new(extension, "zhouji", "wu", 3, 3, General.Female)
generals.zhouji:addSkills { "ofl__yanmouz", "ofl__zhanyan", "ofl__yuhuo" }
generals.zhouji.headnote = "E14001T至宝"
Fk:loadTranslationTable{
  ["zhouji"] = "周姬",
  ["#zhouji"] = "江东的红莲",
  ["illustrator:zhouji"] = "xerez",
}

generals.ehuan = General:new(extension, "ehuan", "qun", 5)
generals.ehuan.subkingdom = "shu"
generals.ehuan:addSkills { "ofl__diwan", "ofl__suiluan", "ofl__conghan" }
generals.ehuan.headnote = "E14001T匡鼎炎汉"
Fk:loadTranslationTable{
  ["ehuan"] = "鄂焕",
  ["#ehuan"] = "牙门汉将",
  ["illustrator:ehuan"] = "小强",
}

generals.ofl__zhonghui = General:new(extension, "ofl__zhonghui", "wei", 4)
generals.ofl__zhonghui:addSkills { "mouchuan", "zizhong", "jizun", "qingsuan" }
generals.ofl__zhonghui:addRelatedSkills { "daohe", "zhiyiz" }
generals.ofl__zhonghui.headnote = "E7005T决战巅峰"
Fk:loadTranslationTable{
  ["ofl__zhonghui"] = "钟会",
  ["#ofl__zhonghui"] = "统定河山",
  ["cv:ofl__zhonghui"] = "Kazami（新月杀原创）",
  ["illustrator:ofl__zhonghui"] = "黯荧岛工作室",

  ["~ofl__zhonghui"] = "时也…命也…",
}

--E5003T荆襄风云
generals.ofl__zhouyu = General:new(extension, "ofl__zhouyu", "wu", 3)
generals.ofl__zhouyu:addSkills { "ofl__xiongzi", "ofl__zhanyanz" }
generals.ofl__zhouyu.headnote = "E5003T荆襄风云"
Fk:loadTranslationTable{
  ["ofl__zhouyu"] = "周瑜",
  ["#ofl__zhouyu"] = "雄姿英发",
  ["illustrator:ofl__zhouyu"] = "魔奇士",
}

generals.godliubiao = General:new(extension, "godliubiao", "god", 4)
generals.godliubiao:addSkills { "xiongju", "fujing", "yongrong" }
generals.godliubiao.headnote = "E5003T荆襄风云"
Fk:loadTranslationTable{
  ["godliubiao"] = "神刘表",
  ["#godliubiao"] = "称雄荆襄",
  ["illustrator:godliubiao"] = "六道目",
}

generals.godcaoren = General:new(extension, "godcaoren", "god", 4)
generals.godcaoren:addSkills { "ofl__jushou" }
generals.godcaoren:addRelatedSkills { "ofl__tuwei" }
generals.godcaoren.headnote = "E5003T荆襄风云"
Fk:loadTranslationTable{
  ["godcaoren"] = "神曹仁",
  ["#godcaoren"] = "征南将军",
  ["illustrator:godcaoren"] = "凡果",
}

generals.tianchuan = General:new(extension, "tianchuan", "qun", 3, 3, General.Female)
generals.tianchuan:addSkills { "huying", "qianjing", "bianchi" }
generals.tianchuan.headnote = "E1002T全武将尊享"
Fk:loadTranslationTable{
  ["tianchuan"] = "田钏",
  ["#tianchuan"] = "潜行之狐",
  ["illustrator:tianchuan"] = "苍月白龙",
}

generals.ofl__jiling = General:new(extension, "ofl__jiling", "qun", 4)
generals.ofl__jiling:addSkills { "ofl__shuangren" }
generals.ofl__jiling.headnote = "E3005至臻·权谋"
Fk:loadTranslationTable{
  ["ofl__jiling"] = "纪灵",
  ["#ofl__jiling"] = "仲家的主将",
  ["illustrator:ofl__jiling"] = "铁杵文化",

  ["~ofl__jiling"] = "穷寇兵强势猛，拂意实在不敌呀……",
}

generals.penghu = General:new(extension, "penghu", "qun", 5)
generals.penghu:addSkills { "juqian", "zhepo", "yizhongp" }
generals.penghu:addRelatedSkill("insurrectionary&")
generals.penghu.headnote = "E24001T至臻·侠客行"
Fk:loadTranslationTable{
  ["penghu"] = "彭虎",
  ["#penghu"] = "鄱阳风浪",
  ["illustrator:penghu"] = "花弟",
}

generals.pengqi = General:new(extension, "pengqi", "qun", 3, 3, General.Female)
generals.pengqi:addSkills { "jushoup", "liaoluan", "huaying", "ofl__jizhong" }
generals.pengqi:addRelatedSkill("insurrectionary&")
generals.pengqi.headnote = "E24001T至臻·侠客行"
Fk:loadTranslationTable{
  ["pengqi"] = "彭绮",
  ["#pengqi"] = "百花缭乱",
  ["illustrator:pengqi"] = "xerez",
}

generals.luoli = General:new(extension, "luoli", "qun", 4)
generals.luoli:addSkills { "juluan", "xianxing" }
generals.luoli:addRelatedSkill("insurrectionary&")
generals.luoli.headnote = "E24001T至臻·侠客行"
Fk:loadTranslationTable{
  ["luoli"] = "罗厉",
  ["#luoli"] = "庐江义寇",
  ["illustrator:luoli"] = "红字虾",
}

generals.zulang = General:new(extension, "zulang", "qun", 5)
generals.zulang.subkingdom = "wu"
generals.zulang:addSkills { "xijun", "haokou", "ronggui" }
generals.zulang:addRelatedSkill("insurrectionary&")
generals.zulang.headnote = "E24001T至臻·侠客行"
Fk:loadTranslationTable{
  ["zulang"] = "祖郎",
  ["#zulang"] = "抵力坚存",
  ["illustrator:zulang"] = "XXX",
}

generals.cuilian = General:new(extension, "cuilian", "qun", 4)
generals.cuilian:addSkills { "tanlu", "jubian" }
generals.cuilian.headnote = "E24001T至臻·侠客行"
Fk:loadTranslationTable{
  ["cuilian"] = "崔廉",
  ["#cuilian"] = "缚树行鞭",
  ["illustrator:cuilian"] = "花花",
}

generals.ofl__xushu = General:new(extension, "ofl__xushu", "qun", 3)
generals.ofl__xushu.subkingdom = "shu"
generals.ofl__xushu:addSkills { "bimeng", "zhue", "fuzhux" }
generals.ofl__xushu.headnote = "E24001T至臻·侠客行"
Fk:loadTranslationTable{
  ["ofl__xushu"] = "单福",
  ["#ofl__xushu"] = "忠孝万全",
  ["illustrator:ofl__xushu"] = "木美人",
}

generals.ofl__godzhangjiao = General:new(extension, "ofl__godzhangjiao", "god", 4)
generals.ofl__godzhangjiao:addSkills { "ofl__mingdao", "ofl__zhongfu", "ofl__dangjing", "ofl__sanshou" }
generals.ofl__godzhangjiao.headnote = "E5002汉末风云"
Fk:loadTranslationTable{
  ["ofl__godzhangjiao"] = "神张角",
  ["#ofl__godzhangjiao"] = "庇佑万千",
  ["illustrator:ofl__godzhangjiao"] = "鬼画府",
}

generals.ofl__godzhangbao = General:new(extension, "ofl__godzhangbao", "god", 4)
generals.ofl__godzhangbao.hidden = true
generals.ofl__godzhangbao:addSkills { "ofl__zhouyuan", "ofl__zhaobing", "ofl__sanshou" }
generals.ofl__godzhangbao.headnote = "E5002汉末风云"
Fk:loadTranslationTable{
  ["ofl__godzhangbao"] = "神张宝",
  ["#ofl__godzhangbao"] = "庇佑万千",
  ["illustrator:ofl__godzhangbao"] = "NOVART",

  ["~ofl__godzhangbao"] = "咒术！为何失灵了？",
}

generals.ofl__godzhangliang = General:new(extension, "ofl__godzhangliang", "god", 4)
generals.ofl__godzhangliang.hidden = true
generals.ofl__godzhangliang:addSkills { "ofl__jijun", "ofl__fangtong", "ofl__sanshou" }
generals.ofl__godzhangliang.headnote = "E5002汉末风云"
Fk:loadTranslationTable{
  ["ofl__godzhangliang"] = "神张梁",
  ["#ofl__godzhangliang"] = "庇佑万千",
  ["illustrator:ofl__godzhangliang"] = "王强",

  ["~ofl__godzhangliang"] = "黄天之道，哥哥我们错了吗？",
}

generals.yanzhengh = General:new(extension, "yanzhengh", "qun", 4)
generals.yanzhengh:addSkills { "ofl__dishi", "ofl__xianxiang" }
generals.yanzhengh.headnote = "E5002汉末风云"
Fk:loadTranslationTable{
  ["yanzhengh"] = "严政",
  ["#yanzhengh"] = "献首投降",
  ["illustrator:yanzhengh"] = "Xiaoi",
}

generals.bairao = General:new(extension, "bairao", "qun", 5)
generals.bairao:addSkills { "ofl__huoyin" }
generals.bairao.headnote = "E5002汉末风云"
Fk:loadTranslationTable{
  ["bairao"] = "白绕",
  ["#bairao"] = "黑山寇首",
  ["illustrator:bairao"] = "君桓文化",
}

generals.busi = General:new(extension, "busi", "qun", 4, 6)
generals.busi:addSkills { "ofl__weiluan", "ofl__tianpan", "ofl__gaiming" }
generals.busi.headnote = "E5002汉末风云"
Fk:loadTranslationTable{
  ["busi"] = "卜巳",
  ["#busi"] = "黄巾渠帅",
  ["illustrator:busi"] = "千秋秋千秋",
}

generals.suigu = General:new(extension, "suigu", "qun", 5)
generals.suigu:addSkills { "ofl__tunquan", "ofl__qianjun" }
generals.suigu:addRelatedSkill("luanji")
generals.suigu.headnote = "E5002汉末风云"
Fk:loadTranslationTable{
  ["suigu"] = "眭固",
  ["#suigu"] = "兔入犬城",
  ["illustrator:suigu"] = "君桓文化",
}

generals.heman = General:new(extension, "heman", "qun", 5, 6)
generals.heman:addSkills { "ofl__juedian", "ofl__nitian" }
generals.heman.headnote = "E5002汉末风云"
Fk:loadTranslationTable{
  ["heman"] = "何曼",
  ["#heman"] = "截天夜叉",
  ["illustrator:heman"] = "千秋秋千秋",
}

generals.yudu = General:new(extension, "yudu", "qun", 4)
generals.yudu:addSkills { "ofl__dafu", "ofl__jipin" }
generals.yudu.headnote = "E5002汉末风云"
Fk:loadTranslationTable{
  ["yudu"] = "于毒",
  ["#yudu"] = "劫富济贫",
  ["illustrator:yudu"] = "MUMU1",
}

generals.tangzhou = General:new(extension, "tangzhou", "qun", 4)
generals.tangzhou:addSkills { "ofl__jukou", "ofl__shupan" }
generals.tangzhou.headnote = "E5002汉末风云"
Fk:loadTranslationTable{
  ["tangzhou"] = "唐周",
  ["#tangzhou"] = "叛门高足",
  ["illustrator:tangzhou"] = "sky",
}

generals.bocai = General:new(extension, "bocai", "qun", 5)
generals.bocai:addSkills { "ofl__kunjun", "ofl__yingzhan", "ofl__cuiji" }
generals.bocai.headnote = "E5002汉末风云"
Fk:loadTranslationTable{
  ["bocai"] = "波才",
  ["#bocai"] = "黄巾执首",
  ["illustrator:bocai"] = "HOOO",
}

generals.chengyuanzhi = General:new(extension, "chengyuanzhi", "qun", 5)
generals.chengyuanzhi:addSkills { "ofl__wuxiao", "ofl__qianhu" }
generals.chengyuanzhi.headnote = "E5002汉末风云"
Fk:loadTranslationTable{
  ["chengyuanzhi"] = "程远志",
  ["#chengyuanzhi"] = "逆流而动",
  ["illustrator:chengyuanzhi"] = "HOOO",
}

generals.dengmao = General:new(extension, "dengmao", "qun", 5)
generals.dengmao:addSkills { "ofl__paoxi", "ofl__houying" }
generals.dengmao.headnote = "E5002汉末风云"
Fk:loadTranslationTable{
  ["dengmao"] = "邓茂",
  ["#dengmao"] = "逆势而行",
  ["illustrator:dengmao"] = "HOOO",
}

generals.gaosheng = General:new(extension, "gaosheng", "qun", 5)
generals.gaosheng:addSkills { "ofl__xiongshi", "ofl__difeng" }
generals.gaosheng.headnote = "E5002汉末风云"
Fk:loadTranslationTable{
  ["gaosheng"] = "高升",
  ["#gaosheng"] = "地公之锋",
  ["illustrator:gaosheng"] = "livsinno",
}

generals.fuyun = General:new(extension, "fuyun", "qun", 4)
generals.fuyun:addSkills { "ofl__suiqu", "ofl__yure" }
generals.fuyun.headnote = "E5002汉末风云"
Fk:loadTranslationTable{
  ["fuyun"] = "浮云",
  ["#fuyun"] = "黄天末代",
  ["illustrator:fuyun"] = "苍月白龙",
}

generals.taosheng = General:new(extension, "taosheng", "qun", 5)
generals.taosheng:addSkills { "ofl__zainei", "ofl__hanwei" }
generals.taosheng.headnote = "E5002汉末风云"
Fk:loadTranslationTable{
  ["taosheng"] = "陶升",
  ["#taosheng"] = "平汉将军",
  ["illustrator:taosheng"] = "佚名",
}

generals.godhuangfusong = General:new(extension, "godhuangfusong", "god", 4)
generals.godhuangfusong:addSkills { "ofl__shice", "ofl__podai" }
generals.godhuangfusong.headnote = "E5002汉末风云"
Fk:loadTranslationTable{
  ["godhuangfusong"] = "神皇甫嵩",
  ["#godhuangfusong"] = "厥功至伟",
  ["cv:godhuangfusong"] = "妙啊（新月杀原创）",
  ["illustrator:godhuangfusong"] = "王宁",

  ["~godhuangfusong"] = "天下大乱兮市如墟，忠臣如梦兮复如痴。",
}

generals.godluzhi = General:new(extension, "godluzhi", "god", 4)
generals.godluzhi:addSkills { "ofl__zhengan", "ofl__weizhu", "ofl__zequan" }
generals.godluzhi.headnote = "E5002汉末风云"
Fk:loadTranslationTable{
  ["godluzhi"] = "神卢植",
  ["#godluzhi"] = "鏖战广宗",
  ["illustrator:godluzhi"] = "聚一_L.M.YANG",
}

generals.godzhujun = General:new(extension, "godzhujun", "god", 4)
generals.godzhujun:addSkills { "ofl__cheji", "ofl__jicui", "ofl__kuixiang" }
generals.godzhujun.headnote = "E5002汉末风云"
Fk:loadTranslationTable{
  ["godzhujun"] = "神朱儁",
  ["#godzhujun"] = "围师必阙",
  ["illustrator:godzhujun"] = "鱼仔",
}

generals.ofl__zhangrang = General:new(extension, "ofl__zhangrang", "qun", 4)
generals.ofl__zhangrang:addSkills { "ofl__taoluan", "changshi" }
generals.ofl__zhangrang.headnote = "E11001T蛇年限定礼盒"
Fk:loadTranslationTable{
  ["ofl__zhangrang"] = "张让",
  ["#ofl__zhangrang"] = "妄尊帝父",
  ["illustrator:ofl__zhangrang"] = "凡果",
}

generals.ofl__zhaozhong = General:new(extension, "ofl__zhaozhong", "qun", 4)
generals.ofl__zhaozhong:addSkills { "ofl__chiyan", "changshi" }
generals.ofl__zhaozhong.headnote = "E11001T蛇年限定礼盒"
Fk:loadTranslationTable{
  ["ofl__zhaozhong"] = "赵忠",
  ["#ofl__zhaozhong"] = "宦刑啄心",
  ["illustrator:ofl__zhaozhong"] = "凡果",
}

generals.ofl__sunzhang = General:new(extension, "ofl__sunzhang", "qun", 4)
generals.ofl__sunzhang:addSkills { "ofl__zimou", "changshi" }
generals.ofl__sunzhang.headnote = "E11001T蛇年限定礼盒"
Fk:loadTranslationTable{
  ["ofl__sunzhang"] = "孙璋",
  ["#ofl__sunzhang"] = "唯利是从",
  ["illustrator:ofl__sunzhang"] = "鬼画府",
}

generals.ofl__bilan = General:new(extension, "ofl__bilan", "qun", 4)
generals.ofl__bilan:addSkills { "ofl__picai", "changshi" }
generals.ofl__bilan.headnote = "E11001T蛇年限定礼盒"
Fk:loadTranslationTable{
  ["ofl__bilan"] = "毕岚",
  ["#ofl__bilan"] = "糜财广筑",
  ["illustrator:ofl__bilan"] = "鬼画府",
}

generals.ofl__xiayun = General:new(extension, "ofl__xiayun", "qun", 4)
generals.ofl__xiayun:addSkills { "ofl__yaozhuo", "changshi" }
generals.ofl__xiayun.headnote = "E11001T蛇年限定礼盒"
Fk:loadTranslationTable{
  ["ofl__xiayun"] = "夏恽",
  ["#ofl__xiayun"] = "言蔽朝尊",
  ["illustrator:ofl__xiayun"] = "铁杵文化",
}

generals.ofl__lisong = General:new(extension, "ofl__lisong", "qun", 4)
generals.ofl__lisong:addSkills { "ofl__kuiji", "changshi" }
generals.ofl__lisong:addRelatedSkill("chouhai")
generals.ofl__lisong.headnote = "E11001T蛇年限定礼盒"
Fk:loadTranslationTable{
  ["ofl__lisong"] = "栗嵩",
  ["#ofl__lisong"] = "道察衕异",
  ["illustrator:ofl__lisong"] = "铁杵文化",
}

generals.ofl__duangui = General:new(extension, "ofl__duangui", "qun", 4)
generals.ofl__duangui:addSkills { "ofl__chihe", "changshi" }
generals.ofl__duangui.headnote = "E11001T蛇年限定礼盒"
Fk:loadTranslationTable{
  ["ofl__duangui"] = "段珪",
  ["#ofl__duangui"] = "断途避圣",
  ["illustrator:ofl__duangui"] = "鬼画府",
}

generals.ofl__guosheng = General:new(extension, "ofl__guosheng", "qun", 4)
generals.ofl__guosheng:addSkills { "ofl__niqu", "changshi" }
generals.ofl__duangui.headnote = "E11001T蛇年限定礼盒"
Fk:loadTranslationTable{
  ["ofl__guosheng"] = "郭胜",
  ["#ofl__guosheng"] = "诱杀党朋",
  ["illustrator:ofl__guosheng"] = "鬼画府",
}

generals.ofl__gaowang = General:new(extension, "ofl__gaowang", "qun", 4)
generals.ofl__gaowang:addSkills { "ofl__miaoyu", "changshi" }
generals.ofl__gaowang.headnote = "E11001T蛇年限定礼盒"
Fk:loadTranslationTable{
  ["ofl__gaowang"] = "高望",
  ["#ofl__gaowang"] = "蛇蝎为药",
  ["illustrator:ofl__gaowang"] = "鬼画府",
}

generals.ofl__hankui = General:new(extension, "ofl__hankui", "qun", 4)
generals.ofl__hankui:addSkills { "ofl__xiaolu", "changshi" }
generals.ofl__hankui.headnote = "E11001T蛇年限定礼盒"
Fk:loadTranslationTable{
  ["ofl__hankui"] = "韩悝",
  ["#ofl__hankui"] = "贪财好贿",
  ["illustrator:ofl__hankui"] = "鬼画府",
}

generals.yongkai = General:new(extension, "yongkai", "shu", 5)
generals.yongkai:addSkills { "xiaofany", "jiaohu", "quanpan", "huoluan" }
generals.yongkai.headnote = "E7006T肃问"
Fk:loadTranslationTable{
  ["yongkai"] = "雍闿",
  ["#yongkai"] = "惑动南中",
  ["illustrator:yongkai"] = "HIM",
}

generals.ofl__chezhou = General:new(extension, "ofl__chezhou", "wei", 6)
generals.ofl__chezhou:addSkills { "anmou", "tousuan" }
generals.ofl__chezhou.headnote = "E7006T肃问"
Fk:loadTranslationTable{
  ["ofl__chezhou"] = "车胄",
  ["#ofl__chezhou"] = "反受其害",
  ["illustrator:ofl__chezhou"] = "YanBai",
}

generals.caocaoyuanshao = General:new(extension, "caocaoyuanshao", "qun", 4)
generals.caocaoyuanshao.subkingdom = "wei"
generals.caocaoyuanshao:addSkills { "guibei", "jiechu", "daojue", "tuonan" }
generals.caocaoyuanshao:addRelatedSkills { "ofl__qingzheng", "ofl__zhian", "feiying", "ol_ex__hujia", "shenliy", "ofl__zhuni", "shishouy" }
generals.caocaoyuanshao.headnote = "E150017至臻-全武将典藏"
Fk:loadTranslationTable{
  ["caocaoyuanshao"] = "曹操袁绍",
  ["#caocaoyuanshao"] = "总角之交",
  ["illustrator:caocaoyuanshao"] = "荆芥",
}

generals.quexiaojiang = General:new(extension, "quexiaojiang", "qun", 4)
generals.quexiaojiang:addSkills { "yingzhen", "yuanjue", "aoyong" }
generals.quexiaojiang:addRelatedSkill("tongkai")
generals.quexiaojiang.headnote = "E9004T全武将太虚幻境"
Fk:loadTranslationTable{
  ["quexiaojiang"] = "曲阿小将",
  ["#quexiaojiang"] = "神人何惧",
  ["illustrator:quexiaojiang"] = "荆芥",
  ["cv:quexiaojiang"] = "notify（新月杀原创）",

  ["~quexiaojiang"] = "壮士同仇，唯死而已。",
}

generals.ofl__lijue = General:new(extension, "ofl__lijue", "qun", 6)
generals.ofl__lijue:addSkills { "cuixi", "jujun" }
generals.ofl__lijue.headnote = "E5003长安风云"
Fk:loadTranslationTable{
  ["ofl__lijue"] = "李傕",
  ["#ofl__lijue"] = "奸谋恶勇",
  ["illustrator:ofl__lijue"] = "梦回唐朝",
}

generals.ofl__guosi = General:new(extension, "ofl__guosi", "qun", 4)
generals.ofl__guosi:addSkills { "sixi", "lvedao" }
generals.ofl__guosi:addRelatedSkill("ofl__bixiong")
generals.ofl__guosi.headnote = "E5003长安风云"
Fk:loadTranslationTable{
  ["ofl__guosi"] = "郭汜",
  ["#ofl__guosi"] = "党豺为虐",
  ["illustrator:ofl__guosi"] = "MUMU",
}

generals.ofl__godjiaxu = General:new(extension, "ofl__godjiaxu", "god", 3)
generals.ofl__godjiaxu:addSkills { "sangluan", "shibaoj", "chuce", "longmu" }
generals.ofl__godjiaxu.headnote = "E5003长安风云"
Fk:loadTranslationTable{
  ["ofl__godjiaxu"] = "神贾诩",
  ["#ofl__godjiaxu"] = "丧尸出笼",
  ["illustrator:ofl__godjiaxu"] = "一品咸鱼堡",
}

generals.ofl__zombie = General:new(extension, "ofl__zombie", "qun", 2, 4)
generals.ofl__zombie.hidden = true
generals.ofl__zombie:addSkills { "shibian", "ganran" }
generals.ofl__zombie.headnote = "E5003长安风云"
Fk:loadTranslationTable{
  ["ofl__zombie"] = "丧尸",
  ["#ofl__zombie"] = "丧尸围城",
  ["illustrator:ofl__zombie"] = "YanBai",
}

generals.ofl2__wangyun = General:new(extension, "ofl2__wangyun", "qun", 3)
generals.ofl2__wangyun:addSkills { "ofl2__lianji", "ofl2__moucheng" }
generals.ofl2__wangyun:addRelatedSkill("ofl2__jingong")
generals.ofl2__wangyun.headnote = "E5003长安风云"
Fk:loadTranslationTable{
  ["ofl2__wangyun"] = "王允",
  ["#ofl2__wangyun"] = "忠魂不泯",
  ["illustrator:ofl2__wangyun"] = "L",
}

generals.ofl2__lvbu = General:new(extension, "ofl2__lvbu", "qun", 5)
generals.ofl2__lvbu:addSkills { "wushuang", "ofl2__liyu" }
generals.ofl2__lvbu.headnote = "E5003长安风云"
Fk:loadTranslationTable{
  ["ofl2__lvbu"] = "吕布",
  ["#ofl2__lvbu"] = "武的化身",
  ["illustrator:ofl2__lvbu"] = "SY",
}

generals.ofl__godcaocao = General:new(extension, "ofl__godcaocao", "god", 4)
generals.ofl__godcaocao:addSkills { "zhaozhao", "jieao" }
generals.ofl__godcaocao.headnote = "E5003长安风云"
Fk:loadTranslationTable{
  ["ofl__godcaocao"] = "神曹操",
  ["#ofl__godcaocao"] = "挟圣诏王",
  ["illustrator:ofl__godcaocao"] = "云涯",
}

generals.godlijueguosi = General:new(extension, "godlijueguosi", "god", 5)
generals.godlijueguosi:addSkills { "weiju", "sixiong" }
generals.godlijueguosi.headnote = "E5003长安风云"
Fk:loadTranslationTable{
  ["godlijueguosi"] = "神李傕郭汜",
  ["#godlijueguosi"] = "祸乱长安",
  ["illustrator:godlijueguosi"] = "旭",
}

generals.ofl__fanchou = General:new(extension, "ofl__fanchou", "qun", 4)
generals.ofl__fanchou:addSkills { "xingwei", "qianmu" }
generals.ofl__fanchou.headnote = "E5003长安风云"
Fk:loadTranslationTable{
  ["ofl__fanchou"] = "樊稠",
  ["#ofl__fanchou"] = "庸生变难",
  ["illustrator:ofl__fanchou"] = "三道纹",
}

generals.ofl__zhangji = General:new(extension, "ofl__zhangji", "qun", 4)
generals.ofl__zhangji:addSkills { "silve", "suibian" }
generals.ofl__zhangji.headnote = "E5003长安风云"
Fk:loadTranslationTable{
  ["ofl__zhangji"] = "张济",
  ["#ofl__zhangji"] = "武威雄豪",
  ["illustrator:ofl__zhangji"] = "君桓文化",
}

generals.godwangyun = General:new(extension, "godwangyun", "god", 4)
generals.godwangyun:addSkills { "anchao", "yurong", "ofl__dingxi" }
generals.godwangyun.headnote = "E5003长安风云"
Fk:loadTranslationTable{
  ["godwangyun"] = "神王允",
  ["#godwangyun"] = "百策御军",
  ["illustrator:godwangyun"] = "alien",
}

generals.ofl__liuxie = General:new(extension, "ofl__liuxie", "qun", 3)
generals.ofl__liuxie:addSkills { "tianzel", "zhaoyuan", "os__zhuiting" }
generals.ofl__liuxie.headnote = "E7009T君霸天下"
Fk:loadTranslationTable{
  ["ofl__liuxie"] = "刘协",
  ["#ofl__liuxie"] = "汉献帝",
  ["illustrator:ofl__liuxie"] = "鬼画府",

  ["~ofl__liuxie"] = "傀儡天子，生不如死……",
}

generals.ofl__liuhong = General:new(extension, "ofl__liuhong", "qun", 4)
generals.ofl__liuhong:addSkills { "ofl__gezhi", "ofl__julian" }
generals.ofl__liuhong.headnote = "E7009T君霸天下"
Fk:loadTranslationTable{
  ["ofl__liuhong"] = "刘宏",
  ["#ofl__liuhong"] = "汉灵帝",
  ["illustrator:ofl__liuhong"] = "匠人绘",

  ["~ofl__liuhong"] = "时也！命也！",
}

generals.ofl2__yuanshao = General:new(extension, "ofl2__yuanshao", "qun", 4)
generals.ofl2__yuanshao:addSkills { "hefa", "xueyi" }
generals.ofl2__yuanshao.headnote = "E7009T君霸天下"
Fk:loadTranslationTable{
  ["ofl2__yuanshao"] = "袁绍",
  ["#ofl2__yuanshao"] = "高贵的名门",
  ["illustrator:ofl2__yuanshao"] = "琛·美弟奇",

  ["$xueyi_ofl2__yuanshao1"] = "世受皇恩，威震海内！",
  ["$xueyi_ofl2__yuanshao2"] = "四世三公，名冠天下！",
  ["~ofl2__yuanshao"] = "我袁家，怎么会输！",
}

generals.ofl__zhangjiao = General:new(extension, "ofl__zhangjiao", "qun", 3)
generals.ofl__zhangjiao:addSkills { "huanlei", "xiandaoz", "huangtian" }
generals.ofl__zhangjiao.headnote = "E7009T君霸天下"
Fk:loadTranslationTable{
  ["ofl__zhangjiao"] = "张角",
  ["#ofl__zhangjiao"] = "天公将军",
  ["illustrator:ofl__zhangjiao"] = "鬼画府",

  ["~ofl__zhangjiao"] = "时也！命也！",
}

generals.ofl__sunquan = General:new(extension, "ofl__sunquan", "wu", 4)
generals.ofl__sunquan:addSkills { "henglv", "jiuyuan" }
generals.ofl__sunquan.headnote = "E7009T君霸天下"
Fk:loadTranslationTable{
  ["ofl__sunquan"] = "孙权",
  ["#ofl__sunquan"] = "年轻的贤君",
  ["illustrator:ofl__sunquan"] = "大鬼",

  ["$jiuyuan_ofl__sunquan1"] = "爱卿勇烈，孤心甚安。",
  ["$jiuyuan_ofl__sunquan2"] = "幸得爱卿，不至有危。",
  ["~ofl__sunquan"] = "英雄志远，奈何坎坷难行……",
}

generals.ofl__sunce = General:new(extension, "ofl__sunce", "wu", 4)
generals.ofl__sunce:addSkills { "ofl__jiang", "zhiyang", "zhiba" }
generals.ofl__sunce.headnote = "E7009T君霸天下"
Fk:loadTranslationTable{
  ["ofl__sunce"] = "孙策",
  ["#ofl__sunce"] = "江东的小霸王",
  ["illustrator:ofl__sunce"] = "M云涯",

  ["$zhiba_ofl__sunce1"] = "酣战强敌，正在此时！",
  ["$zhiba_ofl__sunce2"] = "将军要与我切磋武艺？有趣。",
  ["~ofl__sunce"] = "仲谋，孙家基业，就要靠你了……",
}

generals.ofl2__caopi = General:new(extension, "ofl2__caopi", "wei", 3)
generals.ofl2__caopi:addSkills { "cuanzun", "liufangc", "songwei" }
generals.ofl2__caopi.headnote = "E7009T君霸天下"
Fk:loadTranslationTable{
  ["ofl2__caopi"] = "曹丕",
  ["#ofl2__caopi"] = "霸业的继承者",
  ["illustrator:ofl2__caopi"] = "宋其金",

  ["$songwei_ofl2__caopi1"] = "魏王世子，定登大统！",
  ["$songwei_ofl2__caopi2"] = "千古霸业，只在今朝！",
  ["~ofl2__caopi"] = "大事未成，愧对先父……",
}

generals.ofl3__caocao = General:new(extension, "ofl3__caocao", "wei", 4)
generals.ofl3__caocao:addSkills { "xiongtu", "hujia" }
generals.ofl3__caocao.headnote = "E7009T君霸天下"
Fk:loadTranslationTable{
  ["ofl3__caocao"] = "曹操",
  ["#ofl3__caocao"] = "魏武帝",
  ["illustrator:ofl3__caocao"] = "Town",

  ["$hujia_ofl3__caocao1"] = "众将忠义，护我周全！",
  ["$hujia_ofl3__caocao2"] = "吾麾下，无人乎？",
  ["~ofl3__caocao"] = "旧疾复发，吾命……恐不久矣。",
}

generals.ofl__liushan = General:new(extension, "ofl__liushan", "shu", 3)
generals.ofl__liushan:addSkills { "fuxiang", "lezong", "ruoyu" }
generals.ofl__liushan:addRelatedSkill("jijiang")
generals.ofl__liushan.headnote = "E7009T君霸天下"
Fk:loadTranslationTable{
  ["ofl__liushan"] = "刘禅",
  ["#ofl__liushan"] = "无为的真命主",
  ["illustrator:ofl__liushan"] = "凝聚永恒",

  ["$ruoyu_ofl__liushan1"] = "才思不足以济世，仁愗或可安民。",
  ["$ruoyu_ofl__liushan2"] = "风雨飘摇四十载，自欺若愚安此身……",
  ["$jijiang_ofl__liushan1"] = "季汉兴亡，皆系诸位爱卿之手！",
  ["$jijiang_ofl__liushan2"] = "长安路远，谁可替朕出征！",
  ["~ofl__liushan"] = "漫漫北伐路，独行梦中人……",
}

generals.ofl__liubei = General:new(extension, "ofl__liubei", "shu", 4)
generals.ofl__liubei:addSkills { "renwang", "jijiang" }
generals.ofl__liubei.headnote = "E7009T君霸天下"
Fk:loadTranslationTable{
  ["ofl__liubei"] = "刘备",
  ["#ofl__liubei"] = "乱世的枭雄",
  ["illustrator:ofl__liubei"] = "NOVART",

  ["$jijiang_ofl__liubei1"] = "汉将如云，竟无一人可出战？",
  ["$jijiang_ofl__liubei2"] = "汉室危亡，谁可扶之？",
  ["~ofl__liubei"] = "大业未成，心犹不甘呐！",
}

generals.ofl3__godmachao = General:new(extension, "ofl3__godmachao", "god", 5)
generals.ofl3__godmachao:addSkills { "qiangshu", "yuma" }
generals.ofl3__godmachao.headnote = "E5004渭南风云"
Fk:loadTranslationTable{
  ["ofl3__godmachao"] = "神马超",
  ["#ofl3__godmachao"] = "麾骑撚枪",
  ["illustrator:ofl3__godmachao"] = "君桓文化",
}

generals.ofl__godxuchu = General:new(extension, "ofl__godxuchu", "god", 5)
generals.ofl__godxuchu:addSkills { "bozhan", "piwei" }
generals.ofl__godxuchu.headnote = "E5004渭南风云"
Fk:loadTranslationTable{
  ["ofl__godxuchu"] = "神许褚",
  ["#ofl__godxuchu"] = "猛虎战骊",
  ["illustrator:ofl__godxuchu"] = "鬼画府",
}

generals.ofl2__caocao = General:new(extension, "ofl2__caocao", "wei", 4)
generals.ofl2__caocao:addSkills { "dingluan", "qianjiang" }
generals.ofl2__caocao.headnote = "E5004渭南风云"
Fk:loadTranslationTable{
  ["ofl2__caocao"] = "曹操",
  ["#ofl2__caocao"] = "乱世的奸雄",
  ["illustrator:ofl2__caocao"] = "小牛",
}

generals.ofl__hansui = General:new(extension, "ofl__hansui", "qun", 4, 5)
generals.ofl__hansui:addSkills { "jubing", "ofl__xiongju" }
generals.ofl__hansui:addRelatedSkill("mashu")
generals.ofl__hansui.headnote = "E5004渭南风云"
Fk:loadTranslationTable{
  ["ofl__hansui"] = "韩遂",
  ["#ofl__hansui"] = "征西将军",
  ["illustrator:ofl__hansui"] = "磐蒲",
}

generals.ofl__xuhuang = General:new(extension, "ofl__xuhuang", "wei", 4)
generals.ofl__xuhuang:addSkills { "ofl__zhuying", "ofl__chiyuan" }
generals.ofl__xuhuang.headnote = "E5004渭南风云"
Fk:loadTranslationTable{
  ["ofl__xuhuang"] = "徐晃",
  ["#ofl__xuhuang"] = "乘虚渡江",
  ["illustrator:ofl__xuhuang"] = "凝聚永恒",
}

generals.yangqiuq = General:new(extension, "yangqiuq", "qun", 5)
generals.yangqiuq:addSkills { "qifeng" }
generals.yangqiuq.headnote = "E5004渭南风云"
Fk:loadTranslationTable{
  ["yangqiuq"] = "杨秋",
  ["#yangqiuq"] = "似若无敌",
  ["illustrator:yangqiuq"] = "Neko",
}

generals.chengyi = General:new(extension, "chengyi", "qun", 4)
generals.chengyi:addSkills { "dutan" }
generals.chengyi.headnote = "E5004渭南风云"
Fk:loadTranslationTable{
  ["chengyi"] = "成宜",
  ["#chengyi"] = "气高志远",
  ["illustrator:chengyi"] = "陈鑫",
}

generals.houxuan = General:new(extension, "houxuan", "qun", 4)
generals.houxuan:addSkills { "zhongtao", "mashu" }
generals.houxuan.headnote = "E5004渭南风云"
Fk:loadTranslationTable{
  ["houxuan"] = "侯选",
  ["#houxuan"] = "合众复相",
  ["illustrator:houxuan"] = "陈鑫",
}

generals.ofl__zhanghe = General:new(extension, "ofl__zhanghe", "wei", 4)
generals.ofl__zhanghe:addSkills { "ofl__qiaobian" }
generals.ofl__zhanghe.headnote = "E5004渭南风云"
Fk:loadTranslationTable{
  ["ofl__zhanghe"] = "张郃",
  ["#ofl__zhanghe"] = "料敌机先",
  ["illustrator:ofl__zhanghe"] = "君桓文化",
}

generals.ofl__zhuling = General:new(extension, "ofl__zhuling", "wei", 4)
generals.ofl__zhuling:addSkills { "ofl__zhanyi" }
generals.ofl__zhuling.headnote = "E5004渭南风云"
Fk:loadTranslationTable{
  ["ofl__zhuling"] = "朱灵",
  ["#ofl__zhuling"] = "良将之亚",
  ["illustrator:ofl__zhuling"] = "新艺族",
}

generals.ofl3__jiaxu = General:new(extension, "ofl3__jiaxu", "wei", 3)
generals.ofl3__jiaxu:addSkills { "ofl__jianshu", "ofl__zhenlue" }
generals.ofl3__jiaxu.headnote = "E5004渭南风云"
Fk:loadTranslationTable{
  ["ofl3__jiaxu"] = "贾诩",
  ["#ofl3__jiaxu"] = "巧施间策",
  ["illustrator:ofl3__jiaxu"] = "匠人绘",

  ["~ofl3__jiaxu"] = "算无遗策，然终有疏漏。",
}

generals.ofl3__caopi = General:new(extension, "ofl3__caopi", "wei", 3)
generals.ofl3__caopi:addSkills { "ofl__qinyi", "ofl__jixin", "ofl__jiwei" }
generals.ofl3__caopi.headnote = "E1004一将成名精选合集"
Fk:loadTranslationTable{
  ["ofl3__caopi"] = "侠曹丕",
  ["#ofl3__caopi"] = "弃旧学新",
  ["illustrator:ofl3__caopi"] = "荆芥",
}

generals.ofl__caesar = General:new(extension, "ofl__caesar", "west", 4)
generals.ofl__caesar:addSkills { "ofl__ducai", "ofl__zhitong", "ofl__jiquan" }
generals.ofl__caesar.headnote = "E5006欧陆风云"
Fk:loadTranslationTable{
  ["ofl__caesar"] = "恺撒",
  ["#ofl__caesar"] = "无冕之皇",
  ["cv:ofl__caesar"] = "English Listening 900",
  ["illustrator:ofl__caesar"] = "绘绘子酱",

  ["~ofl__caesar"] = "Let's talk about something else.",
}

generals.macrinus = General:new(extension, "macrinus", "west", 4)
generals.macrinus:addSkills { "ofl__dengtian", "ofl__mingshu", "ofl__juedou" }
generals.macrinus.headnote = "E5006欧陆风云"
Fk:loadTranslationTable{
  ["macrinus"] = "马克里努斯",
  ["#macrinus"] = "传奇的角斗士",
  ["illustrator:macrinus"] = "绘绘子酱",
}

generals.ardashirI = General:new(extension, "ardashirI", "west", 4)
generals.ardashirI:addSkills { "ofl__wanwang", "ofl__sashan", "ofl__nagong" }
generals.ardashirI.headnote = "E5006欧陆风云"
Fk:loadTranslationTable{
  ["ardashirI"] = "阿尔达希尔Ⅰ",
  ["#ardashirI"] = "萨珊的创始人",
  ["illustrator:ardashirI"] = "绘绘子酱",
}

generals.makang = General:new(extension, "makang", "west", 4)
generals.makang:addSkills { "ofl__xiru", "ofl__zongma", "mashu" }
generals.makang.headnote = "E5006欧陆风云"
Fk:loadTranslationTable{
  ["makang"] = "马抗",
  ["#makang"] = "马米科尼扬",
  ["illustrator:makang"] = "绘绘子酱",
}

generals.ofl__yujin = General:new(extension, "ofl__yujin", "wei", 4)
generals.ofl__yujin:addSkills { "ofl__jieyue" }
generals.ofl__yujin.headnote = "E5006欧陆风云"
Fk:loadTranslationTable{
  ["ofl__yujin"] = "于禁",
  ["#ofl__yujin"] = "讨暴坚垒",
  ["illustrator:ofl__yujin"] = "Zero",
}

generals.ofl__zhangliao = General:new(extension, "ofl__zhangliao", "wei", 4)
generals.ofl__zhangliao:addSkills { "ofl__tuxi" }
generals.ofl__zhangliao.headnote = "E5006欧陆风云"
Fk:loadTranslationTable{
  ["ofl__zhangliao"] = "张辽",
  ["#ofl__zhangliao"] = "前将军",
  ["illustrator:ofl__zhangliao"] = "YanBai",
}

generals.ofl__yuejin = General:new(extension, "ofl__yuejin", "wei", 4)
generals.ofl__yuejin:addSkills { "ofl__xiaoguo" }
generals.ofl__yuejin.headnote = "E5006欧陆风云"
Fk:loadTranslationTable{
  ["ofl__yuejin"] = "乐进",
  ["#ofl__yuejin"] = "奋强突固",
  ["illustrator:ofl__yuejin"] = "巴萨小马",
}

generals.roma_warrior = General:new(extension, "roma_warrior", "west", 5)
generals.roma_warrior:addSkills { "ofl__benyong", "ofl__jiaozir" }
generals.roma_warrior.headnote = "E5006欧陆风云"
Fk:loadTranslationTable{
  ["roma_warrior"] = "罗马力士",
  ["#roma_warrior"] = "国王的精锐",
  ["illustrator:roma_warrior"] = "黑桃J",
}

generals.hubaoduwei = General:new(extension, "hubaoduwei", "wei", 4)
generals.hubaoduwei:addSkills { "zhenwei", "ofl__daidi" }
generals.hubaoduwei.headnote = "E5006欧陆风云"
Fk:loadTranslationTable{
  ["hubaoduwei"] = "虎豹都尉",
  ["#hubaoduwei"] = "护卫将军",
  ["illustrator:hubaoduwei"] = "蚂蚁君",
}

generals.envoy = General:new(extension, "envoy", "wei", 3)
generals.envoy:addSkills { "ofl__dizhao", "chenjie" }
generals.envoy.headnote = "E5006欧陆风云"
Fk:loadTranslationTable{
  ["envoy"] = "使臣",
  ["#envoy"] = "奉诏出使",
  ["illustrator:envoy"] = "蒋斯成",
}

generals.ofl__qibing = General:new(extension, "ofl__qibing", "qun", 4)
generals.ofl__qibing:addSkills { "ofl__jixiq", "mashu" }
generals.ofl__qibing.headnote = "E5006欧陆风云"
Fk:loadTranslationTable{
  ["ofl__qibing"] = "骑兵",
  ["#ofl__qibing"] = "凉州铁骑",
  ["illustrator:ofl__qibing"] = "李敏然",
}

return extension

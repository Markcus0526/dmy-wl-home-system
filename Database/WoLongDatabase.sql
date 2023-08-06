-- ----------------------------
-- Table structure for "SYSTEM"."ACTIVITY_COMMENT"
-- ----------------------------
CREATE TABLE "SYSTEM"."ACTIVITY_COMMENT" (
"ID" NUMBER NOT NULL ,
"MID" NUMBER NULL ,
"AID" NUMBER NULL ,
"TYPE" NUMBER NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Table structure for "SYSTEM"."ACTIVITY_ENTRY"
-- ----------------------------
CREATE TABLE "SYSTEM"."ACTIVITY_ENTRY" (
"ID" NUMBER NOT NULL ,
"AID" NUMBER NULL ,
"MID" NUMBER NULL ,
"ENTRYDATE" DATE NULL ,
"ENABLED" NUMBER DEFAULT 1  NULL ,
"DELETED" NUMBER DEFAULT 0  NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Table structure for "SYSTEM"."ACTIVITY_EVAL"
-- ----------------------------
CREATE TABLE "SYSTEM"."ACTIVITY_EVAL" (
"ID" NUMBER NOT NULL ,
"AID" NUMBER NULL ,
"MID" NUMBER NULL ,
"POSTDATE" DATE NULL ,
"BODY" NCLOB NULL ,
"ENABLED" NUMBER NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Table structure for "SYSTEM"."ACTIVITY_IMAGE"
-- ----------------------------
CREATE TABLE "SYSTEM"."ACTIVITY_IMAGE" (
"ID" NUMBER NOT NULL ,
"AID" NUMBER NULL ,
"DATAPATH" NVARCHAR2(1000) NULL ,
"WIDTH" NUMBER NULL ,
"HEIGHT" NUMBER NULL ,
"DELETED" NUMBER DEFAULT 0  NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Table structure for "SYSTEM"."ACTIVITY_INFO"
-- ----------------------------
CREATE TABLE "SYSTEM"."ACTIVITY_INFO" (
"ID" NUMBER NOT NULL ,
"MID" NUMBER NULL ,
"TITLE" NVARCHAR2(1000) NULL ,
"TYPE" NUMBER NULL ,
"BODY" NCLOB NULL ,
"POSTDATE" DATE NULL ,
"ENABLED" NUMBER DEFAULT 0  NULL ,
"READCOUNT" NUMBER DEFAULT 0  NULL ,
"ISSELECTED" NUMBER DEFAULT 0  NULL ,
"ISVISIBLE" NUMBER DEFAULT 1  NULL ,
"GOOD" NUMBER DEFAULT 0  NULL ,
"BAD" NUMBER DEFAULT 0  NULL ,
"DELETED" NUMBER DEFAULT 0  NULL ,
"ISPUBLIC" NUMBER DEFAULT 0  NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Table structure for "SYSTEM"."ACTIVITY_TYPE"
-- ----------------------------
CREATE TABLE "SYSTEM"."ACTIVITY_TYPE" (
"ID" NUMBER NOT NULL ,
"NAME" NVARCHAR2(1000) NULL ,
"DELETED" NUMBER DEFAULT 0  NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Records of ACTIVITY_TYPE
-- ----------------------------
INSERT INTO "SYSTEM"."ACTIVITY_TYPE" VALUES ('1', '会员活动', '0');
INSERT INTO "SYSTEM"."ACTIVITY_TYPE" VALUES ('2', '官方活动', '0');

-- ----------------------------
-- Table structure for "SYSTEM"."COLLECTION_INFO"
-- ----------------------------
CREATE TABLE "SYSTEM"."COLLECTION_INFO" (
"ID" NUMBER NOT NULL ,
"MID" NUMBER NOT NULL ,
"PID" NUMBER NOT NULL ,
"TYPE" NUMBER NOT NULL ,
"POSTDATE" DATE NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Table structure for "SYSTEM"."DATA_DOWNLOAD"
-- ----------------------------
CREATE TABLE "SYSTEM"."DATA_DOWNLOAD" (
"ID" NUMBER NOT NULL ,
"MID" NUMBER NULL ,
"SQID" NUMBER NULL ,
"DOWNLOADDATE" DATE NULL ,
"DELETED" NUMBER NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Table structure for "SYSTEM"."DATA_INFO"
-- ----------------------------
CREATE TABLE "SYSTEM"."DATA_INFO" (
"ID" NUMBER NOT NULL ,
"MID" NUMBER NULL ,
"TITLE" NVARCHAR2(1000) NULL ,
"TYPE" NUMBER NULL ,
"DATAPATH" NVARCHAR2(1000) NULL ,
"BODY" NCLOB NULL ,
"POSTDATE" DATE NULL ,
"DELETED" NUMBER DEFAULT 0  NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Table structure for "SYSTEM"."DATA_TYPE"
-- ----------------------------
CREATE TABLE "SYSTEM"."DATA_TYPE" (
"ID" NUMBER NOT NULL ,
"NAME" NVARCHAR2(1000) NULL ,
"DELETED" NUMBER NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Records of DATA_TYPE
-- ----------------------------
INSERT INTO "SYSTEM"."DATA_TYPE" VALUES ('1', '图片', '0');
INSERT INTO "SYSTEM"."DATA_TYPE" VALUES ('2', '视频', '0');

-- ----------------------------
-- Table structure for "SYSTEM"."INTEGRALLOG"
-- ----------------------------
CREATE TABLE "SYSTEM"."INTEGRALLOG" (
"ID" NUMBER NOT NULL ,
"MID" NUMBER NULL ,
"ADDDATE" DATE NULL ,
"GAININTEGRAL" NUMBER NULL ,
"REASON" NUMBER NULL ,
"ENABLED" NUMBER DEFAULT 1  NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Table structure for "SYSTEM"."INTEGRALREASON"
-- ----------------------------
CREATE TABLE "SYSTEM"."INTEGRALREASON" (
"ID" NUMBER NOT NULL ,
"REASON" NVARCHAR2(1000) NULL ,
"DEFAULTINTEGRAL" NUMBER NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Records of INTEGRALREASON
-- ----------------------------
INSERT INTO "SYSTEM"."INTEGRALREASON" VALUES ('4', '活动加精华', '5');
INSERT INTO "SYSTEM"."INTEGRALREASON" VALUES ('5', '上传学习资料', '1');
INSERT INTO "SYSTEM"."INTEGRALREASON" VALUES ('3', '官方活动评论', '1');
INSERT INTO "SYSTEM"."INTEGRALREASON" VALUES ('6', '下载学习资料', '1');
INSERT INTO "SYSTEM"."INTEGRALREASON" VALUES ('7', '学习评论', '1');
INSERT INTO "SYSTEM"."INTEGRALREASON" VALUES ('8', '会员分享', '3');
INSERT INTO "SYSTEM"."INTEGRALREASON" VALUES ('9', '分享评论', '1');
INSERT INTO "SYSTEM"."INTEGRALREASON" VALUES ('10', '活动上首页', '5');
INSERT INTO "SYSTEM"."INTEGRALREASON" VALUES ('11', '献策上传', '2');
INSERT INTO "SYSTEM"."INTEGRALREASON" VALUES ('12', '献策被采纳', '5');
INSERT INTO "SYSTEM"."INTEGRALREASON" VALUES ('13', '活动参与', '1');
INSERT INTO "SYSTEM"."INTEGRALREASON" VALUES ('2', '会员活动发起', '3');
INSERT INTO "SYSTEM"."INTEGRALREASON" VALUES ('1', '会员登录', '1');
INSERT INTO "SYSTEM"."INTEGRALREASON" VALUES ('14', '问答悬赏最高积分', '10');
INSERT INTO "SYSTEM"."INTEGRALREASON" VALUES ('15', '产品购买', '14');
INSERT INTO "SYSTEM"."INTEGRALREASON" VALUES ('16', '问题采纳', '0');

-- ----------------------------
-- Table structure for "SYSTEM"."MANAGERINFO"
-- ----------------------------
CREATE TABLE "SYSTEM"."MANAGERINFO" (
"ID" NUMBER NOT NULL ,
"NAME" NVARCHAR2(1000) NULL ,
"USERID" NVARCHAR2(1000) NULL ,
"PASSWORD" NVARCHAR2(1000) NULL ,
"PHOTO" NVARCHAR2(1000) NULL ,
"INTEGRAL" NVARCHAR2(1000) NULL ,
"REGISTDATE" DATE NULL ,
"LASTLOGINDATE" TIMESTAMP(7)  NULL ,
"PHONENUM" NVARCHAR2(1000) NULL ,
"EMAILADDRESS" NVARCHAR2(1000) NULL ,
"ISTENDATS" NUMBER NULL ,
"TENDAYDATE" DATE NULL ,
"REGISTIPADDRESS" NVARCHAR2(1000) NULL ,
"PART" NVARCHAR2(1000) NULL ,
"SECTION" NVARCHAR2(1000) NULL ,
"DELETED" NUMBER DEFAULT 0  NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Records of MANAGERINFO
-- ----------------------------
INSERT INTO "SYSTEM"."MANAGERINFO" VALUES ('1', 'admin', 'admin', 'admin', null, null, TO_DATE('2014-04-03 00:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2014-04-11 15:34:37:0000000', 'YYYY-MM-DD HH24:MI:SS:FF7'), null, null, null, null, '192.168.1.69', null, null, '0');

-- ----------------------------
-- Table structure for "SYSTEM"."MEMBERINFO"
-- ----------------------------
CREATE TABLE "SYSTEM"."MEMBERINFO" (
"ID" NUMBER NOT NULL ,
"NAME" NVARCHAR2(1000) NULL ,
"USERID" NVARCHAR2(1000) NULL ,
"PASSWORD" NVARCHAR2(1000) NULL ,
"PHOTO" NVARCHAR2(1000) NULL ,
"INTEGRAL" NUMBER NULL ,
"REGISTDATE" DATE NULL ,
"LASTLOGINDATE" TIMESTAMP(7)  NULL ,
"PHONENUM" NVARCHAR2(1000) NULL ,
"EMAILADDRESS" NVARCHAR2(1000) NULL ,
"ISTENDAYS" NUMBER DEFAULT 0  NULL ,
"TENDAYSDATE" DATE NULL ,
"REGISTIPADDRESS" NVARCHAR2(1000) NULL ,
"PRIVILEGE" NUMBER NULL ,
"PART" NVARCHAR2(255) NULL ,
"SECTION" NVARCHAR2(255) NULL ,
"LOGINCOUNT" NUMBER DEFAULT 0  NULL ,
"NICKNAME" NVARCHAR2(255) NULL ,
"NAMEPASSWORD" NVARCHAR2(255) NULL ,
"DELETED" NUMBER DEFAULT 0  NULL ,
"FIRSTLOGIN" NUMBER DEFAULT 0  NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Table structure for "SYSTEM"."MEMBERLOGINLIST"
-- ----------------------------
CREATE TABLE "SYSTEM"."MEMBERLOGINLIST" (
"ID" NUMBER NOT NULL ,
"MID" NUMBER NULL ,
"LOGINTIME" TIMESTAMP(6)  NULL ,
"LOGINIP" NVARCHAR2(255) NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Table structure for "SYSTEM"."MEMBER_DATA"
-- ----------------------------
CREATE TABLE "SYSTEM"."MEMBER_DATA" (
"ID" NUMBER NOT NULL ,
"MID" NUMBER NULL ,
"TITLE" NVARCHAR2(1000) NULL ,
"TYPE" NUMBER NULL ,
"DATAPATH" NVARCHAR2(1000) NULL ,
"BODY" NCLOB NULL ,
"POSTDATE" DATE NULL ,
"DELETED" NUMBER DEFAULT 0  NULL ,
"DEFIMAGE" NVARCHAR2(1000) NULL ,
"OTHERPATH" NVARCHAR2(1000) NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Table structure for "SYSTEM"."MEMBER_IMAGE"
-- ----------------------------
CREATE TABLE "SYSTEM"."MEMBER_IMAGE" (
"ID" NUMBER NOT NULL ,
"RID" NUMBER NULL ,
"DATAPATH" NVARCHAR2(1024) NULL ,
"DELETED" NUMBER DEFAULT 0  NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Table structure for "SYSTEM"."OPINION"
-- ----------------------------
CREATE TABLE "SYSTEM"."OPINION" (
"ID" NUMBER NOT NULL ,
"MID" NUMBER NULL ,
"TITLE" NVARCHAR2(1000) NULL ,
"BODY" NCLOB NULL ,
"DATAPATH" NVARCHAR2(1000) NULL ,
"POSTDATE" DATE NULL ,
"STATE" NUMBER DEFAULT 0  NULL ,
"GAININTEGRAL" NUMBER NULL ,
"EVALDATE" DATE NULL ,
"EID" NUMBER NULL ,
"DELETED" NUMBER DEFAULT 0  NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Table structure for "SYSTEM"."ORDER_PRODUCT"
-- ----------------------------
CREATE TABLE "SYSTEM"."ORDER_PRODUCT" (
"ID" NUMBER NOT NULL ,
"PID" NUMBER NULL ,
"MID" NUMBER NULL ,
"COUNT" NUMBER NULL ,
"PRICE" NUMBER NULL ,
"ORDERDATE" DATE NULL ,
"STATE" NUMBER NULL ,
"RECEIVEDATE" DATE NULL ,
"DELETED" NUMBER DEFAULT 0  NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Table structure for "SYSTEM"."PROBLEM_AINFO"
-- ----------------------------
CREATE TABLE "SYSTEM"."PROBLEM_AINFO" (
"ID" NUMBER NOT NULL ,
"PID" NUMBER NULL ,
"MID" NUMBER NULL ,
"TITLE" NVARCHAR2(1000) NULL ,
"BODY" NCLOB NULL ,
"POSTDATE" DATE NULL ,
"ENABLED" NUMBER NULL ,
"DELETED" NUMBER DEFAULT 0  NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Table structure for "SYSTEM"."PROBLEM_COMMENT"
-- ----------------------------
CREATE TABLE "SYSTEM"."PROBLEM_COMMENT" (
"ID" NUMBER NOT NULL ,
"MID" NUMBER NULL ,
"PID" NUMBER NULL ,
"TYPE" NUMBER NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Table structure for "SYSTEM"."PROBLEM_QINFO"
-- ----------------------------
CREATE TABLE "SYSTEM"."PROBLEM_QINFO" (
"ID" NUMBER NOT NULL ,
"MID" NUMBER NULL ,
"TITLE" NVARCHAR2(1000) NULL ,
"TYPE" NUMBER NULL ,
"BODY" NCLOB NULL ,
"POSTDATE" DATE NULL ,
"REWARDINTEGRAL" NUMBER NULL ,
"READCOUNT" NUMBER NULL ,
"ISVISIBLE" NUMBER DEFAULT 1  NULL ,
"GOOD" NUMBER DEFAULT 0  NULL ,
"BAD" NUMBER DEFAULT 0  NULL ,
"DELETED" NUMBER DEFAULT 0  NULL ,
"ISPUBLIC" NUMBER DEFAULT 0  NULL ,
"COMMENDNO" NUMBER DEFAULT 0  NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Table structure for "SYSTEM"."PROBLEM_TYPE"
-- ----------------------------
CREATE TABLE "SYSTEM"."PROBLEM_TYPE" (
"ID" NUMBER NULL ,
"NAME" NVARCHAR2(1000) NULL ,
"DELETED" NUMBER NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Records of PROBLEM_TYPE
-- ----------------------------
INSERT INTO "SYSTEM"."PROBLEM_TYPE" VALUES ('1', '专业知识', '0');
INSERT INTO "SYSTEM"."PROBLEM_TYPE" VALUES ('2', '企业相关', '0');
INSERT INTO "SYSTEM"."PROBLEM_TYPE" VALUES ('3', '其他综合', '0');

-- ----------------------------
-- Table structure for "SYSTEM"."PRODUCT_IMAGE"
-- ----------------------------
CREATE TABLE "SYSTEM"."PRODUCT_IMAGE" (
"ID" NUMBER NOT NULL ,
"PID" NUMBER NULL ,
"DATAPATH" NVARCHAR2(1000) NULL ,
"WIDTH" NUMBER NULL ,
"HEIGHT" NUMBER NULL ,
"ISMAIN" NUMBER DEFAULT 0  NULL ,
"DELETED" NUMBER DEFAULT 0  NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Table structure for "SYSTEM"."PRODUCT_INFO"
-- ----------------------------
CREATE TABLE "SYSTEM"."PRODUCT_INFO" (
"ID" NUMBER NOT NULL ,
"NAME" NVARCHAR2(1000) NULL ,
"TYPE" NUMBER NULL ,
"IID" NUMBER NULL ,
"MARKET_PRICE" NUMBER NULL ,
"INTEGRAL_PRICE" NUMBER NULL ,
"TOTAL_EXCHANGE" NUMBER NULL ,
"TOTAL_SECURE" NUMBER NULL ,
"PROPERTY" NCLOB NULL ,
"DETAIL" NCLOB NULL ,
"ISVISIBLE" NUMBER DEFAULT 1  NULL ,
"COMPRICE" NUMBER DEFAULT 0  NULL ,
"DELETED" NUMBER DEFAULT 0  NULL ,
"ISPUBLIC" NUMBER DEFAULT 1  NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Table structure for "SYSTEM"."PRODUCT_TYPE"
-- ----------------------------
CREATE TABLE "SYSTEM"."PRODUCT_TYPE" (
"ID" NUMBER NOT NULL ,
"NAME" NVARCHAR2(1000) NULL ,
"DELETED" NUMBER NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Records of PRODUCT_TYPE
-- ----------------------------
INSERT INTO "SYSTEM"."PRODUCT_TYPE" VALUES ('1', '专业知识', '0');
INSERT INTO "SYSTEM"."PRODUCT_TYPE" VALUES ('2', '企业相关', '0');
INSERT INTO "SYSTEM"."PRODUCT_TYPE" VALUES ('3', '其他综合', '0');

-- ----------------------------
-- Table structure for "SYSTEM"."SHARE_COMMENT"
-- ----------------------------
CREATE TABLE "SYSTEM"."SHARE_COMMENT" (
"ID" NUMBER NOT NULL ,
"MID" NUMBER NULL ,
"SID" NUMBER NULL ,
"TYPE" NUMBER NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Table structure for "SYSTEM"."SHARE_DATA"
-- ----------------------------
CREATE TABLE "SYSTEM"."SHARE_DATA" (
"ID" NUMBER NOT NULL ,
"RID" NUMBER NULL ,
"MID" NUMBER NULL ,
"TYPE" NUMBER NULL ,
"DATAPATH" NVARCHAR2(1000) NULL ,
"DELETED" NUMBER DEFAULT 0  NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Table structure for "SYSTEM"."SHARE_EVAL"
-- ----------------------------
CREATE TABLE "SYSTEM"."SHARE_EVAL" (
"ID" NUMBER NOT NULL ,
"RID" NUMBER NULL ,
"MID" NUMBER NULL ,
"POSTDATE" DATE NULL ,
"BODY" NCLOB NULL ,
"ENABLED" NUMBER NULL ,
"DELETED" NUMBER DEFAULT 0  NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Table structure for "SYSTEM"."SHARE_INFO"
-- ----------------------------
CREATE TABLE "SYSTEM"."SHARE_INFO" (
"ID" NUMBER NOT NULL ,
"MID" NUMBER NULL ,
"TITLE" NVARCHAR2(1000) NULL ,
"TYPE" NUMBER NULL ,
"BODY" NCLOB NULL ,
"POSTDATE" DATE NULL ,
"READCOUNT" NUMBER DEFAULT 0  NULL ,
"ISVISIBLE" NUMBER DEFAULT 0  NULL ,
"GOOD" NUMBER DEFAULT 0  NULL ,
"BAD" NUMBER DEFAULT 0  NULL ,
"DELETED" NUMBER DEFAULT 0  NULL ,
"ISPUBLIC" NUMBER DEFAULT 0  NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Table structure for "SYSTEM"."SHARE_TYPE"
-- ----------------------------
CREATE TABLE "SYSTEM"."SHARE_TYPE" (
"ID" NUMBER NOT NULL ,
"NAME" NVARCHAR2(1000) NULL ,
"DELETED" NUMBER NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Records of SHARE_TYPE
-- ----------------------------
INSERT INTO "SYSTEM"."SHARE_TYPE" VALUES ('1', '分类A', '0');
INSERT INTO "SYSTEM"."SHARE_TYPE" VALUES ('2', '分类B', '0');
INSERT INTO "SYSTEM"."SHARE_TYPE" VALUES ('3', '分类C', '0');

-- ----------------------------
-- Table structure for "SYSTEM"."STUDY_AINFO"
-- ----------------------------
CREATE TABLE "SYSTEM"."STUDY_AINFO" (
"ID" NUMBER NOT NULL ,
"SID" NUMBER NULL ,
"MID" NUMBER NULL ,
"BODY" NCLOB NULL ,
"POSTDATE" DATE NULL ,
"DELETED" NUMBER DEFAULT 0  NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Table structure for "SYSTEM"."STUDY_COMMENT"
-- ----------------------------
CREATE TABLE "SYSTEM"."STUDY_COMMENT" (
"ID" NUMBER NOT NULL ,
"MID" NUMBER NULL ,
"SID" NUMBER NULL ,
"TYPE" NUMBER DEFAULT 0  NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Table structure for "SYSTEM"."STUDY_QINFO"
-- ----------------------------
CREATE TABLE "SYSTEM"."STUDY_QINFO" (
"ID" NUMBER NOT NULL ,
"MID" NUMBER NULL ,
"TITLE" NVARCHAR2(1000) NULL ,
"TYPE" NUMBER NULL ,
"IMAGEPATH" NVARCHAR2(1000) NULL ,
"BODY" NCLOB NULL ,
"POSTDATE" DATE NULL ,
"DATAPATH" NVARCHAR2(1000) NULL ,
"READCOUNT" NUMBER NULL ,
"ENABLED" NUMBER NULL ,
"ISVISIBLE" NUMBER DEFAULT 0  NULL ,
"GOOD" NUMBER DEFAULT 0  NULL ,
"BAD" NUMBER DEFAULT 0  NULL ,
"INTEGRAL" NUMBER DEFAULT 0  NULL ,
"DELETED" NUMBER DEFAULT 0  NULL ,
"ISPUBLIC" NUMBER DEFAULT 0  NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Table structure for "SYSTEM"."STUDY_TYPE"
-- ----------------------------
CREATE TABLE "SYSTEM"."STUDY_TYPE" (
"ID" NUMBER NOT NULL ,
"NAME" NVARCHAR2(1000) NULL ,
"DELETED" NUMBER NULL 
)
LOGGING
NOCOMPRESS
NOCACHE

;

-- ----------------------------
-- Records of STUDY_TYPE
-- ----------------------------
INSERT INTO "SYSTEM"."STUDY_TYPE" VALUES ('3', '其他综合', '0');
INSERT INTO "SYSTEM"."STUDY_TYPE" VALUES ('1', '专业知识', '0');
INSERT INTO "SYSTEM"."STUDY_TYPE" VALUES ('2', '企业相关', '0');

-- ----------------------------
-- Indexes structure for table "SYSTEM"."ACTIVITY_COMMENT"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."ACTIVITY_COMMENT"
-- ----------------------------
ALTER TABLE "SYSTEM"."ACTIVITY_COMMENT" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."ACTIVITY_COMMENT" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."ACTIVITY_COMMENT" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."ACTIVITY_COMMENT" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."ACTIVITY_COMMENT"
-- ----------------------------
ALTER TABLE "SYSTEM"."ACTIVITY_COMMENT" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."ACTIVITY_ENTRY"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."ACTIVITY_ENTRY"
-- ----------------------------
ALTER TABLE "SYSTEM"."ACTIVITY_ENTRY" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."ACTIVITY_ENTRY" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."ACTIVITY_ENTRY" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."ACTIVITY_ENTRY"
-- ----------------------------
ALTER TABLE "SYSTEM"."ACTIVITY_ENTRY" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."ACTIVITY_EVAL"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."ACTIVITY_EVAL"
-- ----------------------------
ALTER TABLE "SYSTEM"."ACTIVITY_EVAL" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."ACTIVITY_EVAL" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."ACTIVITY_EVAL" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."ACTIVITY_EVAL"
-- ----------------------------
ALTER TABLE "SYSTEM"."ACTIVITY_EVAL" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."ACTIVITY_IMAGE"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."ACTIVITY_IMAGE"
-- ----------------------------
ALTER TABLE "SYSTEM"."ACTIVITY_IMAGE" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."ACTIVITY_IMAGE" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."ACTIVITY_IMAGE" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."ACTIVITY_IMAGE"
-- ----------------------------
ALTER TABLE "SYSTEM"."ACTIVITY_IMAGE" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."ACTIVITY_INFO"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."ACTIVITY_INFO"
-- ----------------------------
ALTER TABLE "SYSTEM"."ACTIVITY_INFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."ACTIVITY_INFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."ACTIVITY_INFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."ACTIVITY_INFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."ACTIVITY_INFO" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."ACTIVITY_INFO"
-- ----------------------------
ALTER TABLE "SYSTEM"."ACTIVITY_INFO" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."ACTIVITY_TYPE"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."ACTIVITY_TYPE"
-- ----------------------------
ALTER TABLE "SYSTEM"."ACTIVITY_TYPE" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."ACTIVITY_TYPE" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."ACTIVITY_TYPE" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."ACTIVITY_TYPE" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."ACTIVITY_TYPE"
-- ----------------------------
ALTER TABLE "SYSTEM"."ACTIVITY_TYPE" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."COLLECTION_INFO"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."COLLECTION_INFO"
-- ----------------------------
ALTER TABLE "SYSTEM"."COLLECTION_INFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."COLLECTION_INFO" ADD CHECK ("MID" IS NOT NULL);
ALTER TABLE "SYSTEM"."COLLECTION_INFO" ADD CHECK ("PID" IS NOT NULL);
ALTER TABLE "SYSTEM"."COLLECTION_INFO" ADD CHECK ("TYPE" IS NOT NULL);
ALTER TABLE "SYSTEM"."COLLECTION_INFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."COLLECTION_INFO" ADD CHECK ("MID" IS NOT NULL);
ALTER TABLE "SYSTEM"."COLLECTION_INFO" ADD CHECK ("PID" IS NOT NULL);
ALTER TABLE "SYSTEM"."COLLECTION_INFO" ADD CHECK ("TYPE" IS NOT NULL);
ALTER TABLE "SYSTEM"."COLLECTION_INFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."COLLECTION_INFO" ADD CHECK ("MID" IS NOT NULL);
ALTER TABLE "SYSTEM"."COLLECTION_INFO" ADD CHECK ("PID" IS NOT NULL);
ALTER TABLE "SYSTEM"."COLLECTION_INFO" ADD CHECK ("TYPE" IS NOT NULL);
ALTER TABLE "SYSTEM"."COLLECTION_INFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."COLLECTION_INFO" ADD CHECK ("MID" IS NOT NULL);
ALTER TABLE "SYSTEM"."COLLECTION_INFO" ADD CHECK ("PID" IS NOT NULL);
ALTER TABLE "SYSTEM"."COLLECTION_INFO" ADD CHECK ("TYPE" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."COLLECTION_INFO"
-- ----------------------------
ALTER TABLE "SYSTEM"."COLLECTION_INFO" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."DATA_DOWNLOAD"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."DATA_DOWNLOAD"
-- ----------------------------
ALTER TABLE "SYSTEM"."DATA_DOWNLOAD" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."DATA_DOWNLOAD" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."DATA_DOWNLOAD" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."DATA_DOWNLOAD"
-- ----------------------------
ALTER TABLE "SYSTEM"."DATA_DOWNLOAD" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."DATA_INFO"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."DATA_INFO"
-- ----------------------------
ALTER TABLE "SYSTEM"."DATA_INFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."DATA_INFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."DATA_INFO" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."DATA_INFO"
-- ----------------------------
ALTER TABLE "SYSTEM"."DATA_INFO" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."DATA_TYPE"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."DATA_TYPE"
-- ----------------------------
ALTER TABLE "SYSTEM"."DATA_TYPE" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."DATA_TYPE" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."DATA_TYPE" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."DATA_TYPE"
-- ----------------------------
ALTER TABLE "SYSTEM"."DATA_TYPE" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."INTEGRALLOG"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."INTEGRALLOG"
-- ----------------------------
ALTER TABLE "SYSTEM"."INTEGRALLOG" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."INTEGRALLOG" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."INTEGRALLOG" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."INTEGRALLOG"
-- ----------------------------
ALTER TABLE "SYSTEM"."INTEGRALLOG" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."INTEGRALREASON"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."INTEGRALREASON"
-- ----------------------------
ALTER TABLE "SYSTEM"."INTEGRALREASON" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."INTEGRALREASON" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."INTEGRALREASON" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."INTEGRALREASON"
-- ----------------------------
ALTER TABLE "SYSTEM"."INTEGRALREASON" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."MANAGERINFO"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."MANAGERINFO"
-- ----------------------------
ALTER TABLE "SYSTEM"."MANAGERINFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."MANAGERINFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."MANAGERINFO" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."MANAGERINFO"
-- ----------------------------
ALTER TABLE "SYSTEM"."MANAGERINFO" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."MEMBERINFO"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."MEMBERINFO"
-- ----------------------------
ALTER TABLE "SYSTEM"."MEMBERINFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."MEMBERINFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."MEMBERINFO" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."MEMBERINFO"
-- ----------------------------
ALTER TABLE "SYSTEM"."MEMBERINFO" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."MEMBERLOGINLIST"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."MEMBERLOGINLIST"
-- ----------------------------
ALTER TABLE "SYSTEM"."MEMBERLOGINLIST" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."MEMBERLOGINLIST" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."MEMBERLOGINLIST" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."MEMBERLOGINLIST" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."MEMBERLOGINLIST"
-- ----------------------------
ALTER TABLE "SYSTEM"."MEMBERLOGINLIST" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."MEMBER_DATA"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."MEMBER_DATA"
-- ----------------------------
ALTER TABLE "SYSTEM"."MEMBER_DATA" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."MEMBER_DATA" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."MEMBER_DATA" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."MEMBER_DATA" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."MEMBER_DATA"
-- ----------------------------
ALTER TABLE "SYSTEM"."MEMBER_DATA" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Checks structure for table "SYSTEM"."MEMBER_IMAGE"
-- ----------------------------
ALTER TABLE "SYSTEM"."MEMBER_IMAGE" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Indexes structure for table "SYSTEM"."OPINION"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."OPINION"
-- ----------------------------
ALTER TABLE "SYSTEM"."OPINION" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."OPINION" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."OPINION" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."OPINION" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."OPINION"
-- ----------------------------
ALTER TABLE "SYSTEM"."OPINION" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."ORDER_PRODUCT"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."ORDER_PRODUCT"
-- ----------------------------
ALTER TABLE "SYSTEM"."ORDER_PRODUCT" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."ORDER_PRODUCT" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."ORDER_PRODUCT" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."ORDER_PRODUCT" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."ORDER_PRODUCT"
-- ----------------------------
ALTER TABLE "SYSTEM"."ORDER_PRODUCT" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."PROBLEM_AINFO"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."PROBLEM_AINFO"
-- ----------------------------
ALTER TABLE "SYSTEM"."PROBLEM_AINFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."PROBLEM_AINFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."PROBLEM_AINFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."PROBLEM_AINFO" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."PROBLEM_AINFO"
-- ----------------------------
ALTER TABLE "SYSTEM"."PROBLEM_AINFO" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."PROBLEM_COMMENT"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."PROBLEM_COMMENT"
-- ----------------------------
ALTER TABLE "SYSTEM"."PROBLEM_COMMENT" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."PROBLEM_COMMENT" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."PROBLEM_COMMENT" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."PROBLEM_COMMENT" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."PROBLEM_COMMENT" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."PROBLEM_COMMENT"
-- ----------------------------
ALTER TABLE "SYSTEM"."PROBLEM_COMMENT" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."PROBLEM_QINFO"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."PROBLEM_QINFO"
-- ----------------------------
ALTER TABLE "SYSTEM"."PROBLEM_QINFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."PROBLEM_QINFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."PROBLEM_QINFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."PROBLEM_QINFO" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."PROBLEM_QINFO"
-- ----------------------------
ALTER TABLE "SYSTEM"."PROBLEM_QINFO" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."PRODUCT_IMAGE"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."PRODUCT_IMAGE"
-- ----------------------------
ALTER TABLE "SYSTEM"."PRODUCT_IMAGE" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."PRODUCT_IMAGE" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."PRODUCT_IMAGE" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."PRODUCT_IMAGE" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."PRODUCT_IMAGE"
-- ----------------------------
ALTER TABLE "SYSTEM"."PRODUCT_IMAGE" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."PRODUCT_INFO"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."PRODUCT_INFO"
-- ----------------------------
ALTER TABLE "SYSTEM"."PRODUCT_INFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."PRODUCT_INFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."PRODUCT_INFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."PRODUCT_INFO" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."PRODUCT_INFO"
-- ----------------------------
ALTER TABLE "SYSTEM"."PRODUCT_INFO" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."PRODUCT_TYPE"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."PRODUCT_TYPE"
-- ----------------------------
ALTER TABLE "SYSTEM"."PRODUCT_TYPE" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."PRODUCT_TYPE" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."PRODUCT_TYPE" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."PRODUCT_TYPE"
-- ----------------------------
ALTER TABLE "SYSTEM"."PRODUCT_TYPE" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Checks structure for table "SYSTEM"."SHARE_COMMENT"
-- ----------------------------
ALTER TABLE "SYSTEM"."SHARE_COMMENT" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."SHARE_COMMENT" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."SHARE_COMMENT" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Indexes structure for table "SYSTEM"."SHARE_DATA"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."SHARE_DATA"
-- ----------------------------
ALTER TABLE "SYSTEM"."SHARE_DATA" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."SHARE_DATA" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."SHARE_DATA" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."SHARE_DATA" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."SHARE_DATA"
-- ----------------------------
ALTER TABLE "SYSTEM"."SHARE_DATA" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."SHARE_EVAL"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."SHARE_EVAL"
-- ----------------------------
ALTER TABLE "SYSTEM"."SHARE_EVAL" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."SHARE_EVAL" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."SHARE_EVAL" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."SHARE_EVAL" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."SHARE_EVAL"
-- ----------------------------
ALTER TABLE "SYSTEM"."SHARE_EVAL" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."SHARE_INFO"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."SHARE_INFO"
-- ----------------------------
ALTER TABLE "SYSTEM"."SHARE_INFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."SHARE_INFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."SHARE_INFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."SHARE_INFO" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."SHARE_INFO"
-- ----------------------------
ALTER TABLE "SYSTEM"."SHARE_INFO" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."SHARE_TYPE"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."SHARE_TYPE"
-- ----------------------------
ALTER TABLE "SYSTEM"."SHARE_TYPE" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."SHARE_TYPE" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."SHARE_TYPE" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."SHARE_TYPE"
-- ----------------------------
ALTER TABLE "SYSTEM"."SHARE_TYPE" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."STUDY_AINFO"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."STUDY_AINFO"
-- ----------------------------
ALTER TABLE "SYSTEM"."STUDY_AINFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."STUDY_AINFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."STUDY_AINFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."STUDY_AINFO" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."STUDY_AINFO"
-- ----------------------------
ALTER TABLE "SYSTEM"."STUDY_AINFO" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."STUDY_COMMENT"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."STUDY_COMMENT"
-- ----------------------------
ALTER TABLE "SYSTEM"."STUDY_COMMENT" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."STUDY_COMMENT" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."STUDY_COMMENT" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."STUDY_COMMENT" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."STUDY_COMMENT" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."STUDY_COMMENT" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."STUDY_COMMENT"
-- ----------------------------
ALTER TABLE "SYSTEM"."STUDY_COMMENT" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."STUDY_QINFO"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."STUDY_QINFO"
-- ----------------------------
ALTER TABLE "SYSTEM"."STUDY_QINFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."STUDY_QINFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."STUDY_QINFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."STUDY_QINFO" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."STUDY_QINFO" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."STUDY_QINFO"
-- ----------------------------
ALTER TABLE "SYSTEM"."STUDY_QINFO" ADD PRIMARY KEY ("ID");

-- ----------------------------
-- Indexes structure for table "SYSTEM"."STUDY_TYPE"
-- ----------------------------

-- ----------------------------
-- Checks structure for table "SYSTEM"."STUDY_TYPE"
-- ----------------------------
ALTER TABLE "SYSTEM"."STUDY_TYPE" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."STUDY_TYPE" ADD CHECK ("ID" IS NOT NULL);
ALTER TABLE "SYSTEM"."STUDY_TYPE" ADD CHECK ("ID" IS NOT NULL);

-- ----------------------------
-- Primary Key structure for table "SYSTEM"."STUDY_TYPE"
-- ----------------------------
ALTER TABLE "SYSTEM"."STUDY_TYPE" ADD PRIMARY KEY ("ID");

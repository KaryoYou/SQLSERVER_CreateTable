USE test;

--物料编码设计:
--第一码				(一级分类):	1产成品、2半成品、3原材料、4辅料、5工具、6办公、7客供、8其他
--第二、三码			(二级分类):	10+采购件、20+委外件、30+自制件
----10+:10国内购入、11一般贸易进口
----20+:20国内加工、21出境加工
----30+:30自制件
--第四、五、六、七码	(三级分类):	1000+金属、2000+硅、3000+塑料、4000+纤维、5000+纸、6000+油、7000+水、8000+其他
--第八、九、十码		(流水码)	:	001~999

/*
6108000000 会议桌椅 H150W180L800CM
6108000001 办公桌椅 H150W140L200CM
6108000002 写字板 H200W200L200CM
*/

/*
6108000003 台式电脑
6108000004 笔记本电脑
6108000005 扫描仪
6108000006 打印机
6108000007 路由器
*/
--插入物料列表数据
INSERT INTO dbo.tbl_MaterialList (ApproverTag,CodePrefix,Code,NameEN,NameCH,Model,Size,Unit,UnitWeight,DrawingNo,MakerID,ApproverID)
SELECT 1,'610','6108000000','MeetingDesk','会议桌','Table','H150W180L800CM','SET',0,'安装手册000','K230000100','K230000001' UNION ALL
SELECT 1,'610','6108000001','OfficeDesk','办公桌椅','Table','H150W140L200CM','SET',0,'安装手册001','K230000100','K230000001' UNION ALL
SELECT 1,'610','6108000002','WriteBoard','写字板','Table','H200W200L200CM','SET',0,'安装手册002','K230000100','K230000001' UNION ALL
SELECT 1,'611','6118000003','Computer','台式电脑','PC','SONNY','SET',0,'使用手册000','K230000100','K230000001' UNION ALL
SELECT 1,'611','6118000004','LapTop','笔记本电脑','PC','SONNY','SET',0,'使用手册001','K230000100','K230000001' UNION ALL
SELECT 1,'611','6118000005','Scanner','扫描仪','Device','Sharp','SET',0,'使用手册002','K230000100','K230000001' UNION ALL
SELECT 1,'611','6118000006','Printer','打印机','Device','Sharp','SET',0,'使用手册003','K230000100','K230000001' UNION ALL
SELECT 1,'611','6118000007','Buffalo','路由器','Device','WiFi6','SET',0,'安装手册001','K230000100','K230000001' ;

--采购单号设计:PURC-DB00000001
--PURC:(purchase)采购
--D:(domestic)国内
--I:(import)进口
--B:(buy)购买
--P:(process)加工
--00000001~99999999:流水号

--工号设计:K230000001
--K:公司首字母
--23:入职年份
--0000000~9999999:流水号

--插入采购订单数据
INSERT INTO dbo.tbl_PurchaseOrder (ApproveTag, CloseTag, SupplierID, PurchaseID, PurchaseType, OrderDate, ExpectedDate, Remark, MakerID, ApproverID, CloserID)
SELECT 1,1,'S000000001','PURCDB00000001','国内购买','2023-07-14 09:05:53.257','2023-07-14 09:06:55.690','T-SQL录入数据','K230000100','K230000001','K230000101' UNION ALL
SELECT 1,1,'S000000002','PURCIB00000001','进口购买','2023-07-14 09:38:57.017','2023-07-14 09:40:28.493','T-SQL录入数据','K230000100','K230000001','K230000101' UNION ALL
SELECT 0,0,'S000000003','PURCDP00000001','国内加工','2023-07-14 09:42:44.483','2023-07-14 09:44:01.650','T-SQL录入数据','K230000100',NULL,NULL UNION ALL
SELECT 0,0,'S000000004','PURCIP00000001','进口加工','2023-07-14 09:46:26.900','2023-07-14 09:48:01.423','T-SQL录入数据','K230000100',NULL,NULL;

--插入采购订单明细数据
INSERT INTO dbo.tbl_PurchaseOrderDetail(PurchaseID,DeliveryAddr,SequanceNo,MaterialCode,MaterialUnit,Price,PurchaseQuantity,DeliveryQuantity,Currency,VAT_Rate,DeliveryDate,OverdueDay,Remark)
SELECT 'PURCDB00000001','东胜神洲傲来国花果山水帘洞',1,'6108000000','SET',1000,3,3,'RMB',0.13,'2023-07-14 09:06:55.690',0,'T-SQL录入数据' UNION ALL
SELECT 'PURCDB00000001','东胜神洲傲来国花果山水帘洞',2,'6108000001','SET',200,24,24,'RMB',0.13,'2023-07-14 09:06:55.690',0,'T-SQL录入数据' UNION ALL
SELECT 'PURCDB00000001','东胜神洲傲来国花果山水帘洞',3,'6108000002','SET',100,3,3,'RMB',0.13,'2023-07-14 09:06:55.690',0,'T-SQL录入数据' UNION ALL

SELECT 'PURCIB00000001','东胜神洲傲来国花果山水帘洞',1,'6118000003','SET',100000,100,100,'JPY',0.13,'2023-07-14 09:40:28.493',0,'T-SQL录入数据' UNION ALL
SELECT 'PURCIB00000001','东胜神洲傲来国花果山水帘洞',2,'6118000004','SET',100000,20,20,'JPY',0.13,'2023-07-14 09:40:28.493',0,'T-SQL录入数据' UNION ALL
SELECT 'PURCIB00000001','东胜神洲傲来国花果山水帘洞',3,'6118000005','SET',30000,2,2,'JPY',0.13,'2023-07-14 09:40:28.493',0,'T-SQL录入数据' UNION ALL
SELECT 'PURCIB00000001','东胜神洲傲来国花果山水帘洞',4,'6118000006','SET',20000,3,3,'JPY',0.13,'2023-07-14 09:40:28.493',0,'T-SQL录入数据' UNION ALL
SELECT 'PURCIB00000001','东胜神洲傲来国花果山水帘洞',5,'6118000007','SET',10000,20,20,'JPY',0.13,'2023-07-14 09:40:28.493',0,'T-SQL录入数据';
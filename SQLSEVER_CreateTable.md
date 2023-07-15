#  SQL SERVER - CREATE TABLE  

<Font Size=3>**使用T-SQL创建表格的同时添加字段说明，并使表格具有主键、外键、索引**<font>  

##  目的  

  创建表，并使表具有高效查询，减轻数据库开销;  

##  思路  

- 1.外面的世界很美好，那就从美好的世界中，提取制造业运营模式，作为本文的一个思维导索（不是工厂打螺丝，而是买螺丝）。  
  - 1.1.制造业工厂运行起来，一般都会存在采购的业务，本文就应用此业务所需要的数据作为例子。  
  - 1.2.采购部门去采购，采购‘什么东西’是发起采购行为的最终目的；对于这个‘什么东西’，自己的企业需要有一个明确的标识由仓库部门管控，同时此标识也将作为此次行为产生的数据记录关键。  
  - 1.3.由上条思路举个例子：先有‘仓库’说我们需要一个叫‘鸡米螺丝’的0.5mm螺丝，再去汇报‘采购’去买‘鸡米螺丝’回来；而‘采购’又需要‘仓库’提供‘鸡米螺丝’的详细资料，才不会买错东西。  
  - 1.4.由上条思路得出结论：先创建‘物料表’，再创建‘采购表’；同时采购表的物料数据信息来自物料表。  

- 2.企业还会通过有很多表实现对‘鸡米螺丝’的管控，本文仅使用其中的一个表来举例即可，不作太多牵扯。  

### 1.列出所有需要创建的表格  

- 1.物料表：tbl_MaterialList，记录物料信息的表格；  
- 2.采购订单总表：tbl_PurchaseOrder，记录所有的采购订单信息；  
- 3.采购订单明细表：tbl_PurchaseOrderDetail，记录单个采购订单的具体信息；  

### 2.构思表格之间的字段关系  

- 如图：  
  ![图片链接](https://github.com/KaryoYou/SQLSERVER_CreateTable/blob/main/TableContact.jpg "TableContact.jpg")  

### 3.设定各个表格的仅需字段  

- 具体内容纯属虚构，如有雷同，博主内心窃喜（真NB，构思完全正确。）  

- 物料表：  
  ![图片链接](https://github.com/KaryoYou/SQLSERVER_CreateTable/blob/main/tbl_MaterialList.jpg "tbl_MaterialList.jpg")  

- 采购订单总表：  
  ![图片链接](https://github.com/KaryoYou/SQLSERVER_CreateTable/blob/main/tbl_PurchaseOrder.jpg "tbl_PurchaseOrder.jpg")  

- 采购订单明细表：  
  ![图片链接](https://github.com/KaryoYou/SQLSERVER_CreateTable/blob/main/tbl_PurchaseOrderDetail.jpg "tbl_PurchaseOrderDetail.jpg")  

### 4.明确字段的数据类型、约束以及索引  

可以从数据存储以及被查询的方式思考。  

- 类型1：自动增值的整数，使用`int`。  
  - int的最大数值为2147483647（博主目前没有接触到超过十亿级别的数据库）。  
- 类型2：数值较小的整数，使用`smallint`或者`tinyint`。  
  - smallint的范围`-32768`至`32767`，tinyint的范围`0`至`255`。  
- 类型3：有小数点的数字，使用`decimal`。  
  - 如果数值为金额，个人建议使用`decimal(18,6)`,有效长度为18，小数点后6位。  
- 类型4：包含中文字符，使用`nvarchar`。  
  - 长度取决于字段最大需要存储多长的字符（可以使用`select len('存储的字符串')`进行判断）。  
- 类型5：时间值，使用`datetime`。  
- 类型6：可通过系统自动获取的值,使用‘计算列规范’。  
  - 如：`gatdate()`。  
	![图片链接](https://github.com/KaryoYou/SQLSERVER_CreateTable/blob/main/CalculationColumn.jpg "CalculationColumn.jpg")  
- 类型7：可通过记录自身包含的内容计算得到的值,使用‘计算列规范’  
  - 如：` AS 'columnName1' * 'columnName2'`  
    ![图片链接](https://github.com/KaryoYou/SQLSERVER_CreateTable/blob/main/CalculationColumn2.jpg "CalculationColumn2.jpg")  
- 约束1：主要关键的数据，且不会重复，作为主键。  
  - 如：物料表中的物料编码。  
- 约束2：次要关键的数据，且来自其他表中的主键，作为外键。  
  - 如：采购明细表中的物料编码。  
- 约束3：高频通过单字段或者多字段返回查询数据，通过的字段数据不重复，且按顺序进行排列，创建唯一的聚集索引。  
  - 如：高频的通过物料表中的物料编码，查询物料名称、型号、规格和计量单位。  
- 约束4：高频通过单字段或者多字段返回查询数据，通过的字段数据重复，且按不顺序进行排列，创建不唯一的非聚集索引。  
  - 如：高频的通过采购明细表中的采购单，查询采购的物料、采购单价和采购金额。  
  - 如：高频的通过采购明细表中的采购单和物料编码，查询采购单价和采购金额。  
- 约束5：高频通过索引查询的返回字段可以包含在索引中
  - 非聚集索引可以设置包含返回的列，设置顺序按数据的基数（查询时作为条件值不一致的数量：`A`和`A`为1种，`A`和`a`为1种，`A`和`B`为2种类）从小到大对应上到下排序  
  - 如：高频的通过采购明细表中的采购单和物料编码查询返回的货币、税率、单价、数量。  
- 索引如图：  
![图片链接](https://github.com/KaryoYou/SQLSERVER_CreateTable/blob/main/Index.jpg "Index.jpg")  

##  实现：仅通过1个SQL文件来创建以上内容  

 - 看博主在前面扯了一大堆，终于见到到主要（代码）内容了。  

---  

###  代码如下，请慢用  

 - SQL执行之前，大家需要自行将`USE test`改为需要创建表的数据库对象`USE 数据库名`  

``` SQL SERVER  
USE test;  

--创建物料清单明细表----------------------------------------------------------------------  
CREATE TABLE tbl_MaterialList (  
	AutoNum				int				IDENTITY(1,1)		NOT NULL,	--自动填充序号  
	ApproverTag			BIT				DEFAULT 0			NOT NULL,	--是否过审,审批标签  
	CodePrefix			VARCHAR(3)							NULL,		--编号前缀  
	Code				VARCHAR(10)							NOT NULL,	--编号  
	NameEN				VARCHAR(30)							NOT NULL,	--交付地址  
	NameCH				NVARCHAR(20)						NOT NULL,	--子序号,排序订单物料顺序,便于核对  
	Model				NVARCHAR(50)						NULL,		--型号  
	Size				NVARCHAR(50)						NULL,		--规格  
	Unit				NVARCHAR(10)	DEFAULT 'PCS'		NOT NULL,	--物料计量单位  
	UnitWeight			DECIMAL(18,6)	DEFAULT 0			NOT NULL,	--单位重量  
	DrawingNo			NVARCHAR(50)						NULL,		--图号  
	Remark				NVARCHAR(255)						NULL,		--备注  
	MakerID				VARCHAR(10)							NOT NULL,	--制作人ID  
	AmenderIDRecent		VARCHAR(10)							NULL,		--修改人ID,最近记录  
	ApproverID			VARCHAR(10)							NULL,		--审批人ID  
	RecordDate			DATETIME		DEFAULT(GETDATE())	NOT NULL,	--创建时间,首次记录  
	AmendDateRecent		AS GETDATE(),									--修改时间,最近记录  
    CONSTRAINT PK_Code PRIMARY KEY CLUSTERED (Code)  
)

CREATE UNIQUE NONCLUSTERED			--创建唯一非聚集索引  
INDEX UQ_Clu_Code					--索引名称  
ON tbl_MaterialList (CodePrefix,Code)  
INCLUDE (Unit,UnitWeight, NameEN, NameCH,Model,Size,DrawingNo) --包含键_列  
WITH (  
	FILLFACTOR = 80,	--填充因子为80%  
    PAD_INDEX = ON		--启用填充  
);  

--声明变量,预备使用游标添加表设计说明  
DECLARE @myname			NVARCHAR(100) = N'MS_Description',  
        @myvalue		NVARCHAR(100), --说明内容  
		@mylevel0type	NVARCHAR(100) = N'SCHEMA',  
        @mylevel0name	NVARCHAR(100) = N'dbo',  
        @mylevel1type	NVARCHAR(100) = N'TABLE',  
        @mylevel1name	NVARCHAR(100) = N'tbl_MaterialList',  --表名  
        @mylevel2type	NVARCHAR(100) = N'COLUMN',  
        @mylevel2name	NVARCHAR(100); --字段名  

--声明游标变量,并为游标赋予记录集  
DECLARE CUR1 CURSOR FOR  
SELECT N'AutoNum',			N'自动填充序号'						UNION ALL  
SELECT N'Code',				N'编号'								UNION ALL  
SELECT N'NameEN',			N'名称英文'							UNION ALL  
SELECT N'NameCH',			N'名称中文'							UNION ALL  
SELECT N'Model',			N'型号'								UNION ALL  
SELECT N'Size',				N'规格'								UNION ALL  
SELECT N'Unit',				N'物料计量单位'						UNION ALL  
SELECT N'UnitWeight',		N'单位重量'							UNION ALL  
SELECT N'DrawingNo',		N'图号'								UNION ALL  
SELECT N'Remark',			N'备注'								UNION ALL  
SELECT N'MakerID',			N'制作人ID'							UNION ALL  
SELECT N'AmenderIDRecent',	N'修改人ID,最近记录'					UNION ALL  
SELECT N'ApproverID',		N'审批人ID'							UNION ALL  
SELECT N'RecordDate',		N'创建时间,首次记录'					UNION ALL  
SELECT N'AmendDateRecent',	N'修改时间,最近记录'  

--打开游标,开始读取从头到尾读取记录集,并赋值给变量  
OPEN CUR1  
FETCH NEXT FROM CUR1 INTO @mylevel2name,@myvalue --读取下一行记录,打开时没读  
WHILE @@FETCH_STATUS = 0  
BEGIN  
	--添加表设计说明  
	EXEC sys.sp_addextendedproperty @name		= @myname,  
									@value		= @myvalue,  
									@level0type = @mylevel0type,  
									@level0name = @mylevel0name,  
									@level1type = @mylevel1type,  
									@level1name = @mylevel1name,  
									@level2type = @mylevel2type,  
									@level2name = @mylevel2name;  

	FETCH NEXT FROM CUR1 INTO @mylevel2name,@myvalue --读取下一行记录,不读则si..死循环  
END  
CLOSE CUR1		--关闭游标  
DEALLOCATE CUR1	--释放游标  

--创建采购订单表----------------------------------------------------------------------  
CREATE TABLE tbl_PurchaseOrder (  
	AutoNum			int				IDENTITY(1,1)		NOT NULL,	--自动填充序号  
	ApproveTag		BIT				DEFAULT 0			NOT NULL,	--是否批准,批准标签  
	CloseTag		BIT				DEFAULT 0			NOT NULL,	--是否关闭,关单标签  
	SupplierID		VARCHAR(10)							NOT NULL,	--供应商ID  
	PurchaseID		VARCHAR(14)							NOT NULL,	--采购单编号  
	PurchaseType	NVARCHAR(50)						NULL,		--采购单类型  
	OrderDate		DATETIME							NOT NULL,	--订单日期  
	ExpectedDate	DATETIME							NULL,		--预期交付日期  
	Remark			NVARCHAR(255)						NULL,		--备注  
	MakerID			VARCHAR(10)							NOT NULL,	--制单人ID  
	ApproverID		VARCHAR(10)							NULL,		--审批人ID  
	CloserID		VARCHAR(10)							NULL,		--关单人ID  
	PrinterID		NVARCHAR(255)						NULL,		--打印人ID  
	Printed			SMALLINT		DEFAULT 0			NOT NULL,	--打印次数  
	RecordDate		DATETIME		DEFAULT(GETDATE())	NOT NULL,	--创建时间,首次记录  
	AmendDateRecent DATETIME                            NULL,		--修改时间,最近记录  
	PrintDateRecent	DATETIME                            NULL,		--打印时间,记录最近  
	CloseDate		DATETIME                            NULL,		--关闭时间,结束订单记录  
	CONSTRAINT PK_PurchNo PRIMARY KEY CLUSTERED (PurchaseID)  
)  

CREATE UNIQUE NONCLUSTERED			--创建唯一聚集索引  
INDEX UQ_Clu_PurcID					--索引名称  
ON tbl_PurchaseOrder(PurchaseID)    --数据表名称（建立索引的列名）  
WITH (  
	FILLFACTOR = 80,	--填充因子为80%  
    PAD_INDEX = ON		--启用填充  
);  

--声明变量,预备使用游标添加表设计说明  
SET		@myvalue		= NULL --说明内容  
SET		@mylevel1name	= N'tbl_PurchaseOrder'  --表名  
SET		@mylevel2name	= NULL --字段名  

--声明游标变量,并为游标赋予记录集  
DECLARE CUR2 CURSOR FOR  
SELECT N'AutoNum',			N'自动填充序号'			UNION ALL  
SELECT N'ApproveTag',		N'是否批准,批准标签'		UNION ALL  
SELECT N'CloseTag',			N'是否关闭,关单标签'		UNION ALL  
SELECT N'SupplierID',		N'供应商ID'				UNION ALL  
SELECT N'PurchaseID',		N'采购单编号'				UNION ALL  
SELECT N'PurchaseType',		N'采购单类型'				UNION ALL  
SELECT N'OrderDate',		N'订单日期'				UNION ALL  
SELECT N'ExpectedDate',		N'预期交付日期'			UNION ALL  
SELECT N'Remark',			N'备注'					UNION ALL  
SELECT N'MakerID',			N'制单人ID'				UNION ALL  
SELECT N'ApproverID',		N'审批人ID'				UNION ALL  
SELECT N'CloserID',			N'关单人ID'				UNION ALL  
SELECT N'PrinterID',		N'打印人ID'				UNION ALL  
SELECT N'Printed',			N'打印次数'				UNION ALL  
SELECT N'RecordDate',		N'创建时间,首次记录'		UNION ALL  
SELECT N'AmendDateRecent',	N'修改时间,最近记录'		UNION ALL  
SELECT N'PrintDateRecent',	N'打印时间,记录最近'		UNION ALL  
SELECT N'CloseDate',		N'关闭时间,结束订单记录'  

--打开游标,开始读取从头到尾读取记录集,并赋值给变量  
OPEN CUR2  
FETCH NEXT FROM CUR2 INTO @mylevel2name,@myvalue --读取下一行记录,打开时没读  
WHILE @@FETCH_STATUS = 0  
BEGIN  
	--添加表设计说明  
	EXEC sys.sp_addextendedproperty @name		= @myname,  
									@value		= @myvalue,  
									@level0type = @mylevel0type,  
									@level0name = @mylevel0name,  
									@level1type = @mylevel1type,  
									@level1name = @mylevel1name,  
									@level2type = @mylevel2type,  
									@level2name = @mylevel2name;  

	FETCH NEXT FROM CUR2 INTO @mylevel2name,@myvalue --读取下一行记录,不读则si..死循环  
END  
CLOSE CUR2		--关闭游标  
DEALLOCATE CUR2	--释放游标  

--创建采购订单明细表----------------------------------------------------------------------  
CREATE TABLE tbl_PurchaseOrderDetail (  
	AutoNum				int				IDENTITY(1,1)		NOT NULL,	--自动填充序号  
	PurchaseID			VARCHAR(14)							NOT NULL,	--采购单编号  
	DeliveryAddr		NVARCHAR(250)						NOT NULL,	--交付地址  
	SequanceNo			SMALLINT		DEFAULT 0			NOT NULL,	--子序号,排序订单物料顺序,便于核对  
	MaterialCode		VARCHAR(10)							NOT NULL,	--物料编号  
	MaterialUnit		NVARCHAR(10)						NOT NULL,	--物料计量单位  
	Price				DECIMAL(18,6)	DEFAULT 0			NOT NULL,	--含税单价,基于物料计量单位  
	PurchaseQuantity	DECIMAL(18,6)	DEFAULT 0			NOT NULL,	--采购数量  
	DeliveryQuantity	DECIMAL(18,6)	DEFAULT 0			NOT NULL,	--交付数量  
	Currency			NVARCHAR(10)						NOT NULL,	--货币  
	VAT_Rate			DECIMAL(18,6)	DEFAULT 0			NOT NULL,	--税率  
	DeliveryDate		DATETIME                            NULL,		--交付时间  
	OverdueDay			INT				DEFAULT 0			NOT NULL,	--逾期天数  
	Remark				NVARCHAR(255)						NULL,		--备注  
	RecordDate			DATETIME		DEFAULT(GETDATE())	NOT NULL,	--创建时间,首次记录  
	AmendDateRecent		DATETIME                            NULL,		--修改时间,最近记录  
	TaxTag				AS (CONVERT(BIT,CASE WHEN VAT_Rate <> 0 THEN 1 ELSE 0 END)),		--是否含税,含税标记  
	Amount				AS (CONVERT(DECIMAL(18,6),Price * DeliveryQuantity)),	--含税金额,基于交付数量  
	Shortage			AS (CONVERT(DECIMAL(18,6),PurchaseQuantity - DeliveryQuantity)),	--短缺量,负数为少缺,正数为多余  
    CONSTRAINT FK_Purch_PurchID FOREIGN KEY (PurchaseID) REFERENCES tbl_PurchaseOrder (PurchaseID) ON DELETE CASCADE ON UPDATE CASCADE,  
	CONSTRAINT FK_MateList_MateCode FOREIGN KEY (MaterialCode) REFERENCES tbl_MaterialList (Code) ON DELETE CASCADE ON UPDATE CASCADE  
)  

CREATE NONCLUSTERED	--创建唯一聚集索引  
INDEX IX_tblPurcD_PurcID	--列名  
ON tbl_PurchaseOrderDetail (PurchaseID); --数据表名称（建立索引的列名）  

--创建带有非键列的索引  
CREATE NONCLUSTERED INDEX IX_tblPurchD_PurcID_MateCode --索引名称  
ON tbl_PurchaseOrderDetail (PurchaseID,MaterialCode) --索引键_列  
INCLUDE (Currency,VAT_Rate, Price, DeliveryQuantity); --包含键_列  

--声明变量,预备使用游标添加表设计说明  
SET		@myvalue		= NULL --说明内容  
SET		@mylevel1name	= N'tbl_PurchaseOrderDetail'  --表名  
SET		@mylevel2name	= NULL --字段名  

--声明游标变量,并为游标赋予记录集  
DECLARE CUR3 CURSOR FOR  
SELECT N'AutoNum',			N'自动填充序号'						UNION ALL  
SELECT N'PurchaseID',		N'采购单编号'							UNION ALL  
SELECT N'DeliveryAddr',		N'交付地址'							UNION ALL  
SELECT N'SequanceNo',		N'子序号,排序订单物料顺序,便于核对'		UNION ALL  
SELECT N'MaterialCode',		N'物料编号'							UNION ALL  
SELECT N'MaterialUnit',		N'物料计量单位'						UNION ALL  
SELECT N'Price',			N'含税单价,基于物料计量单位'				UNION ALL  
SELECT N'PurchaseQuantity',	N'采购数量'							UNION ALL  
SELECT N'DeliveryQuantity',	N'交付数量'							UNION ALL  
SELECT N'Amount',			N'含税金额,基于交付数量'				UNION ALL  
SELECT N'Currency',			N'货币'								UNION ALL  
SELECT N'VAT_Rate',			N'税率'								UNION ALL  
SELECT N'DeliveryDate',		N'交付时间'							UNION ALL  
SELECT N'OverdueDay',		N'逾期天数'							UNION ALL  
SELECT N'Remark',			N'备注'								UNION ALL  
SELECT N'RecordDate',		N'创建时间,首次记录'					UNION ALL  
SELECT N'AmendDateRecent',	N'修改时间,最近记录'					UNION ALL  
SELECT N'TaxTag',			N'是否含税,含税标记'					UNION ALL  
SELECT N'Shortage',			N'短缺量,负数为少缺,正数为多余'  

--打开游标,开始读取从头到尾读取记录集,并赋值给变量  
OPEN CUR3  
FETCH NEXT FROM CUR3 INTO @mylevel2name,@myvalue --读取下一行记录,打开时没读  
WHILE @@FETCH_STATUS = 0  
BEGIN  
	--添加表设计说明  
	EXEC sys.sp_addextendedproperty @name		= @myname,  
									@value		= @myvalue,  
									@level0type = @mylevel0type,  
									@level0name = @mylevel0name,  
									@level1type = @mylevel1type,  
									@level1name = @mylevel1name,  
									@level2type = @mylevel2type,  
									@level2name = @mylevel2name;  

	FETCH NEXT FROM CUR3 INTO @mylevel2name,@myvalue --读取下一行记录,不读则si..死循环  
END  
CLOSE CUR3		--关闭游标  
DEALLOCATE CUR3	--释放游标  
```  

### 附带参考数据，仅供测试  

``` SQL SERVER  

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

```  

这是博主第一篇博文,欢迎大家点赞、收藏！  

如果大家有不同的见解，请留下您的评论，博主与大家共勉。  

创作时间：2023/07/16 03:06:09  
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
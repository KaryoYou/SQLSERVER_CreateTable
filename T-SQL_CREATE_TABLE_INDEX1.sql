USE test;

--���������嵥��ϸ��----------------------------------------------------------------------
CREATE TABLE tbl_MaterialList (
	AutoNum				int				IDENTITY(1,1)		NOT NULL,	--�Զ�������
	ApproverTag			BIT				DEFAULT 0			NOT NULL,	--�Ƿ����,������ǩ
	CodePrefix			VARCHAR(3)							NULL,		--���ǰ׺
	Code				VARCHAR(10)							NOT NULL,	--���
	NameEN				VARCHAR(30)							NOT NULL,	--������ַ
	NameCH				NVARCHAR(20)						NOT NULL,	--�����,���򶩵�����˳��,���ں˶�
	Model				NVARCHAR(50)						NULL,		--�ͺ�
	Size				NVARCHAR(50)						NULL,		--���			
	Unit				NVARCHAR(10)	DEFAULT 'PCS'		NOT NULL,	--���ϼ�����λ
	UnitWeight			DECIMAL(18,6)	DEFAULT 0			NOT NULL,	--��λ����
	DrawingNo			NVARCHAR(50)						NULL,		--ͼ��
	Remark				NVARCHAR(255)						NULL,		--��ע
	MakerID				VARCHAR(10)							NOT NULL,	--������ID
	AmenderIDRecent		VARCHAR(10)							NULL,		--�޸���ID,�����¼
	ApproverID			VARCHAR(10)							NULL,		--������ID
	RecordDate			DATETIME		DEFAULT(GETDATE())	NOT NULL,	--����ʱ��,�״μ�¼
	AmendDateRecent		AS GETDATE(),									--�޸�ʱ��,�����¼
    CONSTRAINT PK_Code PRIMARY KEY CLUSTERED (Code)
)

CREATE UNIQUE NONCLUSTERED			--����Ψһ�Ǿۼ�����
INDEX UQ_Clu_Code					--��������
ON tbl_MaterialList (CodePrefix,Code)
INCLUDE (Unit,UnitWeight, NameEN, NameCH,Model,Size,DrawingNo) --������_��
WITH (
	FILLFACTOR = 80,	--�������Ϊ80%
    PAD_INDEX = ON		--�������		
);

--��������,Ԥ��ʹ���α���ӱ����˵��
DECLARE @myname			NVARCHAR(100) = N'MS_Description',
        @myvalue		NVARCHAR(100), --˵������
		@mylevel0type	NVARCHAR(100) = N'SCHEMA',
        @mylevel0name	NVARCHAR(100) = N'dbo',
        @mylevel1type	NVARCHAR(100) = N'TABLE',
        @mylevel1name	NVARCHAR(100) = N'tbl_MaterialList',  --����
        @mylevel2type	NVARCHAR(100) = N'COLUMN',
        @mylevel2name	NVARCHAR(100); --�ֶ���

--�����α����,��Ϊ�α긳���¼��
DECLARE CUR1 CURSOR FOR
SELECT N'AutoNum',			N'�Զ�������'						UNION ALL
SELECT N'Code',				N'���'								UNION ALL
SELECT N'NameEN',			N'����Ӣ��'							UNION ALL
SELECT N'NameCH',			N'��������'							UNION ALL
SELECT N'Model',			N'�ͺ�'								UNION ALL
SELECT N'Size',				N'���'								UNION ALL
SELECT N'Unit',				N'���ϼ�����λ'						UNION ALL
SELECT N'UnitWeight',		N'��λ����'							UNION ALL
SELECT N'DrawingNo',		N'ͼ��'								UNION ALL
SELECT N'Remark',			N'��ע'								UNION ALL
SELECT N'MakerID',			N'������ID'							UNION ALL
SELECT N'AmenderIDRecent',	N'�޸���ID,�����¼'					UNION ALL
SELECT N'ApproverID',		N'������ID'							UNION ALL
SELECT N'RecordDate',		N'����ʱ��,�״μ�¼'					UNION ALL
SELECT N'AmendDateRecent',	N'�޸�ʱ��,�����¼'

--���α�,��ʼ��ȡ��ͷ��β��ȡ��¼��,����ֵ������
OPEN CUR1
FETCH NEXT FROM CUR1 INTO @mylevel2name,@myvalue --��ȡ��һ�м�¼,��ʱû��
WHILE @@FETCH_STATUS = 0
BEGIN
	--��ӱ����˵��
	EXEC sys.sp_addextendedproperty @name		= @myname,
									@value		= @myvalue,
									@level0type = @mylevel0type,
									@level0name = @mylevel0name,
									@level1type = @mylevel1type,
									@level1name = @mylevel1name,
									@level2type = @mylevel2type,
									@level2name = @mylevel2name; 
	
	FETCH NEXT FROM CUR1 INTO @mylevel2name,@myvalue --��ȡ��һ�м�¼,������si..��ѭ��
END
CLOSE CUR1		--�ر��α�
DEALLOCATE CUR1	--�ͷ��α�

--�����ɹ�������----------------------------------------------------------------------
CREATE TABLE tbl_PurchaseOrder (
	AutoNum			int				IDENTITY(1,1)		NOT NULL,	--�Զ�������
	ApproveTag		BIT				DEFAULT 0			NOT NULL,	--�Ƿ���׼,��׼��ǩ
	CloseTag		BIT				DEFAULT 0			NOT NULL,	--�Ƿ�ر�,�ص���ǩ
	SupplierID		VARCHAR(10)							NOT NULL,	--��Ӧ��ID
	PurchaseID		VARCHAR(14)							NOT NULL,	--�ɹ������
	PurchaseType	NVARCHAR(50)						NULL,		--�ɹ�������
	OrderDate		DATETIME							NOT NULL,	--��������
	ExpectedDate	DATETIME							NULL,		--Ԥ�ڽ�������
	Remark			NVARCHAR(255)						NULL,		--��ע
	MakerID			VARCHAR(10)							NOT NULL,	--�Ƶ���ID
	ApproverID		VARCHAR(10)							NULL,		--������ID
	CloserID		VARCHAR(10)							NULL,		--�ص���ID
	PrinterID		NVARCHAR(255)						NULL,		--��ӡ��ID
	Printed			SMALLINT		DEFAULT 0			NOT NULL,	--��ӡ����
	RecordDate		DATETIME		DEFAULT(GETDATE())	NOT NULL,	--����ʱ��,�״μ�¼
	AmendDateRecent DATETIME                            NULL,		--�޸�ʱ��,�����¼
	PrintDateRecent	DATETIME                            NULL,		--��ӡʱ��,��¼���
	CloseDate		DATETIME                            NULL,		--�ر�ʱ��,����������¼
	CONSTRAINT PK_PurchNo PRIMARY KEY CLUSTERED (PurchaseID)
)

CREATE UNIQUE NONCLUSTERED			--����Ψһ�ۼ�����
INDEX UQ_Clu_PurcID					--��������
ON tbl_PurchaseOrder(PurchaseID)    --���ݱ����ƣ�����������������
WITH (
	FILLFACTOR = 80,	--�������Ϊ80%
    PAD_INDEX = ON		--�������		
);

--��������,Ԥ��ʹ���α���ӱ����˵��
SET		@myvalue		= NULL --˵������
SET		@mylevel1name	= N'tbl_PurchaseOrder'  --����
SET		@mylevel2name	= NULL --�ֶ���

--�����α����,��Ϊ�α긳���¼��
DECLARE CUR2 CURSOR FOR
SELECT N'AutoNum',			N'�Զ�������'			UNION ALL
SELECT N'ApproveTag',		N'�Ƿ���׼,��׼��ǩ'		UNION ALL
SELECT N'CloseTag',			N'�Ƿ�ر�,�ص���ǩ'		UNION ALL
SELECT N'SupplierID',		N'��Ӧ��ID'				UNION ALL
SELECT N'PurchaseID',		N'�ɹ������'				UNION ALL
SELECT N'PurchaseType',		N'�ɹ�������'				UNION ALL
SELECT N'OrderDate',		N'��������'				UNION ALL
SELECT N'ExpectedDate',		N'Ԥ�ڽ�������'			UNION ALL
SELECT N'Remark',			N'��ע'					UNION ALL
SELECT N'MakerID',			N'�Ƶ���ID'				UNION ALL
SELECT N'ApproverID',		N'������ID'				UNION ALL
SELECT N'CloserID',			N'�ص���ID'				UNION ALL
SELECT N'PrinterID',		N'��ӡ��ID'				UNION ALL
SELECT N'Printed',			N'��ӡ����'				UNION ALL
SELECT N'RecordDate',		N'����ʱ��,�״μ�¼'		UNION ALL
SELECT N'AmendDateRecent',	N'�޸�ʱ��,�����¼'		UNION ALL
SELECT N'PrintDateRecent',	N'��ӡʱ��,��¼���'		UNION ALL
SELECT N'CloseDate',		N'�ر�ʱ��,����������¼'

--���α�,��ʼ��ȡ��ͷ��β��ȡ��¼��,����ֵ������
OPEN CUR2
FETCH NEXT FROM CUR2 INTO @mylevel2name,@myvalue --��ȡ��һ�м�¼,��ʱû��
WHILE @@FETCH_STATUS = 0
BEGIN
	--��ӱ����˵��
	EXEC sys.sp_addextendedproperty @name		= @myname,
									@value		= @myvalue,
									@level0type = @mylevel0type,
									@level0name = @mylevel0name,
									@level1type = @mylevel1type,
									@level1name = @mylevel1name,
									@level2type = @mylevel2type,
									@level2name = @mylevel2name; 
	
	FETCH NEXT FROM CUR2 INTO @mylevel2name,@myvalue --��ȡ��һ�м�¼,������si..��ѭ��
END
CLOSE CUR2		--�ر��α�
DEALLOCATE CUR2	--�ͷ��α�

--�����ɹ�������ϸ��----------------------------------------------------------------------
CREATE TABLE tbl_PurchaseOrderDetail (
	AutoNum				int				IDENTITY(1,1)		NOT NULL,	--�Զ�������
	PurchaseID			VARCHAR(14)							NOT NULL,	--�ɹ������
	DeliveryAddr		NVARCHAR(250)						NOT NULL,	--������ַ
	SequanceNo			SMALLINT		DEFAULT 0			NOT NULL,	--�����,���򶩵�����˳��,���ں˶�
	MaterialCode		VARCHAR(10)							NOT NULL,	--���ϱ��
	MaterialUnit		NVARCHAR(10)						NOT NULL,	--���ϼ�����λ
	Price				DECIMAL(18,6)	DEFAULT 0			NOT NULL,	--��˰����,�������ϼ�����λ
	PurchaseQuantity	DECIMAL(18,6)	DEFAULT 0			NOT NULL,	--�ɹ�����
	DeliveryQuantity	DECIMAL(18,6)	DEFAULT 0			NOT NULL,	--��������
	Currency			NVARCHAR(10)						NOT NULL,	--����
	VAT_Rate			DECIMAL(18,6)	DEFAULT 0			NOT NULL,	--˰��
	DeliveryDate		DATETIME                            NULL,		--����ʱ��
	OverdueDay			INT				DEFAULT 0			NOT NULL,	--��������
	Remark				NVARCHAR(255)						NULL,		--��ע
	RecordDate			DATETIME		DEFAULT(GETDATE())	NOT NULL,	--����ʱ��,�״μ�¼
	AmendDateRecent		DATETIME                            NULL,		--�޸�ʱ��,�����¼
	TaxTag				AS (CONVERT(BIT,CASE WHEN VAT_Rate <> 0 THEN 1 ELSE 0 END)),		--�Ƿ�˰,��˰���
	Amount				AS (CONVERT(DECIMAL(18,6),Price * DeliveryQuantity)),	--��˰���,���ڽ�������
	Shortage			AS (CONVERT(DECIMAL(18,6),PurchaseQuantity - DeliveryQuantity)),	--��ȱ��,����Ϊ��ȱ,����Ϊ����
    CONSTRAINT FK_Purch_PurchID FOREIGN KEY (PurchaseID) REFERENCES tbl_PurchaseOrder (PurchaseID) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT FK_MateList_MateCode FOREIGN KEY (MaterialCode) REFERENCES tbl_MaterialList (Code) ON DELETE CASCADE ON UPDATE CASCADE
)

CREATE NONCLUSTERED	--����Ψһ�ۼ�����
INDEX IX_tblPurcD_PurcID	--����
ON tbl_PurchaseOrderDetail (PurchaseID); --���ݱ����ƣ�����������������

--�������зǼ��е�����
CREATE NONCLUSTERED INDEX IX_tblPurchD_PurcID_MateCode --��������
ON tbl_PurchaseOrderDetail (PurchaseID,MaterialCode) --������_��
INCLUDE (Currency,VAT_Rate, Price, DeliveryQuantity); --������_��

--��������,Ԥ��ʹ���α���ӱ����˵��
SET		@myvalue		= NULL --˵������
SET		@mylevel1name	= N'tbl_PurchaseOrderDetail'  --����
SET		@mylevel2name	= NULL --�ֶ���

--�����α����,��Ϊ�α긳���¼��
DECLARE CUR3 CURSOR FOR
SELECT N'AutoNum',			N'�Զ�������'						UNION ALL
SELECT N'PurchaseID',		N'�ɹ������'							UNION ALL
SELECT N'DeliveryAddr',		N'������ַ'							UNION ALL
SELECT N'SequanceNo',		N'�����,���򶩵�����˳��,���ں˶�'		UNION ALL
SELECT N'MaterialCode',		N'���ϱ��'							UNION ALL
SELECT N'MaterialUnit',		N'���ϼ�����λ'						UNION ALL
SELECT N'Price',			N'��˰����,�������ϼ�����λ'				UNION ALL
SELECT N'PurchaseQuantity',	N'�ɹ�����'							UNION ALL
SELECT N'DeliveryQuantity',	N'��������'							UNION ALL
SELECT N'Amount',			N'��˰���,���ڽ�������'				UNION ALL
SELECT N'Currency',			N'����'								UNION ALL
SELECT N'VAT_Rate',			N'˰��'								UNION ALL
SELECT N'DeliveryDate',		N'����ʱ��'							UNION ALL
SELECT N'OverdueDay',		N'��������'							UNION ALL
SELECT N'Remark',			N'��ע'								UNION ALL
SELECT N'RecordDate',		N'����ʱ��,�״μ�¼'					UNION ALL
SELECT N'AmendDateRecent',	N'�޸�ʱ��,�����¼'					UNION ALL
SELECT N'TaxTag',			N'�Ƿ�˰,��˰���'					UNION ALL
SELECT N'Shortage',			N'��ȱ��,����Ϊ��ȱ,����Ϊ����'

--���α�,��ʼ��ȡ��ͷ��β��ȡ��¼��,����ֵ������
OPEN CUR3
FETCH NEXT FROM CUR3 INTO @mylevel2name,@myvalue --��ȡ��һ�м�¼,��ʱû��
WHILE @@FETCH_STATUS = 0
BEGIN
	--��ӱ����˵��
	EXEC sys.sp_addextendedproperty @name		= @myname,
									@value		= @myvalue,
									@level0type = @mylevel0type,
									@level0name = @mylevel0name,
									@level1type = @mylevel1type,
									@level1name = @mylevel1name,
									@level2type = @mylevel2type,
									@level2name = @mylevel2name;  
	
	FETCH NEXT FROM CUR3 INTO @mylevel2name,@myvalue --��ȡ��һ�м�¼,������si..��ѭ��
END
CLOSE CUR3		--�ر��α�
DEALLOCATE CUR3	--�ͷ��α�
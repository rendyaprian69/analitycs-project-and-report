USE [CIP_DEV]
GO

/****** Object:  View [dbo].[vp_report_PBI_test]    Script Date: 9/18/2023 3:40:10 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[vp_report_PBI_test] as (
select 
*,
(case when ROW_NUMBER() over(Partition by exim, Bulan order by total_teus desc) <= 10 then 'Kategori 1'
	when ROW_NUMBER() over(Partition by exim, Bulan order by total_teus desc) between 11 and 20 then 'Kategori 2' else 'Kategori 3' end) as Kategori
from 


(
select * from (select x1.Invoicedate, year(x1.Invoicedate) as Tahun, month(x1.Invoicedate) as Bulan, x1.BillName, sum(x1.teus) as total_teus, sum(x1.total) as total_rev, x1.exim from (
select
a.Invoicedate, 
a.BLHeader,
a.billname,
(select sum(case when CTR_SIZE='20' then 1 else 2 end) from tracking_cont_import where BL_NO=c.BL_NO group by BL_NO) as teus,
sum(b.Total) as total,
'IMPORT' as exim  from TR_Invoice_H a 
left outer join TR_Invoice_D b on a.Invoiceno=b.Invoiceno 
left outer join so c on b.SO_NO=c.SO_NO 
where b.SO_NO not in ('-') and b.SO_NO is not null and right(b.SO_NO,3) in ('2IS','2IX') and a.voidedby is null 
group by a.Invoicedate, a.BLHeader,c.BL_NO,a.billname) as x1
group by x1.Invoicedate,x1.billname, x1.exim
order by 2 desc OFFSET 0 ROWS) as xx

union all

select * from (select x2.Invoicedate, year(x2.Invoicedate) as Tahun, month(x2.Invoicedate) as Bulan, x2.BillName, sum(x2.teus) as total_teus, sum(x2.total) as total_rev, x2.exim from (select 
a.Invoicedate,
a.BLHeader,
a.billname,
(select sum(case when SizeOfParty='20' then 1 else 2 end) from soparty where SO_NO=b.SO_NO group by SO_NO) as teus,
sum(b.Total) as total,
'FEEDER' as exim from TR_Invoice_H a 
left outer join TR_Invoice_D b on a.Invoiceno=b.Invoiceno 
left outer join so c on b.SO_NO=c.SO_NO where c.Instruction not in ('Quarantine Inspection','Customs Behandle','Movement For BC15','Hi co scan x-ray') and b.SO_NO not in ('-') and b.SO_NO is not null and right(b.SO_NO,3) in ('.HI') and a.voidedby is null 
group by a.Invoicedate ,a.BLHeader,b.SO_NO,a.billname) as x2
group by x2.Invoicedate,x2.billname, x2.exim
order by 2 desc OFFSET 0 ROWS) as yy

union all

select * from(
select x3.Invoicedate, year(x3.Invoicedate) as Tahun, month(x3.Invoicedate) as Bulan,x3.BillName, sum(x3.teus) as total_teus, sum(x3.total) as total_rev, x3.exim from (
select 
a.Invoicedate,
a.BLHeader,
a.billname,
(select sum(case when CTR_SIZE='20' then 1 else 2 end) from tracking_cont_export where BL_NO=c.BL_NO group by BL_NO) as teus,
sum(b.Total) as total,
'EXPORT' as exim from TR_Invoice_H a 
left outer join TR_Invoice_D b on a.Invoiceno=b.Invoiceno 
left outer join so c on b.SO_NO=c.SO_NO where b.SO_NO not in ('-') and b.SO_NO is not null and right(b.SO_NO,3) in ('2ES') and a.voidedby is null 
group by a.Invoicedate, a.BLHeader,c.BL_NO,a.billname) as x3
group by x3.Invoicedate,x3.billname, x3.exim
order by 2 desc OFFSET 0 ROWS) as zz

) as x --WHERE X.Tahun = 2023
group by x.Invoicedate, x.Tahun,x.Bulan,x.BillName, x.exim, x.total_teus, x.total_rev
)
GO



USE [CIP_DEV]
GO

/****** Object:  View [dbo].[vp_paymethod_report]    Script Date: 9/18/2023 3:36:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vp_paymethod_report]
as

select x.invoiceno, x.createdon,x.proforma_no, x.order_method, x.payment_gateway, x.SO_NO, x.service_cdp, x.payment_method, sum(x.Total) as Nil_Total 
from (select i.invoiceno, i.createdon, mo.invoice_no, m.proforma_no, m.payment_status, m.created_by_user, id.SO_NO,
		(case when m.created_by_user like '%ADM-%' then 'Loket' when m.created_by_user is null then 'CS' else 'User MyCDP' end) as order_method,
		(case when m.proforma_no is not null then 'Doku' else 'Non-Doku' end) as payment_gateway, 
		(case when RIGHT(id.SO_NO,3) = '2IS' then 'Import' 
				when RIGHT(id.SO_NO,3) = '2IX' then 'Extend Import'
				when RIGHT(id.SO_NO,3) = '2ES' then 'Export'
				when RIGHT(id.SO_NO,3) = '2IT' then 'Shuttle Import'
				when RIGHT(id.SO_NO,3) = '2ET' then 'Shuttle Export'
				when RIGHT(id.SO_NO,3) = '.HE' then 'Export Feeder'
				when RIGHT(id.SO_NO,3) = '.RS' then 'Domestik'
				when RIGHT(id.SO_NO,3) = 'RWH' then 'Receiving LCL'
				when RIGHT(id.SO_NO,3) = 'SWH' then 'Releasing LCL'
				when RIGHT(id.SO_NO,3) = 'RNT' then 'Receiving Non-Terminal'
				when RIGHT(id.SO_NO,3) = 'SNT' then 'Releasing Non-Terminal'
				when RIGHT(id.SO_NO,3) = 'XNT' then 'Extend Non-Terminal'
				when RIGHT(id.SO_NO,3) = 'STE' then 'Stacking Non-Terminal'
				else s.Instruction end) as service_cdp,
		id.Total, 
		(case when m.payment_method is null then i.Term else m.payment_method end) as payment_method
		from tr_invoice_h i
		left outer join mycdp_order_item mo on i.Invoiceno = mo.invoice_no
		left outer join mycdp_order m on mo.order_id = m.id
		left outer join TR_Invoice_D id on i.Invoiceno = id.Invoiceno
		left outer join so s on id.SO_NO = s.SO_NO
		where i.createdon between '2019-01-01' and '2022-12-31'and (m.payment_status = 'SUCCESS' or m.payment_status is null)) x 
where x.service_cdp is not null 
group by x.invoiceno, x.createdon, x.proforma_no,x.order_method, x.payment_gateway, x.SO_NO,x.service_cdp, x.payment_method



GO



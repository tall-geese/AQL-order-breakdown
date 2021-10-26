
-- #AQL Inspections dedicated to the transaction Qty
SELECT DISTINCT src2.*, (src2.TranQty/src2.QtyCompleted) * src2.AQLAmount[AQLforTranQty]
FROM (SELECT pt.JobNum, pt.LotNum, jh.DrawNum, pt.PartDescription, pt.TranQty, jh.QtyCompleted, 
	CASE 
		WHEN jh.PhaseID IN ('Tulip','Base','Reduct') THEN 'Tulip'
		WHEN jh.PhaseID IN ('Shank','FShank') THEN 'Shank'
		WHEN jh.PhaseID IN ('Clip','Slip', 'Solid', 'Split') THEN 'Clip/Split Ring'
		WHEN jh.PhaseID IN ('Load') THEN 'Load Ring'
		ELSE jh.PhaseID + '???'
	END AS PhaseID, jh.OrigProdQty,
			CASE
				WHEN jh.OrigProdQty < 14 THEN jh.OrigProdQty 
				WHEN jh.OrigProdQty < 151 THEN 13
				WHEN jh.OrigProdQty < 281 THEN 20
				WHEN jh.OrigProdQty < 501 THEN 29 
				WHEN jh.OrigProdQty < 1201 THEN 34
				WHEN jh.OrigProdQty < 3201 THEN 42
				ELSE 50
			END AS AQLAmount
FROM EpicorLive10.dbo.PartTran pt
Left outer join EpicorLive10.dbo.JobHead jh on pt.LotNum = jh.JobNum 
WHERE pt.TranQty > 0 and pt.JobNum LIKE '00{SO}%' AND jh.PhaseID NOT IN  ('Sub-Assy','Assy')
and JH.PhaseID IS NOT NULL) src2
UNION ALL
SELECT DISTINCT src.*, (src.TranQty/src.QtyCompleted) * src.AQLAmount[AQLforTranQty]
FROM (SELECT pt.JobNum ,jh2.JobNum[LotNum], jh2.DrawNum, jh2.PartDescription, pt.TranQty, jh2.QtyCompleted, 
	CASE 
		WHEN jh2.PhaseID IN ('Tulip','Base','Reduct') THEN 'Tulip'
		WHEN jh2.PhaseID IN ('Extension','Towers') THEN 'Extension'
		ELSE jh2.PhaseID + '???'
	END AS PhaseID, jh2.OrigProdQty,
			CASE
				WHEN jh2.OrigProdQty < 14 THEN jh2.OrigProdQty 
				WHEN jh2.OrigProdQty < 151 THEN 13
				WHEN jh2.OrigProdQty < 281 THEN 20
				WHEN jh2.OrigProdQty < 501 THEN 29 
				WHEN jh2.OrigProdQty < 1201 THEN 34
				WHEN jh2.OrigProdQty < 3201 THEN 42
				ELSE 50
			END AS AQLAmount
FROM EpicorLive10.dbo.PartTran pt
LEFT OUTER JOIN EpicorLive10.dbo.PartTran pt2 ON pt.LotNum = pt2.JobNum 
LEFT OUTER JOIN EpicorLive10.dbo.JobHead jh ON jh.JobNum = pt2.JobNum 
LEFT OUTER JOIN EpicorLive10.dbo.JobHead jh2 ON jh2.JobNum = pt2.LotNum 
WHERE pt.TranQty > 0 and pt.JobNum LIKE '00{SO}%' AND jh.PhaseID = 'Sub-Assy' AND pt2.TranType = 'STK-MTL' AND pt2.TranQty > 0)src
ORDER BY JobNum;


-----------------------------------------------------------------------------------------------------

-- #AQL Inspections dedicated to the transaction Qty (GROUP BY PhaseID)
--(Sum Tran Qty should be roughly the same for an order to be useable)
SELECT MAX(src2.JobNum)[JobNum], Min(src2.LotNum)[LotNum], min(src2.DrawNum)[DrawNum], min(src2.PartDescription)[Description], sum(src2.TranQty)[SumTranQTY], sum(src2.QtyCompleted)[SumQtyCompleted],
	src2.PhaseID, sum((src2.TranQty/src2.QtyCompleted) * src2.AQLAmount)[SumAQLAttributed], sum(src2.AQLAmount)[SUMAQLAmountUpperLim], COUNT(*)[COUNT]
from (SELECT pt.PartNum , pt.TranQty, jh.QtyCompleted, jh.ProdQty, pt.JobNum, pt.PartDescription, pt.LotNum, jh.OrigProdQty, jh.DrawNum,
	CASE
		WHEN jh.ProdQty < 14 THEN jh.ProdQty 
		WHEN jh.ProdQty < 151 THEN 13
		WHEN jh.ProdQty < 281 THEN 20
		WHEN jh.ProdQty < 501 THEN 29 
		WHEN jh.ProdQty < 1201 THEN 34
		WHEN jh.ProdQty < 3201 THEN 42
		ELSE 50
	END AS AQLAmount,
				CASE 
					WHEN jh.PhaseID IN ('Tulip','Base','Reduct', 'Sub-Assy') THEN 'Tulip/Reduc'
					WHEN jh.PhaseID IN ('Shank','FShank') THEN 'Shank'
					WHEN jh.PhaseID IN ('Clip','Slip', 'Solid', 'Split') THEN 'Clip/Split Ring'
					WHEN jh.PhaseID IN ('Load') THEN 'Load Ring'
					ELSE jh.PhaseID + '???'
				END AS PhaseID
FROM EpicorLive10.dbo.PartTran pt
Left outer join EpicorLive10.dbo.JobHead jh on pt.LotNum = jh.JobNum 
WHERE pt.TranQty > 0 and pt.JobNum like '3561%'  --and jh.PhaseID <> 'Sub-Assy'
--and JH.PhaseID IN ('Sub-Assy','screw','shank', 'tulip')
and JH.PhaseID IS NOT NULL) src2
GROUP BY src2.PhaseID;


-----------------------------------------------------------------------------------------------------
-- Transactions, Group By Job
--TODO: Inplement the AQLAmount and AQLforTransaction fields like at the top, but AQLforTran 
SELECT max(pt.PartNum)[PartNum], sum(pt.TranQty)[sumTranQty], max(pt.JobNum)[Line], max(pt.PartDescription)[Description], 
pt.LotNum, max(jh.ProdQty)[JH Qty],max(jh.QtyCompleted)[QtyCompleted], max(jh.PhaseID)[PhaseID], Count(*)[#TransactionsPerJob]
FROM EpicorLive10.dbo.PartTran pt
Left outer join EpicorLive10.dbo.JobHead jh on pt.LotNum = jh.JobNum 
WHERE pt.TranQty <> 0 and pt.JobNum like '3497%'
--and JH.PhaseID IN ('screw','shank','tulip')
and JH.PhaseID IS NOT NULL
GROUP BY pt.LotNum 
Order by max(jh.PhaseID);

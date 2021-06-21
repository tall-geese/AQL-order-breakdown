
-- #AQL Inspections dedicated to the transaction Qty
SELECT src2.*, (src2.TranQty/src2.QtyCompleted) * src2.AQLAmount[AQLforTranQty]
FROM (SELECT pt.JobNum, pt.LotNum, jh.DrawNum, pt.PartDescription, pt.TranQty, jh.QtyCompleted, 
	CASE 
		WHEN jh.PhaseID IN ('Tulip','Base','Reduct') THEN 'Tulip'
		WHEN jh.PhaseID IN ('Shank','FShank') THEN 'Shank'
		WHEN jh.PhaseID IN ('Clip','Slip') THEN 'Clip'
		WHEN jh.PhaseID IN ('Load') THEN 'Load Ring'
		ELSE jh.PhaseID + '???'
	END AS PhaseID,
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
WHERE pt.TranQty <> 0 and pt.JobNum like '3582%' AND jh.PhaseID NOT IN  ('Sub-Assy','Assy')
and JH.PhaseID IS NOT NULL) src2
ORDER BY src2.JobNum;




SELECT ld.JobNum, ld.OprSeq, ld.LaborHrs 
FROM EpicorLive10.dbo.LaborDtl ld 
WHERE (ld.OpCode = 'SWISS' OR ld.OpCode = 'FDINSP') AND ld.JobNum = 'NV14701'


-- Constructing the UNION Query (not yet finished)
-- Right now the Tran Qty is still showing the full assembly job, we care about the amount of that
-- job that has been issued to a line item
SELECT src1.JobNum, src1.TranQty, src1.LotNum, pt2.TranQty, pt2.TranType
FROM (SELECT pt.JobNum, pt.LotNum, jh.PhaseID,pt.TranQty
FROM EpicorLive10.dbo.PartTran pt 
LEFT OUTER JOIN EpicorLive10.dbo.JobHead jh ON jh.JobNum = pt.LotNum 
WHERE pt.JobNum LIKE '3574%' and pt.TranQty <> 0 AND jh.PhaseID = 'Sub-Assy' ) src1
LEFT OUTER JOIN EpicorLive10.dbo.PartTran pt2 ON src1.LotNum = pt2.JobNum
WHERE pt2.TranType = 'STK-MTL'
ORDER BY src1.JobNum

-- Ok, we need another column we can further clarify on, just select everything
SELECT pt.JobNum, pt.LotNum, jh.PhaseID,pt.TranQty
FROM EpicorLive10.dbo.PartTran pt 
LEFT OUTER JOIN EpicorLive10.dbo.JobHead jh ON jh.JobNum = pt.LotNum 
WHERE pt.JobNum LIKE '3574%' and pt.TranQty <> 0 AND jh.PhaseID = 'Sub-Assy'
ORDER BY pt.JobNum 

-------------------------------------------------------------------------------------------------
-- #AQL Inspections dedicated to the transaction Qty (GROUP BY PhaseID)
--(Sum Tran Qty should be roughly the same for an order to be useable)
SELECT Min(src2.LotNum)[LotNum], min(src2.DrawNum)[DrawNum], min(src2.PartDescription)[Description], sum(src2.TranQty)[SumTranQTY], sum(src2.QtyCompleted)[SumQtyCompleted],
	src2.PhaseID, sum((src2.TranQty/src2.QtyCompleted) * src2.AQLAmount)[SumAQLAttributed], sum(src2.AQLAmount)[SUMAQLAmountUpperLim], COUNT(*)[COUNT]
from (SELECT pt.PartNum , pt.TranQty, jh.QtyCompleted, jh.ProdQty, pt.JobNum, pt.PartDescription, pt.LotNum, jh.OrigProdQty, jh.PhaseID, jh.DrawNum,
	CASE
		WHEN jh.ProdQty < 14 THEN jh.ProdQty 
		WHEN jh.ProdQty < 151 THEN 13
		WHEN jh.ProdQty < 281 THEN 20
		WHEN jh.ProdQty < 501 THEN 29 
		WHEN jh.ProdQty < 1201 THEN 34
		WHEN jh.ProdQty < 3201 THEN 42
		ELSE 50
	END AS AQLAmount
FROM EpicorLive10.dbo.PartTran pt
Left outer join EpicorLive10.dbo.JobHead jh on pt.LotNum = jh.JobNum 
WHERE pt.TranQty <> 0 and pt.JobNum like '3582%'  and jh.PhaseID <> 'Sub-Assy'
--and JH.PhaseID IN ('Sub-Assy','screw','shank', 'tulip')
and JH.PhaseID IS NOT NULL) src2
GROUP BY src2.PhaseID


-----------------------------------------------------------------------------------------------------
-- Transactions, Group By Job
--TODO: Inplement the AQLAmount and AQLforTransaction fields like at the top, but AQLforTran 
SELECT max(pt.PartNum)[PartNum], sum(pt.TranQty)[sumTranQty], max(pt.JobNum)[Line], max(pt.PartDescription)[Description], 
pt.LotNum, max(jh.ProdQty)[JH Qty],max(jh.QtyCompleted)[QtyCompleted], max(jh.PhaseID)[PhaseID], Count(*)[#TransactionsPerJob]
FROM EpicorLive10.dbo.PartTran pt
Left outer join EpicorLive10.dbo.JobHead jh on pt.LotNum = jh.JobNum 
WHERE pt.TranQty <> 0 and pt.JobNum like '3582%'
--and JH.PhaseID IN ('screw','shank','tulip')
and JH.PhaseID IS NOT NULL
GROUP BY pt.LotNum 
Order by max(jh.PhaseID)

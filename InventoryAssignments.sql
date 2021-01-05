
-- #AQL Inspections dedicated to the transaction Qty
SELECT src2.LotNum, src2.DrawNum, src2.PartDescription, src2.TranQty, src2.QtyCompleted, src2.PhaseID, (src2.TranQty/src2.QtyCompleted) * src2.AQLAmount[AQLforTran], src2.AQLAmount
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
WHERE pt.TranQty <> 0 and pt.JobNum like '3380%'
--and JH.PhaseID IN ('Sub-Assy','screw','shank', 'tulip')
and JH.PhaseID IS NOT NULL) src2

-- #AQL Inspections dedicated to the transaction Qty (GROUP BY PhaseID)
--(Sum Tran Qty should be roughly the same for an order to be useable)
SELECT Min(src2.LotNum)[LotNum], min(src2.DrawNum)[DrawNum], min(src2.PartDescription)[Description], sum(src2.TranQty)[SumTranQTY], sum(src2.QtyCompleted)[SumQtyCompleted],
	src2.PhaseID, sum((src2.TranQty/src2.QtyCompleted) * src2.AQLAmount)[SumAQLAttributed], sum(src2.AQLAmount)[SUMAQLAmountUpperLim]
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
WHERE pt.TranQty <> 0 and pt.JobNum like '3380%'
--and JH.PhaseID IN ('Sub-Assy','screw','shank', 'tulip')
and JH.PhaseID IS NOT NULL) src2
GROUP BY src2.PhaseID



-- Transactions, Group By Job
--TODO: Inplement the AQLAmount and AQLforTransaction fields like at the top, but AQLforTran 
SELECT max(pt.PartNum)[PartNum], sum(pt.TranQty)[sumTranQty], max(pt.JobNum)[Line], max(pt.PartDescription)[Description], 
pt.LotNum, max(jh.ProdQty)[JH Qty],max(jh.QtyCompleted)[QtyCompleted], max(jh.PhaseID)[PhaseID], Count(*)[#TransactionsPerJob]
FROM EpicorLive10.dbo.PartTran pt
Left outer join EpicorLive10.dbo.JobHead jh on pt.LotNum = jh.JobNum 
WHERE pt.TranQty <> 0 and pt.JobNum like '3452%'
--and JH.PhaseID IN ('screw','shank','tulip')
and JH.PhaseID IS NOT NULL
GROUP BY pt.LotNum 
Order by max(jh.PhaseID)

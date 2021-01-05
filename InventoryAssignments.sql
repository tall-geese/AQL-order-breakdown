
-- #AQL Inspections dedicated to the transaction Qty
SELECT src2.LotNum, src2.DrawNum, src2.PartDescription, src2.TranQty, src2.PhaseID, (src2.TranQty/src2.ProdQty) * src2.AQLAmount[AQLforTran], src2.AQLAmount
from (SELECT pt.PartNum , pt.TranQty, jh.ProdQty, pt.JobNum, pt.PartDescription, pt.LotNum, jh.OrigProdQty, jh.PhaseID, jh.DrawNum,
	CASE
		WHEN jh.ProdQty < 14 THEN jh.ProdQty 
		WHEN jh.ProdQty < 151 THEN 13
		WHEN jh.ProdQty < 281 THEN 20
		WHEN jh.ProdQty < 501 THEN 29 
		WHEN jh.ProdQty < 1201 THEN 34 
		ELSE 1000000
	END AS AQLAmount
FROM EpicorLive10.dbo.PartTran pt
Left outer join EpicorLive10.dbo.JobHead jh on pt.LotNum = jh.JobNum 
WHERE pt.TranQty <> 0 and pt.JobNum like '3452%'
and JH.PhaseID IN ('Sub-Assy','screw','shank', 'tulip')) src2


-- #AQL Inspections dedicated to the transaction Qty (GROUP BY PhaseID)
--(Sum Tran Qty should be roughly the same for an order to be useable)
-- we might need to incorporate the LotNumber (from job) here. Based on the sum amount taken
-- we can decide to use the rounding method or the actual aql method
SELECT max(src2.LotNum)[LotNum], max(src2.DrawNum)[DrawNum], max(src2.PartDescription)[Description], sum(src2.TranQty)[TranQty], src2.PhaseID,
sum(ROUND((src2.TranQty/src2.ProdQty) * src2.AQLAmount, 0))[SumAQLforTran], COUNT(*)[Transactions]
from (SELECT pt.PartNum , pt.TranQty, jh.ProdQty, pt.JobNum, pt.PartDescription, pt.LotNum, jh.OrigProdQty, jh.PhaseID, jh.DrawNum,
	CASE
		WHEN jh.ProdQty < 14 THEN jh.ProdQty 
		WHEN jh.ProdQty < 151 THEN 13
		WHEN jh.ProdQty < 281 THEN 20
		WHEN jh.ProdQty < 501 THEN 29 
		WHEN jh.ProdQty < 1201 THEN 34 
		ELSE 1000000
	END AS AQLAmount
FROM EpicorLive10.dbo.PartTran pt
Left outer join EpicorLive10.dbo.JobHead jh on pt.LotNum = jh.JobNum 
WHERE pt.TranQty <> 0 and pt.JobNum like '3452%'
and JH.PhaseID IN ('Sub-Assy','screw','shank', 'tulip')) src2
Group BY src2.PhaseID 





-- Transactions, Group By Job
--TODO: Inplement the AQLAmount and AQLforTransaction fields like at the top, but AQLforTran 
SELECT max(pt.PartNum)[PartNum], sum(pt.TranQty)[sumTranQty], max(pt.JobNum)[Line], max(pt.PartDescription)[Description], 
pt.LotNum, max(jh.ProdQty)[JH Qty], max(jh.PhaseID)[PhaseID], Count(*)[Total]
FROM EpicorLive10.dbo.PartTran pt
Left outer join EpicorLive10.dbo.JobHead jh on pt.LotNum = jh.JobNum 
WHERE pt.TranQty <> 0 and pt.JobNum like '3452%'
--and JH.PhaseID IN ('Sub-Assy','screw','shank', 
and JH.PhaseID IN ('screw','shank','tulip')
GROUP BY pt.LotNum 
Order by max(jh.PhaseID)

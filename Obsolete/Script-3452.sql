-- Now the combination of the two sql statements. Both grabbing from the jobs made to order and the quantities we pull from inventory
SELECT jh.JobNum, jh.DrawNum,jh.PartDescription, jh.ProdQty, jh.PhaseID,
CASE
	WHEN jh.ProdQty < 14 THEN jh.ProdQty 
	WHEN jh.ProdQty < 151 THEN 13
	WHEN jh.ProdQty < 281 THEN 20
	WHEN jh.ProdQty < 501 THEN 29 
	WHEN jh.ProdQty < 1201 THEN 34 
	ELSE 1000000
END AS AQLAmount
FROM EpicorLive10.dbo.JobHead jh 	
Where jh.ProjectID = '3446' 
and jh.PhaseID IN ('Tulip', 'Shank','Screw')
UNION ALL
SELECT src2.LotNum, src2.DrawNum, src2.PartDescription, src2.TranQty, src2.PhaseID, ROUND((src2.TranQty/src2.ProdQty) * src2.AQLAmount, 0)[AQLAmount]
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
WHERE pt.JobNum  like '3446%' and JH.PhaseID IN ('tulip','shank','screw')) src2


-- and the grouped version
SELECT max(src.JobNum)[Job], max(src.DrawNum)[Draw], max(src.PartDescription)[Description], sum(src.prodQty)[Sum Qty], src.PhaseID, sum(src.AQLAmount)[AQL Amount], COUNT(*)[#Jobs]
FROM (SELECT jh.JobNum, jh.DrawNum,jh.PartDescription, jh.ProdQty, jh.PhaseID,
CASE
	WHEN jh.ProdQty < 14 THEN jh.ProdQty 
	WHEN jh.ProdQty < 151 THEN 13
	WHEN jh.ProdQty < 281 THEN 20
	WHEN jh.ProdQty < 501 THEN 29 
	WHEN jh.ProdQty < 1201 THEN 34 
	ELSE 1000000
END AS AQLAmount
FROM EpicorLive10.dbo.JobHead jh 	
Where jh.ProjectID = '3491' 
and jh.PhaseID IN ('Tulip', 'Shank','Screw', 'Sub-Assy')
UNION ALL
SELECT src2.LotNum, src2.DrawNum, src2.PartDescription, src2.TranQty, src2.PhaseID, ROUND((src2.TranQty/src2.ProdQty) * src2.AQLAmount, 0)[AQLAmount]
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
WHERE pt.TranQty <> 0 and pt.JobNum like '3491%'
and JH.PhaseID IN ('Sub-Assy', 'Screw', 'Shank', 'Tulip')) src2) src
GROUP BY src.PhaseID
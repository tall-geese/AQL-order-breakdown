SELECT src.*, (src.TranQty/src.QtyCompleted) * src.AQLAmount[AQLforTranQty]
FROM (SELECT pt.JobNum ,jh2.JobNum[LotNum], jh2.DrawNum, jh2.PartDescription, pt.TranQty, jh2.QtyCompleted, 
	CASE 
		WHEN jh2.PhaseID IN ('Tulip','Base','Reduct') THEN 'Tulip'
		WHEN jh2.PhaseID IN ('Extension','Towers') THEN 'Extension'
		ELSE jh2.PhaseID + '???'
	END AS PhaseID,
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
WHERE pt.TranQty > 0 and pt.JobNum Like '3574%' AND jh.PhaseID = 'Sub-Assy' AND pt2.TranType = 'STK-MTL' AND pt2.TranQty > 0)src

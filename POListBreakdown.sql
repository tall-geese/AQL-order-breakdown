--	Each Line in an Order
SELECT src.*, jh.JobComplete 	
FROM (SELECT od.OrderNum, cs.CustID, od.OrderQty, od.BasePartNum, od.OrderLine,
		CASE 
			WHEN LEN(od.OrderLine) = 1 THEN Concat(od.OrderNum,'-', '0', od.OrderLine,'-1')
			ELSE Concat(od.OrderNum,'-', od.OrderLine,'-1')
		END AS [ConJobNum]
	FROM EpicorLive10.dbo.OrderDtl od 
	LEFT OUTER JOIN EpicorLive10.dbo.Customer cs on cs.CustNum = od.CustNum
	WHERE LEN(od.OrderNum) = 4 and od.OrderNum ='3452') src
LEFT OUTER JOIN EpicorLive10.dbo.JobHead jh on src.ConJobNum = jh.JobNum 
WHERE jh.JobComplete = 1
ORDER BY src.OrderNum DESC


--	Jobs with every line completed   (This way we know it will have results in PartTran)
SELECT src.OrderNum, max(src.CustID)[Customer], sum(src.OrderQty)[Sum Qty],Count(*)[Completed Lines], max(src.BasePartNum)[PartNum],
max(src.OrderLine)[Max Line], max(src.ConJobNum)[Max Job Num], max(cast(jh.JobComplete as int))[JobComplete]	
FROM (SELECT od.OrderNum, cs.CustID, od.OrderQty, od.BasePartNum, od.OrderLine,
		CASE 
			WHEN LEN(od.OrderLine) = 1 THEN Concat(od.OrderNum,'-', '0', od.OrderLine,'-1')
			ELSE Concat(od.OrderNum,'-', od.OrderLine,'-1')
		END AS [ConJobNum]
	FROM EpicorLive10.dbo.OrderDtl od 
	LEFT OUTER JOIN EpicorLive10.dbo.Customer cs on cs.CustNum = od.CustNum
	WHERE LEN(od.OrderNum) = 4 ) src
LEFT OUTER JOIN EpicorLive10.dbo.JobHead jh on src.ConJobNum = jh.JobNum 
WHERE jh.JobComplete = 1
GROUP BY src.OrderNum
HAVING Count(*) = Max(src.OrderLine) and Count(*) <> 1
ORDER BY src.OrderNum DESC

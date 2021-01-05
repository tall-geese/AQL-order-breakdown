--THIS is currently OBSOLETE
--becuase we know now that not all jobs associated with a project
--will have that project ID 


--	Here, showing the total AQL inspections, grouped by phase ID
SELECT src.Drawnum[DrawNum], max(src.PartDescription)[Description], sum(src.OrigProdQty)[SUM-Qty Made2Order], src.PhaseID[PhasaeID], sum(src.AQLAmount)[SUM-AQLAmount], Count(*)[Jobs]
FROM (SELECT jh.ProjectID, jh.JobNum, jh.DrawNum, jh.OrigProdQty , jh.PhaseID, jh.PartDescription, 
	CASE
		WHEN jh.ProdQty < 14 THEN jh.ProdQty 
		WHEN jh.ProdQty < 151 THEN 13
		WHEN jh.ProdQty < 281 THEN 20
		WHEN jh.ProdQty < 501 THEN 29 
		WHEN jh.ProdQty < 1201 THEN 34 
		ELSE 1000000
	END AS AQLAmount
	FROM EpicorLive10.dbo.JobHead jh 	
	Where jh.ProjectID = '3372' 
--	and jh.PhaseID IN ('Tulip', 'Shank', 'Screw')
	) src
group by src.PhaseID, src.DrawNum
Order By count(*) desc

--	Here, showing the breakdown of each partNumber to prove the above is correct
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
Where jh.ProjectID = '3491' 
and jh.PhaseID IN ('Shank')
--, 'Shank','Screw','Sub-Assy')
ORDER BY jh.PhaseID 


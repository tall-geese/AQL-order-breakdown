### Notes

The big question is can we simply take the AQL dedicated to the transaction for the 
	Subassemblies and just use them as a placeholder for the tulips?
	Or will we get different results if we break up the sub assem components?
> We can't use the subassemblies as representative of the inssepctions on the components because we will often make them in different lot quantities. For example we'll make 500 tulips and do 29 inspections for that lot but they will be assigned to a job of 275 welded sub-assemblies.

Can we use the ROUND(jh.OriginalProdQty * 1.1,0) instead of the jh.ProdQty?
ProdQty doesnt dictate the amount of inspection we do in reality, however we are treating it this way
in the query and if we scrapped a lot of parts mid-way this could throw us into a different AQL Bracket

> Nope, nvm we're fine here. We dont actually apply the 10% when calculating the AQL

In every PO we can have a lines broken up becuase
they are a different length or because they are a 
different diameter.

> Can we find the minimum number of setups per Order?


-----------------------------------------------------------

### Cleaning TODO

* For some reason double posistive assignments from a load ring to a total qty that doesnt make sense.
	Were some of the parts damaged and simply needed new ones?
	- ~~**3563-05-1** ~~(Yeah that seems likely. Best to remove the positive 7 qty.)
* At least 3563-07-1 has MOD assemblies in it. This is giving non-shank components a false strong appearance here.
  * Instead of simply filtering out the 'MOD' in the description here, we should first group by job number and determine which line items having less than 4 components. See if that aligns with our conclusions
    * ~~3497-04-1 has 6~~ (they were neg quantities)
    * ~~3500-10-1, 3500-10-2, 3500-11-1~~ (These are uniplanar assemblies, they do have shanks)
    * ~~**3563-07-1, 3563-08-1, 3563-08-2** (Mods)~~
    * ~~3563-10-1 has 7~~?? (bunch of neg quantites, we filtered our now)
    * ~~3574-18-1~~ and **3574-21-1** have 6 (one of the extensions acc. got assigned twice and with diff lot numbers so we can't UNIQUE filter, must erase this)
    * **3497-01-1** and **3497-01-4** (so epicor says that these lines definitely have subassemblies assigned to them, but for some reason we are losing this information)

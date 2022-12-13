public with sharing class CaseTriggerHandler {

  public static void setEntitlement(List<Case> newCases){
    Set<Id> acctIds = new Set<Id>();
    Set<Id> assetIds = new Set<Id>();
    for (Case c : newCases) {
      acctIds.add(c.AccountId);
      assetIds.add(c.AssetId);
    }
    
    List <Entitlement> entls = [
      SELECT StartDate, Id, EndDate, 
        AccountId, AssetId
        FROM Entitlement e
        WHERE 
        (AccountId IN :acctIds OR AssetId IN:assetIds) AND
        EndDate >= TODAY AND 
        StartDate <= TODAY
    ];
    if(entls.isEmpty()==false){
      for(Case c : newCases){
        if(c.EntitlementId == null && c.AccountId != null){
          for(Entitlement e:entls){
            if(e.AccountId==c.AccountId || e.AssetId == c.AssetId){
              c.EntitlementId = e.Id;
              break;
            }
          } 
        }
      } 
    }
  }
}
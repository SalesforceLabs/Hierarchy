global with sharing class AccountHierarchyComponentData implements kkltng.HierarchyComponentInterface{
  
  global kkltng.HierarchyComponentController.hierarchyData getFullHierarchyData(String inData){
        kkltng.HierarchyComponentController.hierarchyData hdAll = new kkltng.HierarchyComponentController.hierarchyData();
        List<kkltng.HierarchyComponentController.node> nodes = new List<kkltng.HierarchyComponentController.node>();
        Map<String,Object> inDataMap = new Map<String,Object>();
      

        hdAll.nodes = nodes;
        return hdAll;
  }
  
  global kkltng.HierarchyComponentController.hierarchyData getHierarchyDataOnDemand(String inData,kkltng.HierarchyComponentController.node rootNode){
        kkltng.HierarchyComponentController.hierarchyData hdAll = new kkltng.HierarchyComponentController.hierarchyData();
        List<kkltng.HierarchyComponentController.node> nodes = new List<kkltng.HierarchyComponentController.node>();        
        Map<String,Object> inDataMap = new Map<String,Object>();
     
        
        if(inData!=null && inData!=''){
            inDataMap =  (Map<String, Object>) JSON.deserializeUntyped(inData);
        }
        
        
        String nodeType = (String) inDataMap.get('nodeType');
        String tempAccID = (String) inDataMap.get('accountId');
        Id accountID;
        
         
        if(tempAccID!=null && tempAccID != ''){
            accountID = (Id) tempAccID;
        } 
        
        Integer maxAccounts = 50000;
        try{
            maxAccounts = (Integer) inDataMap.get('maxAccounts');
        }catch(Exception e){

        }
        if(maxAccounts==null || maxAccounts <= 0){
            maxAccounts = 50000;
        }
        
        Integer noOfParents = 0;
        try{
           noOfParents =  (Integer) inDataMap.get('noOfParents');
        }catch(Exception e){

        }
        if(noOfParents == null | noOfParents > 10 || noOfParents <0 ){
            noOfParents = 10;
        }
        
             
        if(enforceCRUDFLS()){
            // Get the rootnode 
            if(rootNode==null || rootNode.id==null){
               rootNode = getRootNode(accountID,nodeType);
            }
            nodes.add(rootNode);
            hdall.rootNode= rootNode;
               
            //Get all Children
            for(List<Account> accounts:[Select Id,ParentId,Name,AccountNumber,Type,PhotoUrl,Website,Phone FROM Account where parentId = :rootNode.id LIMIT :maxAccounts]){
                for(Account acc:accounts){
                    nodes.add(getAccountNode(acc,nodeType)); 
                }
            }
           
         
            //Get all Parents
            Id thisAccountId = rootNode.parentId;
            for(Integer i=0;i<noOfParents;i++){
              List<Account> parents = [Select Id,ParentId,Name,AccountNumber,Type,PhotoUrl,Website,Phone FROM Account where id =:thisAccountId];
              if(parents.size() <=0){
                break;
              }
              if(parents[0].Id != null){
                nodes.add(getAccountNode(parents[0],nodeType)); 
              }
              
              if(parents[0].parentId == null){
                break;
              }
              
              thisAccountId = parents[0].ParentId;
            }
        }
        
        
        hdAll.nodes = nodes;
        
        return hdAll;
  }  
  
  private kkltng.HierarchyComponentController.node getAccountNode(Account acc, String nodeType){
       
        if(nodeType==null || nodeType==''){
            nodeType = 'text';
        }
        kkltng.HierarchyComponentController.node node = new kkltng.HierarchyComponentController.node();
         
        try{
            if(acc.name == null){
                 acc.name = '';
            }
            node.id = acc.id;
            node.parentid = acc.parentid;
            node.text = acc.name;
            node.imageURL = acc.PhotoUrl;
            if(nodeType=='text'){
                node.description = acc.type;
            }else{
                node.description = acc.name + ' - ' + acc.type;
            }
            node.type = nodeType;
            node.data = '{"website":"' + acc.website + '","phone":"' + acc.phone + '"}';
        }catch(Exception e){
        }
        
        return node;
  } 
  
  
   private kkltng.HierarchyComponentController.node getRootNode(Id accountId, String nodeType){
        kkltng.HierarchyComponentController.node node = new kkltng.HierarchyComponentController.node();
       
        List<Account> cAccount;
        Account cAccountRec;

        try{ 
            if(enforceCRUDFLS()){
                cAccount = [Select Id,ParentId,Name,AccountNumber,Type,PhotoUrl,Website,Phone FROM Account where id =:accountId];
                cAccountRec = cAccount[0];
            }
        }catch(Exception e){
        }
        return getAccountNode(cAccountRec,nodeType);
   }
  
   private Boolean enforceCRUDFLS(){
        if (!Schema.sObjectType.Account.fields.Id.isAccessible()){
          return false;
        }
        if (!Schema.sObjectType.Account.fields.ParentId.isAccessible()){
          return false;
        }
        if (!Schema.sObjectType.Account.fields.Name.isAccessible()){
          return false;
        }
        if (!Schema.sObjectType.Account.fields.AccountNumber.isAccessible()){
          return false;
        }
        if (!Schema.sObjectType.Account.fields.Type.isAccessible()){
          return false;
        }
        if (!Schema.sObjectType.Account.fields.PhotoUrl.isAccessible()){
          return false;
        }
        if (!Schema.sObjectType.Account.fields.Website.isAccessible()){
          return false;
        }
        if (!Schema.sObjectType.Account.fields.Phone.isAccessible()){
          return false;
        }
        return true;
    }    
        
}
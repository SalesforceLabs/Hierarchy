global with sharing class OrgHierarchyComponentData implements kkltng.HierarchyComponentInterface {
    
    global kkltng.HierarchyComponentController.hierarchyData getFullHierarchyData(String inData){
        kkltng.HierarchyComponentController.hierarchyData hdAll = new kkltng.HierarchyComponentController.hierarchyData();
        List<kkltng.HierarchyComponentController.node> nodes = new List<kkltng.HierarchyComponentController.node>();
        Map<String,Object> inDataMap = new Map<String,Object>();
        
        
        if(inData!=null && inData!=''){
            inDataMap =  (Map<String, Object>) JSON.deserializeUntyped(inData);
        }
        
        String nodeType = (String) inDataMap.get('nodeType');
        
        
        String userName = (String) inDataMap.get('userName');
        hdAll.rootNode = getRootNode(userName,nodeType);
       

        Integer maxUsers = 50000;
        try{
            maxUsers = (Integer) inDataMap.get('maxUsers');
        }catch(Exception e){

        }
        if(maxUsers==null || maxUsers <= 0){
            maxUsers = 50000;
        }
        //If user doesn't have READ access to user fields, nodes will be returned as empty and not hiearchy will be rendered
        if(enforceCRUDFLS()){
            for(List<User> users:[SELECT Id,ManagerId,Name,Title,FullPhotoUrl,phone,email FROM User WHERE UserType = 'Standard' AND IsActive=true LIMIT :maxUsers]){
                for(User u:users){
                    nodes.add(getUserNode(u,nodeType));
                }
            }
        }        
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
      
        String userName = (String) inDataMap.get('userName');
        String nodeType = (String) inDataMap.get('nodeType');

        
        if(rootNode==null || rootNode.id==null){
           rootNode = getRootNode(userName,nodeType); 
        }

        
        nodes.add(rootNode);
        hdAll.rootNode = rootNode;
        
        Integer noOfParents = 0;

        try{
           noOfParents =  (Integer) inDataMap.get('noOfParents');
        }catch(Exception e){

        }

        if(noOfParents == null | noOfParents > 10 || noOfParents <0 ){
            noOfParents = 10;
        }
        
        //Parents
            
        Id thisUserId = rootNode.parentId;

        if(enforceCRUDFLS()){
            if(thisUserId !=null || thisUserId != '' ){
                for(Integer i=0;i<noOfParents;i++){
                    List<User> parents = [Select Id, ManagerId, Name, Title,FullPhotoUrl,phone,email from User where id=:thisUserId and IsActive=true];
                    if(parents.size() <=0){
                        break;
                    }
                    if(parents[0].Id != null){
                        nodes.add(getUserNode(parents[0],nodeType)); 
                    }
                    if(parents[0].ManagerId == null){
                        break;
                    }
                    thisUserId = parents[0].ManagerId;
                }    
            }
        }
        
        //Children
        Integer maxUsers = 50000;

        try{
            maxUsers = (Integer) inDataMap.get('maxUsers');
        }catch(Exception e){

        }

        if(maxUsers==null || maxUsers <= 0){
            maxUsers = 50000;
        }

        if(enforceCRUDFLS()){
            for(List<User> users:[SELECT Id,ManagerId,Name,Title,FullPhotoUrl,phone,email FROM User WHERE ManagerId = :rootNode.id AND UserType = 'Standard' and IsActive=true LIMIT :maxUsers]){
                for(User u:users){
                    nodes.add(getUserNode(u,nodeType));
                }
            }
        }    
        
        hdAll.nodes = nodes;
        
        return hdAll;
    }       
    
    private kkltng.HierarchyComponentController.node getUserNode(User u, String nodeType){
        if(nodeType==null || nodeType==''){
            nodeType = 'text';
        }
        kkltng.HierarchyComponentController.node node = new kkltng.HierarchyComponentController.node();
        if(u.title == null){
            u.title = '';
        }
        node.id = u.id;
        node.parentid = u.ManagerId;
        node.text = u.name;
        node.imageURL = u.FullPhotoUrl;
        if(nodeType=='text'){
            node.description = u.title;
        }else{
            node.description = u.name + ' - ' + u.title;
        }
        node.type = nodeType;
        node.data = '{"email":"' + u.email + '","phone":"' + u.phone + '"}';
        return node;
    }    
    
    private kkltng.HierarchyComponentController.node getRootNode(String userName,String nodeType){
        kkltng.HierarchyComponentController.node node = new kkltng.HierarchyComponentController.node();
        Id currentId = userInfo.getUserId();
        List<User> cUser;
        User cUserRec;

        if(enforceCRUDFLS()){
            if(userName == null || userName==''){
              cUser = [SELECT Id,ManagerId,Name,Title,FullPhotoUrl,phone,email from User WHERE id=:currentId AND IsActive=true];           
            }else{
              cUser = [SELECT Id,ManagerId,Name,Title,FullPhotoUrl,phone,email from User WHERE name=:userName and UserType='Standard' and IsActive=true];  
            }
            cUserRec = cUser[0];
        }
        return getUserNode(cUserRec,nodeType);
    }

    private Boolean enforceCRUDFLS(){
        if (!Schema.sObjectType.User.fields.Id.isAccessible()){
          return false;
        }
        if (!Schema.sObjectType.User.fields.ManagerId.isAccessible()){
          return false;
        }        
        if (!Schema.sObjectType.User.fields.Name.isAccessible()){
          return false;
        }
        if (!Schema.sObjectType.User.fields.Title.isAccessible()){
          return false;
        }
        if (!Schema.sObjectType.User.fields.FullPhotoUrl.isAccessible()){
          return false;
        }
        if (!Schema.sObjectType.User.fields.phone.isAccessible()){
          return false;
        }
        if (!Schema.sObjectType.User.fields.email.isAccessible()){
          return false;
        }

        return true;
    }
    
  
}
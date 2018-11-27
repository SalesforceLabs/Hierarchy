@isTest
private class AccountHierarchyComponentTest {
    
    @isTest static void test_method_one() {

        //Create 10 parent accounts
        List<Account> parents = new List<Account>();
        
        String parentName = 'HierarchyTestParents';
        for (Integer i=0;i<10;i++){
            parents.add(new Account(name=parentName+i));
            
        }
        insert parents;
        
        //parents = [Select id, parentID, name from account where name like 'HierarchyTestParents%' ORDER BY Name];
        //parents = [Select id, parentID, name from account where name like 'HierarchyTestParents%'];
        
        Id parentid = null;
        
        for(Account acc:parents){
        
            if(parentid !=null){
                acc.parentid = parentid;
            }
            parentid = acc.id;
        }
        
        update parents;
        
        String rootName = 'HierarchyTestRoot';
        Account root = new Account(name=rootName);
        insert root;
        //root = [Select id, parentID, name from account where name = :rootName];
        
        root.parentId = parentid;
        update root;
        
        String childName = 'HierarchyTestChild';
        List<Account> children = new List<Account>();
        for (Integer j=0;j<10;j++){
            children.add(new Account(name=childName+j,parentid=root.id));
            
        }
        insert children;
        
        
        
        AccountHierarchyComponentData od = new AccountHierarchyComponentData();

        // Positive Test
        String inData = '{"nodeType":"image","accountId":"'+ root.id + '","noOfParents":2,"maxAccounts":20}';
        kkltng.HierarchyComponentController.hierarchyData hd =  od.getFullHierarchyData(inData);
        hd =  od.getHierarchyDataOnDemand(inData,null);
        
        System.assert(hd.nodes.size()==13);   //2 parents, 10 children plus root
        System.assert(hd.rootNode.text == 'HierarchyTestRoot');
        
        //Negative test; class not available
        inData = '{"nodeType":"image","accountId":"1234456","noOfParents":2,"maxAccounts":20}';
        try{
            hd =  od.getHierarchyDataOnDemand(inData,null);
        }catch(Exception e){
            System.assert(e.getMessage().contains('Invalid id'));
        }
        
        
        

    }

    
}
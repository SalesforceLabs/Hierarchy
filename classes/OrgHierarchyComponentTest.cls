@isTest
private class OrgHierarchyComponentTest {
    
    @isTest static void test_method_one() {

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 

        //Create users first
        User mgr = new User();
        mgr.firstname = 'Marc';
        mgr.lastname = 'Benioff';
        mgr.title = 'Chairman';
        mgr.email = 'marc@salesforce.com';
        mgr.phone = '415.555.5555';
        mgr.username = 'marc@orgexamplexyz.com';
        mgr.alias = 'mbeni';
        mgr.communitynickname = 'mb';
        mgr.timezonesidkey='America/Los_Angeles';
        mgr.localesidkey='en_US';
        mgr.emailencodingkey='UTF-8';
        mgr.profileid=p.id;
        mgr.languagelocalekey='en_US';
        insert mgr;

        //get the created user
        mgr = [SELECT Id,ManagerId,Name,Title,FullPhotoUrl,Phone,Email from User where Name='Marc Benioff' ];

        //Create root user;
        User self = new User();
        self.firstname = 'Keyser';
        self.lastname = 'Soze';
        self.title = 'VP of IT';
        self.email = 'keyser@salesforce.com';
        self.phone = '415.555.5555';
        self.managerid = mgr.id;
        self.username = 'self@orgexamplexyz.com';
        self.alias = 'self';
        self.communitynickname = 'self';
        self.timezonesidkey='America/Los_Angeles';
        self.localesidkey='en_US';
        self.emailencodingkey='UTF-8';
        self.profileid= p.id;
        self.languagelocalekey='en_US';
        insert self;

        self = [SELECT Id,ManagerId,Name,Title,FullPhotoUrl,Phone,Email from User where Name='Keyser Soze' ];

        List<User> reports = new List<User>();

        for(Integer i=0;i<10;i++){
            User report = new User();
            String emp = String.valueOf(i);
            report.firstname = 'Employee ' + emp;
            report.lastname = 'lastname';
            report.title = 'Employee Role ' + emp;
            report.email = 'employee' + emp + '@salesforce.com';
            report.phone = '415.555.5555';
            report.ManagerId = self.id;
            report.username = 'emp' + emp + '@orgexamplexyz.com';
            report.alias = 'emp' + emp;
            report.communitynickname =  'emp' + emp;
            report.timezonesidkey='America/Los_Angeles';
            report.localesidkey='en_US';
            report.emailencodingkey='UTF-8';
            report.profileid= p.id;
            report.languagelocalekey='en_US';

            reports.add(report);
        }
        
        insert reports;

        
        kkltng.OrgHierarchyComponentData od = new kkltng.OrgHierarchyComponentData();

        // Positive Test
        String inData = '{"nodeType":"image","userName":"Keyser Soze","noOfParents":2,"maxUsers":10}';

        kkltng.HierarchyComponentController.hierarchyData hd =  od.getFullHierarchyData(inData);
        
        System.assert(hd.nodes.size()==10);
        System.assert(hd.rootNode.text == 'Keyser Soze');
    
        //On demand test
        for(kkltng.HierarchyComponentController.node n : hd.nodes){
            if(n.text == 'Marc Benioff'){
                 hd = od.getHierarchyDataOnDemand(inData, hd.rootNode);
                 System.assert(hd.nodes.size()==12); 
                 break;
            }  
        }
       
       //Negative test
        try{
            inData = '{"nodeType":"image","userName":"Test for Error","maxUsers":10}';
            hd = od.getHierarchyDataOnDemand(inData, null);
        }catch(Exception e){
            System.assert(e.getMessage().contains('List index out of bounds'));
            System.Debug(e.getMessage());
        }  
        
        //No Parent test
       inData = '{"nodeType":"text","userName":"Marc Benioff","noOfParents":2}';
       hd =  od.getFullHierarchyData(inData);
       System.assert(hd.rootNode.text == 'Marc Benioff');
        
       hd =  od.getHierarchyDataOnDemand(inData,hd.rootNode);
       System.assert(hd.rootNode.text == 'Marc Benioff');  
       
        //Multiple parent test
       inData = '{"nodeType":"text","userName":"Employee 3 lastname","noOfParents":2,"maxUsers":10}'; 
       hd =  od.getHierarchyDataOnDemand(inData,null);
       System.assert(hd.rootNode.text == 'Employee 3 lastname');   

    }

    
}
global with sharing class HierarchyComponentController {

    global with sharing class node{
        global String id {get;set;}
        global String parentid {get;set;}
        global String type {get;set;}
        global String imageURL {get;set;}
        global String text {get;set;}
        global String description {get;set;}
        global evt rootNodeClick {get;set;}
        global evt leftIconClick {get;set;}
        global evt rightIconClick {get;set;}
        global String data {get;set;}
    }

    global with sharing class evt {
        global String name {get;set;}
        global String params{get;set;}
        //public Map<String,ANY> params {get;set;}
    }
    
    global with sharing class hierarchyData{
        global kkltng.HierarchyComponentController.node rootNode {get;set;}
        global List<kkltng.HierarchyComponentController.node> nodes {get;set;}
    }
    
    @AuraEnabled
    public static String getData(String inData,String implClsName,Boolean fullData,String rootNode){
            String ret;
            try{
                Type t = Type.forName(implClsName);
                kkltng.HierarchyComponentInterface h = (kkltng.HierarchyComponentInterface)t.newInstance();
            
                if(fullData){
                    ret = JSON.serialize(h.getFullHierarchyData(inData));
                        
                }else{
                    kkltng.HierarchyComponentController.node sNodeData = new kkltng.HierarchyComponentController.node();
                    if(rootNode!=null && rootNode!='' && rootNode!='{}'){
                        sNodeData = (kkltng.HierarchyComponentController.node) JSON.deserialize(rootNode, kkltng.HierarchyComponentController.node.class);
                    }   
                    ret = JSON.serialize(h.getHierarchyDataOnDemand(inData,sNodeData));
                }
        
            }catch(Exception e){
            }
            
            return ret;
        
    }
}
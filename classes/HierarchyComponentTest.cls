@isTest
private class HierarchyComponentTest {
    

    @isTest static void test_method_one() {
        // Test the Controller first
        String implClsName = 'kkltng.HierarchyComponentExample';
        Boolean fullData = true;
        String rootNode = null;
        String inData = null;

        kkltng.HierarchyComponentController.hierarchyData hd;

        // Positive Test
        //kkltng.HierarchyComponentController hc = new kkltng.HierarchyComponentController();
        String ret = kkltng.HierarchyComponentController.getData(inData,implClsName,fullData,rootNode);
        hd = (kkltng.HierarchyComponentController.hierarchyData) JSON.deserialize(ret, kkltng.HierarchyComponentController.hierarchyData.class);
        
        //System.assert(ret.length()>0); // all good here
        System.assert(hd.nodes.size()>0);
        System.Debug('First Test done');
    
       //Negative test; class not available
       implClsName = 'kkltng.Thisisabadclass';
       try{
            ret = kkltng.HierarchyComponentController.getData(inData,implClsName,fullData,rootNode);
        }catch(Exception e){
            System.assert(e.getMessage().contains('Attempt to de-reference a null object'));
            System.Debug('Second Test done');
        }


        //Check if the rootnode sent in the same as the one coming back
        implClsName = 'kkltng.HierarchyComponentExample';
        fullData = false;
        rootNode = '{"id":"0"}';
        inData = null;
        ret = kkltng.HierarchyComponentController.getData(inData,implClsName,fullData,rootNode);
        hd = (kkltng.HierarchyComponentController.hierarchyData) JSON.deserialize(ret, kkltng.HierarchyComponentController.hierarchyData.class);
        kkltng.HierarchyComponentController.node sNodeData = new kkltng.HierarchyComponentController.node();
        sNodeData = (kkltng.HierarchyComponentController.node) JSON.deserialize(rootNode, kkltng.HierarchyComponentController.node.class);
        System.assertEquals(hd.rootNode.id,sNodeData.id);
        System.Debug('Third Test done');
    }
    
    
}
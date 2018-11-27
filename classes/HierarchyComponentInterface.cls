global interface HierarchyComponentInterface {
    kkltng.HierarchyComponentController.hierarchyData getFullHierarchyData(String inData);
    kkltng.HierarchyComponentController.hierarchyData getHierarchyDataOnDemand(String inData,kkltng.HierarchyComponentController.node rootNode);
}
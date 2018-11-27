({
	frameApexInput: function(component,event) {
			var inData = {}
        	//inData.accountId = component.get("v.accountId");
            inData.accountId = component.get("v.recordId");
        	inData.noOfParents = component.get("v.noOfParents");
        	inData.maxAccounts = component.get("v.noOfRecords");
        	var nodeType = component.get("v.nodeType");
        	try{
        		nodeType = nodeType.toLowerCase();
        	}catch(e){

        	}
        	inData.nodeType = nodeType;
   			component.set('v.apexInput',JSON.stringify(inData));
	}
})
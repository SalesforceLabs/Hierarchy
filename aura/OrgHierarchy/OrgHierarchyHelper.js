({
	frameApexInput: function(component,event) {
		var inData = {};
        inData.userName = component.get("v.userName");
        inData.noOfParents = component.get("v.noOfParents");
        inData.maxUsers = component.get("v.noOfRecords");
        inData.nodeType = component.get("v.nodeType");
   		component.set('v.apexInput',JSON.stringify(inData));
	}
})
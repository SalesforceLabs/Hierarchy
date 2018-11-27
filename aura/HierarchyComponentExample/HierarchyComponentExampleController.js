({
	

	rootNodeClicked: function(component, event, helper) {
		//console.log('Root Node Cicked', event);
		//console.log("Node is ", event.getParam('node'));
		
	},

	leftIconClicked: function(component, event, helper) {
		//console.log('Left Icon Cicked', event);
		//console.log("Node is ", event.getParam('node'));
	},

	righticonclicked: function(component, event, helper) {
		//console.log('Right Icon Cicked', event);
		//console.log("Node is ", event.getParam('node'));
	},

	nodeClicked: function(component, event, helper) {
		//console.log('Node Cicked', event);
		//console.log("Node is ", event.getParam('node'));
		// reset hierarchy data here... (may be call an api)
		
		var sc = event.getSource();
		try{
			var evt = sc.getEvent('rebuildhierarchy');
			evt.fire();
			//console.log('Event triggered successfully', evt);
		}catch(e){
			//console.log('Exception is ', e);
		}
			
	},

	doInit:function(component,event,helper){
		component.set("v.hData",JSON.stringify(helper.getData()));		
	}

	


})
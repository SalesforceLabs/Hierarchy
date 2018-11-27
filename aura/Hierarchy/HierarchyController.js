({
	
	afterScriptsLoaded:function(component,event,helper){
		helper.getData(component);
	},

	doInit:function(component,event,helper){
		//helper.calculateNodesToDisplay(component);
		helper.frameIconStyleForRootNode(component);
		//window.onresize = function(event) {
    		//helper.calculateNodesToDisplay(component);
		//};
	},

	doneRendering:function(component,event,helper){
		
		helper.calculateNodesToDisplay(component);
	},

	navigateHierarchyMain:function(component,event,helper){
		helper.navigateHierarchy(component,event,true);
	},


	navigateHierarchy:function(component,event,helper){
		helper.navigateHierarchy(component,event,false);
	},

	rebuildHierarchy:function(component,event,helper){
		helper.getData(component);
	},

	showAllParents:function(component,event,helper){
		component.set("v.moreView",true);
		component.set("v.mitems",component.get("v.parents"));
	},

	showAllChildren:function(component,event,helper){
		component.set("v.moreView",true);
		component.set("v.mitems",component.get("v.children"));
	},

	showFilter:function(component,event,helper){
		component.set("v.filter",'');
		component.set("v.filteredList",null);
		component.set("v.showFilter",true);
	},

	hideFilter:function(component,event,helper){
		component.set("v.showFilter",false);
	},

	filter:function(component,event,helper){
		helper.getFilteredList(component,event.getSource().get("v.value"));
	},

	hideSearchList:function(component,event,helper){
		helper.hideSearchList(component)
	},

	selfClicked:function(component,event,helper){
		var node = helper.getNode(component,event);
		if(node.rootNodeClick && node.rootNodeClick.name!=='' ){
			helper.handleNodeEvents(node.rootNodeClick);
		}else{
			helper.raiseNodeEvents(component,event,'rootndclick');	
		}
	},

	leftIconClicked:function(component,event,helper){
		var node = helper.getNode(component,event);

		if(node.leftIconClick && node.leftIconClick.name!==''){
			helper.handleNodeEvents(node.leftIconClick);
		}else{
			helper.raiseNodeEvents(component,event,'lefticonclick');	
		}
	},

	rightIconClicked:function(component,event,helper){
		var node = helper.getNode(component,event);
		if(node.rightIconClick && node.rightIconClick.name!==''){
			helper.handleNodeEvents(node.rightIconClick);
		}else{
			helper.raiseNodeEvents(component,event,'righticonclick');	
		}

	}

})
({

    showToast: function(component, type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "mode": "sticky",
            "title": title,
            "message": message
        });
        toastEvent.fire();
    },

    getData: function(component) {
        var apexClassForData = component.get("v.apexClassForData");
        var hierarchyData = component.get("v.hierarchyData");
        if (apexClassForData != null && apexClassForData.length > 0) {
            this.callApex(component);
        } else if (hierarchyData != null && hierarchyData.length > 0) {
            this.callApi(component);
        }

    },

    callApex: function(component) {
        var apexMethod = component.get("c.getData");
        var rootNode = component.get("v.rootNode");
        if (typeof rootNode == 'undefined' || rootNode == null) {
            rootNode = {};
        }
        //console.log('root node is', rootNode);
        //console.log('API Apex Input is ', component.get("v.apexInput"));

        apexMethod.setParams({
            inData: component.get("v.apexInput"),
            implClsName: component.get("v.apexClassForData"),
            fullData: component.get("v.fetchFullData"),
            rootNode: JSON.stringify(rootNode)
        });

        apexMethod.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //console.log('response is ',response.getReturnValue());
                this.createHierarchy(component, JSON.parse(response.getReturnValue()));
            } else if (state === "ERROR") {
                //$A.error("Error calling Apex class:" + response.getError()[0].message);
                this.showToast(component,'error','Error in Apex',response.getError()[0].message);
            }
        });
        $A.enqueueAction(apexMethod);
    },

    callApi: function(component) {
        this.createHierarchy(component, JSON.parse(component.get("v.hierarchyData")));
    },

    createHierarchy: function(component, hd) {
        try {
            component.set("v.hd", hd.nodes);
            var rn = component.get("v.rootNode");
            if (typeof rn == "undefined" || rn == null || rn === "") {
                if (typeof hd.rootNode == "undefined" || hd.rootNode == null || hd.rootNode.id == null) {
                    this.getMainParent(component);
                    component.set("v.rootNode", component.get("v.mainParent"));
                } else {
                    component.set("v.rootNode", hd.rootNode);
                }
            }
            this.getHierarchyFromArray(component, component.get("v.rootNode").id, true);
        } catch (e) {

        }
    },

    showSearchList: function(component) {
        $A.util.removeClass(component.find('searchClose'), 'slds-hide')
        $A.util.removeClass(component.find('searchList'), 'slds-hide')
        $A.util.addClass(component.find('main'), 'slds-hide')
    },

    hideSearchList: function(component) {
        $A.util.addClass(component.find('searchClose'), 'slds-hide')
        $A.util.addClass(component.find('searchList'), 'slds-hide')
        $A.util.removeClass(component.find('main'), 'slds-hide')
        component.set('v.filter', '');
    },

    getFilteredList: function(component, value) {
        var hd = component.get("v.hd");
        if (value != null && value.length > 0) {
            this.showSearchList(component)
            var filteredList = _.filter(hd, function(item) {
                return (item.text.toLowerCase().indexOf(value.toLowerCase()) > -1);
            });
        } else {
            this.hideSearchList(component)

        }
        component.set('v.filteredList', filteredList);
    },

    getMainParent: function(component) {
        var hd = component.get("v.hd");
        var parent = _.find(hd, function(child) {
            return (typeof child.parentid == "undefined" || child.parentid == null);
        });
        component.set("v.mainParent", parent);
    },

    getHierarchyFromArray: function(component, selfid, fullData) {

        var hd = component.get("v.hd");
        var self = _.find(hd, function(child) {
            return (child.id === selfid);
        });

        component.set("v.rootNode", self);

        if (!fullData) {
            this.getData(component);
        } else {
            //console.log('Self is', self);
            if (!_.isUndefined(self)) {
                self.imageStyle = 'background-image:url(' + self.imageURL + ')';
                component.set("v.self", self);
                this.getAllParentsFromId(component, hd, self, []);
                this.getAllChildrenFromId(component, hd, self);
            }
        }
        //component.set("v.showSpinner",false);

        //var el = component.find('spinner').getElement();
        //$A.util.addClass(el, 'hide');
        //console.log('I was here',el);
    },

    navigateHierarchy: function(component, event, isMain) {
        var target;
        if (event.getSource) {
            target = event.getSource();
        } else {
            target = event.target.id;
        }

        component.set("v.moreView", false);
        component.set("v.showFilter", false);
        this.hideSearchList(component)

        if (isMain) {
            var apexClassForData = component.get("v.apexClassForData");
            if ((apexClassForData != null && apexClassForData.length > 0) || component.get("v.fetchFullData")) {
                this.getHierarchyFromArray(component, target, component.get("v.fetchFullData"));
            } else {
                this.raiseNodeEvents(component, event, 'ndclick');
                //component.set("v.showSpinner",true);
                //var el = component.find('spinner').getElement();
                //$A.util.removeClass(el, 'hide');
            }
        } else {
            this.getHierarchyFromArray(component, target, true);

        }

    },

    getAllParentsFromId: function(component, hd, self, parents) {
        var vpIndex = 0;
        var parent = _.find(hd, function(child) {
            return (child.id === self.parentid);
        });

        if (!_.isUndefined(parent)) {
            parent.imageStyle = 'background-image:url(' + parent.imageURL + ')';
            parents.unshift(parent);
            this.getAllParentsFromId(component, hd, parent, parents);
        } else {
            component.set("v.parents", parents);
            var maxNoOfParents = component.get("v.pNos");
            if (_.size(parents) > maxNoOfParents) {
                component.set("v.pMore", true);
                vpIndex = _.size(parents) - maxNoOfParents + 1;
                component.set("v.vparents", _.slice(parents, vpIndex, _.size(parents)));
                component.set("v.vpIndex", vpIndex);
            } else {
                component.set("v.pMore", false);
                component.set("v.vparents", parents);
                component.set("v.vpIndex", vpIndex);
            }
        }
    },

    getAllChildrenFromId: function(component, hd, self) {
        var vcIndex = 0;
        var children = _.filter(hd, function(child) {
            return (child.parentid === self.id);
        });
        _.each(children, function(child) {
            child.imageStyle = 'background-image:url(' + child.imageURL + ')';
        })
        component.set("v.children", children);
        var maxNoOfChildren = component.get("v.cNos");
        //console.log('Max number of children', maxNoOfChildren);
        if (_.size(children) > maxNoOfChildren) {
            component.set("v.cMore", true);
            vcIndex = _.size(children) - maxNoOfChildren + 1;
            component.set("v.vchildren", _.slice(children, vcIndex, _.size(children)));
            component.set("v.vcIndex", vcIndex);
        } else {
            component.set("v.cMore", false);
            component.set("v.vchildren", children);
            component.set("v.vcIndex", vcIndex);
        }
        //console.log('visible children', component.get("v.vchildren"));
        //console.log('more children?', component.get("v.vcIndex"));
    },

    calculateNodesToDisplay: function(component) {
        try {
            var S1App = false;
            var device = $A.get("$Browser.formFactor");
            try {
                var urlEvent = $A.get("e.force:navigateToURL");
                if (urlEvent) S1App = true;
            } catch (e) {}
            var parentsContainer = component.find('parentsContainer').getElement();
            var childrenContainer = component.find('childrenContainer').getElement();

            //var w = $A.util.getWindowSize()
            var w = {}

            var mainDiv = component.find('main').getElement();
            w.height = screen.height
            w.width = childrenContainer.clientWidth;
            //console.log('w is ', w);

            var pcHeight = (w.height - 15) / 2 - 10; //5px for top padding
            //var pcHeight = parentsContainer.clientHeight;

            var cWidth = w.width - 50; //15px for padding and 15 for buffer
            //var cWidth = childrenContainer.clientWidth;

            if (S1App && device !== 'PHONE' && cWidth > 1024) cWidth = 1024;
            //DF demo bug.
            var ndWidth = 80; //with padding of 5px each
            /*
            if(device=='PHONE'){
                var ndWidth = 100;  //100px from CSS + 10 padding
            }else{
                var ndWidth = 110;
            }
            */

            var ndHeight = 35; //35px from CSS
            var connHeight = 35; // 35px from CSS
            var noOfParentNodes = Math.floor(pcHeight / (ndHeight + connHeight));
            var noOfChildNodes = Math.floor(cWidth / ndWidth);
            component.set("v.pNos", noOfParentNodes);
            component.set("v.cNos", noOfChildNodes);



        } catch (e) {
            //console.log('Exception is ', e)
        }

    },

    frameIconStyleForRootNode: function(component) {
        var leftIconURL = component.get("v.rnIconLeftURL")
        var rightIconURL = component.get("v.rnIconRightURL")
        if (leftIconURL != null && leftIconURL.length > 0) {
            component.set("v.showLeftIcon", true);
            component.set("v.leftIconStyle", 'background-image:url(' + leftIconURL + ')');

        };

        if (rightIconURL != null && rightIconURL.length > 0) {
            component.set("v.showRightIcon", true);
            component.set("v.rightIconStyle", 'background-image:url(' + rightIconURL + ')');
        };

    },

    getNode: function(component, event) {
        var target;
        if (event.getSource) {
            target = event.getSource();
        } else {
            target = event.target.id;
        }
        var hd = component.get("v.hd");
        var self = _.find(hd, function(child) {
            return (child.id === target);
        });
        //console.log(self);
        return self;

    },

    handleNodeEvents: function(nodeEvt) {
        try {
            var evt = $A.get(nodeEvt.name);
            evt.setParams(JSON.parse(nodeEvt.params));
            evt.fire();
        } catch (e) {
            //console.log('Exception is ', e);
            //$A.error("Error calling event" + e);
        }
    },

    raiseNodeEvents: function(component, event, compEvtName) {
        var self = this.getNode(component, event);
        try {
            var evt = component.getEvent(compEvtName);
            evt.setParams({ "node": self })
            evt.fire();
            //console.log('Fired event ', compEvtName, self);
        } catch (e) {
            //$A.log('Error in firing the event: ' + compEvtName,e);
        }
    }

})
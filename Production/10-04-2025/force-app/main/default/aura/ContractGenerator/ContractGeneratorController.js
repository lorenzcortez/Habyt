({
	doSaveContract : function(component, event, helper) {
        component.set('v.working', true);
		helper.save(component,helper)
	}
})
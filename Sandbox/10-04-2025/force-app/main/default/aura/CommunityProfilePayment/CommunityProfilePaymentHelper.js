({
    launch: function(action, cb, nostore) {
        if (!nostore) action.setStorable();
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") cb(null, response.getReturnValue())
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) cb(errors[0].message)
                    else cb(errors);
                }
            }
        });
        $A.enqueueAction(action);
    },
    toUrl : function(obj,parent,helper) {
        return Object.keys(obj).map(function(key){ 
            var formattedKey = (parent) ? parent +'['+encodeURIComponent(key)+']' : encodeURIComponent(key)
            if(typeof obj[key] == 'object') return helper.toUrl(obj[key],formattedKey,helper)
            else return formattedKey + '=' + encodeURIComponent(obj[key]); 
        }).join('&');
    }
})
({
    apex : function(cmp, methodName, params){
        return new Promise($A.getCallback(function(resolve, reject) {
            var action = cmp.get(methodName);
            action.setParams(params);
            action.setCallback(self, function(res) {
                var state = res.getState();
                if(state === 'SUCCESS') {
                    resolve(res.getReturnValue());
                } else if(state === 'ERROR') {
                    reject(action.getError())
                }
            });
            $A.enqueueAction(action);
        }));
    },
    toUrl : function(obj,parent,helper) {
        return Object.keys(obj).map(function(key){ 
            var formattedKey = (parent) ? parent +'['+encodeURIComponent(key)+']' : encodeURIComponent(key)
            if(typeof obj[key] == 'object') return helper.toUrl(obj[key],formattedKey,helper)
            else return formattedKey + '=' + encodeURIComponent(obj[key]); 
        }).join('&');
    },
    log : function() {
        var debug = true
        if(debug) console.log.apply(console, arguments);
    },
    showError : function(error) {
       if(this) this.log('showError',error)
       else console.log('scriptError',error)
       
       const errorMap = { }
       
       if(Array.isArray(error)) error = error[0]
       
       if(error["message"]) error = error["message"]
       
       var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":"error",
            "mode": "sticky",
            "title": "Error",
            "message": errorMap[error] || JSON.stringify(error),
            
        });
        toastEvent.fire();
    }
})
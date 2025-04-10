public class GetAvailableProducts {
    public class Input{
       	/*public Input(Date d1, Date d2, id Home){
            dateOne = d1;
            dateTwo = d2;
            home = Home;
			String family;
        }*/
        
    	@invocableVariable (required=true)
    	public date dateOne;
        
    	@invocableVariable
    	public date dateTwo;
        
        @invocableVariable
        public id home;
        
        @invocableVariable
        public String family;
    }
	@invocableMethod
    public static List<List<Product2>> getAvailableProducts(List<Input> inputs){
        //renewal Opps don't have an end Date, so set the end date to 20 years from now for now
        //if (inputs[0].dateTwo == null)
        //{
        //    inputs[0].dateTwo = Date.today() + (365 * 20);
        //}
  
        // select all the orders that would interfere with the dates of the desired order, put all their product IDs in a list     
        List<Order> productOrders = [SELECT id, Product__r.id, Product__r.Home__c, Product__r.family from ORDER WHERE 
        ((effectiveDate <= :inputs[0].dateOne and endDate >= :inputs[0].dateOne) or 
        (effectiveDate <= :inputs[0].dateTwo and endDate >= :inputs[0].dateTwo) or
        (effectiveDate >= :inputs[0].dateOne and endDate <= :inputs[0].dateTwo)) and
        Product__r.Home__c =: inputs[0].home and product__r.family = :inputs[0].family and status != 'Cancelled'];
        
                                     //This is where all the ids are put in a list
        List<id> productIDs = new List<id>();
        for(Order o : productOrders){
        	productIDs.add(o.Product__r.id);
        }
        //Select products that aren't in that list
        List<List<Product2>> products = new List<List<Product2>>();
        products.add([SELECT id, Name from Product2 WHERE
        id not in : productIDs and home__c = :inputs[0].home and family = :inputs[0].family and isActive = true]); 
        return products;
    }
    
    
}
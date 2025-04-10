@isTest(SeeAllData=true)
public class GetAvailableProductsTestClass {
    
    @isTest
    public static void test() {
        date date1 = Date.newInstance(2023, 3, 1);
        date date2 = Date.newInstance(2024, 3, 1);
        //Home__c h = [SELECT id, Name from home__c where Name = 'Terry'];
	//Property__c h = [SELECT id, Name from Property__c where Name = 'Terry'];

        //START
        City__c c = new City__c();
        c.Name = 'Seattle1';
        insert c;

        //START
        Brand__c br = new Brand__c(Name = 'Test Brand',
                                    APINameBrand__c = 'Test Brand API');
        insert br;
        //END

        Property__c h = new Property__c();
        h.Name = 'testproperty';
        h.City_object__c = c.id;
        h.Home_Manager_User__c = UserInfo.getUserId();
        h.Property_Services_Move_out_Task__c = 'Yes';
        h.Maintenance_Tech__c = userinfo.getuserId();
        h.Porter__c = UserInfo.getuserId();
        h.Onboarding_and_Experience_Manager__c = userInfo.getUserId();
        h.Maintenance_Tech__c = UserInfo.getUserId();
        h.Pre_Move_Out_Inspection_Task__c = 'Yes';
        h.Post_Move_Out_Inspection_Task__c = 'Yes';
        h.Leasing_Specialist_Move_out_Task__c = 'Yes';
        h.Onsite_Move_out_Task__c = 'Yes';
        h.Sourcefit_Move_out_Task__c = 'Yes';
        h.Resident_Services_Coordinator__c = UserInfo.getUserId();
        h.Area_Manager__c = UserInfo.getUserId();
        h.BrandRef__c = br.Id;
        insert h;
        //END

        id homeId = h.id;
        GetAvailableProducts.Input testInputs = new GetAvailableProducts.Input();
        testInputs.dateOne = date1;
        testInputs.dateTwo = date2;
        testInputs.home = homeId;
        testInputs.family = 'Parking Spot';
        List<GetAvailableProducts.Input> ttl = new List<GetAvailableProducts.Input>();
        ttl.add(testInputs);
  	 	List<List<Product2>> testList = new List<List<Product2>>();
        testList = GetAvailableProducts.getAvailableProducts(ttl);
       	List<Order> testOrderList = [SELECT id from ORDER WHERE
        ((effectiveDate <=: date1 and endDate >= :date1) or 
        (effectiveDate <= :date2 and endDate >= :date2) or 
        (effectiveDate >= :date1 and endDate <= :date2)) and 
        Product__r.Home__c = :homeId and product__r.family = 'Parking Spot'];
        //id testId = testOrderList[0].id;
        
        //System.assertEquals(testList[0][0].id, testId);
        
    }
    
}
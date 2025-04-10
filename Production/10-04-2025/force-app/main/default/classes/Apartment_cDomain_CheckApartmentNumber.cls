public without sharing class Apartment_cDomain_CheckApartmentNumber extends Paua_SObjectDomain {

    public override void init() {
        domainType = Apartment_cDomain_CheckApartmentNumber.class;
    }

    public override void beforeUpdate() {
        ApartmentService service = new ApartmentService();
        service.checkApartmentNumber((List<Apartment__c>) Trigger.new, (Map<Id, Apartment__c>) Trigger.oldMap);
    }

}
public without sharing class BookingFlowController {
    @AuraEnabled(cacheable=true)
    public static Map<String, List<Neighbourhood__c>> getDistricts() {
        Map<String, List<Neighbourhood__c>> districts;

        try {
            IntegrationService service = new IntegrationService();
            districts = service.getDistrictsByCity();
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }

        return districts;
    }

    @AuraEnabled
    public static IntegrationModels.RoomResponsePayload getRooms(Map<String, String> parameters){
        try {
            IntegrationService service = new IntegrationService();

            IntegrationModels.RoomRequestPayload input = new IntegrationModels.RoomRequestPayload(parameters);
            IntegrationModels.RoomResponsePayload response = service.retrieveRooms(input);

            return response;
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static IntegrationModels.ContractResponsePayload submitApplication(String userPayload, String startOfContract) {
        try {
            IntegrationService service = new IntegrationService();

            IntegrationModels.UserRequestPayload userInput = (IntegrationModels.UserRequestPayload) JSON.deserialize(userPayload, IntegrationModels.UserRequestPayload.class);
            IntegrationModels.UserResponsePayload userResponse = service.upsertUser(userInput);

            // if (userResponse.status != PersonAccountService.STATUS_CUSTOMER_BLOCKED) {
                IntegrationModels.ContractRequestPayload contractInput = new IntegrationModels.ContractRequestPayload();
                contractInput.userId = userResponse.userId;
                contractInput.referenceId = userInput.referenceId;
                contractInput.startOfContract = startOfContract;
                // TODO: define BookingPlatform as a static member of the CustomerOpportunityService
                return service.insertContract(contractInput, 'Booking Page');
            // }
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static IntegrationModels.CalculationFirstMonthResponsePayload getFirstRent(Map<String, String> parameters) {
        try {
            IntegrationService service = new IntegrationService();

            IntegrationModels.CalculationFirstMonthRequestPayload params = new IntegrationModels.CalculationFirstMonthRequestPayload(parameters);
            return service.calculateFirstRent(params);
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<String> getBrandCities(String brandApiName){
        try {
            IntegrationService service = new IntegrationService();
            return service.getCitiesByBrand(brandApiName);
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Phone_Country_Code__mdt> getPhoneCodes() {        
        List<Phone_Country_Code__mdt> phoneCodes;

        try {
            IntegrationService service = new IntegrationService();
            phoneCodes = service.getPhoneCodes();
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }

        return phoneCodes;
    }
}
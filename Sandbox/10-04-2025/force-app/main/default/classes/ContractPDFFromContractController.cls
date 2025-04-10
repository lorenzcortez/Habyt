public without sharing class ContractPDFFromContractController {

    public List<ContractItem__c> contractItems {get; set;}
    public List<ContractItem__c> contractItemsAddItems {get; set;}
    public List<ContractItem__c> contractItemsGeneral {get; set;}
    public List<ContractItem__c> nonPermanentCharges {get; set;}
    public List<ContractItem__c> allContractItems {get; set;}

    public Decimal depositAmount {get; set;}
    public Decimal totalAmount {get; set;}
    public Decimal monthlyDiscountAmount {get; set;}
    public Decimal months {get; set;}
    public Decimal amountDiscounts {get; set;}
    public Decimal generalBalance {get; set;}

    public static final String DEPOSIT_PROD = 'Deposit';
    public static final String DISCOUNT_PROD = 'Discount';
    
    public static final String PRODUCT_RENT_NAME = 'Rent';
    public static final String PRODUCT_RECURRING_NAME = 'Recurring Item';
    public static final String PRODUCT_ONE_OFF_NAME = 'One-off item';
    public static final String PRODUCT_MEMBERSHIP_NAME = 'Membership Fee';

    public Contract contract {get; set;}
    public String brand {get; set;}

    public String curatedRentalContract {get; set;}
    public String curatedInternetUse {get; set;}
    public String curatedHouseRules {get; set;}

    public Boolean showOneTable {get; set;}

    /**
     * 
        Case 1
        When a contract only has 1 and 2 -> show one table in the document with the balance and add header
        text to the table with "This is your permanent rent for the Room {Room.Name}"

        Case 2:
        When there is 1 and at least one contract item with 3 or 4 -> show the table with 
        rent and permanent discounts/charges + an additional table with rent, permanent 
        and non-permanent discounts/charges (the addtional table is waht we already display
        in the current PDF version) and add a header text to the table with "This is your temporary
        rent for the Room {Room.Name} for the first X months" (X is the minimum months that one of 
        the additonal non-temporary discounts/charges is valid) -> show this table below the signature 
        line in the document
    */
    public ContractPDFFromContractController () {
        totalAmount = 0;
        monthlyDiscountAmount = 0;
        contractItemsAddItems = new List<ContractItem__c>();
        contractItemsGeneral = new List<ContractItem__c>();
        Id contractId = Apexpages.currentPage().getParameters().get('id');

        contract = (Contract) Paua_SelectorHandler.getSelector(CustomerContractSelectors.Contracts.class)
            .setParameter('id', contractId)
            .query().get(0);
        contractItems = Paua_SelectorHandler.getSelector(CustomerContractSelectors.ContractItems.class)
            .setParameter('id', contractId)
            .query();

        // We need to perform some manual replacement on the terms and conditions from the BillingEntity.
        Decimal monthlyPrice = 0;
        Decimal generalBalance = 0;
        Date startDate = contract.StartDate;
        depositAmount = 0;

        for (ContractItem__c  iCi: contractItems) {
            if(iCi.ProductRef__r.Name == DEPOSIT_PROD) {
                depositAmount = iCi.PriceTrig__c;
            } else if(iCi.ProductRef__r.Name == DISCOUNT_PROD) {
                totalAmount -= iCi.PriceTrig__c;
            } else {
                totalAmount += iCi.PriceTrig__c;
                // We only consider the rent product as the monthly price.
                if (iCi.ProductRef__r.RecordTypeId == CustomerContractService.PRODUCT_RT_ID_RENT) {
                    monthlyPrice = iCi.PriceTrig__c;
                }
            }
        }

        for (ContractItem__c iContractItem: contractItems) {
            Boolean rentContract = iContractItem.ProductRef__r.Name == PRODUCT_RENT_NAME;
            Boolean membershipProduct = iContractItem.ProductRef__r.Name == PRODUCT_MEMBERSHIP_NAME;
            Boolean permanentCharge = iContractItem.ProductRef__r.Name == PRODUCT_RECURRING_NAME && iContractItem.NumberOfMonths__c == null;

            if(rentContract || permanentCharge || membershipProduct) {
                contractItemsGeneral.add(iContractItem);
                generalBalance += iContractItem.PriceTrig__c;
            }

            /*
            if (iContractItem.ProductRef__r.RecordTypeId == CustomerContractService.PRODUCT_RT_ID_ADD_ITEM 
                && (iContractItem.ProductRef__r.FrequencyPick__c == CustomerContractService.FREQ_ONE_OFF
                || (iContractItem.ProductRef__r.FrequencyPick__c == CustomerContractService.FREQ_RECURRING 
                && iContractItem.NumberOfMonths__c != null))) 
            {
                monthlyDiscountAmount+= iContractItem.PriceTrig__c;
                contractItemsAddItems.add(iContractItem);
            } else if (iContractItem.ProductRef__r.Name != 'Deposit' && 
                iContractItem.ProductRef__r.RecordTypeId != CustomerContractService.PRODUCT_RT_ID_MEMBERSHIP) 
            {
                contractItemsGeneral.add(iContractItem);
                generalBalance += iContractItem.PriceTrig__c;
            }*/
        }

        Decimal months = null;
        Decimal amountDiscounts = 0;
        List<ContractItem__c> nonPermanentCharges = new List<ContractItem__c>();
        for(ContractItem__c item : contractItems) {
            Boolean rentContract = item.ProductRef__r.Name == PRODUCT_RENT_NAME;
            Boolean permanentCharge = item.ProductRef__r.Name == PRODUCT_RECURRING_NAME && item.NumberOfMonths__c == null;

            Boolean oneOffDiscount = item.ProductRef__r.Name == PRODUCT_ONE_OFF_NAME;
            Boolean nonPermanentCharge = item.ProductRef__r.Name == PRODUCT_RECURRING_NAME && item.NumberOfMonths__c > 0;

            if(nonPermanentCharge || oneOffDiscount) {
                nonPermanentCharges.add(item);
            }
        }

        this.allContractItems = new List<ContractItem__c>(contractItemsGeneral);
        for(ContractItem__c nonPermanentItem : nonPermanentCharges) {
            Boolean nonPermanentCharge = nonPermanentItem.ProductRef__r.Name == PRODUCT_RECURRING_NAME && nonPermanentItem.NumberOfMonths__c > 0;

            if(nonPermanentCharge && (months == null || months < nonPermanentItem.NumberOfMonths__c)) {
                months = nonPermanentItem.NumberOfMonths__c;
            } else if (nonPermanentItem.ProductRef__r.Name == PRODUCT_ONE_OFF_NAME) {
                months = 1;
            }

            amountDiscounts += nonPermanentItem.PriceTrig__c;

            Boolean itemInList = false;
            for(ContractItem__c item : allContractItems) {
                if(item.Id == nonPermanentItem.Id) {
                    itemInList = true;
                    break;
                }
            }

            if(!itemInList) {
                allContractItems.add(nonPermanentItem);
            }
        }

        this.nonPermanentCharges = nonPermanentCharges;
        this.showOneTable = nonPermanentCharges.size() == 0;
        this.months = months;
        this.generalBalance = generalBalance;

        brand = contract.Room__r?.Property__r?.BrandRef__c != null ? 
            contract.Room__r.Property__r.BrandRef__r.APINameBrand__c : 
            contract.ApartmentRef__r?.PropertyRef__r?.BrandRef__r?.APINameBrand__c;
        
        if (String.isNotBlank(brand)) {
            brand = 'logos/' + brand.toLowerCase() + '.jpg';
        }

        curatedRentalContract = contract.Billing_Entity__r?.RENTAL_CONTRACT__c?.replace('{START_DATE}', formatDate(startDate))
            .replace('{MONTHLY_PRICE}', formatCurrency(monthlyPrice, 2))
            .replace('{DEPOSIT}', formatCurrency(depositAmount, 2))
            .replace('{BALANCE}', formatCurrency(generalBalance, 2));

        curatedInternetUse = contract.Billing_Entity__r?.TERMS_AND_CONDITIONS_FOR_INTERNET_USE__c;
        curatedHouseRules = contract.Billing_Entity__r?.HOUSE_RULES__c;
    }

    private String formatDate(Date value) {
        return value.format();
    }

    private String formatCurrency(Decimal value, Integer scale) {
        return value.setScale(scale).format() + ' €';
    }
}
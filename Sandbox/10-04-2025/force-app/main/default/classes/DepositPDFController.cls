public with sharing class DepositPDFController {

    public static final String INVOICE_STATUS_OPEN = 'open';

    @AuraEnabled
    public List<InvoiceItem__c> invoiceItems {get; set;}

    @AuraEnabled
    public List<Invoice__c> invoices {get; set;}

    @AuraEnabled
    public Deposit__c deposit {get; set;}

    @AuraEnabled
    public Decimal debits {get; set;}

    @AuraEnabled
    public Decimal credits {get; set;}

    @AuraEnabled
    public String brand {get; set;}

    @AuraEnabled
    public Boolean creditNegative {get; set;}

    @AuraEnabled
    public Decimal depositAmountToBeReimbursed {get; set;}

    public DepositPDFController(ApexPages.StandardController standardController) {
        InvoiceService invoiceService = new InvoiceService();
        List<InvoiceItem__c> invoiceItems = new List<InvoiceItem__c>();

        Id depositId = ((Deposit__c) standardController.getRecord()).Id;

        List<Deposit__c> deposits = DepositService.queryDepositsById(new Set<Id> {depositId});
        this.deposit = deposits.get(0);

        if(deposits.get(0).Contract__c == null) {
            return;
        }
        List<Contract> contracts = queryContractById(deposits.get(0).Contract__c);

        if(contracts.get(0) == null || contracts.get(0).Invoices__r == null) {
            return;
        }
        Set<Id> invoicesIds = (new Map<Id, SObject>(contracts.get(0).Invoices__r)).keySet();
        List<Invoice__c> invoices = invoiceService.queryInvoicesById(invoicesIds);
        for(Invoice__c invoice : invoices) {
            invoiceItems.addAll(invoice.InvoiceItems__r);
        }

        brand = contracts.get(0).Room__r?.Property__r?.BrandRef__c != null ? 
                contracts.get(0).Room__r.Property__r.BrandRef__r.APINameBrand__c : 
                contracts.get(0).ApartmentRef__r?.PropertyRef__r?.BrandRef__r?.APINameBrand__c;

        if (String.isNotBlank(brand)) {
            brand = 'logos/' + brand.toLowerCase() + '.jpg';
        }

        this.invoices = invoices;
        this.deposit = deposits.get(0);
        this.invoiceItems = invoiceItems;

        this.debits = calculateDebits(invoices);
        this.credits = calculateCredits(invoices);

        if(this.credits < 0) {
            this.credits = -this.credits;
            this.creditNegative = true;
        }

        this.depositAmountToBeReimbursed = deposit.OriginalAmount__c != null ? deposit.OriginalAmount__c : 0 - this.debits != null ? this.debits : 0 + this.credits!= null ? this.credits : 0;
    }

    private Decimal calculateDebits(List<Invoice__c> invoices) {
        Decimal sum = 0;

        for(Invoice__c invoice : invoices) {
            Boolean amountRemainingValid = invoice.AmountRemaining__c != null && invoice.AmountRemaining__c > 0;

            if(amountRemainingValid) {
                sum += invoice.AmountRemaining__c;
            }
        }

        return sum;
    }

    private Decimal calculateCredits(List<Invoice__c> invoices) {
        Decimal sum = 0;

        for(Invoice__c invoice : invoices) {
            Boolean amountRemainingValid = invoice.AmountRemaining__c != null && invoice.AmountRemaining__c < 0;

            if(amountRemainingValid) {
                sum += invoice.AmountRemaining__c;
            }
        }

        return sum;
    }

    /**
     * @param contractId    Can't be null.
     * @return              One or zero contracts. Never null.
     * */
    private List<Contract> queryContractById(Id contractId) {
        return (List<Contract>) Paua_SelectorHandler.getSelector(CustomerContractSelectors.ById.class)
                                                    .setParameter('id', contractId)
                                                    .query();
    }
}
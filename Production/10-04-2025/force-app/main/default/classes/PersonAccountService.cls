public without sharing class PersonAccountService {
    public static final Schema.SObjectType SObjectType = Account.SObjectType;

    public static final String RT_CUSTOMER = 'PersonAccount';

    public static final String STATUS_CUSTOMER_BLOCKED = 'REPEAT_BUSINESS_INCIDENT';

    public static final String MEMBERSHIP_STATUS_MEMBER = 'Member';

    public RecordType getCustomerRecordType() {
        RecordTypeInfo rti = Account.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get(RT_CUSTOMER);
        return new RecordType(
            Id = rti.getRecordTypeId(),
            Name = rti.getName(),
            DeveloperName = RT_CUSTOMER
        );
    }

    public Account validateExisting(Account account) {
        return validateExisting(new List<Account>{account})[0];
    }

    public List<Account> validateExisting(List<Account> accounts) {
        Set<String> emailSet = new Set<String>();
        for (Account account: accounts) {
            emailSet.add(account.PersonEmail);
        }

        List<SObject> existing = Paua_SelectorHandler.getSelector(PersonAccountSelectors.FromEmail.class)
            .setParameter('emails', emailSet)
            .query();
        
        Map<String, Account> accountsByEmail = new Map<String, Account>();
        for (SObject account: existing) {
            accountsByEmail.put((String)account.get('PersonEmail'), (Account) account);
        }

        for (Account account: accounts) {
            if (accountsByEmail.containsKey(account.PersonEmail)) {
                account.Id = accountsByEmail.get(account.PersonEmail).Id;
            }
        }

        return accounts;
    }

    public List<Account> filterAccountsNoMembership(List<Account> accounts) {
        List<Account> accountsWithNoMembership = new List<Account>();

        for(Account account : accounts) {
            List<Contract> contracts = account.Contracts;
            Boolean noActiveContract = true;

            for(Contract contract : contracts) {
                if(
                    contract.RecordTypeId == CustomerContractService.RT_ID_MEMBERSHIP && 
                    contract.Status == CustomerContractService.STATUS_ACTIVATED
                ) {
                    noActiveContract = false;
                    break;
                }
            }

            if(noActiveContract) {
                accountsWithNoMembership.add(account);
            }
        }
        
        return accountsWithNoMembership;
    }
}
public with sharing class DepositService {

    public static final String STATUS_SUBMITTED = 'Submitted for Approval';
    public static final String STATUS_APPROVED = 'Approved';
    public static final String DEPOSIT_NAME_HEAD = 'Deposit Settlement Statement ';
    public static final String PDF_EXTENSION = '.pdf';
    public static final String DUMMY_CONTENT_VALUE = 'Unit Test Value';

    /**
     * This method is used to filter out not relevant deposit records from a bulk trigger. As part of the PDF
     * generation process we are only interested in those deposits that change the status from "Submitted for Approval"
     * to "To be refunded". This status change happens after the record was submitted to the approval process and approved.
     * 
     * @param newList       List of all records from trigger (Trigger.New).
     * @param oldMap        Map with key = id of deposit, value = deposit record (Trigger.oldMap).
     * @param newStatus     String with the value for new status.
     * @param oldStatus     String with the value of old status.
     * @return              List of relevant deposit records. Never null.
     */
    public List<Deposit__c> getWithNewRelevantStatus(
        List<Deposit__c> newList, Map<Id, Deposit__c> oldMap, String oldStatus, String newStatus
    ) {
        List<Deposit__c> relevant = new List<Deposit__c>();

        for (Deposit__c deposit: newList) {
            if(oldMap.get(deposit.Id).Status__c == oldStatus && deposit.Status__c == newStatus) {
                relevant.add(deposit);
            }
        } 

        return relevant;
    }

    /**
     * This method is the entry point from a trigger to PDF generation process. 
     * 
     * @param deposits      List of deposits from trigger. Is never null, but might be empty.
     */
    public void generateDepositFile(List<Deposit__c> deposits) {
        if(deposits == null || deposits.isEmpty()){
            return;
        }

        generateDepositFile((new Map<Id, SObject>(deposits)).keySet());
    }

    /**
     * This method is part of the PDF generation process. It is a future method, because we need to call .getContent()
     * from the trigger.
     * 
     * @param depositIds    Id of deposits from trigger. 
     */
    @future(callout = true)
    private static void generateDepositFile(Set<id> depositIds) {
        List<Deposit__c> deposits = queryDepositsById(depositIds);
        Map<Id, ContentVersion> depositIdToCvMap = createDepositToVersionsMap(deposits);

        insertContentVersions(depositIdToCvMap.values());

        for(Deposit__c deposit : deposits) {
            deposit.ContentVersionId__c = depositIdToCvMap.get(deposit.Id).Id;
        }
        update deposits;
    }

    /**
     * As getContent() is counted as callout and the method is called in a loop this part might cause a limit overflow.
     * However, it is very unlikely to happen. Mainly because the method is called from the trigger on deposit record,
     * which is created only once per few months. 
     * 
     * @param deposit     Can't be null.
     */
    private static ContentVersion createContentVersionRecord(Deposit__c deposit) {
        String fileName = DEPOSIT_NAME_HEAD + deposit.Id;

        PageReference pref = page.DepositPDF;
        pref.getParameters().put('id', deposit.Id);
        Blob depositContent;
        if(Test.isRunningTest()) {
            depositContent = Blob.valueOf(DUMMY_CONTENT_VALUE);
        } else {
            depositContent = pref.getContent();
        }

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S'; 
        contentVersion.PathOnClient = fileName + PDF_EXTENSION;
        contentVersion.Title = fileName;
        contentVersion.VersionData = depositContent;
        contentVersion.FirstPublishLocationId = deposit.Id;

        return contentVersion;
    }

    /**
     * This method creates a map with new content version records from deposits.
     * 
     * @param deposits      List of deposits from trigger.
     * @return              Map with key = deposit id, value = content version record.
     */
    private static Map<Id, ContentVersion> createDepositToVersionsMap(List<Deposit__c> deposits) {
        Map<Id, ContentVersion> depositIdToCvMap = new Map<Id, ContentVersion>();

        for(Deposit__c deposit : deposits) {
            ContentVersion contentVersion = createContentVersionRecord(deposit);
            depositIdToCvMap.put(deposit.Id, contentVersion);
        }

        return depositIdToCvMap;
    }

    /**
     * This method is called to create a map and later these content version value are used to create a Document Link 
     * with the deposit record.
     * 
     * @param ids       Set of content versions id. Can't be null.
     * @return          Map with key = content version id, value = content version record.
     */
    private static Map<Id, ContentVersion> createIdToContentVersionMap(Set<Id> ids) {
        List<ContentVersion> contentVersions = queryContentVersionsById(ids);
        Map<Id, ContentVersion> idToContentVersions = new Map<Id, ContentVersion>();

        for(ContentVersion contentVersion : contentVersions) {
            idToContentVersions.put(contentVersion.Id, contentVersion);
        }

        return idToContentVersions;
    }

    /** 
    * @param versions          Can't be null.
    */
    private static void insertContentVersions(List<ContentVersion> versions) {
        Paua_Transaction trans = new Paua_Transaction();
        trans.setPreferredOrder(new List<SObjectType>{ContentVersion.SObjectType});
        trans.addForInsert(versions);
        trans.commitRecords();
    }

    private static List<ContentVersion> queryContentVersionsById(Set<Id> idSet) {
        return (List<ContentVersion>) Paua_SelectorHandler.getSelector(ContentSelectors.ById.class)
                                                          .setParameter('idSet', idSet)
                                                          .query();
    }

    /**
     * This method is used in a process of creating a deposit and helps to deal with related records on the deposit.
     *
     * @param depositId     Can't be null.
     * @return              One or zero deposits. Never null.
     * */
    public static List<Deposit__c> queryDepositsById(Set<Id> idSet) { 
        return (List<Deposit__c>) Paua_SelectorHandler.getSelector(DepositSelectors.ById.class)
                                                      .setParameter('idSet', idSet)
                                                      .query();
    }
}
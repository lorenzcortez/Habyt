public class InvoiceItemTriggerHandler {

    public static void onAfterInsertUpdate(Map<Id, InvoiceItem__c> newMap) {
        calcInvoiceFields(null, newMap);
    }

    public static void onAfterDelete(List<InvoiceItem__c> oldList) {
        calcInvoiceFields(oldList, null);
    }

    private static void calcInvoiceFields(List<InvoiceItem__c> oldList, Map<Id, InvoiceItem__c> newMap) {

        Set<Id> invIdSet = new Set<Id>();

        List<InvoiceItem__c> invItemList = oldList != null ? oldList : newMap.values();

        for(InvoiceItem__c invItem : invItemList) {
            if(invItem.Invoice__c != null) {
                invIdSet.add(invItem.Invoice__c);
            }
        }

        if(invIdSet != null) {

            Map<Id, Decimal> grossRentMap = new Map<Id, Decimal>();
            Map<Id, Decimal> recurAdjMap = new Map<Id, Decimal>();
            Map<Id, Decimal> oneOffAdjMap = new Map<Id, Decimal>();
            Set<Id> invIdToUpdateSet = new Set<Id>();
            List<Invoice__c> invoiceList = new List<Invoice__c>();

            //Added Jan 11 2025
            //START
            Map<Id, Decimal> ciNullSumMap = new Map<Id, Decimal>();
            /*for(AggregateResult ar : [SELECT Invoice__c, SUM(Amount__c) totalAmt FROM InvoiceItem__c WHERE Invoice__c IN: invIdSet AND Contract_Item__c = null GROUP BY Invoice__c]) {
                Decimal totalAmount = (Decimal) ar.get('totalAmt');
                System.debug('Jan 11 totalAmount '+totalAmount);
                Id invId = (Id) ar.get('Invoice__c');
                ciNullSumMap.put(invId, totalAmount);
            }*/
            for(InvoiceItem__c invItem : [SELECT Invoice__c, Amount__c FROM InvoiceItem__c WHERE Invoice__c IN: invIdSet AND Contract_Item__c = null]) {
                if(!ciNullSumMap.containsKey(invItem.Invoice__c)) {
                    ciNullSumMap.put(invItem.Invoice__c, invItem.Amount__c);
                }
                else {
                    ciNullSumMap.put(invItem.Invoice__c, ciNullSumMap.get(invItem.Invoice__c) + invItem.Amount__c);
                }
            }
            
            //END

            System.debug('ciNullSumMap '+ciNullSumMap);

            for(InvoiceItem__c invItem : [SELECT Id, Stripe_Plan_Id__c, Contract_Item_Product__c, Invoice__c, Amount__c,Contract_Item__c FROM InvoiceItem__c WHERE Invoice__c IN: invIdSet]) {

                Decimal amount = invItem.Invoice__c != null ? invItem.Amount__c : 0;

                // System.debug('#### invItem.Contract_Item_Product__c ' + invItem.Contract_Item_Product__c);
                // System.debug('#### amount amount amount ' + amount);
                // System.debug('#### invItem.Stripe_Plan_Id__c ' + invItem.Stripe_Plan_Id__c);

                if(invItem.Stripe_Plan_Id__c != null) {
                    if(!grossRentMap.containsKey(invItem.Invoice__c)) {
                        grossRentMap.put(invItem.Invoice__c, amount);
                    }
                    else {
                        grossRentMap.put(invItem.Invoice__c, grossRentMap.get(invItem.Invoice__c) + amount);
                    }         
                }

                if(invItem.Contract_Item_Product__c == 'Recurring Item') {
                    if(!recurAdjMap.containsKey(invItem.Invoice__c)) {
                        recurAdjMap.put(invItem.Invoice__c, amount);
                    }
                    else {
                        recurAdjMap.put(invItem.Invoice__c, recurAdjMap.get(invItem.Invoice__c) + amount);
                    }    
                }

                if(invItem.Contract_Item_Product__c == 'One-off item') {
                    
                    if(!oneOffAdjMap.containsKey(invItem.Invoice__c)) {
                        oneOffAdjMap.put(invItem.Invoice__c, amount);
                    }
                    else {
                        oneOffAdjMap.put(invItem.Invoice__c, oneOffAdjMap.get(invItem.Invoice__c) + amount);
                    }/*
                    
                    Decimal totalAmt = ciNullSumMap.containsKey(invItem.Invoice__c) ? ciNullSumMap.get(invItem.Invoice__c) + amount : amount;
                    System.debug('totalAmt '+totalAmt);
                    if(!oneOffAdjMap.containsKey(invItem.Invoice__c)) {
                        oneOffAdjMap.put(invItem.Invoice__c, totalAmt);
                    }
                    else {
                        oneOffAdjMap.put(invItem.Invoice__c, oneOffAdjMap.get(invItem.Invoice__c) + totalAmt);
                    }*/  
                }
                
            }

            invIdToUpdateSet.addAll(grossRentMap.keySet());
            invIdToUpdateSet.addAll(recurAdjMap.keySet());
            invIdToUpdateSet.addAll(oneOffAdjMap.keySet());
            invIdToUpdateSet.addAll(ciNullSumMap.keySet());

            System.debug('grossRentMap  '+grossRentMap);
            System.debug('recurAdjMap  '+recurAdjMap);
            System.debug('oneOffAdjMap  '+oneOffAdjMap);
			System.debug('invIdToUpdateSet  '+invIdToUpdateSet);

            for(Invoice__c inv : [SELECT Id, Gross_Rent__c, Recurring_Adjustments__c, One_Off_Adjustments__c FROM Invoice__c WHERE Id IN: invIdToUpdateSet]) {
                System.debug('*** enter loop update  '+inv.Id);
                
                inv.Gross_Rent__c = grossRentMap.containsKey(inv.Id) ? grossRentMap.get(inv.Id) : 0;
                inv.Recurring_Adjustments__c = recurAdjMap.containsKey(inv.Id) ? recurAdjMap.get(inv.Id) : 0;
                //inv.One_Off_Adjustments__c = oneOffAdjMap.containsKey(inv.Id) ? oneOffAdjMap.get(inv.Id) : 0;
                //Decimal totalAmt = ciNullSumMap.containsKey(invItem.Invoice__c) ? ciNullSumMap.get(invItem.Invoice__c) + amount : amount;
                inv.One_Off_Adjustments__c = oneOffAdjMap.containsKey(inv.Id) ? oneOffAdjMap.get(inv.Id) : 0;
                System.debug('*** inv.One_Off_Adjustments__c  '+inv.One_Off_Adjustments__c);
                System.debug('*** ciNullSumMap  '+ciNullSumMap.get(inv.Id));
                inv.One_Off_Adjustments__c = ciNullSumMap.containsKey(inv.Id) ? ciNullSumMap.get(inv.Id) + inv.One_Off_Adjustments__c : inv.One_Off_Adjustments__c;
                invoiceList.add(inv);
            }
        
            if(invoiceList != null) {
                update invoiceList;
            }
        }
    }
}
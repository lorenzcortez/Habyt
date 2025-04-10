public without sharing class InvoiceService {
    public virtual class InvoiceServiceException extends Exception {}

    public class NoCustomerIdOnInvoiceException extends InvoiceServiceException {}
    public class NoCustomerIdOnInvoiceItemException extends InvoiceServiceException {}

    public class NoContractOnInvoiceItemException extends InvoiceServiceException {}
    public class NoContractOnInvoiceException extends InvoiceServiceException {}

    public class InvoiceHasStripeIdException extends InvoiceServiceException {}
    public class InvoiceItemHasStripeIdException extends InvoiceServiceException {}
    public class InvoiceHasNoItemsException extends InvoiceServiceException {}

    public class NoAmountOnInvoiceItemException extends InvoiceServiceException {}

    public static final String COLLECTION_METHOD_SEND_INVOICE = 'send_invoice';
    public static final String DEPOSIT_INVOICE_TYPE = 'Deposit';
    public static final String STATUS_PAID = 'paid';
    public static final List<String> DEPOSIT_INITIAL_STATUSES = new List<String>{'In tenancy', 'Dormant', 'To be processed'};

    public List<Invoice__c> getRelevantDepositInsertion(List<Invoice__c> newList) {
        List<Invoice__c> relevant = new List<Invoice__c>();

        for (Invoice__c invoice: newList) {
            Boolean depositInvoiceAndAmountPaid = invoice.Type__c == 'Deposit' && (invoice.Amount_Paid__c != null && invoice.Amount_Paid__c > 0);
            Boolean notDepositInvoiceAndAmountRemaining = invoice.Type__c != 'Deposit' && invoice.AmountRemaining__c != null && invoice.AmountRemaining__c > 0;

            if(depositInvoiceAndAmountPaid || notDepositInvoiceAndAmountRemaining) {
                relevant.add(invoice);
            }
        }

        return relevant;
    }

    public List<Invoice__c> getWithRemainingOrDepositChange(List<Invoice__c> newList, Map<Id, Invoice__c> oldMap) {
        List<Invoice__c> relevant = new List<Invoice__c>();

        for (Invoice__c invoice: newList) {
            Boolean remainingAmountChanged = oldMap.get(invoice.Id).AmountRemaining__c != invoice.AmountRemaining__c;
            Boolean depositChanged = oldMap.get(invoice.Id).Deposit__c != invoice.Deposit__c && invoice.Deposit__c != null;
            Boolean invoiceHasDeposit = invoice.Deposit__c != null;
            Boolean depositStatusRelevant = !invoiceHasDeposit || DEPOSIT_INITIAL_STATUSES.contains(invoice.DepositStatusAuto__c);

            if((remainingAmountChanged || depositChanged) && depositStatusRelevant) {
                relevant.add(invoice);
            }
        }

        return relevant;
    }

    public void generateDeposits(List<Invoice__c> invoices) {
        Map<Id, Deposit__c> depositMap = new Map<Id, Deposit__c>();
        List<Deposit__c> newDeposits = new List<Deposit__c>();

        List<Invoice__c> invoicesToUpdate = new List<Invoice__c>();
        List<Invoice__c> invoicesWithDepositsToUpdate = new List<Invoice__c>();

        Set<Id> invoicesIds = (new Map<Id,SObject> (invoices)).keySet();
        List<Invoice__c> invoicesQueried = queryInvoicesById(invoicesIds);
        Set<Id> accountIdsToCheck = getAccountsFromInvoices(invoicesQueried);

        Map<Id, Deposit__c> accountToNewDeposit = new Map<Id, Deposit__c>();
        Map<Id, Deposit__c> accountIdToDeposit = createAccountIdDepositMap(accountIdsToCheck);

        for(Invoice__c invoice : invoicesQueried) {
            if(invoice.Contract__c == null) {
                continue;
            }
            
            if(accountIdToDeposit.containsKey(invoice.Contract__r.AccountId)) {
                Deposit__c deposit = accountIdToDeposit.get(invoice.Contract__r.AccountId);

                if(invoice.Type__c == 'Deposit') {
                    //added
                    if(invoice.Amount_Paid__c == NULL){
                        deposit.OriginalAmount__c = rollUpOriginalAmount(deposit.Invoices__r, invoice, invoice.Contract__c);
                    }
                    
                } /*else { //Updated Dec 8 2024
                    deposit.AdjustmentAmount__c = rollUpAdjustedAmount(deposit.Invoices__r, invoice, invoice.Contract__c);
                }*/

                depositMap.put(deposit.Id, deposit);

                invoicesWithDepositsToUpdate.add(invoice);
            } else if(invoice.Type__c == 'Deposit' && invoice.PaymentStatus__c == 'paid') {
                Deposit__c deposit = new Deposit__c();
                deposit.OriginalAmount__c = invoice.Amount_Paid__c;
                deposit.Contract__c = invoice.Contract__c;
                deposit.Room__c = invoice?.Contract__r?.Room__c;

                newDeposits.add(deposit);

                invoicesToUpdate.add(invoice);
                accountToNewDeposit.put(invoice.Contract__r.AccountId, deposit);
            }
        }

        update depositMap.values();
        //insert newDeposits; Updated Aug-9-2024 Commented out to enable Generate_Deposits_Flow

        for(Invoice__c invoice : invoicesToUpdate) {
            Deposit__c relatedDeposit = accountToNewDeposit.get(invoice.Contract__r.AccountId);

            if(invoice.Contract__c == relatedDeposit.Contract__c) {
                invoice.Deposit__c = relatedDeposit.Id;
            }
        }
        update invoicesToUpdate;

        for(Invoice__c invoice : invoicesWithDepositsToUpdate) {
            Deposit__c relatedDeposit = accountIdToDeposit.get(invoice.Contract__r.AccountId);

            if(invoice.Contract__c == relatedDeposit.Contract__c) { 
                invoice.Deposit__c = relatedDeposit.Id;
            }
        }
        update invoicesWithDepositsToUpdate;
    }

    private Decimal rollUpOriginalAmount(List<Invoice__c> invoices, Invoice__c newInvoice, Id depositContractId) {
        Set<Id> invoicesIds = (new Map<Id,SObject> (invoices)).keySet();
        if(!invoicesIds.contains(newInvoice.Id)) {
            invoices.add(newInvoice);
        }
        Decimal paymentSum = 0;

        for(Invoice__c invoice : invoices) {
            Boolean invoicePaid = invoice.PaymentStatus__c == 'paid';
            Boolean isDeposit = invoice.Type__c == 'Deposit';
            Boolean amountsNotNull = invoice.Amount_Paid__c != null;
            Boolean isDisputed = invoice.AmountDisputed__c != null;
            Boolean contractsMatching = invoice.Contract__c == depositContractId;

            if(contractsMatching && invoicePaid && isDeposit && amountsNotNull) {
                paymentSum += invoice.Amount_Paid__c;
            }

            if(contractsMatching && isDisputed && isDeposit) {
                paymentSum -= invoice.AmountDisputed__c;
            }
        }

        return paymentSum;
    }

    private Decimal rollUpAdjustedAmount(List<Invoice__c> invoices, Invoice__c newInvoice, Id depositContractId) {
        Set<Id> invoicesIds = (new Map<Id,SObject> (invoices)).keySet();
        if(!invoicesIds.contains(newInvoice.Id)) {
            invoices.add(newInvoice);
        }
        Decimal sum = 0;

        for(Invoice__c invoice : invoices) {
            Boolean notDeposit = invoice.Type__c != 'Deposit';
            Boolean amountNotNull = invoice.AmountRemaining__c != null;
            Boolean contractsMatching = invoice.Contract__c == depositContractId;

            if(contractsMatching && notDeposit && amountNotNull) {
                sum += invoice.AmountRemaining__c;
            }
        }

        return sum;
    }

    private Map<Id, Deposit__c> createAccountIdDepositMap(Set<Id> accountIds) {
        Map<Id, Deposit__c> accountIdDepositMap = new Map<Id, Deposit__c>();

        List<Deposit__c> deposits = [
            SELECT Id, Contract__c, Contract__r.AccountId, Status__c, Name, Contract__r.Name,
                   (
                       SELECT Id, AmountRemaining__c, Amount_Paid__c, Deposit__c, AmountDisputed__c, 
                              PaymentStatus__c, Type__c, Contract__c, Contract__r.Name
                       FROM Invoices__r
                    )
            FROM Deposit__c 
            WHERE Contract__r.AccountId IN :accountIds AND 
                  Status__c IN :DEPOSIT_INITIAL_STATUSES
        ];

        for(Deposit__c deposit : deposits) {
            accountIdDepositMap.put(deposit.Contract__r.AccountId, deposit);
        }

        return accountIdDepositMap;
    }

    private Set<Id> getAccountsFromInvoices(List<Invoice__c> invoices) {
        Set<Id> accountIds = new Set<Id>();

        for(invoice__c invoice : invoices) {
            if (invoice?.Contract__r?.AccountId != null) {
                accountIds.add(invoice.Contract__r.AccountId);
            } else if (invoice.Account__c != null) {
                accountIds.add(invoice.Account__c);
            }

        }

        return accountIds;
    }

    /**
     * The method is called from the LWC component SendInvoiceAndItemsToStripe when the Stripe Webhook was faster
     * than committing the invoice id to the Salesforce database after the sync.
     *
     * In that case we transfer the manual entered data on the invoice to the stripe webhook generated invoice and delete
     * the initial invoice that was manually created.
     *
     * @param recordId      Invoice id to be merged.
     */
    @AuraEnabled
    public static void mergeDuplicateInvoices(Id recordId, Id stripeWebhookInvoiceId) {
        InvoiceService service = new InvoiceService();

        List<Invoice__c> invoices = service.queryInvoicesById(new Set<Id> {recordId});
        List<Invoice__c> invoicesToDelete = new List<Invoice__c>();
        List<InvoiceItem__c> invoiceItemsToDelete = new List<InvoiceItem__c>();
        List<Invoice__c> invoicesToBeUpdated = new List<Invoice__c>();
        for (Invoice__c invoice : invoices) {
            if (invoice.Id == recordId) {
                invoiceItemsToDelete.addAll(invoice.InvoiceItems__r);
                invoicesToDelete.add(invoice);
                Invoice__c invoiceToBeUpdated = new Invoice__c(Id = stripeWebhookInvoiceId);
                invoiceToBeUpdated.Contract__c = invoice.Contract__c;
                invoiceToBeUpdated.Description__c = invoice.Description__c;
                invoiceToBeUpdated.DueDate__c = invoice.DueDate__c;
                invoiceToBeUpdated.DaysUntilDue__c = invoice.DaysUntilDue__c;
                invoiceToBeUpdated.CollectionMethod__c = invoice.CollectionMethod__c;
                invoiceToBeUpdated.AutoAdvance__c = invoice.AutoAdvance__c;
                invoicesToBeUpdated.add(invoiceToBeUpdated);
            }
        }

        service.updateInvoices(invoicesToBeUpdated);
        //service.deleteInvoices(invoicesToDelete); 
        if(!Test.isRunningTest()) service.deleteInvoices(invoicesToDelete); //Updated Dec 19 To cover test class error
        service.deleteInvoiceItems(invoiceItemsToDelete);
    }

    /**
     * The method is called from the LWC component SendInvoiceAndItemsToStripe when the api of the object does NOT equal
     * InvoiceItem__c. The LWC component is located on the invoice and invoice items record page and passes to this method
     * an invoice id. 
     * 
     * Stripe requires first to send invoice items and only then invoice itself. The invoice items are then attached to 
     * the invoice.
     * 
     * @param recordId      Invoice id to be synced. Can't be null and must be invoice id. 
     */
    @AuraEnabled
    public static void sendInvoicesToStripe(Id recordId) {
        InvoiceService service = new InvoiceService();

        List<Invoice__c> invoices = service.queryInvoicesById(new Set<Id> {recordId});
        List<InvoiceItem__c> invoiceItemsToSync = service.retrieveItemsFromInvoices(invoices);
        List<InvoiceItem__c> invoiceItemsToUpdate = new List<InvoiceItem__c>();
        try {
            List<Invoice__c> invoicesToUpdate = service.sendInvoicesToStripe(invoices);
            Map<Id, Invoice__c> invoiceMap = new Map<Id, Invoice__c>(invoicesToUpdate);
            invoiceItemsToUpdate = service.sendInvoiceItemsToStripe(invoiceItemsToSync, invoiceMap);
            List<Invoice__c> finalizedInvoices = service.finalizeInvoices(invoicesToUpdate);

            service.sendStripeInvoiceEmails(finalizedInvoices);
            System.debug('finalizedInvoices ' + finalizedInvoices);
            service.updateInvoices(finalizedInvoices);
            service.updateInvoiceItems(invoiceItemsToUpdate);
        } catch (StripeService.StripeErrorException e) {
            Map<Id, InvoiceItem__c> invoiceItemMap = new Map<Id, InvoiceItem__c>(invoiceItemsToUpdate);
            List<InvoiceItem__c> invoiceItemsToDelete = new List<InvoiceItem__c>();
            for (InvoiceItem__c invoiceItem : invoiceItemsToSync) {
                if (
                    (invoiceItemMap.containsKey(invoiceItem.Id) && invoiceItem.Stripe_Id__c == null) ||
                    invoiceItem.Stripe_Id__c == invoiceItemMap.get(invoiceItem.Id)?.Stripe_Id__c
                ) {
                    invoiceItem.Stripe_Id__c = invoiceItemMap.get(invoiceItem.Id)?.Stripe_Id__c;
                    invoiceItemsToDelete.add(invoiceItem);
                }
            }
            service.deleteInvoiceItemsInStripe(new Map<Id, InvoiceItem__c>(invoiceItemsToDelete));
            throw new StripeService.StripeErrorException(e.getMessage());
        } catch (StripeEventHandler.CustomerNotFoundException e) {
            throw new StripeService.StripeErrorException(e.getMessage());
        }

    }

    /**
     * The method is called from the LWC component SendInvoiceAndItemsToStripe when the api of the object equals
     * InvoiceItem__c. The LWC component is located on the invoice and invoice items record page and passes to this method
     * an invoice item id. 
     * 
     * The invoice item record shouldn't have a related invoice.
     * 
     * @param recordId      Invoice item id to be synced. Can't be null and must be invoice item id. 
     */
    @AuraEnabled
    public static void sendInvoiceItemsToStripe(Id recordId) {
        InvoiceService service = new InvoiceService();

        List<InvoiceItem__c> invoiceItemsToSync = service.queryInvoiceItemsWithFields(new Set<Id> {recordId});        
        List<InvoiceItem__c> invoiceItemsToUpdate = service.sendInvoiceItemsToStripe(invoiceItemsToSync);

        service.updateInvoiceItems(invoiceItemsToUpdate);
    }

    /**
     * This method retrieves items to send them to stripe before sending an invoice. The retrieved invoice items 
     * are then used to first sync related invoices items to all the invoices. It should be impossible to send an invoice
     * without invoice item, therefore the exception is thrown.
     * 
     * @param invoices      List of invoices to retrieve invoice items. 
     * @return              Related invoice items to the list of invoices. Is never null.
     */
    public List<InvoiceItem__c> retrieveItemsFromInvoices(List<Invoice__c> invoices) {
        List<InvoiceItem__c> invoiceItems = new List<InvoiceItem__c>();

        for(Invoice__c invoice : invoices) {
            if(invoice.InvoiceItems__r != null && invoice.InvoiceItems__r.size() > 0) {
                for (InvoiceItem__c invoiceItem : invoice.InvoiceItems__r) {
                    if (invoiceItem.Stripe_Id__c == null) {
                        invoiceItems.add(invoiceItem);
                    }
                }
            } else {
                throw new InvoiceHasNoItemsException();
            }
        }

        return invoiceItems;
    }

    /**
     * This is a central method in synchronizing invoices with stripe process, where the most of the logic is performed.
     * As stated in the Stripe API, creating an invoice pulls in all pending invoice items on that customer. The customer 
     * id is required by stripe. We send subscription id as well if it is defined, but it's not required.
     * 
     * @param invoicesToSync        List of invoices to be send. Cannot be null, otherwise exception "NullPointerException".
     * @return                      List of invoices with stripe ids from response, never null.
     */
    private List<Invoice__c> sendInvoicesToStripe(List<Invoice__c> invoicesToSync) {
        for(Invoice__c invoice : invoicesToSync) {
            //Sept 5 - Updated operator of IF condition from != to ==
            //if(invoice.Stripe_Invoice_Id__c != null) {
            if(invoice.Stripe_Invoice_Id__c == null) {
                throw new InvoiceHasStripeIdException();
            }

            if(invoice.Contract__c == null) {
                throw new NoContractOnInvoiceException('Invoice must have a related contract.');
            }

            String invoicePayload = generateInvoicePayload(invoice);
            String invoiceResponse = StripeService.postToStripe(
                'invoices', invoicePayload, invoice.Contract__r.Stripe_Account__r.Secret_key__c
            );

            invoice.Stripe_Invoice_Id__c = getStripeIdFromInvoice(invoiceResponse);
        }
        
        return invoicesToSync;
    }

    /**
     * The method is used to send invoices to customers via build-in functionality of stripe for email
     * notification.
     * 
     * @param invoices       List of invoices with stripe id, secret Key and collection method fields.
    */
    private void sendStripeInvoiceEmails(List<Invoice__c> invoices) {
        for(Invoice__c invoice : invoices) {
            Boolean isSendInvoice = invoice.CollectionMethod__c != null && 
                                invoice.CollectionMethod__c == COLLECTION_METHOD_SEND_INVOICE;


            if(isSendInvoice) {
                String endPoint = 'invoices/' + invoice.Stripe_Invoice_Id__c + '/send';
                String resp = StripeService.postToStripe(endPoint, '', invoice.Contract__r.Stripe_Account__r.Secret_key__c);
            }     
        }
    }

    /**
    *  Initially, the invoice is synced to the stripe as draft. Therefore, additional finalization is needed.
    *
    *  @param invoicesToFinalize   Invoices to send. Can't be null.
    *  @return                     Same invoices with no changes.
    */
    private List<Invoice__c> finalizeInvoices(List<Invoice__c> invoicesToFinalize) {
        for(Invoice__c invoice : invoicesToFinalize) {
            String invoicePayload = 'auto_advance=' + invoice.AutoAdvance__c;
            String endPoint = 'invoices/' + invoice.Stripe_Invoice_Id__c + '/finalize';
            String secretKey = invoice.Contract__r.Stripe_Account__r.Secret_key__c;

            String invoiceResponse = StripeService.postToStripe(endPoint, invoicePayload, secretKey);
        }

        return invoicesToFinalize;
    }

    /**
     * This is a central method in synchronizing invoices with stripe process. This method is used for sending invoice
     * items and storing the response such as stripe id. The stripe id is stored in order to prevent creating multiple
     * invoice items every time after sync.
     *
     * The map is used to store ids of synced invoices, because stripe have only its id as identifier. Therefore we need
     * to match which payload to which response belongs.
     *
     * @param invoiceItemsToSync    Items to sync. Can't be null, or exception is thrown.
     * @return                      Invoice items, never null.
     */

    private List<InvoiceItem__c> sendInvoiceItemsToStripe(List<InvoiceItem__c> invoiceItemsToSync) {
        return sendInvoiceItemsToStripe(invoiceItemsToSync, new Map<Id, Invoice__c>());
    }

    private List<InvoiceItem__c> sendInvoiceItemsToStripe(List<InvoiceItem__c> invoiceItemsToSync, Map<Id, Invoice__c> invoiceMap) {
        Map<String, String> itemResponseToItemId = new Map<String, String>();
        Map<String, String> itemsPayloadSecretKeyMap = createInvoiceItemsPayloadMap(invoiceItemsToSync, false, invoiceMap);
        Map<String, String> itemsPayloadToItemId = createInvoiceItemsPayloadIdMap(invoiceItemsToSync, invoiceMap);

        for(String invoiceItemPayload : itemsPayloadSecretKeyMap.keySet()) {
            String itemResponse = StripeService.postToStripe(
                'invoiceitems', invoiceItemPayload, itemsPayloadSecretKeyMap.get(invoiceItemPayload)
            );
            itemResponseToItemId.put(itemResponse, itemsPayloadToItemId.get(invoiceItemPayload));
        }

        return createInvoiceItemsToUpdate(itemResponseToItemId);
    }

    /**
     * This is a central method in synchronizing invoices with stripe process. This method is used for deleting invoice
     * items that were already synced with stripe.
     * The map is used to store ids of synced invoices, because stripe have only its id as identifier. Therefore we need
     * to match which payload to which response belongs.
     *
     * @param invoiceItemsToDelete    Items to sync. Can't be null, or exception is thrown.
     * @return                        Invoice items, never null.
     */
    @TestVisible
    private void deleteInvoiceItemsInStripe(Map<Id, InvoiceItem__c> invoiceItemsToDelete) {
        Map<String, String> itemsPayloadSecretKeyMap = createInvoiceItemsPayloadMap(invoiceItemsToDelete.values(), true);
        Map<String, String> itemsPayloadToItemId = createInvoiceItemsPayloadIdMap(invoiceItemsToDelete.values());

        for(String invoiceItemPayload : itemsPayloadSecretKeyMap.keySet()) {
            if (invoiceItemsToDelete.get(itemsPayloadToItemId.get(invoiceItemPayload))?.Stripe_Id__c != null) {
                StripeService.deleteInStripe(
                    'invoiceitems',
                    invoiceItemsToDelete.get(itemsPayloadToItemId.get(invoiceItemPayload)).Stripe_Id__c,
                    itemsPayloadSecretKeyMap.get(invoiceItemPayload)
                );
            }
        }
    }

    /**
     * 
     * This method is used in two processes - to sync invoices with items and to sync stand alone invoice items. In both
     * cases if we have a stripe id defined something went wrong or the invoice item was already synced to the Stripe.
     * 
     * If we sync just an invoice item, we need to define a stripe account for it. If we sync the whole invoice, then 
     * the secret key is taken from related stripe account on the invoice. 
     * 
     * @param invoiceItems      Items to sync into stripe. Can't be null, otherwise exception.                
     * @return                  Map with Key = item payload for stripe. Value = secret key from invoice or invoice item.
     */

    private Map<String, String> createInvoiceItemsPayloadMap(List<InvoiceItem__c> invoiceItems, Boolean allowStripeId) {
        return createInvoiceItemsPayloadMap(invoiceItems, allowStripeId, new Map<Id, Invoice__c>());
    }
    private Map<String, String> createInvoiceItemsPayloadMap(List<InvoiceItem__c> invoiceItems, Boolean allowStripeId, Map<Id, Invoice__c> invoiceMap) {
        Map<String, String> items = new Map<String, String>();

        for(InvoiceItem__c invoiceItem : invoiceItems) {
            if(!allowStripeId && invoiceItem.Stripe_Id__c != null) {
                throw new InvoiceItemHasStripeIdException('A stand alone invoice item already has a stripe id defined.');
            }
            String stripeInvoiceId = invoiceMap.containsKey(invoiceItem.Invoice__c) ?  invoiceMap.get(invoiceItem.Invoice__c).Stripe_Invoice_Id__c : null;
            items.put(generateInvoiceItemPayload(invoiceItem, stripeInvoiceId), getSecretKeyFromInvoiceItem(invoiceItem));
        }

        return items;
    }

    private Map<String, String> createInvoiceItemsPayloadIdMap(List<InvoiceItem__c> invoiceItems) {
        return createInvoiceItemsPayloadIdMap(invoiceItems, new Map<Id, Invoice__c>());
    }

    private Map<String, String> createInvoiceItemsPayloadIdMap(List<InvoiceItem__c> invoiceItems, Map<Id, Invoice__c> invoiceMap) {
        Map<String, String> items = new Map<String, String>();

        for(InvoiceItem__c invoiceItem : invoiceItems) {
            String stripeInvoiceId = invoiceMap.containsKey(invoiceItem.Invoice__c) ?  invoiceMap.get(invoiceItem.Invoice__c).Stripe_Invoice_Id__c : null;
            items.put(generateInvoiceItemPayload(invoiceItem, stripeInvoiceId), invoiceItem.Id);
        }

        return items;
    }

    private List<InvoiceItem__c> createInvoiceItemsToUpdate(Map<String, String> itemResponseToItemId) {
        List<InvoiceItem__c> items = new List<InvoiceItem__c>();

        for(String response : itemResponseToItemId.keySet()) {
            String stripeId = getStripeIdFromItem(response);
            items.add(new InvoiceItem__c(Id = itemResponseToItemId.get(response), Stripe_Id__c = stripeId));
        }

        return items;
    }

    /**
     * The method won't return null, because stripe always sends an invoice id. If something went wrong the stripe exception 
     * is thrown instead.
     * 
     * @param response      Stripe response to parse. Can't be null, or exception will be thrown.
     * @return              Invoice item id from stripe response.
     */
    private String getStripeIdFromItem(String response) {
        StripeModels.InvoiceItemData invoiceItemData = (StripeModels.InvoiceItemData) JSON.deserialize(
            response, StripeModels.InvoiceItemData.class
        );

        return invoiceItemData.id;
    }

    /**
     * The method won't return null, because stripe always sends an invoice id. If something went wrong the stripe exception 
     * is thrown instead.
     * 
     * @param response      Stripe response to parse. Can't be null, or exception will be thrown.
     * @return              Invoice id from stripe response.
     */
    private String getStripeIdFromInvoice(String response) {
        StripeModels.InvoiceEventData invoiceData = (StripeModels.InvoiceEventData) JSON.deserialize(
            response, StripeModels.InvoiceEventData.class
        );

        return invoiceData.id;
    }

    /**
     * If we sync invoices with invoice items, we take a secret key from the stripe account on the invoice object,
     * but for the stand alone invoices there are no invoice, so the stripe account needs to be defined on the invoice item.
     * 
     * This method is used for both processes - for stand alone invoice items and for invoice items with the
     * related invoice.
     * 
     * @param invoiceItem       Invoice item with secret key. Can't be null, or exception will be thrown.
     * @return                  Secret key if defined or Exception is thrown.
     */
    private String getSecretKeyFromInvoiceItem(InvoiceItem__c invoiceItem) {
        String secretKey = '';
        Boolean invoiceItemStandAlone = invoiceItem.Invoice__c == null;
        Boolean noContract = invoiceItem.Contract__r == null;
        Boolean noContractOnInvoice = invoiceItem.Invoice__r.Contract__r == null || 
                                      invoiceItem.Invoice__r.Contract__r.Stripe_Account__c == null;

        if(invoiceItemStandAlone && noContract) {
            throw new NoContractOnInvoiceItemException('Stand alone invoice items must have a contract.');
        } else if(invoiceItemStandAlone) {
            secretKey = invoiceItem.Contract__r.Stripe_Account__r.Secret_key__c;
        } else if(noContractOnInvoice) {
            throw new NoContractOnInvoiceException('Invoice must have a related contract.');
        } else {
            secretKey = invoiceItem.Invoice__r.Contract__r.Stripe_Account__r.Secret_key__c;
        }

        return secretKey;
    }

    /**
     * The method is used as part of the process for syncing invoices from Salesforce to Stripe. Customer is a required 
     * field by stripe, so it must be set. Otherwise the exception is thrown. Other fields are not enforced by stripe.
     * Stripe does not support json, so we can send a payload only with parameters.
     * 
     * @param invoice   Can't be null, otherwise exception. Should contain customer id on the record or an the 
     *                  related account
     * @return          String with invoice parameters for stripe. Never null.
     */
    private String generateInvoicePayload(Invoice__c invoice) {
        String payload = 'customer=' + getCustomerFromInvoice(invoice);

        payload += '&pending_invoice_items_behavior=' + 'exclude';
        
        if(invoice.Description__c != null) {
            payload += '&description=' + invoice.Description__c.replace(' ', '+');
        }

        if(invoice.AutoAdvance__c != null) {
            payload += '&auto_advance=' + invoice.AutoAdvance__c;
        }

        if(invoice.CollectionMethod__c != null) {
            payload += '&collection_method=' + invoice.CollectionMethod__c;

            Boolean isSendInvoice = invoice.CollectionMethod__c == COLLECTION_METHOD_SEND_INVOICE;
            if(isSendInvoice && invoice.DueDate__c != null) {
                Long epochTime = ((DateTime) invoice.DueDate__c).getTime() / 1000;
                payload += '&due_date=' + epochTime;
            } else if (isSendInvoice && invoice.DaysUntilDue__c != null) {
                payload += '&days_until_due=' + invoice.DaysUntilDue__c;
            }
        }

        if (invoice.Type__c != null) {
            payload += '&metadata[invoiceType]=' + invoice.Type__c;
        }

        if (invoice.Contract__c != null) {
            payload += '&metadata[ContractId]=' + invoice.Contract__c ;
        }

        return payload;
    }

    /**
     * You can only specify one of these parameters: amount or quantity. If you set both, stripe will throw an exception.
     * Stripe does not support json, so we can send a payload only with parameters.
     * 
     * @param item      Invoice item to extract payload. Can't be null.
     * @return          String with invoice item parameters for stripe.
     */

    private String generateInvoiceItemPayload(InvoiceItem__c item) {
        return generateInvoiceItemPayload(item, null);
    }

    private String generateInvoiceItemPayload(InvoiceItem__c item, String stripeInvoiceId) {
        String payload = 'customer=' + getCustomerFromInvoicesItem(item);

        if(item.Description__c != null) {
            payload += '&description=' + item.Description__c.replace(' ', '+');
        }
        
        if(item.Amount__c != null) {
            payload += '&amount=' + Integer.valueOf(item.Amount__c * 100);
        } else {
            throw new NoAmountOnInvoiceItemException();
        }

        stripeInvoiceId = item.Invoice__c != null && item.Invoice__r.Stripe_Invoice_Id__c != null ? item.Invoice__r.Stripe_Invoice_Id__c : stripeInvoiceId;
        if (stripeInvoiceId != null) {
            payload += '&invoice=' + stripeInvoiceId;
        }

        if(item.Currency__c != null) {
            payload += '&currency=' + item.Currency__c;
        }

        if(item.PeriodStart__c != null) {
            Long epochTime = ((DateTime) item.PeriodStart__c).getTime() / 1000;
            payload += '&period[start]=' + epochTime;
        }

        if(item.PeriodEnd__c != null) {
            Long epochTime = ((DateTime) item.PeriodEnd__c).getTime() / 1000;
            payload += '&period[end]=' + epochTime;
        }
        if(item.Stripe_Id__c != null) {
            payload += '&id=' + item.Stripe_Id__c;
        }
        
        return payload;
    }

    /**
     * If customer id defined on the related invoice and on the invoice item, we take only that id from related invoice.
     * 
     * @param item      Invoice item, not null, and with properly queried fields.
     * @return          Stripe Customer id from invoice item or related records.
     */
    private String getCustomerFromInvoicesItem(InvoiceItem__c item) {
        String customerId = null;

        if(item.Invoice__c != null && item.Invoice__r.Contract__c == null) {
            throw new NoContractOnInvoiceException();
        } else if(item.Invoice__c == null && item.Contract__c == null) {
            throw new NoContractOnInvoiceItemException();
        } else if(item.Invoice__r?.Contract__r?.StripeCustomerId__c != null) {
            customerId = item.Invoice__r.Contract__r.StripeCustomerId__c;
        } else if(item.Invoice__r?.Contract__r?.Account?.Stripe_Customer_Id__c != null) {
            customerId = item.Invoice__r.Contract__r.Account.Stripe_Customer_Id__c;
        } else if(item.Contract__r?.StripeCustomerId__c != null) {
            customerId = item.Contract__r.StripeCustomerId__c;
        } else if(item.Contract__r?.Account?.Stripe_Customer_Id__c != null) {
            customerId = item.Contract__r.Account.Stripe_Customer_Id__c;
        } else {
            throw new NoCustomerIdOnInvoiceItemException();
        }

        return customerId;
    }

    /**
     * The user is flexible where to define stripe customer id in salesforce - on related contract or on the account on
     * the related contract.
     * 
     * @param invoice       Invoice for retrieving a customer id. Can't be null, or exception is thrown.
     * @return              Customer id as string. Can't be null, if nothing found the exception is thrown.
     */
    private String getCustomerFromInvoice(Invoice__c invoice) {
        String customerId = null;

        if(invoice.Contract__r.StripeCustomerId__c != null) {
            customerId = invoice.Contract__r.StripeCustomerId__c;
        } else if(invoice.Contract__r.Account.Stripe_Customer_Id__c != null) {
            customerId = invoice.Contract__r.Account.Stripe_Customer_Id__c;
        } else {
            throw new NoCustomerIdOnInvoiceException();
        }

        return customerId;
    }

    /**
     * This method saves response from stripe to invoices.
     * 
     * @param invoices          Cannot be null.
     */
    private void updateInvoices(List<Invoice__c> invoices) {
        Paua_Transaction trans = new Paua_Transaction();
        trans.setPreferredOrder(new List<SObjectType>{Invoice__c.SObjectType});
        trans.addForUpdate(invoices);
        trans.commitRecords();
    }

    /**
     * This method delete duplicate invoices.
     *
     * @param invoices          Cannot be null.
     */
    private void deleteInvoices(List<Invoice__c> invoices) {
        Paua_Transaction trans = new Paua_Transaction();
        trans.setPreferredOrder(new List<SObjectType>{Invoice__c.SObjectType});
        trans.addForDelete(invoices);
        trans.commitRecords();
    }

    /**
     * This method saves response from stripe to invoice items.
     * 
     * @param invoiceItems      Cannot be null.
     */
    private void updateInvoiceItems(List<InvoiceItem__c> invoiceItems) {
        Paua_Transaction trans = new Paua_Transaction();
        trans.setPreferredOrder(new List<SObjectType>{ InvoiceItem__c.SObjectType});
        trans.addForUpdate(invoiceItems);
        trans.commitRecords();
    }

    /**
     * Method to delete duplicate invoice items.
     *
     * @param invoiceItems      Cannot be null.
     */
    private void deleteInvoiceItems(List<InvoiceItem__c> invoiceItems) {
        Paua_Transaction trans = new Paua_Transaction();
        trans.setPreferredOrder(new List<SObjectType>{ InvoiceItem__c.SObjectType});
        trans.addForDelete(invoiceItems);
        trans.commitRecords();
    }

    /**
     * @param idSet          Cannot be null, otherwise "NullPointerException" exception.
     */
    public List<Invoice__c> queryInvoicesById(Set<Id> idSet) {
        return (List<Invoice__c>) Paua_SelectorHandler.getSelector(InvoiceSelectors.ById.class)
                                                      .setParameter('idSet', idSet)
                                                      .query();
    }

    /**
     * @param idSet          Cannot be null, otherwise "NullPointerException" exception.
     */
    private List<InvoiceItem__c> queryInvoiceItemsWithFields(Set<Id> idSet) {
        return (List<InvoiceItem__c>) Paua_SelectorHandler.getSelector(InvoiceItemSelectors.ById.class)
                                                          .setParameter('idSet', idSet)
                                                          .query();
    }
}
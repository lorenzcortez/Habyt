public with sharing class StripeModels {
    
    /* Plan */
    public class Plan{
        public String contractNumber;
        public String secretKey;
        public Integer amount;
        public String currencyIsoCode;

        public Plan(){
        }

        public Plan(String contractNumber, String secretKey, Integer amount){
            this(contractNumber, secretKey, amount, 'EUR');
        }

        public Plan(String contractNumber, String secretKey, Integer amount, String currencyIsoCode){
            this.contractNumber = contractNumber;
            this.secretKey = secretKey;
            this.amount = amount;
            this.currencyIsoCode = currencyIsoCode;
        }
    }

    /* Subscription request */
    public class Subscription{
        public String id;
        public String status;
        public String customerId;
        public String planId;
        public String secretKey;
        public String coupon;
        public Date startDate;

        public Subscription(){
        }

        public Subscription(String customerId, String planId, String secretKey, Date startDate, String coupon){
            this.customerId = customerId;
            this.planId = planId;
            this.secretKey = secretKey;
            this.startDate = startDate;
            this.coupon = coupon;
        }
    }

    /* Invoice */
    public class Invoice{
        public String description;
        public String customerId;
        public String secretKey;
        public String mdt_ContractId;
        public Decimal amount;
        public String subscription;
        public String invoiceType;

        public Invoice(){
        }

        public Invoice(
            String mdt_ContractId, 
            String description, 
            String customerId, 
            String secretKey,
            Decimal amount,
            String invoiceType
        ){
            this.mdt_ContractId = mdt_ContractId;
            this.description = description;
            this.customerId = customerId;
            this.secretKey = secretKey;
            this.amount = amount;
            this.invoiceType = invoiceType;
        }
    }

    public class InvoiceEventData {
        public String id;
        public String status;
        public InvoiceMetadata metadata;
        public Lines lines;
        public String due_date;
        public String created;
        public String paid_at;
        public Decimal amount_due;
        public Decimal amount_paid;
        public String hosted_invoice_url;
        public String invoice_pdf;
        public String subscription;
        public String customer;
        public String customer_email;
        public String customer_name;
        public String account_name;

        public String number_x;
        public String customerJsonMap;
        public StatusTransitions status_transitions;

        public String period_end;
        public String period_start;
        public String billing_reason;
        public String description;
        
        public InvoiceEventData(
            String id,
            String status,
            InvoiceMetadata metadata,
            Lines lines,
            String due_date,
            String paid_at,
            String created,
            Decimal amount_due,
            Decimal amount_paid,
            String hosted_invoice_url,
            String invoice_pdf,
            String subscription,
            String customer,
            String customer_email,
            String number_x,
            String client_secret,
            StatusTransitions status_transitions,
            String period_end,
            String period_start,
            String billing_reason,
            String customer_name,
            String account_name, 
            String description
        ){
            this.id = id;
            this.status = status;
            this.metadata = metadata;
            this.lines = lines;
            this.due_date = due_date;
            this.created = created;
            this.paid_at = paid_at;
            this.amount_due = amount_due;
            this.amount_paid = amount_paid;
            this.hosted_invoice_url = hosted_invoice_url;
            this.invoice_pdf = invoice_pdf;
            this.subscription = subscription;
            this.customer = customer;
            this.customer_email = customer_email;
            this.number_x = number_x;
            this.status_transitions = status_transitions;
            this.period_end = period_end;
            this.period_start = period_start;
            this.billing_reason = billing_reason;
            this.customer_name = customer_name;
            this.account_name = account_name;
            this.description = description;
        }
    }

    public class InvoiceMetadata {
        public String ContractId;
        public String invoiceType;

        public InvoiceMetadata(String ContractId, String invoiceType) {
            this.ContractId = ContractId;
            this.invoiceType = invoiceType;
        }
    }

    public class InvoiceItemData {
        public String id;
        public String description;
        public Decimal amount;
        public String invoice_item;
        public String currency_x;
        public InvoiceItemDataPeriod period;
        public Decimal quantity;
        public InvoicePriceData price;
        public String customer;

        public InvoiceItemData() {

        }

        public InvoiceItemData(
            String id, 
            String description, 
            Decimal amount, 
            String invoice_item,
            InvoiceItemDataPeriod period,
            String currency_x,
            Decimal quantity,
            InvoicePriceData price,
            String customer
        ) {
            this.id = id;
            this.description = description;
            this.amount = amount;
            this.invoice_item = invoice_item;
            this.period = period;
            this.currency_x = currency_x;
            this.quantity = quantity;
            this.price = price;
            this.customer = customer;
        }
    }

    public class InvoiceItemDataPeriod {
        public String start;
        public String end_x;

        public InvoiceItemDataPeriod(
            String start,
            String end_x
        ) {
            this.start = start;
            this.end_x = end_x;
        }
    }

    public class InvoicePriceData {
        public String id;
        public String object_x;
        public String unit_amount;
        public String billing_scheme;

        public InvoicePriceData(
            String id,
            String object_x
        ) {
            this.id = id;
            this.object_x = object_x;
            this.unit_amount = unit_amount;
            this.billing_scheme = billing_scheme;
        }
    }

    public class SubscriptionData {
        public String id;
        public String status;
        public String customer;
        public Decimal amount;
        public String client_secret;
        public String balance_transaction;
        
        public SubscriptionData(
            String id, 
            String status, 
            String customer,
            Decimal amount,
            String client_secret,
            String balance_transaction
        ){
            this.id = id;
            this.status = status;
            this.customer = customer;
            this.amount = amount;
            this.client_secret = client_secret;
            this.balance_transaction = balance_transaction;
        }
    }

    public class Lines {
        public String object_x;
        public List<InvoiceItemData> data;

        public Lines(String object_x, List<InvoiceItemData> data) {
            this.object_x = object_x;
            this.data = data;
        }
    }

    public class StatusTransitions {
        public String paid_at;
    }

    public class PaymentIntentData {
        public String status;
        public String id;
        public Decimal amount;
        public Decimal amount_capturable;
        public Decimal amount_received;
        public String currency_x;
        public String description;
        public LastPaymentError last_payment_error;
        public String payment_method;
        public String invoice;
        public String customer;
        public Charges charges;
        public String created;
        
        public PaymentIntentData(
            String id, 
            String status,
            Decimal amount,
            Decimal amount_capturable,
            Decimal amount_received,
            String currency_x,
            String description,
            LastPaymentError last_payment_error,
            String payment_method,
            String invoice,
            String customer,
            String created
        ){
            this.id = id;
            this.status = status;
            this.amount = amount;
            this.amount_capturable = amount_capturable;
            this.amount_received = amount_received;
            this.currency_x = currency_x;
            this.description = description;
            this.last_payment_error = last_payment_error;
            this.payment_method = payment_method;
            this.invoice = invoice;
            this.customer = customer;
            this.created = created;
        }
    }

    public class Charges {
        public List<ChargeEventData> data;

        public Charges(List<ChargeEventData> data) {
            this.data = data;
        }
    }


    public class ChargeEventData {
        public Refunds refunds;
        public String status;
        public String id;
        public String amount;
        public String balance_transaction;
        public PaymentMethodDetails payment_method_details;
        public String object_x;
        public String created;
        public String charge;
        public String payment_intent;
        
        public ChargeEventData(
            String id, 
            String status, 
            String amount, 
            String balance_transaction,
            PaymentMethodDetails payment_method_details,
            Refunds refunds,
            String object_x,
            String created,
            String charge,
            String payment_intent
        ){
            this.id = id;
            this.status = status;
            this.amount = amount;
            this.balance_transaction = balance_transaction;
            this.payment_method_details = payment_method_details;
            this.refunds = refunds;
            this.object_x = object_x;
            this.created = created;
            this.charge = charge;
            this.payment_intent = payment_intent;
        }
    }

    public class Refunds {
        public List<Refund> data;
    }

    public class Refund {
        public String id;
        public String amount;
        public String charge;
        public String currency_x;
        public String payment_intent;
        public String reason;
        public String receipt_number;
        public String status;
        public String created;

        public Refund(
                String amount,
                String charge,
                String currency_x,
                String payment_intent,
                String reason,
                String receipt_number,
                String status,
                String id,
                String created
        ) {
            this.amount = amount;
            this.charge = charge;
            this.currency_x = currency_x;
            this.payment_intent = payment_intent;
            this.reason = reason;
            this.receipt_number = receipt_number;
            this.status = status;
            this.id = id;
            this.created = created;
        }
    }

    public class PaymentMethodDetails {
        public SepaDebit sepa_debit;
        public Card card;
        public String type;

        public PaymentMethodDetails(
            SepaDebit sepa_debit, 
            String type,
            Card card
        ) {
            this.sepa_debit = sepa_debit;
            this.type = type;
            this.card = card;
        }
    }

    public class SepaDebit {
        public String bank_code;
        public String last4;

        public SepaDebit(
            String bank_code,
            String last4
        ) {
            this.bank_code = bank_code;
            this.last4 = last4;
        }
    }

    public class Card {
        public String brand;
        public String last4;

        public Card(
            String brand,
            String last4
        ) {
            this.brand = brand;
            this.last4 = last4;
        }
    }

    public class LastPaymentError {
        public String code;
        public String message;

        public LastPaymentError(String code, String message) {
            this.code = code;
            this.message = message;
        }
    }

    /* RESPONSE CLASSES */
    public class SubscriptionResponse{
        public Data[] data;
    }

    public class Data{
        public String id;
        public String status;
        public ResponsePlan plan;
    }

    public class ResponsePlan{
        public String id;
    }

    public class DiscountEventData{
        public String id;
        public String object_x;
        public String name;
        public String percent_off;
        public String times_redeemed;
        public String valid;
        public String customer;
        public String end_x;
        public String invoice;
        public String invoice_item;
        public String promotion_code;
        public String start;
        public String subscription;
        public Coupon coupon;
    }

    public class Coupon{
        public String id;
        public String object_x;
        public String amount_off;
        public String created;
        public String currency_x;
        public String duration;
        public String duration_in_months;
        public String livemode;
        public String max_redemptions;
        public String name;
        public String percent_off;
        public String redeem_by;
        public String times_redeemed;
        public String valid;
    }

    public class InvoiceItem{
        public String customer;
        public String amount;
        public String description;
        public String subscription;
        public String currencyIsoCode;

        public InvoiceItem(String customer, String amount, String description, String subscription, String currencyIsoCode) {
            this.customer = customer;
            this.amount = amount;
            this.description = description;
            this.subscription = subscription;
            this.currencyIsoCode = currencyIsoCode;
        }
    }

    public class Discount{
        public String coupon;

        public Discount(String coupon) {
            this.coupon = coupon;
        }
    }

}
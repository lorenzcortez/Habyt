public class IntegrationModels {
    public static final String FORMAT_DATE = 'yyyy-MM-dd';
    public static final String FORMAT_TIME = 'HH:mm:ss.SSS';

    public static final String TYPE_ROOM = 'ROOM';
    public static final String TYPE_UNIT = 'UNIT';
    public static final String TYPE_BUILDING = 'BUILDING';
    public static final String TYPE_FLOORPLAN = 'FLOORPLAN';
    public static final String TYPE_GROUNDPLAN = 'GROUNDPLAN';

    public static final String TYPE_APARTMENT = 'APARTMENT';
    public static final String TYPE_DISTRICT = 'NEIGHBOURHOOD';

    public static final String SHARE_SHARED_ROOM = 'Private Room';
    public static final String SHARE_PRIVATE_ROOM = 'Shared Room';
    public static final String SHARE_PRIVATE_APARTMENT = 'Private apartment';

    public static final String ERROR_BADREQUEST = 'Bad Request';
    public static final String ERROR_UNAUTHORIZED = 'Unauthorized';
    public static final String ERROR_INTERNAL = 'Internal Server Error';

    public static final Integer STATUSCODE_BADREQUEST = 400;
    public static final Integer STATUSCODE_UNAUTHORIZED = 401;
    public static final Integer STATUSCODE_INTERNAL = 500;


    public static Datetime parseDatetime(String str) {
        if (String.isBlank(str)) {
            return null;
        }

        return Datetime.valueOfGmt(str.replace('T', ' '));
    }

    public static Date parseDate(String str) {
        if (String.isBlank(str)) {
            return null;
        }

        List<String> parts = str.split('-');
        return Date.newInstance(Integer.valueOf(parts[0]), Integer.valueOf(parts[1]), Integer.valueOf(parts[2]));
    }

    public static String serializeDatetime(Datetime dt) {
        if (dt == null) {
            return null;
        }
        return dt.formatGMT(FORMAT_DATE) + 'T' + dt.formatGMT(FORMAT_TIME) + 'Z';
    }

    public static String serializeDate(Date d) {
        if (d == null) {
            return null;
        }
        Time t = Time.newInstance(0,0,0,0);
        return Datetime.newInstance(d, t).format(FORMAT_DATE);
    }

    public virtual class IntegrationException extends Exception {
        public ErrorPayload payload {
            get; private set;
        }
    }

    public class InternalServerErrorException extends IntegrationException {

        public InternalServerErrorException init(Exception e) {
            payload = new ErrorPayload();
            payload.error = ERROR_INTERNAL;
            payload.errorMessage = e.getMessage();
            payload.statusCode = STATUSCODE_INTERNAL;
            payload.timestamp = System.now().getTime();
            payload.data = e.getStackTraceString();

            // TODO: clarify data and path fields

            return this;
        }
    }

    public virtual class BadRequestException extends IntegrationException {

        public BadRequestException init() {
            payload = new ErrorPayload();
            payload.error = ERROR_BADREQUEST;
            payload.errorMessage = ERROR_BADREQUEST;
            payload.statusCode = STATUSCODE_BADREQUEST;
            payload.timestamp = System.now().getTime();

            return this;
        }

        public virtual BadRequestException init(String errorMessage) {
            payload = new ErrorPayload();
            payload.error = ERROR_BADREQUEST;
            payload.errorMessage = errorMessage;
            payload.statusCode = STATUSCODE_BADREQUEST;
            payload.timestamp = System.now().getTime();

            return this;
        }
    }

    public class MissingParameterException extends BadRequestException {
        private final String ERROR_MESSAGE = 'Invalid request parameter';

        public override BadRequestException init(String parameter) {
            super.init();
            payload.errorMessage = ERROR_MESSAGE + ': ' + parameter;

            return this;
        }
    }

    public class UnauthorizedException extends IntegrationException {
        public UnauthorizedException init() {
            payload = new ErrorPayload();
            payload.error = ERROR_UNAUTHORIZED;
            payload.errorMessage = ERROR_UNAUTHORIZED;
            payload.statusCode = STATUSCODE_UNAUTHORIZED;
            payload.timestamp = System.now().getTime();

            return this;
        }
    }

    public class ErrorPayload {
        public String error;  //": "Bad Request",
        public String errorMessage;  //": "Invalid request parameter: test",
        public Integer statusCode;  //": 400,
        public Long timestamp;  //": 0,
        public Object data;  //": {},
        public String path;  //": "string"
    }

    public virtual class RequestPayload {
        protected virtual String checkRequired() {
            return null;
        }

        public virtual void validate() {
            String missingRequired = checkRequired();

            if (String.isNotBlank(missingRequired)) {
                throw new MissingParameterException().init(missingRequired);
            }
        }
    }

    // Users

    public class UserRequestPayload extends RequestPayload {
        @AuraEnabled
        public String firstName;  //": "Tom",
        @AuraEnabled
        public String lastName;  //": "Swanson",
        @AuraEnabled
        public String email;  //": "email@example.org",
        @AuraEnabled
        public String companyName;  //": "Medici Living GmbH",
        @AuraEnabled
        public String addressLine1;  //": "Zossener Str. 55",
        @AuraEnabled
        public String addressLine2;  //": "Building B",
        @AuraEnabled
        public String addressLine3;  //": "C/O Quarters",
        @AuraEnabled
        public String postalCode;  //": "10961",
        @AuraEnabled
        public String city;  //": "Berlin",
        @AuraEnabled
        public String state;  //": "Berlin",
        @AuraEnabled
        public String countryCode;  //": "DE",
        @AuraEnabled
        public String phone;  //": "+495555555555",
        @AuraEnabled
        public String type;  //": "MOBILE",
        @AuraEnabled
        public String idNumber;  //": "L38F3N4MG",
        @AuraEnabled
        public String nationality;  //": "DE",
        @AuraEnabled
        public String gender;  //": "FEMALE",
        @AuraEnabled
        public String birthday;  //": "1985-01-03",
        @AuraEnabled
        public String occupation;  //": "STUDENT",
        @AuraEnabled
        public String incomeLevel;  //": "LEVEL_3",
        @AuraEnabled
        public String referenceId;  //": "DE-01-001-01Q"

        protected override String checkRequired() {
            if (String.isBlank(firstName)) { return 'firstName'; }
            if (String.isBlank(lastName)) { return 'lastName'; }
            if (String.isBlank(email)) { return 'email'; }
            if (String.isBlank(addressLine1)) { return 'addressLine1'; }
            if (String.isBlank(postalCode)) { return 'postalCode'; }
            if (String.isBlank(city)) { return 'city'; }
            // if (String.isBlank(state)) { return 'state'; }
            if (String.isBlank(countryCode)) { return 'countryCode'; }
            if (String.isBlank(phone)) { return 'phone'; }
            if (String.isBlank(type)) { return 'type'; }
            if (String.isBlank(idNumber)) { return 'idNumber'; }
            if (String.isBlank(nationality)) { return 'nationality'; }
            // if (String.isBlank(gender)) { return 'gender'; }
            if (String.isBlank(birthday)) { return 'birthday'; }
            if (String.isBlank(occupation)) { return 'occupation'; }
            if (String.isBlank(incomeLevel)) { return 'incomeLevel'; }
            if (String.isBlank(referenceId)) { return 'referenceId'; }

            return null;
        }

        private String consolidatedStreetAddress {
            get {
                if (consolidatedStreetAddress == null) {
                    List<String> addressLines = new List<String>{addressLine1};
                    if (String.isNotBlank(addressLine2)) {
                        addressLines.add(addressLine2);
                    }
                    if (String.isNotBlank(addressLine3)) {
                        addressLines.add(addressLine3);
                    }

                    consolidatedStreetAddress = String.join(addressLines, ', ');
                }
                return consolidatedStreetAddress;
            }
            set;
        }

        public Account toAccount() {
            PersonAccountService service = new PersonAccountService();
            return new Account(
                RecordTypeId = service.getCustomerRecordType().Id,
                FirstName = firstName,
                LastName = lastName,
                PersonEmail = email,
                Company_School__c = companyName,
                PersonMailingStreet = consolidatedStreetAddress,
                PersonMailingPostalCode = postalCode,
                PersonMailingCity = city,
                PersonMailingState = state,
                PersonMailingCountry = countryCode,
                PersonMobilePhone = phone,
                IdNumber__c = idNumber,
                Nationality__c = nationality,
                GenderPick__c = gender,
                PersonBirthdate = parseDate(birthday),
                OccupationPick__c = occupation,
                IncomeLevelPick__c = incomeLevel
            );
        }
    }

    public class UserResponsePayload {
        @AuraEnabled
        public Long userId;  //: 1234,
        @AuraEnabled
        public String username;  //: "mark.smith34",
        // public Long mediciLivingCustomerId;  //: 100000001,
        // public Long quartersMemberId;  //: 400000001,
        @AuraEnabled
        public String status;  //: "READY_TO_BOOK"

        public UserResponsePayload() {}
        public UserResponsePayload(Account account) {
            userId = Long.valueOf(account.UserId__c);
            username = account.PersonEmail;
            status = account.CustomerStatusPick__c;
        }
    }

    // Contracts

    public class ContractRequestPayload extends RequestPayload {
        public Long userId;  //: 1,
        public String referenceId;  //: "DE-01-001-01Q",
        public String startOfContract;  //: "2019-01-01",
        public String plannedEndOfContract;  //: "2019-04-01"
      
        protected override String checkRequired() {
            if (userId == null) { return 'userId'; }
            if (String.isBlank(referenceId)) { return 'referenceId'; }
            if (String.isBlank(startOfContract)) { return 'startOfContract'; }

            return null;
        }
    }

    public class ContractResponsePayload {
        @AuraEnabled
        public Long contractId;  //: 1,
        @AuraEnabled
        public String periodType = 'FIXED';  //: "FLEXI",
        @AuraEnabled
        public String status = 'DRAFT';  //: "CREATED"

        public ContractResponsePayload(Opportunity opp) {
            contractId = Long.valueOf(opp.ContractIdAuto__c);
        }
    }


    // Rooms
    public class RoomRequestPayload extends RequestPayload {
        public Integer page = 0;
        public Integer size = 10;
        
        public String[] sortX = new List<String>();

        public String[] countryCode;  // IN
        public String[] brand;  // IN
        public String[] brandApi;  // IN
        public String[] referenceId;  // IN
        public String[] notReferenceId;  // NOT IN

        public String streetAddress;  // LIKE
        public String streetNumber;  // ==
        public String postalCode;  // ==
        public String[] city;  // IN
        public String[] district;  // IN

        public Decimal latitudeFrom; // >=
        public Decimal latitudeTo;  // <=
        public Decimal longitudeFrom; // >=
        public Decimal longitudeTo;  // <=

        public String amenities;  // CONTAINS

        public Decimal rentFrom; // >=
        public Decimal rentTo;  // <=

        public String[] currencyCode;  // IN
        public String[] notCurrencyCode;  // NOT IN

        public Decimal sizeFrom; // >=
        public Decimal sizeTo;  // <=

        public Integer bedroomsFrom; // >=
        public Integer bedroomsTo;  // <=

        public String[] type; // IN
        public String[] notType; // NOT IN

        public String[] shareType; // IN
        // public String[] notShareType; // NOT IN

        public Boolean fixedContractLength;  // ==
        public Boolean flexibleContractLength;  // == ?

        public String contractDurationType;  // ==
        public String[] noticePeriodType;  // IN
        public String[] notNoticePeriodType;  // NOT IN

        public Date availableDateFrom;  // >=
        public Date availableDateTo;  // <=

        public Datetime latestUpdateFrom;  // >=
        public Datetime latestUpdateTo;  // <=

        public Boolean bookable;  // ==
        public String[] view;

        public RoomRequestPayload(Map<String, String> params) {
            if (params.containsKey('page')) { page = Integer.valueOf(params.get('page')); }
            if (params.containsKey('size')) { size = Integer.valueOf(params.get('size')); }

            if (params.containsKey('sort')) { sortX = params.get('sort').split(';'); }

            if (params.containsKey('countryCode')) { countryCode = params.get('countryCode').split(';'); }
            if (params.containsKey('brand')) { brand = params.get('brand').split(';'); }
            if (params.containsKey('brandApi')) { brandApi = params.get('brandApi').split(';'); }
            if (params.containsKey('referenceId')) { referenceId = params.get('referenceId').split(';'); }
            if (params.containsKey('notReferenceId')) { notReferenceId = params.get('notReferenceId').split(';'); }

            if (params.containsKey('streetAddress')) { streetAddress = params.get('streetAddress'); }
            if (params.containsKey('streetNumber')) { streetNumber = params.get('streetNumber'); }
            if (params.containsKey('postalCode')) { postalCode = params.get('postalCode'); }
            if (params.containsKey('city')) { city = params.get('city').split(';'); }
            if (params.containsKey('district')) { district = params.get('district').split(';'); }

            if (params.containsKey('latitudeFrom')) { latitudeFrom = Decimal.valueOf(params.get('latitudeFrom')); }
            if (params.containsKey('latitudeTo')) { latitudeTo = Decimal.valueOf(params.get('latitudeTo')); }
            if (params.containsKey('longitudeFrom')) { longitudeFrom = Decimal.valueOf(params.get('longitudeFrom')); }
            if (params.containsKey('longitudeTo')) { longitudeTo = Decimal.valueOf(params.get('longitudeTo')); }

            if (params.containsKey('amenities')) { amenities = params.get('amenities'); }

            if (params.containsKey('rentFrom')) { rentFrom = Decimal.valueOf(params.get('rentFrom')); }
            if (params.containsKey('rentTo')) { rentTo = Decimal.valueOf(params.get('rentTo')); }

            if (params.containsKey('currencyCode')) { currencyCode = params.get('currencyCode').split(';'); }
            if (params.containsKey('notCurrencyCode')) { notCurrencyCode = params.get('notCurrencyCode').split(';'); }

            if (params.containsKey('sizeFrom')) { sizeFrom = Decimal.valueOf(params.get('sizeFrom')); }
            if (params.containsKey('sizeTo')) { sizeTo = Decimal.valueOf(params.get('sizeTo')); }

            if (params.containsKey('bedroomsFrom')) { bedroomsFrom = Integer.valueOf(params.get('bedroomsFrom')); }
            if (params.containsKey('bedroomsTo')) { bedroomsTo = Integer.valueOf(params.get('bedroomsTo')); }

            if (params.containsKey('type')) { type = params.get('type').split(';'); }
            if (params.containsKey('notType')) { notType = params.get('notType').split(';'); }

            if (params.containsKey('shareType')) { shareType = params.get('shareType').split(';'); }

            if (params.containsKey('fixedContractLength')) { fixedContractLength = Boolean.valueOf(params.get('fixedContractLength')); }
            if (params.containsKey('flexibleContractLength')) { flexibleContractLength = Boolean.valueOf(params.get('flexibleContractLength')); }

            if (params.containsKey('contractDurationType')) { contractDurationType = params.get('contractDurationType'); }
            if (params.containsKey('noticePeriodType')) { noticePeriodType = params.get('noticePeriodType').split(';'); }
            if (params.containsKey('notNoticePeriodType')) { notNoticePeriodType = params.get('notNoticePeriodType').split(';'); }

            if (params.containsKey('availableDateFrom')) { availableDateFrom = Date.valueOf(params.get('availableDateFrom')); }
            if (params.containsKey('availableDateTo')) { availableDateTo = Date.valueOf(params.get('availableDateTo')); }

            if (params.containsKey('latestUpdateFrom')) { latestUpdateFrom = parseDatetime(params.get('latestUpdateFrom')); }
            if (params.containsKey('latestUpdateTo')) { latestUpdateTo = parseDatetime(params.get('latestUpdateTo')); }

            if (params.containsKey('bookable')) { bookable = Boolean.valueOf(params.get('bookable')); }
            if (params.containsKey('view')) { view = params.get('view').split(';'); }
        }
    }

    public class Area {
        @AuraEnabled
        public Decimal size;  //": 10,
        @AuraEnabled
        public String measure;  //": "sqm",
        @AuraEnabled
        public String formatted {  //": "10.0 sqm"
            get {
                if (size != null) {
                    return size.setScale(1).format() + ' ' + measure;
                }
                return formatted;
            }
            private set;
        }
    }

    public class Price {
        @AuraEnabled
        public Decimal amount;  //": 1500,
        @AuraEnabled
        public String currencyCode = 'EUR'; //": "1500.00 EUR"
        @AuraEnabled
        public String currencySymbol {
            get {
                return currencyCode == 'EUR' ? '€' : currencyCode;
            }
            private set;
        }
        @AuraEnabled
        public String formatted {  //": "1500.00 EUR"
            get {
                if (amount != null) {
                    return amount.setScale(2).format() + ' ' + currencySymbol;
                }
                return formatted;
            }
            private set;
        }
    }

    public class ImageFile {
        @AuraEnabled
        public String url;  // : "https://static.goquarters.com/images/property/123/example.jpg",
        @AuraEnabled
        public Integer width;  // : 1024,
        @AuraEnabled
        public Integer height;  // : 768,
        public Long fileSize;  // : 1500073

        public ImageFile() {}

        public ImageFile(DragDropToCloud__Cloud_Documents__c document) {
            url = document.S3PublicUrlAuto__c;
            fileSize = document.DragDropToCloud__File_Size_Numeric__c?.longValue();
        }
    }

    public class Image {
        @AuraEnabled
        public String type;  //":  ROOM, UNIT, BUILDING, GROUNDPLAN, FLOORPLAN
        @AuraEnabled
        public Map<String, ImageFile> files;

        public Image() {}

        public Image(String type, DragDropToCloud__Cloud_Documents__c document) {
            this.type = type;
            files = new Map<String, ImageFile> {
                'original' => new ImageFile(document)
            };
        }
    }

    public class Fee {
        @AuraEnabled
        public Decimal amount;  //: 1000,
        @AuraEnabled
        public String currencyCode = 'EUR';
        @AuraEnabled
        public String name;  //: "Rebooking Fee",
        @AuraEnabled
        public String description;  //: "Fee that has to be paid when changing rooms, non refundable",
        @AuraEnabled
        public String collector;  //: "Quarters, None",
        @AuraEnabled
        public String juncture;  //: "ON_BOOKING"
        @AuraEnabled
        public String currencySymbol {
            get {
                return currencyCode == 'EUR' ? '€' : currencyCode;
            }
            private set;
        }
        @AuraEnabled
        public String formatted {  //": "1500.00 EUR"
            get {
                if (amount != null) {
                    return amount.setScale(2).format() + ' ' + currencySymbol;
                }
                return formatted;
            }
            private set;
        }

        public Fee() {}

        public Fee(Fee__c record) {
            amount = record.Fee__c;
            name = record.Name;
            description = record.Description__c;
            juncture = record.JuncturePick__c;
            currencyCode = record.CurrencyIsoCode;
        }

        public Fee(Fee__c record, String collector) {
            this(record);
            this.collector = collector;
        }

        public Fee(Condition__c condition) {
            amount = condition.MembershipFee__c;
            name = 'Membership Fee';
            description = 'Charged only at the signature of the contract';
            currencyCode = condition.CurrencyIsoCode;
        }
    }

    public class Description {
        @AuraEnabled
        public String locale;  //: "de",
        @AuraEnabled
        public String type; 
        @AuraEnabled
        public String description;  //: "Dies ist ein sehr hübsches Zimmer.",
        @AuraEnabled
        public String markdown;  //: "string"

        public Description() {}

        public Description(Description__c record) {
            locale = record.LanguagePick__c;
            description = record.Description__c;
            if (record.RoomRef__c != null) {
                type = TYPE_ROOM;
            } else if (record.ApartmentRef__c != null) {
                type = TYPE_APARTMENT;
            } else if (record.PropertyRef__c != null) {
                type = TYPE_BUILDING;
            } else if (record.NeighbourhoodRef__c != null) {
                type = TYPE_DISTRICT;
            }
        }
    }

    public class TimePeriod {
        @AuraEnabled
        public Integer amount;  //": 14,
        @AuraEnabled
        public String unit;  //": "DAYS"
    }

    public class LeaseCondition {
        @AuraEnabled
        public Boolean fixedContractLength;  //": true,
        @AuraEnabled
        public Boolean flexibleContractLength;  //": true,
        @AuraEnabled
        public String contractDurationType;  //": "UNLIMITED",        
        @AuraEnabled
        public String noticePeriodType;  //": "END_OF_MONTH",
        @AuraEnabled
        public TimePeriod noticePeriod;
        @AuraEnabled
        public TimePeriod minimumStay;
        @AuraEnabled
        public TimePeriod maximumStay;
        @AuraEnabled
        public Date earliestStartOfContract;  //": "0202-09-24",
        @AuraEnabled
        public Date latestStartOfContract;  //": "2020-10-24"

        public LeaseCondition() {}
        public LeaseCondition(Condition__c condition, SObject record) {
            contractDurationType = condition?.ContractDurationTypePick__c;
            noticePeriodType = condition?.NoticePeriodTypePick__c;

            noticePeriod = new TimePeriod();
            noticePeriod.amount = (Integer) condition?.NoticePeriodNumber__c;
            noticePeriod.unit = condition?.NoticePeriodUnitPick__c;

            minimumStay = new TimePeriod();
            minimumStay.amount = (Integer) condition?.MinimumStayNumber__c;
            minimumStay.unit = condition?.MinimumStayUnitPick__c;

            maximumStay = new TimePeriod();
            maximumStay.amount = (Integer) condition?.MaximumStayNumber__c;
            maximumStay.unit = condition?.MaximumStayUnitPick__c;

            if (record.get('EarliestStartOfContractAuto__c') != null) {
                earliestStartOfContract = ((Datetime) record.get('EarliestStartOfContractAuto__c')).date();
            }
            if (record.get('LatestStartOfContractAuto__c') != null) {
                latestStartOfContract = ((Datetime) record.get('LatestStartOfContractAuto__c')).date();
            }
        }
    }

    public class Room {
        @AuraEnabled
        public String referenceId;  //": "NL-01-001-01",
        @AuraEnabled
        public String streetAddress;  //": "Grand Street",
        @AuraEnabled
        public String streetNumber;  //": "324",
        @AuraEnabled
        public String postalCode;  //": "13089",
        @AuraEnabled
        public String district;  //": "Scheveningen",
        @AuraEnabled
        public String city;  //": "The Hague",
        @AuraEnabled
        public String countryCode;  //": "NL",
        @AuraEnabled
        public String brand;  //": "MEDICI_LIVING",
        @AuraEnabled
        public String brandApi;  //": "MEDICI_LIVING",
        @AuraEnabled
        public Decimal latitude;  //": 0,
        @AuraEnabled
        public Decimal longitude;  //": 0,
        @AuraEnabled
        public String floor;  //": "Ground floor",
        @AuraEnabled
        public Integer bedrooms;  //": 5,
        @AuraEnabled
        public String amenities;  //": "Rooftop access, Free Wi-Fi, Games Room",
        @AuraEnabled
        public Area area;
        @AuraEnabled
        public Area apartmentArea;
        @AuraEnabled
        public Price rent;
        @AuraEnabled
        public Price deposit;
        @AuraEnabled
        public String type; //": "ROOM",
        @AuraEnabled
        public String shareType;
        @AuraEnabled
        public Boolean bookable; //": true,
        @AuraEnabled
        public String availableDate; //": "2020-09-24",
        @AuraEnabled
        public String latestUpdate; //": "2021-04-28T08:40:19.639Z",
        @AuraEnabled
        public String propertyCode;
        @AuraEnabled
        public String apartmentCode;

        @AuraEnabled
        public List<Image> images {
            get {
                if (images == null) {
                    images = new List<Image>();
                }
                return images;
            }
            private set;
        }

        @AuraEnabled
        public List<Fee> fees {
            get {
                if (fees == null) {
                    fees = new List<Fee>();
                }
                return fees;
            }
            private set;
        }
        
        @AuraEnabled
        public List<Description> descriptions {
            get {
                if (descriptions == null) {
                    descriptions = new List<Description>();
                }
                return descriptions;
            }
            private set;
        }

        @AuraEnabled
        public Decimal positionX;  //": 0.62,
        @AuraEnabled
        public Decimal positionY;  //": 0.18,
        @AuraEnabled
        public LeaseCondition leaseConditions;

        private String feeCollector;

        public Room() {}

        public Room(Room__c record) {
            type = TYPE_ROOM;

            referenceId = record.Name;
            bookable = record.IsBookableAuto__c;
            availableDate = serializeDate(record.EarliestStartofContractAuto__c);
            latestUpdate = serializeDatetime(record.LastModifiedDate);
            shareType = record.TypePick__c;

            area = new Area();
            area.size = record.SizeNumber__c;
            area.measure = record.UnitSizePick__c;

            rent = new Price();
            rent.amount = record.NetPrice__c;
            rent.currencyCode = record.CurrencyIsoCode;

            setPropertyValues(record.Property__r);
            setApartmentValues(record.ApartmentRef__r);
        }

        public Room(Apartment__c record) {
            type = TYPE_UNIT;

            referenceId = record.Name;
            bookable = record.IsBookableAuto__c;
            availableDate = serializeDate(record.EarliestStartofContractAuto__c.date());
            latestUpdate = serializeDatetime(record.LastModifiedDate);
            shareType = SHARE_PRIVATE_APARTMENT;

            area = new Area();
            area.size = record.SizeNumber__c;
            area.measure = record.UnitSizePick__c;

            rent = new Price();
            rent.amount = record.NetPrice__c != null ? record.NetPrice__c : 0;
            rent.currencyCode = record.CurrencyIsoCode;

            setApartmentValues(record);
            setPropertyValues(record.PropertyRef__r);
        }

        public Room setApartmentValues(Apartment__c apartment) {
            bedrooms = Integer.valueOf(apartment?.Number_of_units__c);
            floor = apartment?.FloorPick__c;
            apartmentCode = apartment?.Name;

            apartmentArea = new Area();
            apartmentArea.size = apartment?.SizeNumber__c;
            apartmentArea.measure = apartment?.UnitSizePick__c;

            return this;
        }

        public Room setPropertyValues(Property__c property) {
            streetAddress = property?.Street__c;
            // streetNumber
            postalCode = property?.Postal_Code__c;
            district = property?.NeighbourhoodRef__r?.Name;
            city = property?.City__c;
            countryCode = property?.Country__c;
            brand = property?.BrandRef__r?.Name;
            brandApi = property?.BrandRef__r?.APINameBrand__c;
            latitude = property?.PropertyLocation__latitude__s;
            longitude = property?.PropertyLocation__longitude__s;

            feeCollector = property?.Billing_Entity__r.Name;
            propertyCode = property?.Name;

            return this;
        }

        public Room setAmenities(List<Amenity__c> amenities) {
            if (amenities != null && !amenities.isEmpty()) {
                List<String> amenitiesList = new List<String>();
                
                for (Amenity__c amenity: amenities) {
                    amenitiesList.add(amenity.Name);
                }
                
                this.amenities = String.join(amenitiesList, ', ');
            }

            return this;
        }

        public Room setDescriptions(List<Description__c> descriptions) {
            if (descriptions != null) {
                for (Description__c record: descriptions) {
                    this.descriptions.add(new Description(record));
                }
            }

            return this;
        }

        public Room setFees(List<Fee__c> fees) {
            if (fees != null) {
                for (Fee__c fee: fees) {
                    this.fees.add(new Fee(fee, feeCollector));
                }
            }

            return this;
        }

        public Room setCondition(Condition__c condition, SObject record) {
            leaseConditions = new LeaseCondition(condition, record);

            deposit = new Price();
            if (rent != null && condition != null) {
                if (condition.DepositRule__c == 'Multiplier') {
                    deposit.amount = rent.amount * condition.DepositMultiplier__c;
                } else if (condition.DepositRule__c == 'Absolute') {
                    deposit.amount = condition.AbsoluteDepositAmount__c;
                } else if (condition.DepositRule__c == 'MultiplierPlusAbsolute') {
                    deposit.amount = rent.amount * condition.DepositMultiplier__c + condition.AbsoluteDepositAmount__c;
                } else if (condition.DepositRule__c == 'None') {
                    deposit.amount = 0;
                } else {
                    // Should not reach this part of the code
                    deposit.amount = 0;
                }
                deposit.currencyCode = condition.CurrencyIsoCode;
            }

            // Adding the Membership fee, located on the Property condition
            if (condition != null && condition.MembershipFee__c != null) {
                this.fees.add(new Fee(condition));
            }

            return this;
        }

        public Room addImages(String type, List<DragDropToCloud__Cloud_Documents__c> documents) {
            for (DragDropToCloud__Cloud_Documents__c doc: documents) {
                addImage(type, doc);
            }
            return this;
        }

        public Room addImage(String type, DragDropToCloud__Cloud_Documents__c doc) {
            images.add(new Image(type, doc));
            return this;
        }
    }

    public class SortX {
        @AuraEnabled
        public Boolean sorted = false;
        @AuraEnabled
        public Boolean unsorted = true;
        @AuraEnabled
        public Boolean empty = true;
    }

    public class Pageable {
        @AuraEnabled
        public Integer page = 0;
        @AuraEnabled
        public Integer size = 10;
        @AuraEnabled
        public SortX sortX = new SortX();
    }

    public virtual class PaginatedResponsePayload {
        @AuraEnabled
        public Integer totalPages = 0;
        @AuraEnabled
        public Long totalElements = 0;
        @AuraEnabled
        public Integer size = 0;

        @AuraEnabled
        public SortX sortX = new SortX();

        @AuraEnabled
        public Boolean first = false;
        @AuraEnabled
        public Boolean last = false;
        @AuraEnabled
        public Boolean empty = true;

        @AuraEnabled
        public Integer numberX = 0;
        @AuraEnabled
        public Integer numberOfElements = 0;

        @AuraEnabled
        public Pageable pageable = new Pageable();
    }

    public class RoomResponsePayload extends PaginatedResponsePayload {
        @AuraEnabled
        public Room[] content {
            get {
                if (content == null) {
                    content = new List<Room>();
                }
                return content;
            }
            private set;
        }

        public Room add(SObject record) {
            return record.getSObjectType() == RoomService.SObjectType ? 
                addRoom((Room__c) record) : 
                addApartment((Apartment__c) record);
        }

        public Room addRoom(Room__c record) {
            Room entry = new Room(record);
            content.add(entry);
            return entry;
        }

        public Room addApartment(Apartment__c record) {
            Room entry = new Room(record);
            content.add(entry);
            return entry;
        }

        public void initFromInput(RoomRequestPayload input, Integer totalCount) {
            totalElements = totalCount;
            totalPages = Integer.valueOf((Decimal.valueOf(totalElements) / input.size).round(RoundingMode.CEILING));
            numberX = (input.page != null) ? input.page : 0;

            first = numberX == 0;
            last = numberX == totalPages - 1;

            sortX.sorted = input.sortX != null && !input.sortX.isEmpty();
            sortX.unsorted = ! sortX.sorted;
            sortX.empty = sortX.unsorted;

            pageable.page = numberX;
            pageable.sortX = sortX;
        }

        public RoomResponsePayload finalize() {
            size = content.size();
            numberOfElements = size;

            empty = size == 0;
            pageable.size = size;

            return this;
        }

        public String toJson() {
            return JSON.serialize(this).replace('sortX', 'sort').replace('numberX', 'number');
        }
    }

    // Calculations
    public class CalculationFirstMonthRequestPayload extends RequestPayload {
        @AuraEnabled
        public String referenceId;  //: "DE-01-001-01Q",
        @AuraEnabled
        public Date startOfContract;  //: "2019-01-01",

        public CalculationFirstMonthRequestPayload(Map<String, String> params) {
            if (params.containsKey('referenceId')) { referenceId = params.get('referenceId'); }
            if (params.containsKey('startOfContract')) { startOfContract = Date.valueOf(params.get('startOfContract')); }
        }

        protected override String checkRequired() {
            if (String.isBlank(referenceId)) { return 'referenceId'; }
            if (startOfContract == null) { return 'startOfContract'; }

            return null;
        }
    }

    public class CalculationFirstMonthResponsePayload {
        @AuraEnabled
        public Decimal firstMonthRent;
        @AuraEnabled
        public String currencyCode = 'EUR';
        @AuraEnabled
        public String currencySymbol {
            get {
                return currencyCode == 'EUR' ? '€' : currencyCode;
            }
            private set;
        }
        @AuraEnabled
        public String formatted {  //": "1500.00 EUR"
            get {
                if (firstMonthRent != null) {
                    return firstMonthRent.setScale(2).format() + ' ' + currencySymbol;
                }
                return formatted;
            }
            private set;
        }

        public CalculationFirstMonthResponsePayload(Decimal firstMonthRent) {
            this(firstMonthRent, 'EUR');
        }


        public CalculationFirstMonthResponsePayload(Decimal firstMonthRent, String currencyIsoCode) {
            this.firstMonthRent = firstMonthRent;
            this.currencyCode = currencyIsoCode;
            this.currencySymbol = currencyIsoCode == 'EUR' ? '€' : currencyIsoCode;
        }

    }
}
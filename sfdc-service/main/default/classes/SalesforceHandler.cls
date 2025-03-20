public with sharing class SalesforceHandler extends ServiceHandler {
    public virtual class SalesforceObject extends ServiceObject {
        Schema.DescribeSobjectResult sObjDescribe;
        public SalesforceObject(Schema.DescribeSobjectResult obj) { this.sObjDescribe = obj; }
        public override String getApiName() { return this.sObjDescribe.getName(); }
        public override String getDisplayName() { return this.sObjDescribe.getLabel(); }
        public override List<ServiceObjectField> getFields() {
            // if (this.fields == null) {
            //     this.fields = new List<ServiceObjectField>();
            //     List<Object_Field__mdt> flds = [SELECT API_Name__c, Display_Name__c, Data_Type__c FROM Object_Field__mdt WHERE Object__c=:this.obj.Id];
            //     for (Object_Field__mdt fld : flds) {
            //         this.fields.add(new DefaultObjectField(fld));
            //     }
            // }
            // return this.fields;
            return null;
        }
    }

    public virtual class SalesforceObjectField extends ServiceObjectField {
        protected Object_Field__mdt field;

        public SalesforceObjectField(Object_Field__mdt fld) { this.field = fld; }
        public override String getApiName() { return this.field.API_Name__c; }
        public override String getDisplayName() { return this.field.Display_Name__c; }
        // TODO: need a map of our values to SFDC types
        public override String getType() { return this.field.Data_Type__c; }
    }

    public override List<ServiceObject> getAllObjects() {
        // There are so many standard sObjects in Salesforce that we still need to call out the most common, which are stored as
        // Object custom metadata records.

        // DataSource ds = DataSource.getRecordByName(this.getServiceApiName());
        // if (ds == null) throw new IllegalArgumentException('Unable to find a metadata record for the ' + this.getServiceDisplayName() + ' service');
        // List<Object__mdt> mdObjs = [SELECT API_Name__c, Display_Name__c, Data_Source__c FROM Object__mdt WHERE Data_Source__c=:ds.Id];
        // List<ServiceObject> objs = new List<ServiceObject>();
        // for (Object__mdt mdObj : mdObjs) {
        //     objs.add(new DefaultObject(mdObj));
        // }
        // return objs;
        return null;
    }

    public override ServiceObject getObject(String apiName) {
        // if (String.isBlank(apiName)) throw new IllegalArgumentException('A valid object name must be provided');
        // String mdName = getObjectName(apiName);
        // Object_mdt obj = Object__mdt.getInstance(mdName);
        // if (obj != null) return new DefaultObject(obj);
        return null;
    }

    public SalesforceHandler() {}

    public override String getServiceApiName() {
        return 'sfdc';
    }

    public override String getServiceDisplayName() {
        return 'Salesforce';
    }

    // public virtual ServiceResponse createResponse(HttpResponse resp) {
    //     return new StripeResponse(resp);
    // }

    // public override Map<String,String> getHeaders(Object_Action__mdt action) {
    //     Map<String,String> headers = new Map<String,String>();
    //     headers.put('Content-Type', 'application/json');
    //     return headers;
    // }
}
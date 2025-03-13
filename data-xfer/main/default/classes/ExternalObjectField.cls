public with sharing class ExternalObjectField extends ObjectWrapper {
    public static String getObjectName(ExternalObject obj, String fldName) {
        if ((obj == null) || String.isBlank(fldName)) throw new IllegalArgumentException('External object and field name must be provided');
        return String.format('{0}_{1}', new List<Object>{ obj.getApiName(), fldName });
    }

    public static ExternalObjectField getRecordByName(String name) {
        if (String.isBlank(name)) throw new IllegalArgumentException('Name must be specified');
        Object_Field__mdt obj = Object_Field__mdt.getInstance(name);
        if (obj != null) return new ExternalObjectField(obj);
        return null;
    }

    public ExternalObjectField(Object_Field__mdt obj) {
        super(obj);
    }

    public override String getApiName() { return (String)this.get('API_Name__c'); }
    public String getDisplayName() { return (String)this.get('Display_Name__c'); }
    public String getType() { return (String)this.get('Data_Type__c'); }
    public Boolean isDeduplicateField() {
        return false;
    }
}
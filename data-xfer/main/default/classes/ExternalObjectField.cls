public with sharing class ExternalObjectField extends ObjectWrapper {
    public virtual class Selector extends ObjectWrapper.Selector {
        public Selector() { super(ExternalObjectField.class); }
        public virtual override SObject getInstance(String name) { return Object_Field__mdt.getInstance(name); }
    }

    public static String getObjectName(ExternalObject obj, String fldName) {
        if ((obj == null) || String.isBlank(fldName)) throw new IllegalArgumentException('External object and field name must be provided');
        return String.format('{0}_{1}', new List<Object>{ obj.getName(), fldName });
    }

    public static ExternalObjectField getRecordByName(String name) {
        return (ExternalObjectField)ObjectWrapper.getInstance(new Selector(), name);
    }

    public static List<ExternalObjectField> queryByObjectName(String objName) {
        Selector sltr = new Selector();
        sltr.setQueryResults([SELECT DeveloperName, Display_Name__c, API_Name__c, Object__c, Data_Type__c, Options__c FROM Object_Field__mdt WHERE Object__r.DeveloperName=:objName]);
        return (List<ExternalObjectField>)ObjectWrapper.query(sltr);
    }

    public ExternalObjectField() {}
    public ExternalObjectField(Object_Field__mdt obj) {
            super(obj);
    }

    public String getName() { return (String)this.get('DeveloperName'); }
    public override String getApiName() { return (String)this.get('API_Name__c'); }
    public String getDisplayName() { return (String)this.get('Display_Name__c'); }
    public String getType() { return (String)this.get('Data_Type__c'); }
}

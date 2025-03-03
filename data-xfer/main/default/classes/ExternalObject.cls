public with sharing class ExternalObject extends ObjectWrapper {
    public static String getObjectName(DataSource src, String name) {
        if ((src == null) || String.isBlank(name)) throw new IllegalArgumentException('Data source and name must be provided');
        return String.format('{0}_{1}', new List<Object>{ src.getApiName(), name });
    }

    public static ExternalObject getRecordByName(String name) {
        if (String.isBlank(name)) throw new IllegalArgumentException('Name must be specified');
        Object__mdt obj = Object__mdt.getInstance(name);
        if (obj != null) return new ExternalObject(obj);
        return null;
    }

    public ExternalObject(Object__mdt obj) {
        super(obj);
    }

    public String getDisplayName() { return (String)this.get('Display_Name__c'); }
}
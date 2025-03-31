public with sharing class ExternalObject extends ObjectWrapper {
    public virtual class Selector extends ObjectWrapper.Selector {
        public Selector() { super(ExternalObject.class); }
        public virtual override SObject getInstance(String name) { return Object__mdt.getInstance(name); }
    }

    public static String getObjectName(DataSource src, String name) {
        if ((src == null) || String.isBlank(name)) throw new IllegalArgumentException('Data source and name must be provided');
        return String.format('{0}_{1}', new List<Object>{ src.getApiName(), name });
    }

    public static ExternalObject getRecordByName(String name) {
        return (ExternalObject)ObjectWrapper.getInstance(new Selector(), name);
    }

    public ExternalObject() {}
    public ExternalObject(Object__mdt src) {
        super(src);
    }

    public override String getApiName() { return (String)this.get('API_Name__c'); }
    public String getDisplayName() { return (String)this.get('Display_Name__c'); }
    public DataSource getDataSource() {
        string dsName = (String)this.get('Data_Source__c');
        if (String.isNotBlank(dsName)) {
            DataSource ds = DataSource.getRecordByName(dsName);
            if (ds == null) throw new StandardException('Did not find DataSource with name ' + dsName);
            return ds;
        }
        return null;
    }

}

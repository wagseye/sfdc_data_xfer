public with sharing virtual class DataSource extends ObjectWrapper {
    public virtual class Selector extends ObjectWrapper.Selector {
        public Selector() { super(DataSource.class); }
        public virtual override SObject getInstance(String name) { return Data_Source__mdt.getInstance(name); }
        public virtual override List<SObject> getAll() { return Data_Source__mdt.getAll().values(); }
    }

    public static DataSource getRecordByName(String name) {
        return (DataSource)ObjectWrapper.getInstance(new Selector(), name);
    }

    public static List<DataSource> getAll() {
        return (List<DataSource>)ObjectWrapper.getAll(new Selector());
    }

    public static List<DataSource> queryExternalRecords(String name) {
        Selector sltr = new Selector();
        sltr.setQueryResults([SELECT Id, DeveloperName, Display_Name__c, Handler_Class__c FROM Data_Source__mdt WHERE DeveloperName!='sfdc']);
        return (List<DataSource>)ObjectWrapper.query(sltr);
    }

    public DataSource() {}
    public DataSource(Data_Source__mdt src) {
        super(src);
    }

    public String getLabel() { return (String)this.get('Display_Name__c'); }
    public String getApiVersion() { return (String)this.get('API_Version__c'); }
    public String getBasePath() { return (String)this.get('Base_Url__c'); }
    public String getHandlerClass() { return (String)this.get('Handler_Class__c'); }

    public ServiceHandler getHandler() {
        String className = getHandlerClass();
        Object newObj = Type.forName(className).newInstance();
        if (!(newObj instanceof ServiceHandler)) throw new StandardException('Class "' + className + '" does not extend ServiceHandler');
        return (ServiceHandler)newObj;
    }
}
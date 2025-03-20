public with sharing virtual class DataSource extends ObjectWrapper {
    public virtual class Selector extends ObjectWrapper.Selector {
        private List<Data_Source__mdt> queryResults;
        public Selector() {}
        public Selector(List<Data_Source__mdt> queryResults) { this.queryResults = queryResults; }
        public override ObjectWrapper wrap(SObject obj) { return new DataSource((Data_Source__mdt) obj); }
        public override List<ObjectWrapper> createList() { return new List<DataSource>(); }
        public virtual override SObject getInstance(String identifier) { return Data_Source__mdt.getInstance(identifier); }
        public virtual override List<SObject> getAll() { return Data_Source__mdt.getAll().values(); }
        public virtual override List<SObject> query() { return queryResults; }
    }

    public static DataSource getRecordByName(String name) {
        if (String.isBlank(name)) throw new IllegalArgumentException('Name must be specified');
        return (DataSource)ObjectWrapper.getInstance(new Selector(), name);
    }

    // public static List<DataSource> queryExternalRecords() {
    //     return (List<DataSource>)ObjectWrapper.query(new Selector([SELECT Id, DeveloperName, Display_Name__c, Handler_Class__c FROM Data_Source__mdt WHERE DeveloperName!='sfdc']));
    // }

    public static List<DataSource> getAll() {
        return (List<DataSource>)ObjectWrapper.getAll(new Selector());
    }
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
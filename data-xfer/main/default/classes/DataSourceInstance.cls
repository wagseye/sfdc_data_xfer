public with sharing class DataSourceInstance extends ObjectWrapper {
    public virtual class Selector extends ObjectWrapper.Selector {
        public Selector() { super(DataSourceInstance.class); }
        public virtual override SObject getInstance(String name) { return Data_Source_Instance__c.getInstance(name); }
        public virtual override List<SObject> getAll() { return Data_Source_Instance__c.getAll().values(); }
    }

    public static DataSourceInstance getRecordByName(String name) {
        return (DataSourceInstance)ObjectWrapper.getInstance(new Selector(), name);
    }

    public static List<DataSourceInstance> getAll() {
        return (List<DataSourceInstance>)ObjectWrapper.getAll(new Selector());
    }

    public static List<DataSourceInstance> queryByDataSourceName(String dataSourceName) {
        Selector sltr = new Selector();
        // Note that this intentionally does not load up the API id or secret, as we should never need those when loading multiple records
        sltr.setQueryResults([SELECT Id, Data_Source_Name__c, Display_Name__c, Instance_Type__c, Options__c FROM Data_Source_Instance__c WHERE Data_Source_Name__c=:dataSourceName]);
        return (List<DataSourceInstance>)ObjectWrapper.query(sltr);
    }

    public DataSourceInstance() {}
    public DataSourceInstance(Data_Source_Instance__c dsi) {
        super(dsi);
    }

    public String getDisplayName() { return (String)super.get('Display_Name__c'); }
    public String getInstanceType() { return (String)super.get('Instance_Type__c'); }
    public String getApiId() { return (String)super.get('API_Id__c'); }
    public String getApiSecret() { return (String)super.get('API_Secret__c'); }

    public DataSource getDataSource() {
        String sourceName = (String)super.get('Data_Source_Name__c');
        if (String.isNotBlank(sourceName)) {

            DataSource source = DataSource.getRecordByName(sourceName);
            if (source == null) throw new StandardException('Did not find DataSource with name ' + sourceName);
            return source;
        }
        return null;
    }

    public Map<String,Object> getOptions() {
        try {
            return (Map<String,Object>)JSON.deserializeUntyped((String)this.get('Options__c'));
        } catch (JSONException ex) {
            throw new StandardException('DataSourceInstance.Extras contains invalid JSON');
        }
    }
}
public with sharing class DataSourceInstance extends ObjectWrapper {

    public static DataSourceInstance getRecordByName(String name) {
        if (String.isBlank(name)) throw new IllegalArgumentException('Name must be specified');
        Data_Source_Instance__c dsi = Data_Source_Instance__c.getInstance(name);
        if (dsi != null) return new DataSourceInstance(dsi);
        return null;
    }

    public DataSourceInstance(Data_Source_Instance__c dsi) {
        super(dsi);
    }

    public String getApiId() { return (String)super.get('API_Id__c'); }
    public String getApiSecret() { return (String)super.get('API_Secret__c'); }
    public String getOptions() { return (String)super.get('Options__c'); }
}
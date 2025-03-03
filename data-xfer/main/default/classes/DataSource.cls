public with sharing virtual class DataSource extends ObjectWrapper {

    public static DataSource getRecordByName(String name) {
        if (String.isBlank(name)) throw new IllegalArgumentException('Name must be specified');
        Data_Source__mdt source = Data_Source__mdt.getInstance(name);
        if (source != null) return new DataSource(source);
        return null;
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
public with sharing class DataFlowDefinition extends ObjectWrapper {
    protected DataSource source;
    protected DataSourceInstance dsi;
    protected ExternalObject exObj;
    protected ExternalObjectAction action;

    public static DataFlowDefinition getRecordById(Id recId) {
        if (String.isBlank(recId)) throw new IllegalArgumentException('Record id must be specified');
        Data_Flow_Definition__c dfd =
            [SELECT Id, Name, External_Object__c, Salesforce_Object__c, Type__c, External_Data_Source__c, Field_Mapping_Set__c, Data_Source_Instance_Name__c
             FROM Data_Flow_Definition__c WHERE Id=:recId];
        if (dfd != null) return new DataFlowDefinition(dfd);
        return null;
    }

    public DataFlowDefinition(Data_Flow_Definition__c dfd) {
        super(dfd);
    }

    public String getSourceApiName() { return (String)this.get('External_Data_Source__c'); }
    public String getExternalObjectApiName() { return (String)this.get('External_Object__c'); }
    public Boolean isImport() { return this.get('Type__c') == 'import'; }

    public DataSource getDataSource() {
        if (this.source == null){
            this.source = DataSource.getRecordByName(this.getSourceApiName());
        }
        return this.source;
    }

    public DataSourceInstance getDataSourceInstance() {
        if (this.dsi == null) {
            this.dsi = DataSourceInstance.getRecordByName((String)this.get('Data_Source_Instance_Name__c'));
        }
        return this.dsi;
    }

    public ExternalObject getExternalObject() {
        if (this.exObj == null){
            this.exObj = ExternalObject.getRecordByName(this.getExternalObjectApiName());
        }
        return this.exObj;
    }

    public ExternalObjectAction getDefaultAction() {
        if (this.action == null) {
            if (!this.isImport()) throw new IllegalArgumentException('No default action found');
            this.action = this.getAction('query');
        }
        return this.action;
    }

    public ExternalObjectAction getAction(String actionName) {
        String fullName = ExternalObjectAction.getActionName(this.getExternalObject(), actionName);
        return ExternalObjectAction.getRecordByName(fullName);
    }

    public void run() {
        DataSource ds = this.getDataSource();
        if (ds == null) throw new StandardException('Unable to find the data source for this data flow definition');
        ServiceHandler handler = ds.getHandler();
        handler.transferData(this);
    }

    public Datetime getLastRunTimestamp(Boolean successOnly)
    {
        Data_Transfer_Job__c lastJob;
        if (successOnly) {
            lastJob = [SELECT Id, Operation_Timestamp__c FROM Data_Transfer_Job__c WHERE Data_Flow_Definition__c=:this.record.Id AND Status__c='Succeeded' ORDER BY Operation_Timestamp__c DESC LIMIT 1];
        } else {
            lastJob = [SELECT Id, Operation_Timestamp__c FROM Data_Transfer_Job__c WHERE Data_Flow_Definition__c=:this.record.Id ORDER BY Operation_Timestamp__c DESC LIMIT 1];
        }
        if (lastJob != null) return lastJob.Operation_Timestamp__c;
        return null;
    }
}
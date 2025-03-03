List<SObjectType> objTypes = new List<SOBjectType>{
  Field_Mapping__c.sObjectType,
  Data_Flow_Definition__c.sObjectType,
  Field_Mapping_Set__c.sObjectType
};

for (SObjectType objType : objTypes) {
    List<SObject> objs = Database.query(String.format('SELECT Id FROM {0}', new List<Object>{ objType.getDescribe().name }));
    if (objs.size() > 0) {
        delete objs;
    }
}

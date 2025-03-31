@isTest
public class ObjectRelationTest {
    /************************************************************************/
    /*  Utility methods and classes
    /************************************************************************/
    public static Object_Relation__mdt createObjectRelation(String name, String dataSource, String access) {
        Map<String,Object> data = new Map<String,Object>{ 'DeveloperName' => name, 'Data_Source__c' => dataSource, 'Extras__c' => '{ "forwardAccess":"' + access + '"}' };
        return (Object_Relation__mdt)ObjectWrapperTest.createMetadataRecord(Object_Relation__mdt.getSObjectType(), data);
    }

    public static void addObjectRelations() {
        Map<String,SObject> mapRels = new Map<String,SObject>();
        for (Object_Relation__mdt rel : getObjectRelations()) {
            mapRels.put(rel.DeveloperName, rel);
        }
        ObjectWrapper.addMock(new ObjectWrapperTest.TestSelector(ObjectRelation.class, mapRels));
    }

    public static List<Object_Relation__mdt> getObjectRelations() {
        List<Object_Relation__mdt> rels = new List<Object_Relation__mdt>();
        rels.add(createObjectRelation('strp_p1_c1', 'strp', 'junction'));
        rels.add(createObjectRelation('strp_p1_c2', 'strp', 'expand'));
        rels.add(createObjectRelation('strp_c2_g1', 'strp', 'expand'));
        return rels;
    }


    /************************************************************************/
    /*  Test methods
    /************************************************************************/
    @isTest
    static void testAccessors() {
        // Create the metadata inner record
        Map<String,Object> data = new Map<String,Object>{
            'DeveloperName' => 'myRelation',
            'Data_Source__c' => 'svc',
            'Field1__c' => 'f1',
            'Field2__c' => 'f2',
            'Intermediate_Object__c' => 'intObj',
            'Ratio__c' => '1:1',
            'Type__c' => 'lookup',
            'Extras__c' => '{ "forwardAccess":"expand"}' };
        Object_Relation__mdt rel_m = (Object_Relation__mdt)ObjectWrapperTest.createMetadataRecord(Object_Relation__mdt.getSObjectType(), data);

        // Create the wrapper object
        ObjectRelation rel = new ObjectRelation(rel_m);

        // Create a mock to load the data source
        Data_Source__mdt ds_m = DataSourceTest.createDataSource('svc', 'TestDataSource', ServiceHandlerTest.ServiceHandlerMock.class.toString(), null, null);
        ObjectWrapper.addMock(new ObjectWrapperTest.TestSelector(DataSource.class, ds_m));

        Test.startTest();
        {
            System.assertEquals('myRelation', rel.getApiName());
            System.assertEquals('f1', rel.getField1());
            System.assertEquals('f2', rel.getField2());
            System.assertEquals('intObj', rel.getIntermediateObject());
            System.assertEquals('1:1', rel.getRatio());
            System.assertEquals('lookup', rel.getType());
            DataSource src = rel.getDataSource();
            System.assertNotEquals(null, src);
            System.assertEquals('svc', src.getApiName());
        }
        Test.stopTest();
    }

    @isTest
    static void testSelector() {
        // This test ensures the selector does not cause any errors but we don't assert the results of
        // any of the calls because we don't want to rely on certain data being present
        DataSource.getRecordByName('strp');
        DataSource.getAll();
        DataSource.queryExternalSources();
    }
}

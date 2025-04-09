@isTest
public class ObjectRelationTest {
    /************************************************************************/
    /*  Utility methods and classes
    /************************************************************************/
    public static Object_Relation__mdt createObjectRelation(String name, String dataSource, String access, String intermediateObject) {
        String type = String.isBlank(intermediateObject) ? 'reference' : 'junction';
        Map<String,Object> data = new Map<String,Object>{ 'DeveloperName' => name, 'Data_Source__c' => dataSource,  'Type__c' => type, 'Intermediate_Object__c' => intermediateObject};
        if (String.isNotBlank(access)) data.put('Extras__c', '{ "forwardAccess":"' + access + '"}');
        return (Object_Relation__mdt)ObjectWrapperTest.createMetadataRecord(Object_Relation__mdt.getSObjectType(), data);
    }

    public static Object_Relation__mdt createObjectRelation(String name, String dataSource, Object__mdt obj1, String fld1, Object__mdt obj2, String fld2) {
        System.assert(obj1 != null); System.assert(obj2 != null);
        Map<String,Object> data = new Map<String,Object>{ 'DeveloperName' => name, 'Data_Source__c' => dataSource, 'Type__c' => 'reference', 'Object1__c' => obj1.DeveloperName, 'Field1__c' => fld1, 'Object2__c' => obj2.DeveloperName, 'Field2__c' => fld2 };
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
        rels.add(createObjectRelation('strp_p1_c1', 'strp', null, 'junction'));
        rels.add(createObjectRelation('strp_p1_c2', 'strp', 'expand', null));
        rels.add(createObjectRelation('strp_c2_g1', 'strp', 'expand', null));
        return rels;
    }


    /************************************************************************/
    /*  Test methods
    /************************************************************************/
    @isTest
    static void testReferenceAccessors() {
        Object__mdt obj_m = ExternalObjectTest.addTestExternalObject();
        obj_m.DeveloperName = 'test_object';

        // Create the metadata inner record
        Map<String,Object> data = new Map<String,Object>{
            'DeveloperName' => 'myRelation',
            'Data_Source__c' => 'svc',
            'Field1__c' => 'f1',
            'Field2__c' => 'f2',
            'Ratio__c' => '1:1',
            'Type__c' => 'reference',
            'Object1__c' => 'test_object',
            'Object2__c' => 'test_object',
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
            System.assertEquals(null, rel.getIntermediateObject());
            System.assertEquals('1:1', rel.getRatio());
            System.assertEquals(ObjectRelation.REFERENCE, rel.getType());
            System.assert(rel.isReference());
            System.assert(!rel.isJunction());

            ExternalObject obj = rel.getObject1();
            System.assertNotEquals(null, obj);
            System.assertEquals('test_object', obj.getName());
            obj = rel.getObject2();
            System.assertNotEquals(null, obj);
            System.assertEquals('test_object', obj.getName());

            DataSource src = rel.getDataSource();
            System.assertNotEquals(null, src);
            System.assertEquals('svc', src.getApiName());

        }
        Test.stopTest();
    }

    @isTest
    static void testJunctionAccessors() {
        Object__mdt obj_m = ExternalObjectTest.addTestExternalObject();
        obj_m.DeveloperName = 'test_object';

        // Create the metadata inner record
        Map<String,Object> data = new Map<String,Object>{
            'DeveloperName' => 'myJunction',
            'Data_Source__c' => 'svc',
            'Field1__c' => 'sub1',
            'Field2__c' => 'sub1',
            'Intermediate_Object__c' => 'juncObject',
            'Type__c' => 'junction',
            'Object1__c' => 'test_object',
            'Object2__c' => 'test_object' };
        Object_Relation__mdt junc_m = (Object_Relation__mdt)ObjectWrapperTest.createMetadataRecord(Object_Relation__mdt.getSObjectType(), data);
        Object_Relation__mdt sub_m = createObjectRelation('sub', 'svc', null, null);
        ObjectWrapper.addMock(new ObjectWrapperTest.TestSelector(ObjectRelation.class, sub_m));

        // Create the wrapper object
        ObjectRelation junc = new ObjectRelation(junc_m);

        // Create a mock to load the data source
        Data_Source__mdt ds_m = DataSourceTest.createDataSource('svc', 'TestDataSource', ServiceHandlerTest.ServiceHandlerMock.class.toString(), null, null);
        ObjectWrapper.addMock(new ObjectWrapperTest.TestSelector(DataSource.class, ds_m));

        Test.startTest();
        {
            System.assertEquals('myJunction', junc.getApiName());
            System.assertEquals('juncObject', junc.getIntermediateObject());
            System.assertEquals(ObjectRelation.JUNCTION, junc.getType());
            System.assert(junc.isJunction());
            System.assert(!junc.isReference());

            ObjectRelation sub = junc.getSubRelation1();
            System.assertNotEquals(null, sub);
            System.assertEquals('sub', sub.getApiName());
            sub = junc.getSubRelation2();
            System.assertNotEquals(null, sub);
            System.assertEquals('sub', sub.getApiName());

            ExternalObject obj = junc.getObject1();
            System.assertNotEquals(null, obj);
            System.assertEquals('test_object', obj.getName());
            obj = junc.getObject2();
            System.assertNotEquals(null, obj);
            System.assertEquals('test_object', obj.getName());

            DataSource src = junc.getDataSource();
            System.assertNotEquals(null, src);
            System.assertEquals('svc', src.getApiName());

        }
        Test.stopTest();
    }

    @isTest
    static void testInvalidAccessors() {
        Object__mdt obj_m = ExternalObjectTest.addTestExternalObject();
        obj_m.DeveloperName = 'test_object';

        Map<String,Object> data = new Map<String,Object>{ 'DeveloperName' => 'InvalidRelation', 'Type__c' => 'invalid' };
        Object_Relation__mdt inv_m = (Object_Relation__mdt)ObjectWrapperTest.createMetadataRecord(Object_Relation__mdt.getSObjectType(), data);
        ObjectRelation inv = new ObjectRelation(inv_m);

        Test.startTest();
        {
            // Ensure that all attempts to access the invalid type should throw an exception
            Boolean isError = false;
            try {
                inv.getType();
            } catch (Exception ex) { isError = true; }
            System.assert(isError, 'Expected exception on getType() but none thrown');

            isError = false;
            try {
                inv.isJunction();
            } catch (Exception ex) { isError = true; }
            System.assert(isError, 'Expected exception on isJunction() but none thrown');

            isError = false;
            try {
                inv.isReference();
            } catch (Exception ex) { isError = true; }
            System.assert(isError, 'Expected exception on isReference() but none thrown');
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

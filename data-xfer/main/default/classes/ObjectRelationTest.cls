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
        Object_Relation__mdt orm = createObjectRelation('relation', 'strp', 'junction');
        ObjectRelation rel = new ObjectRelation(orm);

        Test.startTest();
        {
            System.assertEquals('relation', rel.getApiName());
            // System.assertEquals('strp', ds.());
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

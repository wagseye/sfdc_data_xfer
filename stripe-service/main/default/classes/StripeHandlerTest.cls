@isTest
private class StripeHandlerTest {
    public static List<Object_Relation__mdt> getObjectRelations() {
        List<Object_Relation__mdt> rels = new List<Object_Relation__mdt>();
        rels.add(createObjectRelation('strp_p1_c1', 'strp', 'junction'));
        rels.add(createObjectRelation('strp_p1_c2', 'strp', 'expand'));
        rels.add(createObjectRelation('strp_c2_g1', 'strp', 'expand'));
        return rels;
    }

    private static void addTestDataSource() {
        Data_Source__mdt ds_m = DataSourceTest.createDataSource('test', 'TestDataSource', StripeHandler.class.toString(), 'https://test.com', '1');
        ObjectWrapper.addMock(new ObjectWrapperTest.TestSelector(DataSource.class, ds_m));
    }

    private static Object_Relation__mdt createObjectRelation(String name, String dataSource, String access) {
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

    public static String getTestConfigString() {
        // TODO: refine this
        return '{' +
        '"sourceSystem": "strp",' +
        '"sourceTree": {' +
        '  "objectName": "parent1",' +
        '  "childObjects": [{' +
        '    "objectName": "child1",' +
        '    "parentRelation": "strp_p1_c1",' +
        '    "childObjects": null' +
        '  },{' +
        '  "objectName": "child2",' +
        '  "parentRelation": "strp_p1_c2",' +
        '  "childObjects": [{' +
        '    "objectName": "grand1",' +
        '    "parentRelation": "strp_c2_g1",' +
        '    "childObjects": null' +
        '  }]' +
        '}]' +
        '}}';
    }

    @isTest
    static void testExpandParams() {
        // Setup
        addTestDataSource();
        DataSourceInstanceTest.addTestDataSourceInstance();
        addObjectRelations();
        ExternalObjectTest.addTestExternalObject();
        Object_Action__mdt actn_m = ExternalObjectActionTest.addTestExternalObjectAction();
        Configuration cfg = Configuration.fromString(getTestConfigString());
        DataTransfer.init(cfg);
        StripeHandler hdlr = (StripeHandler)DataTransfer.handler;

        Test.startTest();
        {
            List<String> expansions = hdlr.getExpansions(cfg);
            System.assertEquals(2, expansions.size());
            Set<String> expSet = new Set<String>(expansions);
            System.assert(expSet.contains('child2'));
            System.Assert(expSet.contains('child2.grand1'));

            actn_m.Extras__c = '{ "resultsPrefix":"foo" }';
            expansions = hdlr.getExpansions(cfg);
            System.assertEquals(2, expansions.size());
            expSet = new Set<String>(expansions);
            System.assert(expSet.contains('foo.child2'));
            System.Assert(expSet.contains('foo.child2.grand1'));
        }
        Test.stopTest();
    }
}

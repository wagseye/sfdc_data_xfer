@isTest
private class StripeHandlerTest {
    public static List<Object_Relation__mdt> getObjectRelations() {
        List<Object_Relation__mdt> rlns_m = new List<Object_Relation__mdt>();
        rlns_m.add(ObjectRelationTest.createObjectRelation('strp_p1_c1', 'strp', null, 'junction'));
        rlns_m.add(ObjectRelationTest.createObjectRelation('strp_p1_c2', 'strp', 'expand', null));
        rlns_m.add(ObjectRelationTest.createObjectRelation('strp_c2_g1', 'strp', 'expand', null));
        return rlns_m;
    }

    private static void addTestDataSource() {
        Data_Source__mdt ds_m = DataSourceTest.createDataSource('test', 'TestDataSource', StripeHandler.class.toString(), 'https://test.com', '1');
        ObjectWrapper.addMock(new ObjectWrapperTest.TestSelector(DataSource.class, ds_m));
    }

    public static void addObjectRelations() {
        Map<String,SObject> mapRels_m = new Map<String,SObject>();
        for (Object_Relation__mdt rel_m : getObjectRelations()) {
            mapRels_m.put(rel_m.DeveloperName, rel_m);
        }
        ObjectWrapper.addMock(new ObjectWrapperTest.TestSelector(ObjectRelation.class, mapRels_m));
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

            // Set the prefix and ensure the expansions use it
            actn_m.Extras__c = '{ "resultsPrefix":"foo" }';
            expansions = hdlr.getExpansions(cfg);
            System.assertEquals(2, expansions.size());
            expSet = new Set<String>(expansions);
            System.assert(expSet.contains('foo.child2'));
            System.Assert(expSet.contains('foo.child2.grand1'));

            // Improperly set the prefix and ensure the expansions do not use it
            actn_m.Extras__c = '{ "resultPrefix":"foo" }';
            expansions = hdlr.getExpansions(cfg);
            System.assertEquals(2, expansions.size());
            expSet = new Set<String>(expansions);
            System.assert(expSet.contains('child2'));
            System.Assert(expSet.contains('child2.grand1'));
        }
        Test.stopTest();
    }
}

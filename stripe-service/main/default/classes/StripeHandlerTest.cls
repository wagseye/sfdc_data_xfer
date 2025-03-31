@isTest
private class StripeHandlerTest {
    public static List<Object_Relation__mdt> getObjectRelations() {
        List<Object_Relation__mdt> rels = new List<Object_Relation__mdt>();
        rels.add(createObjectRelation('strp_p1_c1', 'strp', 'junction'));
        rels.add(createObjectRelation('strp_p1_c2', 'strp', 'expand'));
        rels.add(createObjectRelation('strp_c2_g1', 'strp', 'expand'));
        return rels;
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
        addObjectRelations();
        Configuration cfg = Configuration.fromString(getTestConfigString());
        StripeHandler hdlr = new StripeHandler();

        Test.startTest();
        {
            List<String> expansions = hdlr.getExpansions(cfg);
            System.assertEquals(2, expansions.size());
            Set<String> expSet = new Set<String>(expansions);
            System.assert(expSet.contains('parent1.child2'));
            System.Assert(expSet.contains('parent1.child2.grand1'));
        }
        Test.stopTest();
    }
}

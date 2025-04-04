@isTest
private class DataTransferTest {
    /************************************************************************/
    /*  Utility methods and classes
    /************************************************************************/
    public static Configuration getTestConfig() {
        String configStr = '{' +
        '"sourceSystem": "test",' +
        '"sourceTree": {' +
        '  "objectName": "parent",' +
        '  "childObjects": [{' +
        '    "objectName": "child1",' +
        '    "parentRelation": "test_p1_c1",' +
        '    "childObjects": null' +
        '  },{' +
        '  "objectName": "child2",' +
        '  "parentRelation": "test_p1_c2",' +
        '  "childObjects": [{' +
        '    "objectName": "grand",' +
        '    "parentRelation": "test_c2_g1",' +
        '    "childObjects": null' +
        '  }]' +
        '}]' +
        '}}';

        return Configuration.fromString(configStr);
    }

    private static void addTestRelations() {
        List<Object_Relation__mdt> rltns_m = new List<Object_Relation__mdt>();
        rltns_m.add(ObjectRelationTest.createObjectRelation('test_p1_c1', 'test', null, 'junction'));
        rltns_m.add(ObjectRelationTest.createObjectRelation('test_p1_c2', 'test', 'expand', null));
        rltns_m.add(ObjectRelationTest.createObjectRelation('test_c2_g1', 'test', 'expand', null));

        Map<String,SObject> mapRels = new Map<String,SObject>();
        for (Object_Relation__mdt rltn_m : rltns_m) {
            mapRels.put(rltn_m.DeveloperName, rltn_m);
        }
        ObjectWrapper.addMock(new ObjectWrapperTest.TestSelector(ObjectRelation.class, mapRels));
    }


    /************************************************************************/
    /*  Test methods
    /************************************************************************/
    @isTest
    static void myUnitTest() {
        Configuration config = getTestConfig();
        addTestRelations();
        List<List<TargetRecordHandle>> handles = DataTransfer.groupTargetObjects(config);
        System.assertNotEquals(null, handles);
        System.assertEquals(3, handles.size());

        List<TargetRecordHandle> tierHandles = handles[0];
        System.assertEquals(2, tierHandles.size());
        TargetRecordHandle hndl = tierHandles[0];
        System.assertEquals('parent', hndl.targetObject.objectName);
        System.assertEquals('parent', hndl.targetObject.path);
        System.assertEquals(TargetRecordHandle.Type.TARGET, hndl.type);
        System.assertEquals(TargetRecordHandle.Status.PENDING, hndl.status);
        hndl = tierHandles[1];
        System.assertEquals('child1', hndl.targetObject.objectName);
        System.assertEquals('parent.child1', hndl.targetObject.path);
        System.assertEquals(TargetRecordHandle.Type.TARGET, hndl.type);
        System.assertEquals(TargetRecordHandle.Status.PENDING, hndl.status);

        tierHandles = handles[1];
        System.assertEquals(2, tierHandles.size());
        hndl = tierHandles[0];
        System.assertEquals('junction', hndl.targetObject.objectName);
        System.assertEquals('parent.child1.junction', hndl.targetObject.path);
        System.assertEquals(TargetRecordHandle.Type.JUNCTION, hndl.type);
        System.assertEquals(TargetRecordHandle.Status.PENDING, hndl.status);
        hndl = tierHandles[1];
        System.assertEquals('child2', hndl.targetObject.objectName);
        System.assertEquals('parent.child2', hndl.targetObject.path);
        System.assertEquals(TargetRecordHandle.Type.TARGET, hndl.type);
        System.assertEquals(TargetRecordHandle.Status.PENDING, hndl.status);

        tierHandles = handles[2];
        System.assertEquals(1, tierHandles.size());
        hndl = tierHandles[0];
        System.assertEquals('grand', hndl.targetObject.objectName);
        System.assertEquals('parent.child2.grand', hndl.targetObject.path);
        System.assertEquals(TargetRecordHandle.Type.TARGET, hndl.type);
        System.assertEquals(TargetRecordHandle.Status.PENDING, hndl.status);
    }
}

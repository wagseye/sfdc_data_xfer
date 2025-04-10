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

    private static Data_Source__mdt addTestDataSource() {
        Data_Source__mdt ds_m = DataSourceTest.addTestDataSource();
        ds_m.DeveloperName = 'test'; // Make sure the name is set to "test"
        ObjectWrapper.addMock(new ObjectWrapperTest.TestSelector(DataSource.class, ds_m));
        return ds_m;
    }

    private static Map<String,Object__mdt> addTestObjects() {
        List<Object__mdt> objs_m = new List<Object__mdt>();
        objs_m.add(ExternalObjectTest.createExternalObject('test_parent', 'Parent', 'parent', 'test'));
        objs_m.add(ExternalObjectTest.createExternalObject('test_child1', 'Child 1', 'child1', 'test'));
        objs_m.add(ExternalObjectTest.createExternalObject('test_child2', 'Child 2', 'child2', 'test'));
        objs_m.add(ExternalObjectTest.createExternalObject('test_grand', 'Grandchild', 'grand', 'test'));
        objs_m.add(ExternalObjectTest.createExternalObject('junc_obj', 'JunctionObject', 'junc', 'test'));

        Map<String,Object__mdt> mapObjs = new Map<String,Object__mdt>();
        for (Object__mdt obj_m : objs_m) {
            mapObjs.put(obj_m.DeveloperName, obj_m);
        }
        ObjectWrapper.addMock(new ObjectWrapperTest.TestSelector(ExternalObject.class, mapObjs));
        return mapObjs;
    }

    private static void addTestRelations(Map<String,Object__mdt> mapObjs) {
        Object__mdt parent_m = mapObjs.get('test_parent');
        Object__mdt child1_m = mapObjs.get('test_child1');
        Object__mdt child2_m = mapObjs.get('test_child2');
        Object__mdt grand_m = mapObjs.get('test_grand');
        Object__mdt junc_m = mapObjs.get('junc_obj');

        List<Object_Relation__mdt> rltns_m = new List<Object_Relation__mdt>();
        // First create the 3 relations needed for the parent<=>child1 junction relation
        rltns_m.add(ObjectRelationTest.createReferenceRelation('test_p1_junc', 'test', null, parent_m, 'id', junc_m, 'parent_id'));
        rltns_m.add(ObjectRelationTest.createReferenceRelation('test_c1_junc', 'test', null, child1_m, 'id', junc_m, 'child1_id'));
        rltns_m.add(ObjectRelationTest.createJunctionRelation('test_p1_c1', 'test', junc_m, rltns_m[0], rltns_m[1]));

        // Then add the other reference relations
        rltns_m.add(ObjectRelationTest.createReferenceRelation('test_p1_c2', 'test', null, parent_m, 'id', child2_m, 'parent_id'));
        rltns_m.add(ObjectRelationTest.createReferenceRelation('test_c2_g1', 'test', null, child2_m, 'id', grand_m, 'child2_id'));

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
    static void testGroupTargetObjects() {
        Configuration config = getTestConfig();
        addTestDataSource();
        Map<String,Object__mdt> objs_m = addTestObjects();
        addTestRelations(objs_m);

        Test.startTest();
        {
            List<List<TargetRecordHandle>> handles = DataTransfer.groupTargetObjects(config);
            System.assertNotEquals(null, handles);
            System.assertEquals(3, handles.size()); // There should be 3 tiers

            // Check objects in the first tier
            List<TargetRecordHandle> tierHandles = handles[0];
            System.assertEquals(2, tierHandles.size());
            TargetRecordHandle hndl = tierHandles[0];
            System.assertEquals('parent', hndl.targetObject.objectName);
            System.assertEquals('parent', hndl.targetObject.path);
            System.assertEquals(TargetRecordHandle.Type.TARGET, hndl.type);
            System.assertEquals(TargetRecordHandle.Status.PENDING, hndl.status);
            System.assertEquals(0, hndl.relations.size());
            hndl = tierHandles[1];
            System.assertEquals('child1', hndl.targetObject.objectName);
            System.assertEquals('parent.child1', hndl.targetObject.path);
            System.assertEquals(TargetRecordHandle.Type.TARGET, hndl.type);
            System.assertEquals(TargetRecordHandle.Status.PENDING, hndl.status);
            System.assertEquals(0, hndl.relations.size());

            // Check objects in the second tier
            tierHandles = handles[1];
            System.assertEquals(2, tierHandles.size());
            hndl = tierHandles[0];
            System.assertEquals('junc_obj', hndl.targetObject.objectName);
            System.assertEquals('parent.child1.junc_obj', hndl.targetObject.path);
            System.assertEquals(TargetRecordHandle.Type.JUNCTION, hndl.type);
            System.assertEquals(TargetRecordHandle.Status.PENDING, hndl.status);
            // junction object relations
            System.assertEquals(2, hndl.relations.size());
            TargetRecordHandle.ParentRelation rel = hndl.relations[0];
            System.assertEquals('parent', rel.parent.targetObject.objectName);
            System.assertEquals('id', rel.parentFieldName);
            System.assertEquals('parent_id', rel.childFieldName);
            rel = hndl.relations[1];
            System.assertEquals('child1', rel.parent.targetObject.objectName);
            System.assertEquals('id', rel.parentFieldName);
            System.assertEquals('child1_id', rel.childFieldName);

            hndl = tierHandles[1];
            System.assertEquals('child2', hndl.targetObject.objectName);
            System.assertEquals('parent.child2', hndl.targetObject.path);
            System.assertEquals(TargetRecordHandle.Type.TARGET, hndl.type);
            System.assertEquals(TargetRecordHandle.Status.PENDING, hndl.status);
            System.assertEquals(1, hndl.relations.size());
            // child2 object relations
            System.assertEquals(1, hndl.relations.size());
            rel = hndl.relations[0];
            System.assertEquals('parent', rel.parent.targetObject.objectName);
            System.assertEquals('id', rel.parentFieldName);
            System.assertEquals('parent_id', rel.childFieldName);

            // Check objects in the third tier
            tierHandles = handles[2];
            System.assertEquals(1, tierHandles.size());
            hndl = tierHandles[0];
            System.assertEquals('grand', hndl.targetObject.objectName);
            System.assertEquals('parent.child2.grand', hndl.targetObject.path);
            System.assertEquals(TargetRecordHandle.Type.TARGET, hndl.type);
            System.assertEquals(TargetRecordHandle.Status.PENDING, hndl.status);
            // grand object relations
            System.assertEquals(1, hndl.relations.size());
            rel = hndl.relations[0];
            System.assertEquals('child2', rel.parent.targetObject.objectName);
            System.assertEquals('id', rel.parentFieldName);
            System.assertEquals('child2_id', rel.childFieldName);
        }
        Test.stopTest();
    }
}

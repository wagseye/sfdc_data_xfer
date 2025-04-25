@isTest
private class ConfigurationTest {
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
        '    "objectName": "child2",' +
        '    "parentRelation": "test_p1_c2",' +
        '    "childObjects": [{' +
        '      "objectName": "grand",' +
        '      "parentRelation": "test_c2_g1",' +
        '      "childObjects": null' +
        '    }]' +
        '  }]' +
        '}}';

        return Configuration.fromString(configStr);
    }

    /************************************************************************/
    /*  Test methods
    /************************************************************************/
    @isTest
    static void testSourceTree() {
        Configuration config = getTestConfig();
        Configuration.MappedObject obj = config.sourceTree;
        System.assertNotEquals(null, obj);
        System.assertEquals(null, obj.parent);
        System.assertEquals('parent', obj.objectName);
        System.assertEquals('parent', obj.path);

        List<Configuration.MappedObject> children = obj.childObjects;
        System.assertEquals(2, children.size());
        Configuration.MappedObject child = children[0];
        System.assertNotEquals(null, child);
        System.assertEquals(obj, child.parent);
        System.assertEquals('child1', child.objectName);
        System.assertEquals('parent.child1', child.path);
        System.assertEquals(null, child.childObjects);

        child = children[1];
        System.assertNotEquals(null, child);
        System.assertEquals(obj, child.parent);
        System.assertEquals('child2', child.objectName);
        System.assertEquals('parent.child2', child.path);
        System.assertNotEquals(null, child.childObjects);
        System.assertEquals(1, child.childObjects.size());

        obj = child;
        child = child.childObjects[0];
        System.assertEquals(obj, child.parent);
        System.assertEquals('grand', child.objectName);
        System.assertEquals('parent.child2.grand', child.path);
        System.assertEquals(null, child.childObjects);
    }

    @isTest
    static void testMappedObjects() {
        Configuration config = getTestConfig();
        List<Configuration.MappedObject> objs = config.sourceObjects;
        System.assertEquals(4, objs.size());

        // We use the list (instead of the map) to ensure the values are in the correct order
        // They should be because Apex maps return values in the order they were inserted, but it's
        // nice to verify because other things will break if this order is not correct
        Configuration.MappedObject obj = objs[0];
        System.assertNotEquals(null, obj);
        System.assertEquals(null, obj.parent);
        System.assertEquals('parent', obj.objectName);
        System.assertEquals('parent', obj.path);
        System.assertEquals(2, obj.childObjects.size());

        obj = objs[1];
        System.assertNotEquals(null, obj);
        System.assertEquals(objs[0], obj.parent);
        System.assertEquals('child1', obj.objectName);
        System.assertEquals('parent.child1', obj.path);
        System.assertEquals(null, obj.childObjects);

        obj = objs[2];
        System.assertNotEquals(null, obj);
        System.assertEquals(objs[0], obj.parent);
        System.assertEquals('child2', obj.objectName);
        System.assertEquals('parent.child2', obj.path);
        System.assertNotEquals(null, obj.childObjects);
        System.assertEquals(1, obj.childObjects.size());

        obj = objs[3];
        System.assertNotEquals(null, obj);
        System.assertEquals(objs[2], obj.parent);
        System.assertEquals('grand', obj.objectName);
        System.assertEquals('parent.child2.grand', obj.path);
        System.assertEquals(null, obj.childObjects);
    }
}
@isTest
public class ExternalObjectActionTest {
    /************************************************************************/
    /*  Utility methods and classes
    /************************************************************************/
    public static Object_Action__mdt createExternalObjectAction(String name, String objName, String action, String method, String path) {
        Map<String,Object> data = new Map<String,Object>{ 'DeveloperName' => name, 'Object__c' => objName, 'Action__c' => action, 'Method__c' => method, 'Path__c' => path };
        return (Object_Action__mdt)ObjectWrapperTest.createMetadataRecord(Object_Action__mdt.getSObjectType(), data);
    }

    public static Object_Action__mdt addTestExternalObjectAction() {
        Object_Action__mdt actn_m = createExternalObjectAction('test_action', 'test_object', 'query', 'get', '/unit/test');
        ObjectWrapper.addMock(new ObjectWrapperTest.TestSelector(ExternalObjectAction.class, actn_m));
        return actn_m;
    }


    /************************************************************************/
    /*  Test methods
    /************************************************************************/
    @isTest
    static void testAccessors() {
        Object_Action__mdt actn_m = createExternalObjectAction('test', 'obj', 'query', 'get', '/unit/test');
        ExternalObjectAction actn = new ExternalObjectAction(actn_m);

        Test.startTest();
        {
            System.assertEquals('query', actn.getAction());
            System.assertEquals('get', actn.getMethod());
            System.assertEquals('/unit/test', actn.getPath());
        }
        Test.stopTest();
    }

    @isTest
    static void testSelector() {
        // This test ensures the selector does not cause any errors but we don't assert the results of
        // any of the calls because we don't want to rely on certain data being present
        ExternalObjectAction actn = ExternalObjectAction.getRecordByName('strp_pi_get');
    }

    @isTest
    static void testGetActionName() {
        Object__mdt obj_m = ExternalObjectTest.createExternalObject('svc_obj', 'Object', 'obj', 'svc');
        ExternalObject obj = new ExternalObject(obj_m);

        System.assertEquals('svc_obj_query', ExternalObjectAction.getActionName(obj, 'query'));
        System.assertEquals('svc_obj_create', ExternalObjectAction.getActionName(obj, 'create'));

        Boolean isError = false;
        try {
            ExternalObjectAction.getActionName(obj, 'invalid');
        } catch (Exception ex) { isError = true; }
        System.assert(isError, 'Expected error from invalid action name but none thrown');
    }
}

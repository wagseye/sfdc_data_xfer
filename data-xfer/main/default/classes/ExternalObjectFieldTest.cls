@isTest
public class ExternalObjectFieldTest {
    /************************************************************************/
    /*  Utility methods and classes
    /************************************************************************/
    public static Object_Field__mdt createExternalObjectField(String name, String apiName, String displayName, String objName, String dataType) {
        Map<String,Object> data = new Map<String,Object>{ 'DeveloperName' => name, 'API_Name__c' => apiName, 'Display_Name__c' => displayName, 'Object__c' => objName, 'Data_Type__c' => dataType };
        return (Object_Field__mdt)ObjectWrapperTest.createMetadataRecord(Object_Field__mdt.getSObjectType(), data);
    }

    public static void addTestExternalObjectField() {
        Object_Field__mdt fld_m = createExternalObjectField('svc_obj_fld', 'fld', 'Field', 'svc_obj', 'text');
        ObjectWrapper.addMock(new ObjectWrapperTest.TestSelector(ExternalObjectField.class, fld_m));
    }


    /************************************************************************/
    /*  Test methods
    /************************************************************************/
    @isTest
    static void testAccessors() {
        Object_Field__mdt fld_m = createExternalObjectField('svc_obj_fld', 'fld', 'Field', 'svc_obj', 'text');
        ExternalObjectField fld = new ExternalObjectField(fld_m);

        Test.startTest();
        {
            System.assertEquals('svc_obj_fld', fld.getName());
            System.assertEquals('fld', fld.getApiName());
            System.assertEquals('Field', fld.getDisplayName());
            System.assertEquals('text', fld.getType());
        }
        Test.stopTest();
    }

    @isTest
    static void testSelector() {
        // This test ensures the selector does not cause any errors but we don't assert the results of
        // any of the calls because we don't want to rely on certain data being present
        ExternalObjectField.getRecordByName('strp_inv_id');
        ExternalObjectField.queryByObjectName('strp_pi');
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

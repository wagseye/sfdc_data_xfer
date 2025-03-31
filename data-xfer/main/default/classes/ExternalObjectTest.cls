@isTest
private class ExternalObjectTest {
    /************************************************************************/
    /*  Utility methods and classes
    /************************************************************************/
    public static Object__mdt createExternalObject(String name, String displayName, String apiName, String dataSource) {
        Map<String,Object> data = new Map<String,Object>{ 'DeveloperName' => name, 'Display_Name__c' => displayName, 'API_Name__c' => apiName, 'Data_Source__c' => dataSource };
        return (Object__mdt)ObjectWrapperTest.createMetadataRecord(Object__mdt.getSObjectType(), data);
    }

    public static void addTestExternalObject() {
        Object__mdt obj_m = createExternalObject('testObject', 'Test Object', 'test_object', 'test_source');
        ObjectWrapper.addMock(new ObjectWrapperTest.TestSelector(ExternalObjectTest.class, obj_m));
    }


    /************************************************************************/
    /*  Test methods
    /************************************************************************/
    @isTest
    static void testAccessors() {
        Object__mdt obj_m = createExternalObject('testObject', 'Test Object', 'test_object', 'svc');
        ExternalObject obj = new ExternalObject(obj_m);

        Data_Source__mdt ds_m = DataSourceTest.createDataSource('svc', 'TestDataSource', ServiceHandlerTest.ServiceHandlerMock.class.toString(), 'https://test.com', '1');
        ObjectWrapper.addMock(new ObjectWrapperTest.TestSelector(DataSource.class, ds_m));


        Test.startTest();
        {
            System.assertEquals('Test Object', obj.getDisplayName());
            System.assertEquals('test_object', obj.getApiName());

            DataSource src = obj.getDataSource();
            System.assertNotEquals(null, src);
            System.assertEquals('svc', src.getApiName());
        }
        Test.stopTest();
    }

    @isTest
    static void testSelector() {
        // This test ensures the selector does not cause any errors but we don't assert the results of
        // any of the calls because we don't want to rely on certain data being present
        ExternalObject.getRecordByName('strp');
    }
}

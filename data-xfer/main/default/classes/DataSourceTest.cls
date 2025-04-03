@isTest
public class DataSourceTest {
    /************************************************************************/
    /*  Utility methods and classes
    /************************************************************************/
    public static Data_Source__mdt createDataSource(String name, String displayName, String handlerClass, String baseUrl, String apiVersion) {
        Map<String,Object> data = new Map<String,Object>{ 'DeveloperName' => name, 'Display_Name__c' => displayName, 'Handler_Class__c' => handlerClass, 'Base_Url__c' => baseUrl, 'API_Version__c' => apiVersion };
        return (Data_Source__mdt)ObjectWrapperTest.createMetadataRecord(Data_Source__mdt.getSObjectType(), data);
    }

    public static Data_Source__mdt addTestDataSource() {
        Data_Source__mdt ds_m = createDataSource('test', 'TestDataSource', ServiceHandlerTest.ServiceHandlerMock.class.toString(), 'https://test.com', '1');
        ObjectWrapper.addMock(new ObjectWrapperTest.TestSelector(DataSource.class, ds_m));
        return ds_m;
    }


    /************************************************************************/
    /*  Test methods
    /************************************************************************/
    @isTest
    static void testAccessors() {
        Data_Source__mdt ds_m = createDataSource('test', 'TestDataSource', ServiceHandlerTest.ServiceHandlerMock.class.toString(), 'https://test.com', '1');
        DataSource ds = new DataSource(ds_m);

        Test.startTest();
        {
            System.assertEquals('test', ds.getApiName());
            System.assertEquals('TestDataSource', ds.getDisplayName());
            System.assertEquals('https://test.com', ds.getBasePath());
            System.assertEquals('1', ds.getApiVersion());
            ServiceHandler handler = ds.getHandler();
            System.assertNotEquals(null, handler);
            System.assert(handler instanceof ServiceHandlerTest.ServiceHandlerMock);
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

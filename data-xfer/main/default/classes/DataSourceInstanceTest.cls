@isTest
public class DataSourceInstanceTest {
    /************************************************************************/
    /*  Utility methods and classes
    /************************************************************************/
    public static Data_Source_Instance__c createDataSourceInstance(String name, String dataSource, String instanceType) {
        return new Data_Source_Instance__c( Display_Name__c = name, Data_Source_Name__c = dataSource, Instance_Type__c = instanceType );
    }

    public static void addTestDataSource() {
        Data_Source_Instance__c inst_m = createDataSourceInstance('test', 'svc', 'production');
        ObjectWrapper.addMock(new ObjectWrapperTest.TestSelector(DataSourceInstance.class, inst_m));
    }


    /************************************************************************/
    /*  Test methods
    /************************************************************************/
    @isTest
    static void testAccessors() {
        Data_Source_Instance__c inst_m = new Data_Source_Instance__c( Display_Name__c = 'instance',
                                                                      Data_Source_Name__c = 'svc',
                                                                      Instance_Type__c = 'sandbox',
                                                                      API_Id__c = 'api_id',
                                                                      API_Secret__c = 'api_key',
                                                                      Options__c = '{ "key":"value" }' );
        DataSourceInstance inst = new DataSourceInstance(inst_m);

        // Create a mock to load the data source
        Data_Source__mdt ds_m = DataSourceTest.createDataSource('svc', 'TestDataSource', ServiceHandlerTest.ServiceHandlerMock.class.toString(), null, null);
        ObjectWrapper.addMock(new ObjectWrapperTest.TestSelector(DataSource.class, ds_m));

        Test.startTest();
        {
            System.assertEquals('instance', inst.getDisplayName());
            System.assertEquals('sandbox', inst.getInstanceType());
            System.assertEquals('api_id', inst.getApiId());
            System.assertEquals('api_key', inst.getApiSecret());

            DataSource src = inst.getDataSource();
            System.assertNotEquals(null, src);
            System.assertEquals('TestDataSource', src.getDisplayName());

            Map<String,Object> opts = inst.getOptions();
            System.assertNotEquals(null, opts);
            System.assertEquals(1, opts.size());
            System.assert(opts.containsKey('key'));
            System.assertEquals('value', opts.get('key'));

            inst_m.Options__c = 'key';
            Boolean isError = false;
            try {
                inst.getOptions();
            } catch (Exception e) { isError = true; }
            System.assert(isError, 'Expected a JSON error but not was thrown');
        }
        Test.stopTest();
    }

    @isTest
    static void testSelector() {
        // This test ensures the selector does not cause any errors but we don't assert the results of
        // any of the calls because we don't want to rely on certain data being present
        DataSourceInstance.getRecordByName('strp');
        DataSourceInstance.getAll();
        DataSourceInstance.queryByDataSourceName('svc');
    }
}

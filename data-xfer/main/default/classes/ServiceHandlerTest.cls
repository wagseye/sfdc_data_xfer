@isTest
public class ServiceHandlerTest {
    /************************************************************************/
    /*  Utility methods and classes
    /************************************************************************/
    public static void setupTest() {
        DataSourceTest.addTestDataSource();
        DataSourceInstanceTest.addTestDataSource();
        Configuration config = Configuration.fromString(getTestConfigString());
        DataTransfer.init(config);
    }

    public static String getTestConfigString() {
        // TODO: refine this
        return '{' +
        '"sourceSystem": "test",' +
        '"sourceTree": {' +
        '  "objectName": "srcObj1",' +
        '  "targetObjects": [{' +
        '    "name": "tgtObj1",' +
        '    "ratio": "1:1",' +
        '    "behavior": [{' +
        '      "type": "create"' +
        '    }]' +
        '  }]' +
        '},' +
        '"targetSystem": "sfdc",' +
        '"targetTree": {' +
        '  "objectName": "Opportunity",' +
        '  "label": "opportunity1"' +
        '}' +
        '}';
    }

    public class ServiceHandlerMock extends ServiceHandler {
        public String serviceApiName = 'test';
        public String serviceDisplayName = 'Test';
        public String httpMethod = 'GET';
        public String path = '/';
        public Map<String,Object> requestData = new Map<String,Object>();

        public override String getServiceApiName() { return this.serviceApiName; }
        public override String getServiceDisplayName() { return this.serviceDisplayName; }
        public override String getHttpMethod(DataSource src) { return this.httpMethod; }
        public override String getPath(DataSource src) { return this.path; }
        public override Map<String,Object> getRequestData(DataSource src) { return this.requestData; }
    }


    /************************************************************************/
    /*  Test methods
    /************************************************************************/
    @isTest
    static void testHttpGetParameters() {
        setupTest();
        DataSource src = DataTransfer.sourceSystem;
        ServiceHandlerTest.ServiceHandlerMock hdlr = (ServiceHandlerTest.ServiceHandlerMock)DataTransfer.handler;
        Map<String,Object> data = hdlr.requestData;

        Test.startTest();
        {
            // Basic string parameter
            hdlr.httpMethod = 'GET';
            data.put('param', 'value');
            System.assertEquals('https://test.com/?param=value', hdlr.getEndpoint(src));

            // Complex string parameter
            hdlr.httpMethod = 'GET';
            data.put('param', 'complex&value?');
            System.assertEquals('https://test.com/?param=complex%26value%3F', hdlr.getEndpoint(src));

            // Multiple string parameters
            data.clear();
            data.put('param1', 'value1');
            data.put('param2', 'value2');
            data.put('param3', 'value3');
            System.assertEquals('https://test.com/?param1=value1&param2=value2&param3=value3', hdlr.getEndpoint(src));

            // Integer parameter
            data.clear();
            data.put('param1', 111);
            System.assertEquals('https://test.com/?param1=111', hdlr.getEndpoint(src));

            // Integer parameter
            data.clear();
            data.put('array[]', new List<String>{ 'arr1', 'arr2', 'arr3' });
            System.assertEquals('https://test.com/?array[]=arr1&array[]=arr2&array[]=arr3', hdlr.getEndpoint(src));
        }
        Test.stopTest();
    }

    @isTest
    static void testHttpGetParameterErrors() {
        DataSourceTest.addTestDataSource();

        setupTest();
        DataSource src = DataTransfer.sourceSystem;
        ServiceHandlerTest.ServiceHandlerMock hdlr = (ServiceHandlerTest.ServiceHandlerMock)DataTransfer.handler;

        Test.startTest();
        {
            Map<String,Object> data = hdlr.requestData;
            hdlr.httpMethod = 'GET';

            // Array param name with scalar value
            Boolean isError = false;
            try {
                data.put('array[]', 'value');
                hdlr.getEndpoint(src);
            } catch (Exception ex) { isError = true; }
            System.assert(isError, 'Expected exception for array name scalar value, none thrown');

            // Scalar param name with array value
            isError = false;
            try {
                data.clear();
                data.put('array', new List<String>{ 'arr1', 'arr2' });
                hdlr.getEndpoint(src);
            } catch (Exception ex) { isError = true; }
            System.assert(isError, 'Expected exception for scalar name array value, none thrown');
        }
    }
}
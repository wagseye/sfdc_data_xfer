@isTest
private class ServiceHandlerTest {
    /************************************************************************/
    /*  Utiltiy methods and classes
    /************************************************************************/
    public static void setupTest() {
        addTestDataSource();
        DataTransfer.configString = getTestConfigString();
        DataTransfer.init();
    }

    private static SObject createMetadataRecord(SObjectType t, Map<String,Object> data) {
        if ((t == null) || !t.toString().endsWith('__mdt')) throw new IllegalArgumentException('Provided SObjectType is not a metadata type');
        String name = (String)data.get('DeveloperName');
        if (String.isBlank(name)) throw new IllegalArgumentException('Metadata DeveloperName field must be provided');
        SObject sobj = t.newSObject();
        for (String fldName : data.keySet()) sobj.put(fldName, data.get(fldName));
        return sobj;
    }

    private static Data_Source__mdt createDataSource(String name, String displayName, String handlerClass, String baseUrl, String apiVersion) {
        Map<String,Object> data = new Map<String,Object>{ 'DeveloperName' => name, 'Display_Name__c' => displayName, 'Handler_Class__c' => handlerClass, 'Base_Url__c' => baseUrl, 'API_Version__c' => apiVersion };
        return (Data_Source__mdt)createMetadataRecord(Data_Source__mdt.getSObjectType(), data);
    }

    public static void addTestDataSource() {
        Data_Source__mdt ds = createDataSource('test', 'TestDataSource', 'ServiceHandlerTest.ServiceHandlerMock', 'https://test.com', '1');
        ObjectWrapper.setMock(new TestSelector(new DataSource.Selector(), ds));
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

    public class TestSelector extends ObjectWrapper.Selector {
        protected ObjectWrapper.Selector typeSelector;
        List<SObject> records;

        public TestSelector( ObjectWrapper.Selector typeSelector, SObject record) {
            this.typeSelector = typeSelector;
            this.records = new List<SObject>{ record };
        }
        public TestSelector( ObjectWrapper.Selector typeSelector, List<SObject> records) {
            this.typeSelector = typeSelector;
            this.records = records;
        }
        public override ObjectWrapper wrap(SObject obj) { return this.typeSelector.wrap(obj); }
        public override List<ObjectWrapper> createList() { return this.typeSelector.createList(); }

        public override SObject getInstance(String identifier) { return records[0]; }
        public override List<SObject> getAll() { return records; }
        public override List<SObject> query() { return records; }
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
        addTestDataSource();

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
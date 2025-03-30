@isTest
public class ObjectWrapperTest {
    /************************************************************************/
    /*  Utility methods and classes
    /************************************************************************/
    public static SObject createMetadataRecord(SObjectType t, Map<String,Object> data) {
        if ((t == null) || !t.toString().endsWith('__mdt')) throw new IllegalArgumentException('Provided SObjectType is not a metadata type');
        String name = (String)data.get('DeveloperName');
        if (String.isBlank(name)) throw new IllegalArgumentException('Metadata DeveloperName field must be provided');
        SObject sobj = t.newSObject();
        for (String fldName : data.keySet()) sobj.put(fldName, data.get(fldName));
        return sobj;
    }

    // A Selector implementation that makes it easy to control the records returned for use in unit tests
    public class TestSelector extends ObjectWrapper.Selector {
        // TestSelector keeps its own copy of the query results in list or map format so it can decide which record(s) to return
        // instead of using ObjectWrapper.Selector.setQueryResults()
        List<SObject> records;
        Map<String,SObject> mapRecords;

        public TestSelector(Type t, SObject record) {
            super(t);
            this.records = new List<SObject>{ record };
        }
        public TestSelector(Type t, List<SObject> records) {
            super(t);
            this.records = records;
        }
        public TestSelector(Type t, Map<String,SObject> records) {
            super(t);
            this.mapRecords = records;
        }
        public override SObject getInstance(String identifier) {
            if (mapRecords != null) return mapRecords.get(identifier);
            return records[0];
        }
        public override List<SObject> getAll() { return (mapRecords != null) ? mapRecords.values() : records; }
        public override List<SObject> query() { return getAll(); }
    }

    // A test class that wraps the Account object (because it is the most fundamental SObject)
    public class Selector extends ObjectWrapper.Selector {
        public Selector() { super(TestWrapper.class); }
        public virtual override SObject getInstance(String name) { return new Account(Name = 'TestAccount'); }
        public virtual override List<SObject> getAll() { return new List<Account>{ (Account)this.getInstance(null) }; }
    }

    // A test class that wraps the Account object (because it is the most fundamental SObject)
    public class TestWrapper extends ObjectWrapper {
        public TestWrapper() { super(); }
        public TestWrapper(Account acct) { super(acct); }
        public TestWrapper getRecordByName(String name) { return (TestWrapper)ObjectWrapper.getInstance(new Selector(), name); }
        public List<TestWrapper> getAll() { return (List<TestWrapper>)ObjectWrapper.getAll(new Selector()); }
        public List<TestWrapper> query() {
            Selector sltr = new Selector();
            sltr.setQueryResults(sltr.getAll());
            return (List<TestWrapper>)ObjectWrapper.query(sltr);
        }
    
        public String getName() { return (String)this.get('Name'); }
    }


    /************************************************************************/
    /*  Test methods
    /************************************************************************/
    @isTest
    static void testAccessor() {
        Test.startTest();
        {
            Account acct = new Account(Name = 'acct');
            TestWrapper wrapper = new TestWrapper(acct);
            System.assertEquals('acct', wrapper.getName());
        }
        Test.stopTest();
    }

    @isTest
    static void testSelector() {
        Test.startTest();
        {
            Account acct = new Account(Name = 'acct');
            // Salesforce doesn't allow inner classes to have static methods, so we instantiate an object to call the methods that would
            // normally be statice
            TestWrapper testWrapper = new TestWrapper(acct); 
            TestWrapper wrapper = testWrapper.getRecordByName('foo');
            System.assertNotEquals(null, wrapper);
            System.assertEquals('TestAccount', wrapper.getName());

            List<TestWrapper> wrappers = testWrapper.getAll();
            System.assertEquals(1, wrappers.size());
            System.assertEquals('TestAccount', wrappers[0].getName());

            wrappers = testWrapper.query();
            System.assertEquals(1, wrappers.size());
            System.assertEquals('TestAccount', wrappers[0].getName());
        }
        Test.stopTest();
    }

    @isTest
    static void testTestSelectors() {
        Test.startTest();
        {
            Data_Source__mdt ds1_m = DataSourceTest.createDataSource('testSource1', 'TestDataSource', ServiceHandlerTest.ServiceHandlerMock.class.toString(), 'https://test.com', '1');
            TestSelector sel1 = new ObjectWrapperTest.TestSelector(DataSource.class, ds1_m);
            ObjectWrapper.addMock(sel1);

            Object_Relation__mdt rel1_m = ObjectRelationTest.createObjectRelation('testRelation1', 'strp', 'junction');
            TestSelector sel2 = new ObjectWrapperTest.TestSelector(ObjectRelation.class, rel1_m);
            ObjectWrapper.addMock(sel2);

            DataSource ds = DataSource.getRecordByName('foo');
            System.assertEquals('testSource1', ds.getApiName());

            ObjectRelation rel = ObjectRelation.getRecordByName('foo');
            System.assertEquals('testRelation1', rel.getApiName());

            Map<String,Data_Source__mdt> mapSrcs = new Map<String,Data_Source__mdt>{ 'testSource1' => ds1_m,
                'testSource2' => DataSourceTest.createDataSource('testSource2', 'TestDataSource', null, null, null)
            };
            ObjectWrapper.addMock(new ObjectWrapperTest.TestSelector(DataSource.class, mapSrcs));

            // Make sure we can pull out the two new records
            ds = DataSource.getRecordByName('testSource1');
            System.assertEquals('testSource1', ds.getApiName());
            ds = DataSource.getRecordByName('testSource2');
            System.assertEquals('testSource2', ds.getApiName());

            // Make sure the old mock is no longer in place
            ds = DataSource.getRecordByName('foo');
            System.assertEquals(null, ds);

            // Make sure the other mock was not changed
            rel = ObjectRelation.getRecordByName('foo');
            System.assertEquals('testRelation1', rel.getApiName());
        }
        Test.stopTest();
    }
}

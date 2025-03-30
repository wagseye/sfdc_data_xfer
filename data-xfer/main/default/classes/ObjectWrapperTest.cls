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
        Account acct = new Account(Name = 'acct');
        TestWrapper wrapper = new TestWrapper(acct);
        System.assertEquals('acct', wrapper.getName());
    }

    @isTest
    static void testSelector() {
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
}

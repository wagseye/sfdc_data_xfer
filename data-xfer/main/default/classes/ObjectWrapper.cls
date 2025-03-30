public with sharing abstract class ObjectWrapper {
    public abstract class Selector {
        private Type wrapperClass;
        private List<SObject> queryResults;

        protected Selector(Type wrapperClass) {
            if (wrapperClass == null) throw new StandardException('A valid wrapper class must be provided');
            this.wrapperClass = wrapperClass;
        }

        public void setQueryResults(List<SObject> records) {
            if (records == null) throw new StandardException('A valid list of records must be provided');
            if (this.queryResults != null) throw new StandardException('The query records have already been set for this selector');
            this.queryResults = records;
        }

        public virtual ObjectWrapper wrap(SObject obj) {
            ObjectWrapper wrapper = (ObjectWrapper)this.wrapperClass.newInstance();
            wrapper.setObject(obj);
            return wrapper;
        }

        public virtual List<ObjectWrapper> createList() {
            String listTypeName = 'List<' + this.wrapperClass + '>';
            List<ObjectWrapper> newList = (List<ObjectWrapper>)Type.forName(listTypeName).newInstance();
            return newList;
        }

        public virtual SObject getInstance(String identifier) { throw new StandardException('Method not implemented'); }
        public virtual List<SObject> getAll() { throw new StandardException('Method not implemented'); }
        public virtual List<SObject> query() {
            // Note that an empty list is still a valid value here
            if (this.queryResults == null) throw new StandardException('No records specified');
            return this.queryResults;
        }
    }

    protected SObject record;
    private static Selector mockSelector;
    @TestVisible private static void setMock(Selector selector) { mockSelector = selector; }

    private static Selector getActiveSelector(Selector selector) { return getActiveSelector(mockSelector, selector); }
    private static Selector getActiveSelector(Selector selector1, Selector selector2) {
        if (selector1 != null) return selector1;
        if (selector2 != null) return selector2;
        throw new StandardException('No valid selector found');
    }

    // SFDC doesn't allow protected static functions(?!!?) so these methods have to be public
    public static ObjectWrapper getInstance(Selector selector, String name) {
        if (String.isBlank(name)) throw new StandardException('An valid name must be provided');
        Selector activeSelector = getActiveSelector(selector);
        SObject obj = activeSelector.getInstance(name);
        return (obj == null) ? null : activeSelector.wrap(obj);
    }

    public static List<ObjectWrapper> getAll(Selector selector) {
        Selector activeSelector = getActiveSelector(selector);
        List<SObject> sobjs = activeSelector.getAll();
        return wrapList(activeSelector, sobjs);
    }

    public static List<ObjectWrapper> query(Selector selector) {
        Selector activeSelector = getActiveSelector(selector);
        List<SObject> sobjs = activeSelector.query();
        return wrapList(activeSelector, sobjs);
    }

    private static List<ObjectWrapper> wrapList(Selector selector, List<SObject> sobjs) {
        List<ObjectWrapper> wrappers = selector.createList();
        if (wrappers == null) throw new StandardException('CreateList must return a valid list');
        if (sobjs != null) {
            for (SObject sobj : sobjs) wrappers.add(selector.wrap(sobj));
        }
        return wrappers;
    }

    public ObjectWrapper() {}
    public ObjectWrapper(SObject rec) {
        if (rec == null) throw new StandardException('A valid record must be provided');
        this.record = rec;
    }

    public void setObject(SObject rec) {
        if (rec == null) throw new StandardException('A valid SObject must be provided');
        if (this.record != null) throw new StandardException('This wrapper already has an inner record');
        this.record = rec;
    }

    public Object get(String fldName) {
        if (this.record == null) throw new StandardException('Wrapper object has no inner record');
        return this.record.get(fldName);
    }

    public virtual String getApiName() { return (String)this.get('DeveloperName'); }
}

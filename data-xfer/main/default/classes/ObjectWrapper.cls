public with sharing abstract class ObjectWrapper {
    public abstract class Selector {
        public abstract ObjectWrapper wrap(SObject obj);
        public abstract List<ObjectWrapper> createList();
        public virtual SObject getInstance(String identifier) { throw new StandardException('Method not implemented'); }
        public virtual List<SObject> getAll() { throw new StandardException('Method not implemented'); }
    }

    protected SObject record;
    private static Selector mockSelector;
    @TestVisible private static void setMock(Selector selector) { mockSelector = selector; }

    // SFDC doesn't allow protected static functions(?!!?) so this has to be public
    public static ObjectWrapper getInstance(Selector selector, String identifier) {
        Selector activeSelector = (mockSelector != null) ? mockSelector : selector;
        if (activeSelector == null) throw new StandardException('No valid selector found');

        SObject obj = activeSelector.getInstance(identifier);
        return (obj == null) ? null : activeSelector.wrap(obj);
    }

    // SFDC doesn't allow protected static functions(?!!?) so this has to be public
    public static List<ObjectWrapper> getAll(Selector selector) {
        Selector activeSelector = (mockSelector != null) ? mockSelector : selector;
        if (activeSelector == null) throw new StandardException('No valid selector found');

        List<SObject> objs = activeSelector.getAll();
        List<ObjectWrapper> wrappers = activeSelector.createList();
        if (wrappers == null) throw new StandardException('CreateList must return a valid list');
        if (objs != null) {
            for (SObject obj : objs) wrappers.add(activeSelector.wrap(obj));
        }
        return wrappers;
    }

    public ObjectWrapper(SObject rec) {
        System.assert(rec != null);
        this.record = rec;
    }

    public Object get(String fldName) {
        return this.record.get(fldName);
    }

    public virtual String getApiName() { return (String)this.get('DeveloperName'); }

}

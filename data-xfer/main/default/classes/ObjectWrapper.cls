public with sharing abstract class ObjectWrapper {
    public abstract class Selector {
        public abstract ObjectWrapper wrap(SObject obj);
        public abstract List<ObjectWrapper> createList();
        public virtual SObject getInstance(String identifier) { throw new StandardException('Method not implemented'); }
        public virtual List<SObject> getAll() { throw new StandardException('Method not implemented'); }
        public virtual List<SObject> query() { return getAll(); }
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
    public static ObjectWrapper getInstance(Selector selector, String identifier) {
        Selector activeSelector = getActiveSelector(selector);
        SObject obj = activeSelector.getInstance(identifier);
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

    public ObjectWrapper(SObject rec) {
        System.assert(rec != null);
        this.record = rec;
    }

    public Object get(String fldName) {
        return this.record.get(fldName);
    }

    public virtual String getApiName() { return (String)this.get('DeveloperName'); }

}

public with sharing abstract class ObjectWrapper {
    protected SObject record;
    public ObjectWrapper(SObject rec) {
        System.assert(rec != null);
        this.record = rec;
    }

    public Object get(String fldName) {
        return this.record.get(fldName);
    }

    public String getApiName() { return (String)this.get('DeveloperName'); }

}
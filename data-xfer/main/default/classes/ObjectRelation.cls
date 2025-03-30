public with sharing virtual class ObjectRelation extends ObjectWrapper {
    public virtual class Selector extends ObjectWrapper.Selector {
        public Selector() { super(ObjectRelation.class); }
        public virtual override SObject getInstance(String name) { return Object_Relation__mdt.getInstance(name); }
        public virtual override List<SObject> getAll() { return Object_Relation__mdt.getAll().values(); }
    }

    public static ObjectRelation getRecordByName(String name) {
        return (ObjectRelation)ObjectWrapper.getInstance(new Selector(), name);
    }

    public static List<ObjectRelation> getAll() {
        return (List<ObjectRelation>)ObjectWrapper.getAll(new Selector());
    }

    public ObjectRelation() {}
    public ObjectRelation(Object_Relation__mdt src) {
        super(src);
    }

    public String getField1() { return (String)this.get('Field1__c'); }
    public String getField2() { return (String)this.get('Field2__c'); }
    public ExternalObject getObject1() { return this.getObject('Object1__c'); }
    public ExternalObject getObject2() { return this.getObject('Object2__c'); }

    public String getIntermediateObject() { return (String)this.get('Intermediate_Object__c'); }

    public Map<String,Object> getExtras() {
        try {
            return (Map<String,Object>)JSON.deserializeUntyped((String)this.get('Extras__c'));
        } catch (JSONException ex) {
            System.debug('ObjectRelation.Extras contains invalid JSON');
            return null;
        }
    }

    private ExternalObject getObject(String fldName) {
        String obj1Id = (String)this.get(fldName);
        if (String.isNotBlank(obj1Id)) {
            Object__mdt obj1 = Object__mdt.getInstance(obj1Id);
            if (obj1 == null) throw new StandardException('Could not load custom metadata record of type "Object__mdt" with id=' + obj1Id);
            return new ExternalObject(obj1);
        }
        return null;
    }
}
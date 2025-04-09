public with sharing virtual class ObjectRelation extends ObjectWrapper {
    public static final String JUNCTION = 'junction';
    public static final String REFERENCE = 'reference';
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

    public DataSource getDataSource() {
        string dsName = (String)this.get('Data_Source__c');
        if (String.isNotBlank(dsName)) {
            DataSource ds = DataSource.getRecordByName(dsName);
            if (ds == null) throw new StandardException('Did not find DataSource with name ' + dsName);
            return ds;
        }
        return null;
    }

    public String getField1() { return (String)this.get('Field1__c'); }
    public String getField2() { return (String)this.get('Field2__c'); }
    public ExternalObject getIntermediateObject() { return this.getObject('Intermediate_Object__c'); }
    public String getRatio() { return (String)this.get('Ratio__c'); }
    public Boolean isJunction() { return getType() == JUNCTION; }
    public Boolean isReference() { return getType() == REFERENCE; }
    public ExternalObject getObject1() { return this.getObject('Object1__c'); }
    public ExternalObject getObject2() { return this.getObject('Object2__c'); }
    public ObjectRelation getSubRelation1() { return this.getRelation('Field1__c'); }
    public ObjectRelation getSubRelation2() { return this.getRelation('Field2__c'); }
    public String getType() {
        String t = (String)this.get('Type__c');
        if (String.isNotBlank(t)) {
            t = t.toLowerCase();
            if  (t.equals(JUNCTION) || t.equals(REFERENCE)) return t;
            throw new StandardException('Unrecognized object relation type: ' + t);
        }
        return null;
    }

    public Map<String,Object> getExtras() {
        try {
            return (Map<String,Object>)JSON.deserializeUntyped((String)this.get('Extras__c'));
        } catch (JSONException ex) {
            System.debug('ObjectRelation.Extras contains invalid JSON');
            return null;
        }
    }

    private ExternalObject getObject(String fldName) {
        String objId = (String)this.get(fldName);
        if (String.isNotBlank(objId)) {
            ExternalObject obj = ExternalObject.getRecordByName(objId);
            if (obj == null) throw new StandardException('Could not load custom metadata record of type "Object__mdt" with id=' + objId);
            return obj;
        }
        return null;
    }

    private ObjectRelation getRelation(String fldName) {
        if (this.getType().equalsIgnoreCase('junction')) {
            String relName = (String)this.get(fldName);
            if (String.isNotBlank(relName)) {
                ObjectRelation rel = ObjectRelation.getRecordByName(relName);
                if (rel == null) throw new StandardException('Could not load custom metadata record of type "Object_Relation__mdt" with name=' + relName);
                return rel;
            }
        }
        return null;
    }
}
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

    /***  Field 1  *************************************************************************************
     * For a reference relation, it holds the name of the field for Object 1. Object 1 is supposed to be the "parent"
     *   field for relations, so in most cases this will be the primary key for Object 1
     * For a junction relation, this holds the name of the Object_Relation__mdt record that relates Object 1 to the junction object
     ***************************************************************************************************/
    public String getField1() { return (String)this.get('Field1__c'); }

    /***  Field 2  *************************************************************************************
     * For a reference relation, it holds the name of the field for Object 2. Object 2 is supposed to be the "child"
     *   field for relations, so in most cases this will be the foreign key on Object 2, most likely ending with "id"
     * For a junction relation, this holds the name of the Object_Relation__mdt record that relates Object 2 to the junction object
     ***************************************************************************************************/
    public String getField2() { return (String)this.get('Field2__c'); }

    /***  IntermediateObject  **************************************************************************
     * Only used for junction relations. It holds a reference to the ExternalObject that is used to join Object 1 to Object 2.
     * This object must have its own relations relating back to Object 1 and Object 2 (referenced in Field 1 and Field 2)
     ***************************************************************************************************/
    public ExternalObject getIntermediateObject() { return this.getObject('Intermediate_Object__c'); }

    /***  Ratio  ***************************************************************************************
     * Used to represent e.g. many-to-one, one-to-one relationships. A "1" represents a "one" side, and a "+" sign represents
     * a "many", so values look like e.g. "+:1", "1:1" etc.
     ***************************************************************************************************/
    public String getRatio() { return (String)this.get('Ratio__c'); }

    /***  Type  ****************************************************************************************
     * Must be "reference" or "junction". Represents the type of relationship between the two objects, and can affect the meaning
     * of Field 1 and Field 2. For checking the type it is recommended to use isReference() or isJunction() methods.
     ***************************************************************************************************/
    public String getType() {
        String t = (String)this.get('Type__c');
        if (String.isNotBlank(t)) {
            t = t.toLowerCase();
            if  (t.equals(JUNCTION) || t.equals(REFERENCE)) return t;
            throw new StandardException('Unrecognized object relation type: ' + t);
        }
        return null;
    }
    public Boolean isReference() { return getType() == REFERENCE; }
    public Boolean isJunction() { return getType() == JUNCTION; }

    /***  Object 1  ************************************************************************************
     * Holds a reference to the ExternalObject that represents the primary (or "parent") object in this relation
     ***************************************************************************************************/
    public ExternalObject getObject1() { return this.getObject('Object1__c'); }

    /***  Object 2  ************************************************************************************
     * Holds a reference to the ExternalObject that represents the secondary (or "child") object in this relation
     ***************************************************************************************************/
    public ExternalObject getObject2() { return this.getObject('Object2__c'); }

    /***  SubRelation 1 ********************************************************************************
     * Used only for junction relations. Holds a reference to the ObjectRelation record that represents the relation
     * between Object 1 (primary) and the Intermediate Object (secondary)
     ***************************************************************************************************/
    public ObjectRelation getSubRelation1() { return this.getRelation('Field1__c'); }

    /***  SubRelation 2 ********************************************************************************
     * Used only for junction relations. Holds a reference to the ObjectRelation record that represents the relation
     * between Object 2 (primary) and the Intermediate Object (secondary)
     ***************************************************************************************************/
    public ObjectRelation getSubRelation2() { return this.getRelation('Field2__c'); }

    /***  Extras  **************************************************************************************
     * Holds a serialized JSON String (meaning it must be enclosed between curly brackets) for any other extra configuration
     * options that might be needed. Usually these extra options are dependent on the particular service this relation is connected to
     ***************************************************************************************************/
    public Map<String,Object> getExtras() {
        try {
            String extras = (String)this.get('Extras__c');
            if (String.isNotBlank(extras)) {
                return (Map<String,Object>)JSON.deserializeUntyped(extras);
            }
        } catch (JSONException ex) {
            System.debug('ObjectRelation.Extras contains invalid JSON');
        }
        return null;
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

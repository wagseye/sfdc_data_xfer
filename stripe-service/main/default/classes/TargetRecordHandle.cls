public with sharing class TargetRecordHandle {
    public class ParentRelation {
        public ParentRelation(TargetRecordHandle parent, String prntFld, String chldFld) {
            if (parent == null) throw new StandardException('A parent object must be provided');
            if (String.isBlank(prntFld)) throw new StandardException('A parent field must be provided');
            if (String.isBlank(chldFld)) throw new StandardException('A child field must be provided');
            this.parent = parent;
            this.parentFieldName = prntFld;
            this.childFieldName = chldFld;
        }
        public TargetRecordHandle parent;
        // ObjectRelation relation;
        public String childFieldName;
        public String parentFieldName;
    }

    public enum Type { TARGET, JUNCTION }
    public enum Status { PENDING, CREATED, QUERIED }

    public ObjectRelation  objectRelation;
    public Type type;
    public Status status;
    // We probably don't want all the source records because each source record might not cleanly map to a 
    // target record. Instead at a higher level we'll probably want these objects to be mapped by path so
    // they can easily be pulled up as each field mapping is processed and the data needs to be written.
    public DataRecord[] sourceRecords;
    public DataRecord[] targetRecords;
    public Configuration.MappedObject targetObject;

    public List<ParentRelation> relations = new List<ParentRelation>();

    public TargetRecordHandle(Configuration.MappedObject tgt) {
        this.targetObject = tgt;
    }

    public void addParentRelation(TargetRecordHandle parent, String prntFld, String chldFld) {
        this.relations.add(new ParentRelation(parent, prntFld, chldFld));
    }
}

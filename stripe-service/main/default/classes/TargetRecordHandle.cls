public with sharing class TargetRecordHandle {
    public class ParentRelation {
        public TargetRecordHandle parent { public get; public set {
            if (value == null) throw new StandardException('A parent object must be provided');
            if (value.targetObject.path != this.parentPath) throw new StandardException('The parent object path does not match the path of this record');
            this.parent = value;
        } }
        public String parentPath { public get; private set; }
        public String childFieldName { public get; private set; }
        public String parentFieldName { public get; private set; }

        public ParentRelation(String prntPath, String prntFld, String chldFld) {
            if (String.isBlank(prntPath)) throw new StandardException('A parent path must be provided');
            if (String.isBlank(prntFld)) throw new StandardException('A parent field must be provided');
            if (String.isBlank(chldFld)) throw new StandardException('A child field must be provided');
            this.parentPath = prntPath;
            this.parentFieldName = prntFld;
            this.childFieldName = chldFld;
        }
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

    public void addParentRelation(ParentRelation rel) {
        if (rel.parent == null) throw new StandardException('A relation without no parent object can not be added');
        this.relations.add(rel);
    }
}

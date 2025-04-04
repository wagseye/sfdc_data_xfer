public with sharing class TargetRecordHandle {
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

    public TargetRecordHandle(Configuration.MappedObject tgt) {
        this.targetObject = tgt;
    }
}

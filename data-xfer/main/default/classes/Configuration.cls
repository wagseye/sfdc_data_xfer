public with sharing class Configuration {
    public virtual class MappedObject {
        public String objectName;
        public List<TargetObject> targetObjects;
        public String parentRelation;
        public List<MappedObject> childObjects;

        // These are not set in the configuration json, but are manually set when the json is parsed
        public String path;
        public MappedObject parent;
        
        public ObjectRelation getParentRelation() {
            if (String.isNotBlank(this.parentRelation)) {
                ObjectRelation rel = ObjectRelation.getRecordByName(this.parentRelation);
                if (rel == null) throw new StandardException('Unable to find object relation with the name ' + this.parentRelation);
                return rel;
            }
            return null;
        }
    }

    public class Relation {
        public String type;
        public String parentField;
        public String childField;
        public String access;
    }

    public class ForeignObjectStrategy{
        public String type;
        List<String> lookupFields;
        Boolean copyChangesOnLookup = false;
        Boolean createAlways = false;
    }

    public class TargetObject {
        public String name;
        public String ratio;
        public List<ForeignObjectStrategy> behavior;
    }

    public String sourceSystem;
    public MappedObject sourceTree;
    public String targetSystem;
    public MappedObject targetTree;

    // These are not set in the configuration json, but are manually set when the json is parsed
    public Map<RecordPath,MappedObject> targetObjectMap { public get; private set; }
    public List<MappedObject> targetObjects { public get { return this.targetObjectMap.values(); } }
    public Map<RecordPath,MappedObject> sourceObjectMap { public get; private set; }
    public List<MappedObject> sourceObjects { public get { return this.sourceObjectMap.values(); } }

    public static Configuration fromString(String configStr) {
        Configuration config = (Configuration)JSON.deserialize(configStr, Configuration.class);
        config.sourceObjectMap = new Map<RecordPath,MappedObject>();
        config.targetObjectMap = new Map<RecordPath,MappedObject>();
        parseTreeRecursive(config.sourceObjectMap, config.sourceTree, new RecordPath());
        parseTreeRecursive(config.targetObjectMap, config.targetTree, new RecordPath());
        validateConfiguration(config);
        return config;
    }

    public static void validateConfiguration(Configuration config) {
        // TODO: keep adding to this
        if ((config.sourceTree != null) && (config.sourceTree.parentRelation != null)) throw new StandardException('The top level source object must not specify a parent relation');
        if ((config.targetTree != null) && (config.targetTree.parentRelation != null)) throw new StandardException('The top level target object must not specify a parent relation');
    }

    private static void parseTreeRecursive(Map<RecordPath,MappedObject> objMap, MappedObject obj, RecordPath currPath) {
        if (obj != null) {
            RecordPath newPath = new RecordPath(currPath);
            newPath.addToEnd(obj.objectName);
            obj.path = newPath.toString(); // TODO: change MappedObject.path to be a RecordPath
            objMap.put(newPath, obj);
            if (obj.childObjects != null) {
                for (MappedObject child : obj.childObjects) {
                    child.parent = obj;
                    parseTreeRecursive(objMap, child, newPath);
                }
            }
        }
    }
}

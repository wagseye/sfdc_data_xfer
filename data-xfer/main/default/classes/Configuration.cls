public with sharing class Configuration {
    public interface StartListener {
        void onConfigurationStart();
    }

    public interface FinishListener {
        void onConfigurationFinish();
    }

    public interface ObjectListener {
        void onConfigurationObject(MappedObject obj, MappedObject parent);
    }

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
    public List<MappedObject> sourceObjects { public get; private set; }
    public List<MappedObject> targetObjects { public get; private set; }

    public static Configuration fromString(String configStr) {
        Configuration config = (Configuration)JSON.deserialize(configStr, Configuration.class);
        config.sourceObjects = new List<MappedObject>();
        config.targetObjects = new List<MappedObject>();
        parseTreeRecursive(config.sourceObjects, config.sourceTree, new RecordPath());
        parseTreeRecursive(config.targetObjects, config.targetTree, new RecordPath());
        validateConfiguration(config);
        return config;
    }

    public static void validateConfiguration(Configuration config) {
        // TODO: keep adding to this
        if ((config.sourceTree != null) && (config.sourceTree.parentRelation != null)) throw new StandardException('The top level source object must not specify a parent relation');
        if ((config.targetTree != null) && (config.targetTree.parentRelation != null)) throw new StandardException('The top level target object must not specify a parent relation');
    }

    private static void parseTreeRecursive(List<MappedObject> objList, MappedObject obj, RecordPath currPath) {
        if (obj != null) {
            objList.add(obj);
            RecordPath newPath = new RecordPath(currPath);
            newPath.addToEnd(obj.objectName);
            obj.path = newPath.toString(); // TODO: change MappedObject.path to be a RecordPath
            if (obj.childObjects != null) {
                for (MappedObject child : obj.childObjects) {
                    child.parent = obj;
                    parseTreeRecursive(objList, child, newPath);
                }
            }
        }
    }

    public void traverseSource(Object listener) {
        traversePrivate(listener, this.sourceTree);
    }

    public void traverseTarget(Object listener) {
        traversePrivate(listener, this.targetTree);
    }

    private void traversePrivate(Object listener, MappedObject obj) {
        if (listener == null) throw new StandardException('A listener must be provided');
        // While not required, it is almost certainly a bug if the listener does not implement the ObjectListener interface
        // so we check for it here
        if (!(listener instanceOf ObjectListener)) {
            throw new StandardException('The listener must implement at least one of the listener interfaces');
        }

        if (listener instanceof StartListener) ((StartListener)listener).onConfigurationStart();
        if (obj != null) traverseRecursive(listener, obj, null);
        if (listener instanceof FinishListener) ((FinishListener)listener).onConfigurationFinish();
    }

    private void traverseRecursive(Object listener, MappedObject currObj, MappedObject parent) {
        if (listener instanceof ObjectListener) ((ObjectListener)listener).onConfigurationObject(currObj, parent);
        if (currObj.childObjects != null) {
            for (MappedObject child : currObj.childObjects) {
                traverseRecursive(listener, child, currObj);
            }
        }
    }
}

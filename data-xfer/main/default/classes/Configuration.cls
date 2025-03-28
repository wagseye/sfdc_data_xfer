public with sharing class Configuration {
    public class MappedObject {
        public String objectName;
        public List<TargetObject> targetObjects;
        public String parentRelation;
        public List<MappedObject> childObjects;

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

    public static Configuration fromString(String configStr) {
        Configuration config = (Configuration)JSON.deserialize(configStr, Configuration.class);
        validationConfiguration(config);
        return config;
    }

    public static void validationConfiguration(Configuration config) {
        // TODO: implement this
    }
}
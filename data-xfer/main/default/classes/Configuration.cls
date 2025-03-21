public with sharing class Configuration {
    public class MappedObject {
        private Object_Relation__mdt parentRelationObject;

        public String objectName;
        public List<TargetObject> targetObjects;
        public String parentRelation;
        public List<MappedObject> childObjects;

        public Object_Relation__mdt getParentRelation() {
            if (String.isNotBlank(this.parentRelation)) {
                if (this.parentRelationObject == null) {
                    this.parentRelationObject = Object_Relation__mdt.getInstance(this.parentRelation);
                    if (this.parentRelationObject == null) throw new StandardException('Could not find object relation with name ' + this.parentRelation);
                }
                return this.parentRelationObject;
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
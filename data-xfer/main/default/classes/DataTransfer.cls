public with sharing class DataTransfer {
    public static Configuration config { get; private set; }
    public static DataSource sourceSystem { get; private set; }
    public static DataSourceInstance sourceSystemInstance { get; private set; }
    public static ServiceHandler handler { get; private set; }

    public class JunctionObject extends Configuration.MappedObject {}

    public static void run(Configuration cfg) {
        init(cfg);
        handler.transferData(sourceSystem);
    }

    @TestVisible
    private static void init(Configuration cfg) {
        config = cfg;
        sourceSystem = loadSourceDataSource();
        sourceSystemInstance = loadSourceInstance();
        handler = loadServiceHandler();
        handler.init(config, sourceSystem, sourceSystemInstance);
    }

    public static DataSource loadSourceDataSource() {
        if (config == null) throw new StandardException('No configuration has been loaded');
        if (String.isBlank(config.sourceSystem)) throw new StandardException('Configuration does not specify a source system');
        DataSource ds = DataSource.getRecordByName(config.sourceSystem);
        if (ds == null) throw new StandardException('Could not find data source named "' + config.sourceSystem + '"');
        return ds;
    }

    public static DataSourceInstance loadSourceInstance() {
        // TODO: fix this!
        // For now we are just trying to load the oldest data source instance and using that
        List<DataSourceInstance> insts = DataSourceInstance.getAll();
        if (insts.isEmpty()) throw new StandardException('Could not find any data source instances to use');
        return insts[0];
    }

    private static ServiceHandler loadServiceHandler() {
        if (sourceSystem == null) throw new StandardException('Source system has not yet been loaded');
        ServiceHandler hdlr = sourceSystem.getHandler();
        if (hdlr == null) throw new StandardException('Could not find a service handler for data source ' + sourceSystem.getDisplayName());
        return hdlr;
    }

    private class ConfigListener implements Configuration.ObjectListener {
        public Map<String,Integer> tiers = new Map<String,Integer>();
        public Map<String,Configuration.MappedObject> objects = new  Map<String,Configuration.MappedObject>();
        public Map<String,List<TargetRecordHandle.ParentRelation>> relations = new Map<String,List<TargetRecordHandle.ParentRelation>>();
        public void onConfigurationObject(Configuration.MappedObject obj, Configuration.MappedObject parent) {
            objects.put(obj.path, obj);
            if (parent != null) {
                Integer parentTier = tiers.get(parent.path);
                if (parentTier == null) throw new StandardException('Unable to find parent tier');
                ObjectRelation rltn = ObjectRelation.getRecordByName(obj.parentRelation);
                if (rltn == null) throw new StandardException('Unable to find object relation with name ' + obj.parentRelation);
                if (rltn.isJunction()) {
                    tiers.put(obj.path, parentTier);
                    JunctionObject junc = new JunctionObject();
                    ExternalObject intObj = rltn.getIntermediateObject();
                    if (intObj == null) throw new StandardException('Did not find intermediate object for object relation ' + rltn.getApiName());
                    junc.objectName = intObj.getName();
                    junc.path = obj.path + '.' + junc.objectName;
                    objects.put(junc.path, junc);
                    tiers.put(junc.path, parentTier + 1);

                    ObjectRelation parentSubRel = rltn.getSubRelation1();
                    ObjectRelation childSubRel = rltn.getSubRelation2();
                    if (parentSubRel == null) throw new StandardException('Could not find parent subrelation for junction ' + rltn.getApiName());
                    if (childSubRel == null) throw new StandardException('Could not find child subrelation for junction ' + rltn.getApiName());
                    List<TargetRecordHandle.ParentRelation> rels = new List<TargetRecordHandle.ParentRelation>();
                    rels.add(new TargetRecordHandle.ParentRelation(parent.path, parentSubRel.getField1(), parentSubRel.getField2()));
                    rels.add(new TargetRecordHandle.ParentRelation(obj.path, childSubRel.getField1(), childSubRel.getField2()));
                    if (!parentSubRel.getObject1().getApiName().equalsIgnoreCase(parent.objectName)) throw new StandardException('Object 1 on relation ' + parentSubRel.getApiName() + ' is not ' + parent.objectName);
                    if (!childSubRel.getObject1().getApiName().equalsIgnoreCase(obj.objectName)) throw new StandardException('Object 1 on relation ' + childSubRel.getApiName() + ' is not ' + obj.objectName);
                    relations.put(junc.path, rels);
                } else { // To get here the relation MUST be a reference
                    tiers.put(obj.path, parentTier + 1);
                    TargetRecordHandle.ParentRelation rel = new TargetRecordHandle.ParentRelation(parent.path, rltn.getField1(), rltn.getField2());
                    relations.put(obj.path, new List<TargetRecordHandle.ParentRelation>{ rel });
                }
            } else {
                tiers.put(obj.path, 0);
            }
        }
    }

    public static List<List<TargetRecordHandle>> groupTargetObjects(Configuration cfg) {
        List<List<TargetRecordHandle>> handles;
        ConfigListener listener = new ConfigListener();
        cfg.traverseTarget(listener);

        // Instantiate the list to the correct size
        Integer maxTier = 0;
        for (Integer tier : listener.tiers.values()) {
            if (tier > maxTier) maxTier = tier;
        }
        handles = new List<List<TargetRecordHandle>>(maxTier + 1);
        Map<String,TargetRecordHandle> handlesByPath = new Map<String,TargetRecordHandle>();

        for (Configuration.MappedObject obj : listener.objects.values()) {
            Integer tier = listener.tiers.get(obj.path);
            List<TargetRecordHandle.ParentRelation> rels = listener.relations.get(obj.path);
            List<TargetRecordHandle> tierHandles = handles[tier];
            if (tierHandles == null) tierHandles = new List<TargetRecordHandle>();
            handles[tier] = tierHandles;

            TargetRecordHandle hndl = new TargetRecordHandle(obj);
            hndl.type = (obj instanceof JunctionObject) ?  TargetRecordHandle.Type.JUNCTION : TargetRecordHandle.Type.TARGET;
            hndl.status = TargetRecordHandle.Status.PENDING;
            if (rels != null) {
                for (TargetRecordHandle.ParentRelation rel : rels) {
                    TargetRecordHandle parent = handlesByPath.get(rel.parentPath);
                    if (parent == null) throw new StandardException('Did not find parent object with path ' + rel.parentPath + ' for object ' + obj.path);
                    rel.parent = parent;
                    hndl.addParentRelation(rel);
                }
            }
            tierHandles.add(hndl);
            handlesByPath.put(obj.path, hndl);
        }
        return handles;
    }

    public static Map<RecordPath,List<DataRecord>> loadDataRecords(Configuration config, ServiceHandler hdlr, Map<String,Object> jsonData) {
        Map<RecordPath,List<DataRecord>> mapRecs = new Map<RecordPath,List<DataRecord>>();

        // TODO: Get the starting place (probably want handler for this?)
        Object root = jsonData; //handler.getDataRoot();
        // Is top level a list or an object?
        RecordPath rootPath = new RecordPath(config.sourceObjects[0].path);
        List<DataRecord> rootRecords = new List<DataRecord>();
        mapRecs.put(rootPath, rootRecords);
        DataRecord rootRecord = new DataRecord(jsonData, null, rootPath);
        if (rootRecord.isList) {
            rootRecords.addAll(rootRecord.getChildren());
        } else {
            rootRecords.add(rootRecord);
        }

        for (Configuration.MappedObject configObj : config.sourceObjects) {
            RecordPath path = new RecordPath(configObj.path);
            parseDataRecords(path, mapRecs);
        }

        return mapRecs;
    }

    public static void parseDataRecords(RecordPath configPath, Map<RecordPath,List<DataRecord>> mapRecs) {
        List<DataRecord> children = mapRecs.get(configPath);
        if (children == null) {
            // Go up the hierarchy, looking for the longest prefix path that already has DataRecords created for it
            RecordPath parentPath = new RecordPath(configPath);
            List<DataRecord> parentList;
            while (!parentPath.isEmpty() && (parentList == null)) {
                parentPath.removeFromEnd();
                parentList = mapRecs.get(parentPath);
            }
            if (parentList == null) throw new StandardException('Did not find parent record');

            // Retrieve the child record. If it is a list, add all child elements, otherwise add the record itself
            RecordPath relativePath = configPath.removeFromStart(parentPath);
            children = new List<DataRecord>();
            mapRecs.put(configPath, children);
            Boolean childIsList;
            for (DataRecord parent : parentList) {
                DataRecord child = parent.getChild(relativePath);
                if (childIsList == null) {
                    childIsList = child.isList;
                } else if (childIsList != child.isList) throw new StandardException('Found isList mismatch on children at path ' + configPath);
                if (childIsList) {
                    List<DataRecord> grandchildren = child.getChildren();
                    for (Integer idx=0; idx<grandchildren.size(); idx++) {
                        grandchildren[idx].path.setIndex(idx);
                        children.add(grandchildren[idx]);
                    }
                } else {
                    children.add(child);
                }
            }
        }
    }
}

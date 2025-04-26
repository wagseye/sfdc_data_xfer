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

    public static List<List<TargetRecordHandle>> groupTargetObjects(Configuration cfg) {
        Map<RecordPath,Configuration.MappedObject> objMap = new Map<RecordPath,Configuration.MappedObject>();
        Map<RecordPath,List<TargetRecordHandle.ParentRelation>> relMap = getRelations(cfg.targetObjects, /*output*/ objMap);
        Map<RecordPath,Integer> tierMap = calculateTiers(objMap, relMap);

        return createTierHandles(objMap, relMap, tierMap);
    }

    private static List<List<TargetRecordHandle>> createTierHandles(Map<RecordPath,Configuration.MappedObject> objMap, Map<RecordPath,List<TargetRecordHandle.ParentRelation>> relMap, Map<RecordPath,Integer> tierMap) {
        Integer maxTier = getMaxTier(tierMap);
        List<List<TargetRecordHandle>> handles = new List<List<TargetRecordHandle>>(maxTier + 1);
        Map<RecordPath,TargetRecordHandle> handleMap = new Map<RecordPath,TargetRecordHandle>();

        for (Configuration.MappedObject obj : objMap.values()) {
            Integer tier = tierMap.get(obj.path);
            List<TargetRecordHandle.ParentRelation> rels = relMap.get(obj.path);
            List<TargetRecordHandle> tierHandles = handles[tier];
            if (tierHandles == null) tierHandles = new List<TargetRecordHandle>();
            handles[tier] = tierHandles;

            TargetRecordHandle hndl = new TargetRecordHandle(obj);
            hndl.type = (obj instanceof JunctionObject) ?  TargetRecordHandle.Type.JUNCTION : TargetRecordHandle.Type.TARGET;
            hndl.status = TargetRecordHandle.Status.PENDING;
            if (rels != null) {
                for (TargetRecordHandle.ParentRelation rel : rels) {
                    TargetRecordHandle parent = handleMap.get(rel.parentPath);
                    if (parent == null) throw new StandardException('Did not find parent object with path ' + rel.parentPath + ' for object ' + obj.path);
                    rel.parent = parent;
                    hndl.addParentRelation(rel);
                }
            }
            tierHandles.add(hndl);
            handleMap.put(new RecordPath(obj.path), hndl); // Create a new RecordPath object when adding to a map
        }
        return handles;
    }

    private static Integer getMaxTier(Map<RecordPath,Integer> tierMap) {
        // Find the number of tiers by looking for the highest number in the map
        Integer maxTier = 0;
        for (Integer tier : tierMap.values()) {
            if (tier > maxTier) maxTier = tier;
        }
        return maxTier;
    }

    private static Map<RecordPath,Integer> calculateTiers(Map<RecordPath,Configuration.MappedObject> objMap, Map<RecordPath,List<TargetRecordHandle.ParentRelation>> relMap) {
        Map<RecordPath,Integer> tierMap = new Map<RecordPath,Integer>();
        for (Configuration.MappedObject obj : objMap.values()) {
            Integer tier;
            if (obj.parent == null) {
                tier = 0;
            } else {
                Integer parentTier = tierMap.get(obj.parent.path);
                if (parentTier == null) throw new StandardException('Unable to find parent tier');
                if (obj instanceof JunctionObject) {
                    // The junction object always ends up one tier below its parent(s)
                    tier = parentTier + 1;
                } else {
                    ObjectRelation rltn = ObjectRelation.getRecordByName(obj.parentRelation);
                    if (rltn == null) throw new StandardException('Unable to find object relation with name ' + obj.parentRelation);
                    if (rltn.isJunction()) {
                        // If we're using a junction object, the two objects will be in the same tier because they don't have any interdependencies
                        tier = parentTier;
                    } else {
                        // A normal reference relation needs its parent's id so it is added to the tier below the parent
                        tier = parentTier + 1;
                    }
                }
            }
            tierMap.put(new RecordPath(obj.path), tier); // Create a new RecordPath object when adding to a map
        }
        return tierMap;
    }

    private static Map<RecordPath,List<TargetRecordHandle.ParentRelation>> getRelations(List<Configuration.MappedObject> objs, /*output*/ Map<RecordPath,Configuration.MappedObject> objMap) {
        Map<RecordPath,List<TargetRecordHandle.ParentRelation>> relMap = new Map<RecordPath,List<TargetRecordHandle.ParentRelation>>();
        for (Configuration.MappedObject obj : objs) {
            objMap.put(new RecordPath(obj.path), obj); // Create a new RecordPath object when adding to a map
            if (obj.parent != null) {
                ObjectRelation rltn = ObjectRelation.getRecordByName(obj.parentRelation);
                if (rltn == null) throw new StandardException('Unable to find object relation with name ' + obj.parentRelation);
                if (rltn.isJunction()) {
                    JunctionObject junc = createJunctionObject(obj, rltn);
                    List<TargetRecordHandle.ParentRelation> rels = createJunctionRelations(obj, rltn);
                    RecordPath juncPath = new RecordPath(junc.path);  // Create a new RecordPath object when adding to a map
                    relMap.put(juncPath, rels);
                    objMap.put(juncPath, junc);
                } else { // The relation is a reference
                    TargetRecordHandle.ParentRelation rel = new TargetRecordHandle.ParentRelation(obj.parent.path, rltn.getField1(), rltn.getField2());
                    relMap.put(new RecordPath(obj.path), new List<TargetRecordHandle.ParentRelation>{ rel });  // Create a new RecordPath object when adding to a map
                }
            }
        }
        return relMap;
    }

    private static JunctionObject createJunctionObject(Configuration.MappedObject obj, ObjectRelation rltn) {
        if (!rltn.isJunction()) throw new StandardException('Relation is not a junction');

        JunctionObject junc = new JunctionObject();
        ExternalObject intObj = rltn.getIntermediateObject();
        if (intObj == null) throw new StandardException('Did not find intermediate object for object relation ' + rltn.getApiName());
        junc.objectName = intObj.getName();
        junc.parent = obj;
        RecordPath juncPath = new RecordPath(obj.path);
        juncPath.addToEnd(junc.objectName);
        junc.path = juncPath;

        return junc;
    }

    public static List<TargetRecordHandle.ParentRelation> createJunctionRelations(Configuration.MappedObject obj, ObjectRelation rltn) {
        if (!rltn.isJunction()) throw new StandardException('Relation is not a junction');

        List<TargetRecordHandle.ParentRelation> rels = new List<TargetRecordHandle.ParentRelation>();
        ObjectRelation parentSubRel = rltn.getSubRelation1();
        ObjectRelation childSubRel = rltn.getSubRelation2();
        if (parentSubRel == null) throw new StandardException('Could not find parent subrelation for junction ' + rltn.getApiName());
        if (childSubRel == null) throw new StandardException('Could not find child subrelation for junction ' + rltn.getApiName());
        rels.add(new TargetRecordHandle.ParentRelation(obj.parent.path, parentSubRel.getField1(), parentSubRel.getField2()));
        rels.add(new TargetRecordHandle.ParentRelation(obj.path, childSubRel.getField1(), childSubRel.getField2()));
        if (!parentSubRel.getObject1().getApiName().equalsIgnoreCase(obj.parent.objectName)) throw new StandardException('Object 1 on relation ' + parentSubRel.getApiName() + ' is not ' + obj.parent.objectName);
        if (!childSubRel.getObject1().getApiName().equalsIgnoreCase(obj.objectName)) throw new StandardException('Object 1 on relation ' + childSubRel.getApiName() + ' is not ' + obj.objectName);

        return rels;
    }

    public static Map<RecordPath,List<DataRecord>> loadDataRecords(Configuration config, ServiceHandler hdlr, Map<String,Object> jsonData) {
        Map<RecordPath,List<DataRecord>> recMap = new Map<RecordPath,List<DataRecord>>();

        // TODO: Get the starting place (probably want handler for this?)
        Object root = jsonData; //handler.getDataRoot();
        // Is top level a list or an object?
        RecordPath rootPath = config.sourceObjects[0].path;
        List<DataRecord> rootRecords = new List<DataRecord>();
        recMap.put(new RecordPath(rootPath), rootRecords); // Create a new RecordPath object when adding to a map
        DataRecord rootRecord = new DataRecord(jsonData, null, rootPath);
        if (rootRecord.isList) {
            rootRecords.addAll(rootRecord.getChildren());
        } else {
            rootRecords.add(rootRecord);
        }

        for (Configuration.MappedObject configObj : config.sourceObjects) {
            parseDataRecords(configObj.path, recMap);
        }

        return recMap;
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
            mapRecs.put(new RecordPath(configPath), children); // Create a new RecordPath object when adding to a map
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

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
        public void onConfigurationObject(Configuration.MappedObject obj, Configuration.MappedObject parent) {
            objects.put(obj.path, obj);
            if (parent != null) {
                Integer parentTier = tiers.get(parent.path);
                if (parentTier == null) throw new StandardException('Unable to find parent tier');
                ObjectRelation rltn = ObjectRelation.getRecordByName(obj.parentRelation);
                if (rltn == null) throw new StandardException('Unable to find object relation with name ' + obj.parentRelation);
                if (rltn.getType().equalsIgnoreCase('junction')) {
                    tiers.put(obj.path, parentTier);
                    JunctionObject junc = new JunctionObject();
                    junc.objectName = rltn.getIntermediateObject();
                    if (String.isBlank(junc.objectName)) throw new StandardException('Did not find junction object name for object relation ' + rltn.getApiName());
                    junc.path = obj.path + '.' + junc.objectName;
                    objects.put(junc.path, junc);
                    tiers.put(junc.path, parentTier + 1);
                } else if (rltn.getType().equalsIgnoreCase('reference')) {
                    tiers.put(obj.path, parentTier + 1);
                } else throw new StandardException('Unrecognized object relation type ' + rltn.getType());
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

        for (Configuration.MappedObject obj : listener.objects.values()) {
            Integer tier = listener.tiers.get(obj.path);
            List<TargetRecordHandle> tierHandles = handles[tier];
            if (tierHandles == null) tierHandles = new List<TargetRecordHandle>();
            handles[tier] = tierHandles;

            TargetRecordHandle hndl = new TargetRecordHandle(obj);
            hndl.type = (obj instanceof JunctionObject) ?  TargetRecordHandle.Type.JUNCTION : TargetRecordHandle.Type.TARGET;
            hndl.status = TargetRecordHandle.Status.PENDING;
            tierHandles.add(hndl);
        }
        return handles;
    }
}

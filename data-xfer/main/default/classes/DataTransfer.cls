public with sharing class DataTransfer {
    public static Configuration config { get; private set; }
    public static DataSource sourceSystem { get; private set; }
    public static DataSourceInstance sourceSystemInstance { get; private set; }
    public static ServiceHandler handler { get; private set; }

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
}

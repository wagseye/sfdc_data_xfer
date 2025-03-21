public with sharing class DataTransfer {
    @TestVisible private static String configString;

    public static Configuration config { get; private set; }
    public static DataSource sourceSystem { get; private set; }
    public static ServiceHandler handler { get; private set; }

    public static void init() {
        config = Configuration.fromString(getConfigString());
        loadSourceDataSource();
        loadServiceHandler();
    }

    public static void loadSourceDataSource() {
        if (config == null) throw new StandardException('No configuration has been loaded');
        if (String.isBlank(config.sourceSystem)) throw new StandardException('Configuration does not specify a source system');
        sourceSystem = DataSource.getRecordByName(config.sourceSystem);
        if (sourceSystem == null) throw new StandardException('Could not find data source named "' + config.sourceSystem + '"');
    }

    private static void loadServiceHandler() {
        if (sourceSystem == null) throw new StandardException('Source system has not yet been loaded');
        handler = sourceSystem.getHandler();
    }

    private static String getConfigString() {
        if (String.isNotBlank(configString)) {
            return configString;
        }
        throw new StandardException('Loading config string from database is not yet supported');
    }
}

public with sharing abstract class ServiceHandler {
    static final Set<String> HTTP_METHODS = new Set<String>{ 'GET', 'POST', 'PUT', 'PATCH', 'DELETE' };
    protected Configuration config;
    protected DataSource dataSource;
    protected DataSourceInstance dataSourceInstance;

    public abstract class ServiceObject {
        public abstract String getApiName();
        public abstract String getDisplayName();
        public abstract List<ServiceObjectField> getFields();
    }

    public abstract class ServiceObjectField {
        public abstract String getApiName();
        public abstract String getDisplayName();
        public abstract String getType();
    }

    public virtual class DefaultServiceObject extends ServiceObject {
        protected Object__mdt obj;
        List<ServiceObjectField> fields;

        public DefaultServiceObject(Object__mdt obj) { this.obj = obj; }
        public override String getApiName() { return this.obj.API_Name__c; }
        public override String getDisplayName() { return this.obj.Display_Name__c; }
        public override List<ServiceObjectField> getFields() {
            if (this.fields == null) {
                this.fields = new List<ServiceObjectField>();
                List<Object_Field__mdt> flds = [SELECT API_Name__c, Display_Name__c, Data_Type__c FROM Object_Field__mdt WHERE Object__c=:this.obj.Id];
                for (Object_Field__mdt fld : flds) {
                    this.fields.add(new DefaultServiceObjectField(fld));
                }
            }
            return this.fields;
        }
    }

    public abstract class Query {
        public abstract void addCondition(String fldName, String operator, Object value);
    }

    public virtual class DefaultServiceObjectField extends ServiceObjectField {
        protected Object_Field__mdt field;

        public DefaultServiceObjectField(Object_Field__mdt fld) { this.field = fld; }
        public override String getApiName() { return this.field.API_Name__c; }
        public override String getDisplayName() { return this.field.Display_Name__c; }
        public override String getType() { return this.field.Data_Type__c; }
    }

    public virtual class ServiceResponse {
        protected HttpResponse response;
        List<DataRecord> records;
        public ServiceResponse(HttpResponse resp) {
            this.response = resp;
        }
        public virtual Boolean isSuccess() {
            return (this.response.getStatusCode() == 200);
        }

        public virtual String getError() {
            if (this.isSuccess()) return null;
            return this.response.getStatus();
        }
    }

    // TODO: find a better way to do this!
    public void init(Configuration config, DataSource dataSource, DataSourceInstance dataSourceInstance) {
        this.config = config;
        this.dataSource = dataSource;
        this.dataSourceInstance = dataSourceInstance;
    }

    public virtual List<ServiceObject> getAllObjects() {
        Data_Source__mdt src = Data_Source__mdt.getInstance(this.getServiceApiName());
        if (src == null) throw new IllegalArgumentException('Unable to find a metadata record for the ' + this.getServiceDisplayName() + ' service');
        List<Object__mdt> mdObjs = [SELECT API_Name__c, Display_Name__c, Data_Source__c FROM Object__mdt WHERE Data_Source__c=:src.Id];
        List<ServiceObject> objs = new List<ServiceObject>();
        for (Object__mdt mdObj : mdObjs) {
            objs.add(new DefaultServiceObject(mdObj));
        }
        return objs;
    }

    public virtual ServiceObject getObject(String apiName) {
        if (String.isBlank(apiName)) throw new IllegalArgumentException('A valid object name must be provided');
        String mdName = getObjectName(apiName);
        Object__mdt obj = Object__mdt.getInstance(mdName);
        if (obj != null) return new DefaultServiceObject(obj);
        return null;
    }

    public String getObjectName(String apiName) {
        return String.format('{0}_{1}', new List<Object>{ getServiceApiName(), apiName });
    }

    // TODO: figure out if structuring the code this way makes sense
    // public virtual List<DataRecord> query(ServiceObject obj, List<ServiceObjectField> flds, List<Object> params) {
    //     String mdActionName = getObjectActionName(obj.getApiName(), 'query');
    //     Object_Action__mdt mdAction = Object_Action__mdt.getInstance(mdActionName);
    //     if (mdAction == null) throw new IllegalArgumentException('Unable to find object action metadata record');
    //     ServiceResponse resp = transferData(mdAction);
    //     if (!resp.isSuccess()) {
    //         System.debug(getServiceApiName() + ' service returned an error: ' + resp.getError());
    //         throw new IllegalArgumentException('External service returned an error');
    //     }
    //     return resp.getRecords();
    // }

    public virtual List<DataRecord> retrieveRecords(DataSource src) {
        //ExternalObjectAction action = dfd.getAction('query');
        return null;
    }

    public virtual void updateRecords(DataSource src) {
        //ExternalObjectAction action = dfd.getAction('create');
    }

    public virtual ServiceResponse transferData(DataSource src) {
        if (src == null) throw new IllegalArgumentException('A valid DataSource must be provided');
        //String mdName = getObjectActionName(actionName);
        //Object_Action__mdt objAction = Object_Action__mdt.getInstance(mdName);
        //if (objAction == null) throw new IllegalArgumentException('No object action record found with the name ' + mdName);
        HttpRequest req = new HttpRequest();

        String endpoint = getEndpoint(src);
        System.debug('Setting endpoint: ' + endpoint);
        req.setEndpoint(endpoint);

        String method = getHttpMethod(src);
        System.debug('Setting http method: ' + method);
        req.setMethod(method);

        Map<String,String> headers = getRequestHeaders(src);
        if (headers != null) {
            for (String name : headers.keySet()) {
                if (String.isBlank(name)) throw new IllegalArgumentException('Http header names must not be blank');
                System.debug('Adding header: ' + name + '="' + headers.get(name) + '"');
                req.setHeader(name, headers.get(name));
            }
        }

        String body = getRequestBody(src);
        System.debug('Setting body to: ' + body);
        if (String.isNotBlank(body)) req.setBody(body);
        
        HttpResponse resp = new Http().send(req);
        System.debug('HTTP response: ' + resp.getBody());
        return createResponse(resp);
    }

    public virtual ServiceResponse createResponse(HttpResponse resp) {
        return new ServiceResponse(resp);
    }

    public virtual String getEndpoint(DataSource src) {
        String server = getServer(src);
        String path = getPath(src);
        String endpoint = server + path;

        Map<String,Object> data = this.getRequestData(src);
        if ((data == null) || data.isEmpty()) return endpoint;

        String method = this.getHttpMethod(src);
        if (!HTTP_METHODS.contains(method.toUpperCase())) throw new StandardException('Invalid http method: ' + method);

        // Get and Delete aren't supposed to have bodies. The parameters should be appended to the URL.
        if (method.equalsIgnoreCase('get') || method.equalsIgnoreCase('delete')) {
            List<String> paramList = new List<String>();
            for (String key : data.keySet()) {
                Object value = data.get(key);
                Boolean keyIsList = key.endsWith('[]');
                Boolean valueIsList = value instanceof List<Object>;
                if (keyIsList && !valueIsList) throw new IllegalArgumentException('Found list parameter name with scalar value');
                if (!keyIsList && valueIsList) throw new IllegalArgumentException('Found scalar parameter name with list value');
                if (keyIsList && valueIsList) {
                    for (Object listValue : (List<Object>)value) {
                        paramList.add(key + '=' + EncodingUtil.urlEncode(String.valueOf(listValue), 'UTF-8'));
                    }
                }
                else {
                    paramList.add(key + '=' + EncodingUtil.urlEncode(String.valueOf(value), 'UTF-8'));
                }
            }
            endpoint += '?' + String.join(paramList, '&');
        }
        return endpoint;
    }

    public virtual String getServer(DataSource src) {
        return src.getBasePath();
    }

    public virtual String getPath(DataSource src) {
        return null; //dfd.getDefaultAction().getPath();
    }

    public virtual String getHttpMethod(DataSource src) {
        // Default to GET here, subclasses can override
        return 'GET';
    }

    public virtual Map<String,String> getRequestHeaders(DataSource src) {
        return null;
    }

    public virtual String getRequestBody(DataSource src) {
        Map<String,Object> data = this.getRequestData(src);
        if ((data != null) && !data.isEmpty()) {
            String method = this.getHttpMethod(src);
            // Get and Delete aren't supposed to have bodies. The parameters should be appended to the URL. This right
            // here is a bit of a placeholder until more specific rules are determined
            if (!method.equalsIgnoreCase('get') && !method.equalsIgnoreCase('delete')) {
                List<String> params = new List<String>();
                for (String key : data.keySet()) {
                    return JSON.serialize(data);
                }
            }
        }
        return null;
    }

    public virtual Map<String,Object> getRequestData(DataSource src) {
        return null;
    }

    public String getObjectActionName(String objectApiName, String actionName) {
        if (String.isBlank(actionName)) throw new IllegalArgumentException('A valid action name must be provided');
        return String.format('{0}_{1}_{2}', new List<Object>{ getServiceApiName(), objectApiName, actionName });
    }

    public abstract String getServiceApiName();
    public abstract String getServiceDisplayName();
}
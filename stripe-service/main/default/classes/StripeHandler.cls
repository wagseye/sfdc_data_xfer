public with sharing class StripeHandler extends ServiceHandler {

    public class StripeQuery extends Query {
        List<String> filters = new List<String>();
        Set<String> expansions = new Set<String>();

        public StripeQuery() {}

        public override void addCondition(String fldName, String operator, Object value) {
            if (String.isBlank(fldName)) throw new IllegalArgumentException('Field name must be specified');

            String expr;
            String queryValue = (value instanceof String) ? '"' + value + '"' : String.valueOf(value);
            List<String> params = new List<String>{ fldName, queryValue };
            switch on operator {
                when '=', 'eq' {
                   expr = String.format('{0}:{1}', params);
                }
                when '!=', '<>', 'ne' {
                    expr = String.format('-{0}:{1}', params);
                }
                when '>', 'gt' {
                    expr = String.format('{0}>{1}', params);
                }
                when '>=', 'gte' {
                    expr = String.format('{0}>={1}', params);
                }
                when '<', 'lt' {
                    expr = String.format('{0}<{1}', params);
                }
                when '<=', 'lte' {
                    expr = String.format('{0}<={1}', params);
                }
                when else {
                    throw new IllegalArgumentException('Unsupported operator: "' + operator + '"');
                }
            }
            this.filters.add(expr);
        }

        public void addExpansion(String objName) {
            if (String.isBlank(objName)) throw new IllegalArgumentException('Field to expand must be provided');
            this.expansions.add(objName);
        }

        public String getQueryString() {
            if (this.filters != null && !this.filters.isEmpty()) {
                return String.join(filters, ' AND ');
            }
            return null;
        }
        public List<String> getExpansions() {
            return new List<String>(this.expansions);
        }
    }

    public List<String> getExpansions(Configuration cfg) {
        List<String> expansions = new List<String>();

        ExternalObjectAction actn = this.dataSource.getObject(this.config.sourceTree.objectName).getAction('query');
        RecordPath prefix = getResultsPrefix(actn);

        for (Configuration.MappedObject obj : cfg.sourceObjects) {
            if (StripeHandler.getRelationAccess(obj.getParentRelation()) == 'expand') {
                // The expansions are relative to the top-level object, so we need to strip off the top-level object (if present)
                RecordPath fullPath = obj.path.removeFromStart();
                // If there is a prefix, that needs to be added to the front of the path
                if ((prefix != null) && !prefix.isEmpty()) {
                    fullPath = fullPath.addToStart(prefix);
                }
                expansions.add(fullPath.toString());
            }
        }
        return expansions;
    }


    public class StripeResponse extends ServiceResponse {
        List<DataRecord> records;
        protected Map<String,Object> responseObject;
        public StripeResponse(HttpResponse resp) {
            super(resp);
            Map<String,Object> json = (Map<String,Object>)JSON.deserializeUntyped(resp.getBody());
            if (json.containsKey('object') && json.get('object') == 'search_result') {
                List<Object> jsonRecs = (List<Object>)json.get('data');
                if (jsonRecs != null) {
                    this.records = new List<DataRecord>();
                    for (Object jsonRec : jsonRecs) {
                        DataRecord dr = new StripeRecord((Map<String,Object>)jsonRec);
                        this.records.add(dr);
                    }
                }
            } else if (json.containsKey('error')) {
                Map<String,Object> error = (Map<String,Object>)json.get('error');
                String errMsg = (String)error.get('message');
                System.debug('Stripe returned the following error: ' + error);
                throw new StandardException('Stripe returned an error: ' + errMsg);
            }
            else throw new StandardException('Did not find object key, or value was not search_result');
        }

        public override Boolean isSuccess() {
            return (this.response.getStatusCode() == 200) &&
                   !this.responseObject.containsKey('error');
        }

        public override String getError() {
            return String.valueOf(responseObject.get('error'));
        }

        public virtual List<Map<String,Object>> getObjects() {
            // TODO: Figure out the format difference between a single object and a list of objects
            List<Map<String,Object>> lst = new List<Map<String,Object>>();
            lst.add(responseObject);
            return lst;
        }
    }

    public static String getRelationAccess(ObjectRelation rel) {
        if (rel != null) {
            Map<String,Object> extras = rel.getExtras();
            if (extras != null) {
                return (String)extras.get('forwardAccess');
            }
        }
        return null;
    }

    private RecordPath getResultsPrefix(ExternalObjectAction actn) {
        if (actn != null) {
            Map<String,Object> extras = actn.getExtras();
            if (extras != null) {
                String pathStr = (String)extras.get('resultsPrefix');
                if (String.isNotBlank(pathStr)) return new RecordPath(pathStr);
            }
        }
        return null;
    }

    public override String getPath(DataSource src) {
        // TODO: cache the action somewhere; we're using it in multiple methods
        String objName = this.config.sourceTree.objectName;
        ExternalObjectAction action = this.dataSource.getObject(objName).getAction('query');
        if (action == null) throw new StandardException('Could not find Stripe query action for ' + objName + ' object');
        return action.getPath();
    }

    public override String getHttpMethod(DataSource src) {
        // TODO: cache the action somewhere; we're using it in multiple methods
        String objName = this.config.sourceTree.objectName;
        ExternalObjectAction action = this.dataSource.getObject(objName).getAction('query');
        if (action == null) throw new StandardException('Could not find Stripe query action for ' + objName + ' object');
        return action.getMethod();
    }

    public override Map<String,Object> getRequestData(DataSource src) {
        String objName = this.config.sourceTree.objectName;
        ExternalObjectAction action = this.dataSource.getObject(objName).getAction('query');
        if (action == null) throw new StandardException('Could not find Stripe query action for ' + objName + ' object');
        Map<String,Object> data = new Map<String,Object>();
        StripeQuery q = new StripeQuery();
        q.addCondition('amount', '>', 0);
        // q.addCondition('customer', '=', 'cus_Rs7xP84wr6CJPD');
        String queryString = q.getQueryString();
        if (String.isNotBlank(queryString)) data.put('query', queryString);
        List<String> expansions = this.getExpansions(this.config);
        //List<String> expansions = q.getExpansions();
        System.debug('Expansions: ' + expansions);
        if (expansions != null && !expansions.isEmpty()) {
            data.put('expand[]', expansions);
        }
        return data;
    }

    public override String getServiceApiName() {
        return 'strp';
    }

    public override String getServiceDisplayName() {
        return 'Stripe';
    }

    public override ServiceResponse createResponse(HttpResponse resp) {
        return new StripeResponse(resp);
    }

    public override Map<String,String> getRequestHeaders(DataSource src) {
        Map<String,String> headers = new Map<String,String>();
        headers.put('Content-Type', 'application/json');
        headers.put('Authorization', 'Bearer ' + getApiKey(src));
        return headers;
    }

    private String getApiKey(DataSource src) {
        if (this.dataSourceInstance == null) { throw new StandardException('Data source instance object not set'); }
        String apiKey = this.dataSourceInstance.getApiSecret();
        if (String.isBlank(apiKey)) throw new StandardException('Data source instance does not have api key set');
        return apiKey;
    }
}
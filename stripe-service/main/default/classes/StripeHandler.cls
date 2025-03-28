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
        if (cfg == null) throw new StandardException('A configuration object must be provided');
        if (cfg.sourceSystem != getServiceApiName()) throw new StandardException('Source system is not Stripe');
        List<String> expansions = new List<String>();
        if (cfg.sourceTree != null) {
            String objPath = cfg.sourceTree.objectName;
            if (String.isBlank(objPath)) throw new StandardException('Configuration source tree does not have objectName set');
            this.addExpansionsRecursive(cfg.sourceTree, objPath, expansions);
        }
        return expansions;
    }

    private void addExpansionsRecursive(Configuration.MappedObject obj, String objPath, List<String> expansions) {
        if ((obj == null) || (obj.childObjects == null)) return;
        for (Configuration.MappedObject chld : obj.childObjects) {
            String chldName = chld.objectName;
            if (String.isBlank(chldName)) throw new StandardException('Child object does not have objectName set');
            String chldPath = objPath + '.' + chldName;
            if (this.getRelationAccess(chld.getParentRelation()) == 'expand') {
                expansions.add(chldPath);
            }
            addExpansionsRecursive(chld, chldPath, expansions);
        }
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

    public String getRelationAccess(ObjectRelation rel) {
        if (rel != null) {
            Map<String,Object> extras = rel.getExtras();
            if (extras != null) {
                return (String)extras.get('forwardAccess');
            }
        }
        return null;
    }

    public override Map<String,Object> getRequestData(DataSource src) {
        /*
        ExternalObjectAction action = src.getAction('query');
        if (action == null) throw new StandardException('Could not find Stripe query action for ' + dfd.getExternalObject() + ' object');
        Map<String,Object> data = new Map<String,Object>();
        StripeQuery q = new StripeQuery();
        q.addCondition('amount', '>', 1000);
        q.addCondition('customer', '=', 'cus_Rs7xP84wr6CJPD');
        data.put('query', q.toString());
        List<String> expansions = q.getExpansions();
        if (expansions != null && !expansions.isEmpty()) {
            data.put('expand[]', expansions);
        }
        return data;
        */ return null;
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
        // headers.put('Authorization', 'Bearer ' + getApiKey(dfd));
        return headers;
    }

    private String getApiKey(DataSource src) {
        /*
        DataSourceInstance dsi = dfd.getDataSourceInstance();
        if (dsi == null) { throw new StandardException('Could not load data source instance from data flow definition'); }
        String apiKey = dsi.getApiSecret();
        if (String.isBlank(apiKey)) throw new StandardException('Data source instance does not have api key set');
        return apiKey;
        */ return null;
    }
}
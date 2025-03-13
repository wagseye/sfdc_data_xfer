public with sharing class StripeHandler extends ServiceHandler {

    public class StripeQuery extends Query {
        List<String> filters = new List<String>();

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

        public override String toString() {
            return String.join(filters, ' AND ');
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

    public override Map<String,Object> getRequestData(DataFlowDefinition dfd) {
        ExternalObjectAction action = dfd.getAction('query');
        if (action == null) throw new StandardException('Could not find Stripe query action for ' + dfd.getExternalObject() + ' object');
        Map<String,Object> data = new Map<String,Object>();
        StripeQuery q = new StripeQuery();
        q.addCondition('amount', '>', 1000);
        q.addCondition('customer', '=', 'cus_Rs7xP84wr6CJPD');
        data.put('query', q.toString());
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

    public override Query createQuery() {
        return new StripeQuery();
    }

    public override Map<String,String> getRequestHeaders(DataFlowDefinition dfd) {
        Map<String,String> headers = new Map<String,String>();
        headers.put('Content-Type', 'application/json');
        headers.put('Authorization', 'Bearer ' + getApiKey(dfd));
        return headers;
    }

    private String getApiKey(DataFlowDefinition dfd) {
        DataSourceInstance dsi = dfd.getDataSourceInstance();
        if (dsi == null) { throw new StandardException('Could not load data source instance from data flow definition'); }
        String apiKey = dsi.getApiSecret();
        if (String.isBlank(apiKey)) throw new StandardException('Data source instance does not have api key set');
        return apiKey;
    }
}
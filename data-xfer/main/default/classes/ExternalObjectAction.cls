public with sharing class ExternalObjectAction  extends ObjectWrapper {
    private final static Set<String> VALID_ACTIONS = new Set<String>{ 'get', 'query', 'create', 'update', 'delete' };

    public static String getActionName(ExternalObject obj, String actionName) {
        if ((obj == null) || String.isBlank(actionName)) throw new IllegalArgumentException('External object and action name must be provided');
        if (!VALID_ACTIONS.contains(actionName)) throw new IllegalArgumentException('Invalid action: ' + actionName);
        return String.format('{0}_{1}', new List<Object>{ obj.getApiName(), actionName });

    }

    public static ExternalObjectAction getRecordByName(String name) {
        if (String.isBlank(name)) throw new IllegalArgumentException('Name must be specified');
        Object_Action__mdt action = Object_Action__mdt.getInstance(name);
        if (action != null) return new ExternalObjectAction(action);
        return null;
    }

    public ExternalObjectAction(Object_Action__mdt action) {
        super(action);
    }

    public String getAction() { return (String)this.get('Action__c'); }
    public String getMethod() { return (String)this.get('Method__c'); }
    public String getPath() { return (String)this.get('Path__c'); }
}

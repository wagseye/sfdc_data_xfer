public with sharing class ExternalObjectAction  extends ObjectWrapper {
    private final static Set<String> VALID_ACTIONS = new Set<String>{ 'get', 'query', 'create', 'update', 'delete' };

    public virtual class Selector extends ObjectWrapper.Selector {
        public Selector() { super(ExternalObjectAction.class); }
        public virtual override SObject getInstance(String name) { return Object_Action__mdt.getInstance(name); }
    }

    public static String getActionName(ExternalObject obj, String actionName) {
        if ((obj == null) || String.isBlank(actionName)) throw new IllegalArgumentException('External object and action name must be provided');
        if (!VALID_ACTIONS.contains(actionName)) throw new IllegalArgumentException('Invalid action: ' + actionName);
        return String.format('{0}_{1}', new List<Object>{ obj.getName(), actionName });

    }

    public static ExternalObjectAction getRecordByName(String name) {
        return (ExternalObjectAction)ObjectWrapper.getInstance(new Selector(), name);
    }

    public ExternalObjectAction() {}
        public ExternalObjectAction(Object_Action__mdt action) {
        super(action);
    }

    public String getAction() { return (String)this.get('Action__c'); }
    public String getMethod() { return (String)this.get('Method__c'); }
    public String getPath() { return (String)this.get('Path__c'); }
}

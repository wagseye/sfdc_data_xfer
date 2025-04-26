@isTest
private class DataRecordTest {

    private static DataRecord getTestRecord() {
        return new DataRecord(getTestJson(), null, new RecordPath());
    }

    private static Map<String,Object> getTestJson() {
        return (Map<String,Object>)JSON.deserializeUntyped(getTestString());
    }

    private static String getTestString() {
        return '{' +
               '  "id": "in_1R5ufU2eZvKYlo2CViW9Gagx",' +
               '  "object": "invoice",' +
               '  "payment_settings": null,' +
               '  "lines": {' +
               '    "object": "list",' +
               '    "data": [' +
               '      {' +
               '        "id": "il_1R5ufU2eZvKYlo2CDZFovXVv",' +
               '        "object": "line_item",' +
               '        "parent": {' +
               '          "invoice_item_details": null,' +
               '          "subscription_item_details": {' +
               '            "subscription": "sub_1Qv2MW2eZvKYlo2C7bp37Db6",' +
               '            "subscription_item": "si_Rofhg8jLplNMT3"' +
               '          },' +
               '          "type": "subscription_item_details"' +
               '  }}]},' +
               '  "parent": {' +
               '    "subscription_details": {' +
               '      "metadata": {' +
               '        "Vehicles": "33333333-3333-3333-3333-333333333333"' +
               '      },' +
               '      "subscription": "sub_1Qv2MW2eZvKYlo2C7bp37Db6",' +
               '      "items": {' +
               '        "object": "list",' +
               '        "data": [' +
               '          { "name": "item1" },' +
               '          { "name": "item2" },' +
               '          { "name": "item3" }' +
               '    ]}},' +
               '    "type": "subscription_details"' +
               '}}}';
    }

    @isTest
    static void testGetChild() {
        DataRecord rec = getTestRecord();

        // First get a top level child
        DataRecord child = rec.getChild('parent');
        System.assertNotEquals(null, child);
        String childType = child.getString('type');
        System.assertEquals('subscription_details', childType);

        // Next get a child of the child
        child = child.getChild('subscription_details');
        System.assertNotEquals(null, child);
        System.assert(String.isNotBlank(child.getString('subscription')));

        // Get the grandchild directly
        child = rec.getChild('parent.subscription_details.metadata');
        System.assertNotEquals(null, child);
        System.assert(String.isNotBlank(child.getString('Vehicles')));

        // Get a null child
        child = rec.getChild('payment_settings');
        System.assertEquals(null, child);

        // Attempt to get a nonexistent child
        Boolean isError = false;
        try {
            child = rec.getChild('no_child');
        } catch (Exception ex) { isError = true; }
        System.assert(isError, 'No exception thrown');
    }

    @isTest
    static void testGetChildren() {
        DataRecord rec = getTestRecord();

        // First get a top level child (though it's still under "data")
        List<DataRecord> children = rec.getChildren('lines.data');
        System.assertNotEquals(null, children);
        System.assertEquals(1, children.size());
        System.assertEquals('line_item', children[0].getString('object'));

        // Get a deeply nested child
        children = rec.getChildren('parent.subscription_details.items.data');
        System.assertNotEquals(null, children);
        System.assertEquals(3, children.size());
        System.assertEquals('item1', children[0].getString('name'));
        System.assertEquals('item2', children[1].getString('name'));
        System.assertEquals('item3', children[2].getString('name'));

        // Get a null child (in this case there's no distinction if it is a list)
        children = rec.getChildren('payment_settings');
        System.assertEquals(null, children);

        // Attempt to get a nonexistent child
        Boolean isError = false;
        try {
            children = rec.getChildren('no_child');
        } catch (Exception ex) { isError = true; }
        System.assert(isError, 'No exception thrown');
    }
}
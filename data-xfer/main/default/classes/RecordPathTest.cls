@isTest
private class RecordPathTest {

    @isTest
    static void testIsValidPath() {
        System.assertEquals(true,  RecordPath.isValidPath('abc', '.'));
        System.assertEquals(true,  RecordPath.isValidPath('a-b-c', '.'));
        System.assertEquals(true,  RecordPath.isValidPath('a_b-c', '.'));
        System.assertEquals(false, RecordPath.isValidPath('abc.', '.'));
        System.assertEquals(false, RecordPath.isValidPath('.abc', '.'));
        System.assertEquals(true,  RecordPath.isValidPath('abc.def', '.'));
        System.assertEquals(false, RecordPath.isValidPath('abc\\.def', '.'));
        System.assertEquals(true,  RecordPath.isValidPath('abc.123', '.'));
        System.assertEquals(true,  RecordPath.isValidPath('abc.123.DEF', '.'));
        System.assertEquals(false, RecordPath.isValidPath('abc.123.DEF.', '.'));
        System.assertEquals(true,  RecordPath.isValidPath('a_c.1-3.D_F', '.'));
        System.assertEquals(false, RecordPath.isValidPath('abc*def', '.'));

        System.assertEquals(true,  RecordPath.isValidPath('abc', '='));
        System.assertEquals(false, RecordPath.isValidPath('abc=', '='));
        System.assertEquals(false, RecordPath.isValidPath('=abc', '='));
        System.assertEquals(true,  RecordPath.isValidPath('abc=def', '='));
        System.assertEquals(true,  RecordPath.isValidPath('abc=123', '='));
        System.assertEquals(true,  RecordPath.isValidPath('abc=123=DEF', '='));
        System.assertEquals(false, RecordPath.isValidPath('abc=123=DEF=', '='));
    }

    @isTest
    static void testConstructors() {
        RecordPath path = new RecordPath();
        System.assertEquals('', path.toString());
        System.assertEquals('.', path.delimiter);

        path = new RecordPath('abc');
        System.assertEquals('abc', path.toString());
        System.assertEquals('.', path.delimiter);

        path = new RecordPath('abc', '=');
        System.assertEquals('abc', path.toString());
        System.assertEquals('=', path.delimiter);

        RecordPath path2 = new RecordPath(path);
        System.assertEquals('abc', path2.toString());
        System.assertEquals('=', path2.delimiter);

        path = new RecordPath(null, '=');
        System.assertEquals('', path.toString());
        System.assertEquals('=', path.delimiter);

        Boolean isError = false;
        try {
            path = new RecordPath('abc', null);
        } catch (Exception ex) { isError = true; }
        System.assertEquals(true, isError, 'Expected exception to be thrown but none caught');
    }

    @isTest
    static void testGetElements() {
        RecordPath path = new RecordPath('abc.d-f.g_i');
        List<String> elements = path.getElements();
        System.assertEquals(3, elements.size());
        System.assertEquals('abc', elements[0]);
        System.assertEquals('d-f', elements[1]);
        System.assertEquals('g_i', elements[2]);

        path = new RecordPath('abc=d-f=g_i', '=');
        elements = path.getElements();
        System.assertEquals(3, elements.size());
        System.assertEquals('abc', elements[0]);
        System.assertEquals('d-f', elements[1]);
        System.assertEquals('g_i', elements[2]);
    }

    @isTest
    static void testEditEnd() {
        RecordPath path = new RecordPath('');
        path.addToEnd('abc');
        System.assertEquals('abc', path.toString());
        String value = path.removeFromEnd();
        System.assertEquals('abc', value);
        System.assertEquals('', path.toString());

        path = new RecordPath('abc');
        path.addToEnd('def');
        System.assertEquals('abc.def', path.toString());
        value = path.removeFromEnd();
        System.assertEquals('def', value);
        System.assertEquals('abc', path.toString());

        path = new RecordPath('abc.def');
        path.addToEnd('ghi');
        System.assertEquals('abc.def.ghi', path.toString());
        value = path.removeFromEnd();
        System.assertEquals('ghi', value);
        System.assertEquals('abc.def', path.toString());

        // Run it all the way down to empty
        value = path.removeFromEnd();
        System.assertEquals('def', value);
        System.assertEquals('abc', path.toString());
        value = path.removeFromEnd();
        System.assertEquals('abc', value);
        System.assertEquals('', path.toString());
        value = path.removeFromEnd();
        System.assertEquals(null, value);
        System.assertEquals('', path.toString());

        path = new RecordPath('abc.def.ghi.jkl');
        Boolean isError = false;
        try {
            path.removeFromEnd(new RecordPath('abc'));
        } catch (Exception ex) { isError = true; }
        System.assertEquals(true, isError);
        System.assertEquals('abc.def.ghi', path.removeFromEnd(new RecordPath('jkl')).toString());
        System.assertEquals('abc.def', path.removeFromEnd(new RecordPath('ghi.jkl')).toString());
        System.assertEquals('abc', path.removeFromEnd(new RecordPath('def.ghi.jkl')).toString());
        System.assertEquals('', path.removeFromEnd(new RecordPath('abc.def.ghi.jkl')).toString());
    }

    @isTest
    static void testEditStart() {
        RecordPath path = new RecordPath('');
        path.addToStart('abc');
        System.assertEquals('abc', path.toString());
        String value = path.removeFromStart();
        System.assertEquals('abc', value);
        System.assertEquals('', path.toString());


        path = new RecordPath('abc');
        path.addToStart('def');
        System.assertEquals('def.abc', path.toString());
        value = path.removeFromStart();
        System.assertEquals('def', value);
        System.assertEquals('abc', path.toString());

        path = new RecordPath('abc.def');
        path.addToStart('ghi');
        System.assertEquals('ghi.abc.def', path.toString());
        value = path.removeFromStart();
        System.assertEquals('ghi', value);
        System.assertEquals('abc.def', path.toString());

        // Run it all the way down to empty
        value = path.removeFromStart();
        System.assertEquals('abc', value);
        System.assertEquals('def', path.toString());
        value = path.removeFromStart();
        System.assertEquals('def', value);
        System.assertEquals('', path.toString());
        value = path.removeFromStart();
        System.assertEquals(null, value);
        System.assertEquals('', path.toString());

        path = new RecordPath('abc.def.ghi.jkl');
        Boolean isError = false;
        try {
            path.removeFromStart(new RecordPath('jkl'));
        } catch (Exception ex) { isError = true; }
        System.assertEquals(true, isError);
        System.assertEquals('def.ghi.jkl', path.removeFromStart(new RecordPath('abc')).toString());
        System.assertEquals('ghi.jkl', path.removeFromStart(new RecordPath('abc.def')).toString());
        System.assertEquals('jkl', path.removeFromStart(new RecordPath('abc.def.ghi')).toString());
        System.assertEquals('', path.removeFromStart(new RecordPath('abc.def.ghi.jkl')).toString());
    }

    @isTest
    static void testEqualsAndHashCode() {
        RecordPath p1 = new RecordPath('abc.def.ghi');
        RecordPath p2 = new RecordPath('abc.def.ghi');
        RecordPath p3 = new RecordPath('abc.de.fghi');
        System.assert(p1.equals(p2));
        System.assert(p2.equals(p1));
        System.assert(!p1.equals(p3));
        System.assert(!p3.equals(p1));
        System.assert(!p2.equals(p3));
        System.assert(!p3.equals(p2));
        System.assert(p1.equals('abc.def.ghi'));
        System.assert(!p1.equals('abc.de.fghi'));

        System.assertEquals(p1.hashCode(), p2.hashCode());
        System.assertNotEquals(p1.hashCode(), p3.hashCode());
        System.assertNotEquals(p2.hashCode(), p3.hashCode());

        Map<RecordPath,String> testMap = new Map<RecordPath,String>();
        testMap.put(p1, 'test');
        System.assertEquals(1, testMap.size());
        System.assertEquals('test', testMap.get(p1));
        System.assertEquals('test', testMap.get(p2));

        testMap.put(p2, 'test');
        System.assertEquals(1, testMap.size());
        System.assertEquals('test', testMap.get(p1));
        System.assertEquals('test', testMap.get(p2));

        testMap.put(p3, 'test2');
        System.assertEquals(2, testMap.size());
        System.assertEquals('test', testMap.get(p1));
        System.assertEquals('test', testMap.get(p2));
        System.assertEquals('test2', testMap.get(p3));

        testMap.remove(p1);
        System.assertEquals(1, testMap.size());
        System.assertEquals(null, testMap.get(p1));
        System.assertEquals(null, testMap.get(p2));
        System.assertEquals('test2', testMap.get(p3));
    }
}

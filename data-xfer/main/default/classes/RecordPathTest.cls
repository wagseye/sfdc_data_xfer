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
    static void testAppend() {
        RecordPath path = new RecordPath('');
        path.append('abc');
        System.assertEquals('abc', path.toString());

        path = new RecordPath('abc');
        path.append('def');
        System.assertEquals('abc.def', path.toString());

        path = new RecordPath('abc.def');
        path.append('ghi');
        System.assertEquals('abc.def.ghi', path.toString());
    }

    @isTest
    static void testPrepend() {
        RecordPath path = new RecordPath('');
        path.prepend('abc');
        System.assertEquals('abc', path.toString());

        path = new RecordPath('abc');
        path.prepend('def');
        System.assertEquals('def.abc', path.toString());

        path = new RecordPath('abc.def');
        path.prepend('ghi');
        System.assertEquals('ghi.abc.def', path.toString());
    }
}

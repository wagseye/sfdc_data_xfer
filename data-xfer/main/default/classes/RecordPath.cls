public with sharing class RecordPath {
    // Static elements
    public static final String DEFAULT_DELIMITER = '.';

    public static Boolean isValidPath(String path, String delimiter) {
        if (String.isBlank(path)) return true; // Path can be empty (for now?)
        String pathPattern = String.format('[a-zA-Z0-9_\\-]+({0}[a-zA-Z0-9_\\-]+)*', new List<String>{ escapeDelimiter(delimiter) });
        return Pattern.matches(pathPattern, path);
    }

    private static String escapeDelimiter(String delimiter) {
        return (delimiter == '.') ? '\\.' : delimiter; // We might need to cover more cases if they come up
    }


    // Instance elements
    private String path { private get; private set; }
    public String delimiter { public get; private set {
        if (String.isBlank(value)) throw new StandardException('The delimiter can not be empty');
        this.delimiter = value;
    } } { this.delimiter = DEFAULT_DELIMITER; }

    public RecordPath() {}

    public RecordPath(String path) {
        if (!isValidPath(path, this.delimiter)) throw new StandardException('Path is not a valid format');
        this.path = path;
    }

    public RecordPath(String path, String delimiter) {
        if (!isValidPath(path, delimiter)) throw new StandardException('Path is not a valid format');
        this.delimiter = delimiter;
        this.path = path;
    }

    public RecordPath(RecordPath other) {
        if (!isValidPath(other.path, other.delimiter)) throw new StandardException('Path is not a valid format');
        this.path = other.path;
        this.delimiter = other.delimiter;
    }

    public override String toString() {
        if (String.isBlank(this.path)) return '';
        return this.path;
    }

    public Boolean equals(Object obj) {
        if (obj == null) return false;
        if (obj instanceOf String) {
            return this.path == (String)obj;
        }
        if (obj instanceof RecordPath) {
            return this.path == ((RecordPath)obj).path;
        }
        return false;
    }
    
    public override Integer hashCode() {
        return this.toString().hashCode();
    }

    public List<String> getElements() {
        if (String.isBlank(this.path)) return new List<String>();
        return this.path.split(escapeDelimiter(this.delimiter));
    }

    public void addToStart(String prefix) {
        if (String.isBlank(prefix)) throw new StandardException('String to prepend must be specified');
        if (prefix.indexOf(delimiter) >= 0 ) throw new StandardException('Elements must be prepended one at a time');
        List<String> elements = this.getElements();
        if (elements.isEmpty()) {
            elements.add(prefix);
        } else {
            elements.add(0, prefix);
        }
        this.path = String.join(elements, this.delimiter);
    }

    public String removeFromStart() {
        List<String> elements = this.getElements();
        if (elements.isEmpty()) return null;
        String element = elements.remove(0);
        this.path = String.join(elements, this.delimiter);
        return element;
    }

    // I do not like that even though these two functions have the same name, one mutates the instance while the other does not,
    // but I can't come up with a better name so I'm leaving it for now.
    public RecordPath removeFromStart(RecordPath otherPath) {
        // We can get around this, but it'll be a harder implementation (that we may or may not ever need)
        System.assertEquals(this.delimiter, otherPath.delimiter);

        if (String.isBlank(this.path)) {
            if (String.isBlank(otherPath.path)) throw new StandardException('No path set');
        } else {
            if (!this.path.startsWith(otherPath.path)) throw new StandardException('Parameter path () ' + otherPath.path + ' is not a prefix of this path (' + this.path + ')');
            if (!this.path.equals(otherPath.path)) {
                return new RecordPath(this.path.removeStart(otherPath.path + this.delimiter));
           }
        }
        return new RecordPath();
    }

    public void addToEnd(String suffix) {
        if (String.isBlank(suffix)) throw new StandardException('String to prepend must be specified');
        List<String> elements = this.getElements();
        elements.add(suffix);
        this.path = String.join(elements, this.delimiter);
    }

    public void addToEnd(RecordPath otherPath) {
        // This is a quick, basic implementation that probably has some edge cases which break...
        if (String.isNotBlank(this.path)) {
            this.path += this.delimiter + otherPath;
        } else {
            this.path = otherPath.toString();
        }
    }

    public String removeFromEnd() {
        List<String> elements = this.getElements();
        if (elements.isEmpty()) return null;
        String element = elements.remove(elements.size() - 1);
        this.path = String.join(elements, this.delimiter);
        return element;
    }

    // I do not like that even though these two functions have the same name, one mutates the instance while the other does not,
    // but I can't come up with a better name so I'm leaving it for now.
    public RecordPath removeFromEnd(RecordPath otherPath) {
        // We can get around this, but it'll be a harder implementation (that we may or may not ever need)
        System.assertEquals(this.delimiter, otherPath.delimiter);

        if (String.isBlank(this.path)) {
            if (String.isBlank(otherPath.path)) throw new StandardException('No path set');
        } else {
           if (!this.path.endsWith(otherPath.path)) throw new StandardException('Parameter path () ' + otherPath.path + ' is not a suffix of this path (' + this.path + ')');
           if (!this.path.equals(otherPath.path)) {
               return new RecordPath(this.path.removeEnd(this.delimiter + otherPath.path));
           }
        }
        return new RecordPath();
    }
}

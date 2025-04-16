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

    public List<String> getElements() {
        if (String.isBlank(this.path)) return new List<String>();
        return this.path.split(escapeDelimiter(this.delimiter));
    }

    public void prepend(String prefix) {
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

    public void append(String suffix) {
        if (String.isBlank(suffix)) throw new StandardException('String to prepend must be specified');
        if (suffix.indexOf(delimiter) >= 0 ) throw new StandardException('Elements must be appended one at a time');
        List<String> elements = this.getElements();
        elements.add(suffix);
        this.path = String.join(elements, this.delimiter);
    }
}

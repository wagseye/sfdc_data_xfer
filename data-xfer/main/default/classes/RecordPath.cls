public with sharing class RecordPath {
    // Static elements
    public static final String DEFAULT_DELIMITER = '.';

    public static Boolean isValidPath(String path) { return isValidPath(path, DEFAULT_DELIMITER); }
    public static Boolean isValidPath(String path, String delimiter) {
        if (String.isBlank(path)) return true; // Path can be empty (for now?)
        String pathPattern = String.format('[a-zA-Z0-9_\\-]+(\\[[0-9]*\\])?({0}[a-zA-Z0-9_\\-]+(\\[[0-9]*\\])?)*', new List<String>{ escapeDelimiter(delimiter) });
        return Pattern.matches(pathPattern, path);
    }

    private static String escapeDelimiter(String delimiter) {
        return (delimiter == '.') ? '\\.' : delimiter; // We might need to cover more cases if they come up
    }


    // Instance elements
    private String path { private get; private set {
        if (this.path != null) throw new StandardException('RecordPath objects are immutable');
        this.path = value;
    } }
    public String delimiter { public get; private set {
        if (this.delimiter != null) throw new StandardException('RecordPath objects are immutable');
        if (String.isBlank(value)) throw new StandardException('The delimiter can not be empty');
        this.delimiter = value;
    } }

    public RecordPath() { this.delimiter = DEFAULT_DELIMITER; }

    public RecordPath(String path) {
        if (!isValidPath(path, DEFAULT_DELIMITER)) throw new StandardException('Path is not a valid format');
        this.path = path;
        this.delimiter = DEFAULT_DELIMITER;
    }

    public RecordPath(String path, String delimiter) {
        if (!isValidPath(path, delimiter)) throw new StandardException('Path is not a valid format');
        this.delimiter = delimiter;
        this.path = path;
    }

    public RecordPath(RecordPath other) {
        if (other == null) throw new StandardException('A valid path must be provided');
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
    
    public Boolean isEmpty() { return String.isBlank(this.path); }
    public override Integer hashCode() {
        return this.toString().hashCode();
    }

    public Integer size() { return this.getElements().size(); }

    public List<String> getElements() {
        if (String.isBlank(this.path)) return new List<String>();
        return this.path.split(escapeDelimiter(this.delimiter));
    }

    public RecordPath setIndex(Integer idx) {
        if (idx < 0) throw new StandardException('Invalid index: ' + idx);
        Pattern indexPattern = Pattern.compile('^(.*)(\\[[0-9]*\\])$');
        Matcher mtchr = indexPattern.matcher(this.path);
        if (mtchr.matches()) {
            return new RecordPath(mtchr.group(1) + '[' + idx + ']', this.delimiter);
        } else {
            return new RecordPath(this.path + '[' + idx + ']', this.delimiter);
        }
    }

    public RecordPath addToStart(String prefix) {
        if (String.isBlank(prefix)) throw new StandardException('String to prepend must be specified');
        if (prefix.indexOf(delimiter) >= 0 ) throw new StandardException('Elements must be prepended one at a time');
        List<String> elements = this.getElements();
        if (elements.isEmpty()) {
            elements.add(prefix);
        } else {
            elements.add(0, prefix);
        }
        return new RecordPath(String.join(elements, this.delimiter), this.delimiter);
    }

    public RecordPath addToStart(RecordPath otherPath) {
        // This is a quick, basic implementation that probably has some edge cases which break...
        if ((otherPath != null) && !otherPath.isEmpty()) {
            if (String.isNotBlank(this.path)) {
                return new RecordPath(otherPath.path + this.delimiter + this.path, this.delimiter);
            } else {
                return otherPath; // Since instances are immutable they can be freely reused
            }
        }
        return this;
    }

    public RecordPath removeFromStart() {
        List<String> elements = this.getElements();
        if (elements.isEmpty()) return new RecordPath();
        elements.remove(0);
        return new RecordPath(String.join(elements, this.delimiter), this.delimiter);
    }

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

    public RecordPath addToEnd(String suffix) {
        if (String.isBlank(suffix)) throw new StandardException('String to prepend must be specified');
        List<String> elements = this.getElements();
        elements.add(suffix);
        RecordPath newPath = new RecordPath(String.join(elements, this.delimiter), this.delimiter);
        System.debug('newPath: ' + newPath.toString());
        return newPath;
        //return new RecordPath(String.join(elements, this.delimiter), this.delimiter);
    }

    public RecordPath addToEnd(RecordPath otherPath) {
        if ((otherPath != null) && !otherPath.isEmpty()) {
            // This is a quick, basic implementation that probably has some edge cases which break...
            if (String.isNotBlank(this.path)) {
                return new RecordPath(this.path + this.delimiter + otherPath.path, this.delimiter);
            } else {
                return otherPath; // Since instances are immutable they can be freely reused
            }
        }
        return this;
    }

    public RecordPath removeFromEnd() {
        List<String> elements = this.getElements();
        if (elements.isEmpty()) return new RecordPath();
        String element = elements.remove(elements.size() - 1);
        return new RecordPath(String.join(elements, this.delimiter), this.delimiter);
    }

    public RecordPath removeFromEnd(RecordPath otherPath) {
        // We can get around this, but it'll be a harder implementation (that we may or may not ever need)
        System.assertEquals(this.delimiter, otherPath.delimiter);

        if ((otherPath != null) && !otherPath.isEmpty()) {
            if (String.isBlank(this.path)) {
                throw new StandardException('Parameter path (' + otherPath.path + ') is not a suffix of this path (' + this.path + ')');
            } else {
                if (!this.path.endsWith(otherPath.path)) throw new StandardException('Parameter path (' + otherPath.path + ') is not a suffix of this path (' + this.path + ')');
                if (!this.path.equals(otherPath.path)) {
                    return new RecordPath(this.path.removeEnd(this.delimiter + otherPath.path));
                }
            }
        }
        return new RecordPath();
    }
}

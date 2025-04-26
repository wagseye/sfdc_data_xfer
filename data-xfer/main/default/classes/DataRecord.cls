public with sharing virtual class DataRecord {
    public DataRecord parent { public get{System.assert(false); return null; } private set; }
    public RecordPath path { public get; private set; }
    public Boolean isList { public get; private set; }
    private Map<String,Object> record;
    private List<DataRecord> children;

    public DataRecord(Object record, DataRecord parent, RecordPath path) {
        this.parent = parent;
        this.path = (path != null) ? path : new RecordPath();
        if (record instanceof List<Object>) {
            // If the record is an instance of a list, parse out the children
            this.isList = true;
            this.children = new List<DataRecord>();
            Integer idx = 0;
            for (Object child : (List<Object>)record) {
                if (!(child instanceof Map<String,Object>)) throw new StandardException('Unexpected list child type');
                DataRecord childRecord = new DataRecord((Map<String,Object>)child, this, this.path);
                this.children.add(childRecord);
                idx++;
            }
        } else if (record instanceof Map<String,Object>) {
            // If the record is an instance of a map, set it as the internal record
            this.isList = false;
            this.record = (Map<String,Object>)record;
        } else {
            // Otherwise we don't know what to do with the record, so throw an exception
            throw new StandardException('Unexpected record type');
        }
    }

    public DataRecord getChild(Integer idx) {
        System.assert(false); // TODO: Remove this line or the whole method
        if (!this.isList) throw new StandardException('This method can only be called on a list node');
        return this.children[idx];
    }

    public DataRecord getChild(RecordPath relativePath) {
        if (this.record == null) throw new StandardException('This method can not be used for list nodes');
        Object currRec = this.record;
        // Traverse down the tree based on the elements in the path
        for (String objName : relativePath.getElements()) {
            if (!(currRec instanceof Map<String,Object>)) throw new StandardException('Unexpected object found at ' + objName + ' in path ' + relativePath);
            Object childRec = ((Map<String,Object>)currRec).get(objName);
            if (childRec == null) return null;
            // It is valid for currRec to be a list if it is the last element in the path. If it's not the last element
            // the type check above will throw an error because getChild() can return a list but can't traverse over one.
            currRec = childRec;
        }
        if (currRec != null) {
            return new DataRecord(currRec, this, this.path.addToEnd(relativePath));
        }
        return null;
    }

    public List<DataRecord> getChildren() {
        if (!this.isList) throw new StandardException('This method can only be called on a list node');
        return this.children;
    }

    public void setPathIndex(Integer idx) {
        this.path = this.path.setIndex(idx);
    }

    public Object getValue(String fldName) {
        if (this.isList) throw new StandardException('This method can not be used for a list node');
        Object value = this.record.get(fldName);
        if (value instanceof Map<String,Object>) throw new StandardException('Value at ' + fldName + ' is a child object');
        if (value instanceof List<Object>) throw new StandardException('Value at ' + fldName + ' is a child list');
        return value;
    }

    // TODO: this method is a temporary solution, we need to figure out a better system
    public virtual String getString(String fldName) {
        return (String)this.record.get(fldName);
    }

    public virtual Object get(ExternalObjectField fld) {
        switch on fld.getType().toLowerCase() {
            when 'text' {
                return this.toText(null);
            }
            when else {
                throw new StandardException('Unrecognized field type: ' + fld.getType());
            }
        }
    }

    public virtual DataRecord getChild(String fldName) {
        if (String.isBlank(fldName)) throw new StandardException('A valid field name must be provided');
        List<String> fldComponents = fldName.split('\\.'); // String.split() uses regex so we need to escape the dot
        Map<String,Object> currentMap = this.record;
        for (String fldComponent : fldComponents) {
            if (!currentMap.containsKey(fldComponent)) throw new StandardException('Record does not contain the field "' + fldComponent + '"');
            Object value = currentMap.get(fldComponent);
            if (value == null) return null;
            if (!(value instanceof Map<String,Object>)) throw new StandardException('Child component ' + fldComponent + ' is not an object');
            currentMap = (Map<String,Object>)value;
        }
        return new DataRecord(currentMap, this, this.path.addToEnd(fldName));
    }

    public virtual List<DataRecord> getChildren(String fldName) {
        if (String.isBlank(fldName)) throw new StandardException('A valid field name must be provided');
        List<String> fldComponents = fldName.split('\\.'); // String.split() uses regex so we need to escape the dot
        Map<String,Object> currentMap = this.record;
        List<Map<String,Object>> childObjs;
        List<Object> listObjects;

        for (Integer i = 0; i < fldComponents.size(); i++) {
            String fldComponent = fldComponents[i];
            Boolean isLast = (i == (fldComponents.size() - 1));

            if (!currentMap.containsKey(fldComponent)) throw new StandardException('Record does not contain the field "' + fldComponent + '"');
            Object value = currentMap.get(fldComponent);
            if (value == null) return null;
            if (isLast) {
                if (!(value instanceof List<Object>)) throw new StandardException('Child component ' + fldComponent + ' is not a list of objects');
                listObjects = (List<Object>)value;
            } else {
                if (!(value instanceof Map<String,Object>)) throw new StandardException('Child component ' + fldComponent + ' is not an object');
                currentMap = (Map<String,Object>)value;
            }
        }
        if (listObjects != null) {
            List<DataRecord> children = new List<DataRecord>();
            for (Object obj : listObjects) {
                if (!(obj instanceof Map<String,Object>)) throw new StandardException('Child record is not a map');
                children.add(new DataRecord((Map<String,Object>)obj, this, this.path));
            } 
            return children;
        }
        return null;
    }

    public virtual void set(String fldName, Object value, String fieldType) {
        this.record.put(fldName, value);
    }

    public virtual String toText(Object value) {
        return (String)value;
    }
    public virtual Object fromText(String value) {
        return value;
    }


    public virtual Boolean toBoolean(Object value) {
        return (Boolean)value;
    }
    public virtual Object fromBoolean(Boolean value) {
        return value;
    }


    public virtual Integer toInteger(Object value) {
        return (Integer)value;
    }
    public virtual Object fromInteger(Integer value) {
        return value;
    }


    public virtual Decimal toDecimal(Object value) {
        return (Decimal)value;
    }
    public virtual Object fromDecimal(Decimal value) {
        return value;
    }


    public virtual String toReference(Object value) {
        return toText(value);
    }
    public virtual Object fromReference(String value) {
        return fromText(value);
    }


    public virtual Date toDate(Object value) {
        return (Date)value;
    }
    public virtual Object fromDate(Date value) {
        return value;
    }


    public virtual DateTime toDateTime(Object value) {
        return (DateTime)value;
    }
    public virtual Object fromDateTime(DateTime value) {
        return value;
    }


    public virtual Decimal toCurrency(Object value) {
        return this.toDecimal(value);
    }
    public virtual Object fromCurrency(Decimal value) {
        return this.fromDecimal(value);
    }
}
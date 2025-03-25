// TODO: this should eventually be made abstract
public with sharing virtual class DataRecord {
    private Map<String,Object> record;

    public DataRecord(Map<String,Object> record) {
        this.record = record;
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
        return new DataRecord(currentMap);
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
                children.add(new DataRecord((Map<String,Object>)obj));
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
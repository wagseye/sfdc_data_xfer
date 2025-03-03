// TODO: this should eventually be made abstract
public with sharing virtual class DataRecord {
    private Map<String,Object> record;

    public DataRecord(Map<String,Object> record) {
        this.record = record;
    }

    public virtual Object get(String fldName) {
        return this.record.get(fldName);
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
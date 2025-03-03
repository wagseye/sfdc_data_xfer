public with sharing class StripeRecord extends DataRecord {
    public StripeRecord(Map<String,Object> record) {
        super(record);
    }

    // Date/time values in Stripe are stored as posix-type timestamps based in seconds. Salesforce Datetime objects
    // expect timestamps in milliseconds, so we need to multiply these by 1000 to get the expected behavior
    public override DateTime toDateTime(Object value) {
        return DateTime.newInstance((Long)value * 1000);
    }
    public override Object fromDateTime(DateTime value) {
        return Integer.valueOf(value.getTime() / 1000);
    }


    // Date values in Stripe are stored as posix-type timestamps based in seconds. To pull a pure date value out of this,
    // we first convert it to a Datetime, then take only the Date portion of it. NB: this implementation below might have
    // issues with timezones. If dates appear to be off occasionally, that is probably what is happening
    public override Date toDate(Object value) {
        return DateTime.newInstance((Long)value * 1000).date();
    }
    public override Object fromDate(Date value) {
        return Integer.valueOf(DateTime.newInstance(value, Time.newInstance(0, 0, 0, 0)).getTime() / 1000);
    }

    // Currency values in Stripe are stored as integers representing the smallest unit of currency (e.g. cents for USD)
    // so we need to divide by 100 to get the value in USD. This will not work correctly for currencies like JPY and
    // may need to be revisited
    public override Decimal toCurrency(Object value) {
        Integer i;
        if (value instanceOf Integer) {
            i = (Integer)value;
        }
        else if (value instanceOf String) {
            i = Integer.valueOf((String)value);
        }
        if (i != null) {
            return Decimal.valueOf(i) / 100;
        }
        throw new IllegalArgumentException('Unable to convert value to Decimal: ' + value);
    }
    public override Object fromCurrency(Decimal value) {
        return Integer.valueOf(value * 100);
    }
}
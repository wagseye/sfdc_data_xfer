public with sharing class Settings
{
    public static String getStringValue(String settingName)
	{
        try {
			Setting_Value__c val = loadSettingRecord(settingName);
	        if (val.Type__c == 'String') return val.Value__c;
        } catch (Exception ex) {}
        return null;
	}

    public static void setStringValue(String settingName, String value)
    {
        setValue(settingName, 'String', value);
    }

	public static Integer getIntValue(String settingName)
    {
        try {
			Setting_Value__c val = loadSettingRecord(settingName);
        	if (val.Type__c == 'Integer') return Integer.valueOf(val.Value__c);
		} catch (Exception ex) {}
        return null;
    }

    public static void setIntValue(String settingName, Integer value)
    {
        setValue(settingName, 'Integer', String.valueOf(value));
    }

	public static Double getDoubleValue(String settingName)
    {
        try {
			Setting_Value__c val = loadSettingRecord(settingName);
        	if (val.Type__c == 'Double') return Double.valueOf(val.Value__c);
		} catch (Exception ex) {}
        return null;
    }

    public static void setDoubleValue(String settingName, Double value)
    {
        setValue(settingName, 'Double', String.valueOf(value));
    }

	public static Boolean getBoolValue(String settingName)
    {
        try {
			Setting_Value__c val = loadSettingRecord(settingName);
        	if (val.Type__c == 'Boolean') return Boolean.valueOf(val.Value__c);
		} catch (Exception ex) {}
        return null;
    }

    public static void setBoolValue(String settingName, Boolean value)
    {
        setValue(settingName, 'Boolean', String.valueOf(value));
    }

	public static Date getDateValue(String settingName)
    {
        try {
			Setting_Value__c val = loadSettingRecord(settingName);
        	if (val.Type__c == 'Date') return Date.valueOf(val.Value__c);
		} catch (Exception ex) {}
        return null;
    }

    public static void setDateValue(String settingName, Date value)
    {
        setValue(settingName, 'Date', String.valueOf(value));
    }

	public static DateTime getDateTimeValue(String settingName)
    {
        try {
			Setting_Value__c val = loadSettingRecord(settingName);
        	if (val.Type__c == 'DateTime') return DateTime.valueOf(val.Value__c);
		} catch (Exception ex) {}
        return null;
    }

    public static void setDateTimeValue(String settingName, DateTime value)
    {
        setValue(settingName, 'DateTime', String.valueOf(value));
    }

	public static void deleteValue(String settingName)
    {
        Setting_Value__c val = loadSettingRecord(settingName);
        if (val != null) delete val;
    }

    private static void setValue(String settingName, String settingType, String value)
    {
        // Check that the type is supported
        if ((settingType == null) || !(new Set<String>{ 'String', 'Integer', 'Double', 'Boolean', 'Date', 'DateTime' }.contains(settingType)))
        {
            throw new System.IllegalArgumentException('Invalid type: ' + settingType);
        }

        Setting_Value__c val = loadSettingRecord(settingName);
        if (val == null)
        {
            val = new Setting_Value__c(Name = settingName, Type__c = settingType);
        }
        val.Value__c = value;
        upsert val;
    }

    private static Setting_Value__c loadSettingRecord(String settingName)
	{
        Setting_Value__c val = Setting_Value__c.getInstance(settingName);
        if (val.Active__c) return val;
        return null;
    }
}
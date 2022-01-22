public inherited sharing class CustomSettingsUtilities implements VlocityOpenInterface, Callable {
        private static final String FIX_TOGGLE_SETTING = 'FixToggleList';
        public static Boolean isFixToggleOn(String issueNumber)
        {
                if(String.isEmpty(issueNumber))
                        return false;

                String toggleSettings = getGeneralSettings(FIX_TOGGLE_SETTING);

                if(String.isEmpty(toggleSettings))
                        return false;

                List<String> issueList = toggleSettings.split(',');
                Set<String> issueSet = new Set<String>();
                for ( String s : issueList)
                {
                        if (issueNumber.equalsIgnoreCase(s))
                                return true;
                }
                return false;
        }


    public static List<String> getClassImplementationNamesByInterfaceName(String interfaceName) {

        List<String> implementationClassNames = new List<String>();
        List<InterfaceImplementation__c> interfaceImplementationList =
            [SELECT Id, Name FROM InterfaceImplementation__c WHERE Name=:interfaceName];

        if ( interfaceImplementationList.size()<1 ) {
            return implementationClassNames;
        }

        InterfaceImplementation__c interfaceImplementation = interfaceImplementationList[0];

        List<InterfaceImplementationDetail__c> implementationDetailList =
            [SELECT Id, Name, IsActive__c, IsDefault__c, InterfaceName__c FROM InterfaceImplementationDetail__c WHERE InterfaceId__c=:interfaceImplementation.Id];

        for ( InterfaceImplementationDetail__c implementationDetail : implementationDetailList ) {
            // validate the InterfaceImplementation before returning them
            try {
                Type t = Type.forName(implementationDetail.Name);

                if ( t==null ) {
                    continue;
                }

                Logger.dbg('T value:'+t);
                Object impl = (Object)t.newInstance();

                implementationClassNames.add(implementationDetail.Name);

            } catch ( Exception ex ) {
                Logger.err(ex);
            }
        }

        return implementationClassNames;
    }

    static Map<String, String> customClassImplementations = new Map<String, String>();

        public static String getCustomClassImplemenationName(String settingName) {

                if (!customClassImplementations.containsKey(settingName))
                {
                        Logger.err('Inside getCustomClassImplementation ');

                        CustomClassImplementation__c customSetting = CustomClassImplementation__c.getInstance(settingName);
                        String retval = null;
                        //system.debug(':::customSetting: ' + customSetting);
                        if (customSetting != null
                                //expected condition: there is a Custom Setting
                                && customSetting.ClassName__c != null
                                && customSetting.ClassName__c.length() > 0) {
                                retval = customSetting.ClassName__c;
                                //system.debug(':::retval1: ' + retval);

                        } else {
                                String str = settingName.replaceAll(' ', '');
                                retval = 'Default' + str + 'Implementation';

                                try {
                                        Type t = Type.forName(retval);
                                        Logger.dbg('T value:' + t);
                                        Object impl = (Object)t.newInstance();
                                } catch (Exception e) {
                                        Logger.dbg('!! No implementation for Interface Name '+ settingName + 'Interface ' );
                                        Logger.dbg(e.getStackTraceString());
                                        /* !!!!!!!!!!!!!! NO NEED TO QUERY  implementation
                                                // check to see if there is an ImplementationDetail marked as Default
                                                String interName = settingName + 'Interface';

                                                String query = 'SELECT Name FROM InterfaceImplementationDetail__c ' +
                                                               ' WHERE InterfaceName__c = \'' + interName + '\' and isDefault__c = true and isActive__c = true limit 1';

                                                List<SObject> impDetl = Database.query(query);

                                                if (impDetl.size() > 0) {
                                                        retval = String.valueOf( impDetl[0].get('Name') ); //impDetl[0].Name;
                                                        Logger.dbg(':::retval : ' + retval);
                                                }
                                                */
                                }
                        }

                        customClassImplementations.put(settingName, retVal);
                }

                return customClassImplementations.get(settingName);
        }

        public static String getCpqConfigurationSetupValue(String setupName) {
                CpqConfigurationSetup__c cpqSetup = CpqConfigurationSetup__c.getInstance(setupName);
                String retval = null;
                if (cpqSetup != null
                        //expected condition: there is a Custom Setting
                        && cpqSetup.SetupValue__c != null
                        && cpqSetup.SetupValue__c.length() > 0) {
                        retval = cpqSetup.SetupValue__c;

                }
                return retval;
        }

        public static Boolean getCpqConfigurationSetupBooleanValue(String setupName, Boolean defaultValue)
        {
            String valueString = getCpqConfigurationSetupValue(setupName);

            if (String.isEmpty(valueString))
            {
                return defaultValue;
            }

            return Boolean.valueOf(valueString);
        }

        public static String getRelationshipGraphConfigurationSetupValue(String setupName)
        {
            RelationshipGraphConfigurationSetup__c relGraphSetup = RelationshipGraphConfigurationSetup__c.getInstance(setupName);
            String retval = null;
            if (relGraphSetup != null && relGraphSetup.SetupValue__c != null && relGraphSetup.SetupValue__c.length() > 0) 
            {
                retval = relGraphSetup.SetupValue__c;
            }
            return retval;
        }

        public static String getGeneralSettings(String keyName) {
                GeneralSettings__c genSetup = GeneralSettings__c.getInstance(keyName);
                String retval = null;
                if (genSetup != null
                        //expected condition: there is a Custom Setting
                        && genSetup.Value__c != null
                        && genSetup.Value__c.length() > 0) {
                        retval = genSetup.Value__c;

                }
                return retval;
        }

        public static String getProductManagementSettings(String keyName) {
                ProductManagementConfiguration__c settings = ProductManagementConfiguration__c.getInstance(keyName);
                String retval = null;
                if (settings != null && settings.Value__c != null && settings.Value__c.length() > 0) {
                        retval = settings.Value__c;
                }
                return retval;
        }

        /*check the status of a feature trigger
         @param handler the handler class instance
         @param featureName the feature name to check
         @return the feature trigger setting
          eg .
          if the trigger name is "PartyTriggerHandler" & featureName is "EnablePartyModel"
          the custom Setting will be Party.EnablePartyModel

          */
        public static Boolean isFeatureTriggerOn(ITrigger handler, String featureName) {
                String className = String.valueOf(handler).substring(0, String.valueOf(handler).indexOf(':'));
                className = className.replace('TriggerHandler', '');
                return getTriggerStatus(className + '.' + featureName);
        }
        /* different form ,using String Object.FeatureName
                eg  Party.EnablePartyModel
         CORE-742*/
        public static Boolean isFeatureTriggerOn(String featureName) {
                return getTriggerStatus(featureName);
        }

        //check if a trigger setup instance exists and it's value
        //@param the instance name
        //@return the instance status
        public static Boolean getTriggerStatus(String settingName) {
                TriggerSetup__c customSetting = TriggerSetup__c.getInstance(settingName);
                Boolean retval = false;
                if (customSetting != null
                        && customSetting.IsTriggerOn__c != null) {
                        retval = customSetting.IsTriggerOn__c;
                } else {
                        retval = false; // CORE-742 : by default feature settings should be FAlse
                }

                return retval;
        }

        public static Boolean invokeOpenImplementation( String settingName,
                                                                                                        String mthdName,
                                                                                                Map<String, Object> input,
                                                                                                Map<String, Object> output,
                                                                                                Map<String, Object> options
                                                      ) {
                String clazzName = getCustomClassImplemenationName(settingName);
                Type t = Type.forName(clazzName );
                String message;
                Boolean retStat = false;
                Logger.dbg('invokeImplementation for : ' + clazzName);
                if (t == null) {
                        Logger.err('Type is null');
                        message = constructInvalidClassMessage( clazzName ,settingName);
                        Logger.err(new InvalidImplementationException(message));
                        try {
                                 Logger.dbg(message);
                        } catch (System.FinalException exc51) {
                                // This won't actually cantch this exception for some very annoying reason.
                        }
                        return false;
                }
                try {
                        VlocityOpenInterface voi = (VlocityOpenInterface)t.newInstance();
                        retStat = voi.invokeMethod(mthdName, input, output, options);
                        message = (String)output.get('errMessage');

                } catch (Exception e) {
                        message = constructErrorInClassMessage( clazzName ,mthdName);
                        Logger.err(new InvalidImplementationException(message));
                        try {

                        } catch (System.FinalException e2) {

                        }
                        throw e;
                }
                return retStat;
        }


        public static String constructInvalidClassMessage(String token1, String token2) {
                String message = Label.InvalidCustomSetting;
                Map<String, String> tokens = new Map<String, String>();
                tokens.put('{1}', token1);
                tokens.put('{2}', token2);
                String formattedMessage = message;
                for (String token : tokens.keySet()) {
                        formattedMessage = formattedMessage.replace(token, tokens.get(token));
                }
                return formattedMessage;
        }

        public static String constructErrorInClassMessage(String token1, String token2) {
                String message = Label.ErrorInImplementation;
                Map<String, String> tokens = new Map<String, String>();
                tokens.put('{1}', token1);
                tokens.put('{2}', token2);

                String formattedMessage = message;
                for (String token : tokens.keySet()) {
                        formattedMessage = formattedMessage.replace(token, tokens.get(token));
                }
                return formattedMessage;
        }

        public class InvalidImplementationException extends Exception {
        }

        public Boolean invokeMethod(String methodName,Map<String,Object> inputs, Map<String,Object> output, Map<String,Object> options)
        {
                List<String> customClassImplemenationName = new List<String>();
                if(methodName == 'getClassImplementationNamesByInterfaceName')
                {
                        customClassImplemenationName = getClassImplementationNamesByInterfaceName((String)inputs.get('interfaceName'));
                        output.put('customClassImplemenationName', customClassImplemenationName[0]);
                }
                if(methodName == 'getCustomClassImplemenationName') {
                output.put('customClassImplemenationName', getCustomClassImplemenationName((String)inputs.get('interfaceName')));
                }
                return true;
        }

        public Object call(String action, Map<String,Object> args)
	{
		Map<String,Object> inputMap = (Map<String,Object>)args.get('input');
		Map<String,Object> outMap = (Map<String,Object>)args.get('output');
		Map<String,Object> options = (Map<String,Object>)args.get('options');

		return invokeMethod(action, inputMap, outMap, options);
	}
}
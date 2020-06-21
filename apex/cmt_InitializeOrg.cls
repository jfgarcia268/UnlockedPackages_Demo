// Reset Interface Implementation
vlocity_cmt.TelcoAdminConsoleController telcoAdminConsoleController = new vlocity_cmt.TelcoAdminConsoleController();
telcoAdminConsoleController.setParameters('{"methodName":"resetInterfaceImplementations"}');
telcoAdminConsoleController.invokeMethod();

telcoAdminConsoleController.setParameters('{"methodName":"createDefaultPricingVariables"}');
telcoAdminConsoleController.invokeMethod();

// Add CPQ Configuration Setup for Default Pricing Plan
if (vlocity_cmt__CpqConfigurationSetup__c.getInstance('DefaultPricingPlan') == null) 
{
    insert new vlocity_cmt__CpqConfigurationSetup__c(Name = 'DefaultPricingPlan', vlocity_cmt__SetupValue__c = 'DEFAULT_PRICING_PLAN');
}

// Ensure Offering Procedure Records Exist
Set<String> names = new Set<String>();
for (vlocity_cmt__OfferingProcedure__c off : [ Select Name from vlocity_cmt__OfferingProcedure__c ])
{
    names.add(off.Name);
}

Set<String> defaultTypes = new Set<String>{ 'Includes', 'Excludes' };
    
for (String typeName : defaultTypes)
{
    if (!names.contains(typeName))
    {
        insert new vlocity_cmt__OfferingProcedure__c(Name = typeName, vlocity_cmt__Type__c = typeName);
    }
}
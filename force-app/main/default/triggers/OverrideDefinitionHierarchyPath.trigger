trigger OverrideDefinitionHierarchyPath on vlocity_cmt__OverrideDefinition__c (before insert) 
{
    VlocityHierarchyPathTriggerUtility.onNewRecordTriggerHandler(Trigger.new);
}
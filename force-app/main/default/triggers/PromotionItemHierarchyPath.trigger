trigger PromotionItemHierarchyPath on vlocity_cmt__PromotionItem__c (before insert) 
{
    VlocityHierarchyPathTriggerUtility.onNewRecordTriggerHandler(Trigger.new);
}
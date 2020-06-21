public class VlocityHierarchyPathTriggerUtility 
{
    public static void onNewRecordTriggerHandler(List<SObject> allRecords)
    {
        List<SObject> withGlobalKeyPath = new List<SObject>();
        List<SObject> withoutGlobalKeyPath = new List<SObject>();
        
        for (SObject obj : allRecords)
        {
            try 
            {
                if (String.isNotBlank((String)obj.get('GlobalKeysPathCustom__c')))
                {
                    withGlobalKeyPath.add(obj);
                }
                else if (String.isNotBlank((String)obj.get('vlocity_cmt__ProductHierarchyPath__c')))
                {
                    withoutGlobalKeyPath.add(obj);
                }
            }
            catch (Exception e)
            {
                System.debug(LoggingLevel.ERROR, e.getmessage());
            }
        }
         
        if (withGlobalKeyPath.size() > 0)
        {
            buildHierarchyKeysPath(withGlobalKeyPath);
        }
            
        if (withoutGlobalKeyPath.size() > 0)
        {
            buildGlobalKeysPath(withoutGlobalKeyPath);        
        }
    }

    public static void buildGlobalKeysPath(List<SObject> objectsWithHierarchy)
    {
        Set<String> productIds = new Set<String>();

        for (SObject objWithHierarchy : objectsWithHierarchy)
        {
            productIds.addAll(((String)objWithHierarchy.get('vlocity_cmt__ProductHierarchyPath__c')).split('<'));
        }

        Map<Id, String> idToKey = new Map<Id, String>();

        for (Product2 product : [SELECT vlocity_cmt__GlobalKey__c, Id FROM Product2 WHERE Id IN :productIds])
        {
            idToKey.put(product.Id, product.vlocity_cmt__GlobalKey__c);
        }

        for (SObject objWithHierarchy : objectsWithHierarchy)
        {
            String prodHierarchyPath = (String)objWithHierarchy.get('vlocity_cmt__ProductHierarchyPath__c');
            List<String> productIdsInPath = prodHierarchyPath.split('<');
            List<String> globalKeysForPath = new List<String>();

            Boolean invalidIdsInHierarchy = false;

            String error = 'Cannot Build due to Missing Ids:'; 

            for (String productId : productIdsInPath)
            {
                if (idToKey.containsKey(productId))
                {
                    globalKeysForPath.add(idToKey.get(productId));
                }
                else 
                {
                    invalidIdsInHierarchy = true;
                    error += ' ' + productId;
                }
            }

            if (!invalidIdsInHierarchy)
            {
                //globalKeys path to be add
                objWithHierarchy.put('GlobalKeysPathCustom__c', String.join(globalKeysForPath, '<'));
            }
            else
            {
                objWithHierarchy.put('GlobalKeysPathCustom__c', error);
            }
        }
    }

    public static void buildHierarchyKeysPath(List<SObject> objectsWithHierarchy)
    {
        Set<String> globalKeys = new Set<String>();

        for (SObject objWithHierarchy : objectsWithHierarchy)
        {
            String globalKeysPath = (String)objWithHierarchy.get('GlobalKeysPathCustom__c');
            globalKeys.addAll(globalKeysPath.split('<'));
        }

        Map<String, String> globalKeysToNewId = new Map<String, String>();

        for (Product2 product : [ SELECT Id, vlocity_cmt__GlobalKey__c FROM Product2 WHERE vlocity_cmt__GlobalKey__c IN :globalKeys ])
        {
            globalKeysToNewId.put(product.vlocity_cmt__GlobalKey__c, product.Id);
        }

        for (SObject objWithHierarchy : objectsWithHierarchy)
        {
            String globalKeysPath = (String)objWithHierarchy.get('GlobalKeysPathCustom__c');

            List<String> globalKeysList = globalKeysPath.split('<');
            List<String> newProductIds = new List<String>();
            
            Boolean missingReferencedKey = false;

            for (String globalKey : globalKeysList)
            {
                if (globalKeysToNewId.containsKey(globalKey))
                {
                    newProductIds.add(globalKeysToNewId.get(globalKey));
                }
                else
                {
                    missingReferencedKey = true;
                }
            }

            if (!missingReferencedKey)
            {
                objWithHierarchy.put('vlocity_cmt__ProductHierarchyPath__c', String.join(newProductIds, '<'));
            }   
        }
    }
}
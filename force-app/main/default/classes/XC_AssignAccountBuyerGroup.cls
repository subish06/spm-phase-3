public without sharing class XC_AssignAccountBuyerGroup {
    public static void assignBuyerGroup(Map<String,Object> accountMap){
        Set<String> accountIds = accountMap.keySet();
        Set<String> existingBuyerAccount = getExistingBuyerAccount(accountIds);
        checkCreateBuyerAccount(accountMap, existingBuyerAccount);
        Set<String> existingBuyerGroupMembers = getExistingBuyerGroupMember(accountIds);
        Map<String,String> buyerGroupMap = getBuyerGroupInfo();
        Set<String> newBuyerMemberSet = new Set<String>();
        Map<String,String> nameMapping = new Map<String,String>{
            'Acoustic' => 'Gibson Acoustic',
            'Custom' => 'Gibson Custom',
            'USA' => 'Gibson USA',
            'Lifestyle / Accessories' => 'Lifestyle & Accessories'
        };

        for(String s : accountMap.keySet()){
            Map<String,String> accountInfo = (Map<String,String>) accountMap.get(s);
            String entity = accountInfo.get('entity');
            String priceGroup = accountInfo.get('priceGroup');
            String accountId = s;

            if(entity.contains(';')){
                List<String> entityList = entity.split(';');
                for(String str : entityList){
                    String entityName = (nameMapping.containsKey(str) ? nameMapping.get(str) : str);

                    String buyerGroupName = (priceGroup == 'GC' ? 'Guitar Center' : str + ' - ' + priceGroup);
                    if(buyerGroupMap.containsKey(buyerGroupName)){
                        String buyerGroupMemberId = accountId + '_' + buyerGroupMap.get(buyerGroupName);
                        if(!existingBuyerGroupMembers.contains(buyerGroupMemberId)){
                            newBuyerMemberSet.add(buyerGroupMemberId);
                        }

                    }
                }
            }

        }

        if(newBuyerMemberSet.size()>0){
            createBuyerGroupMember(newBuyerMemberSet);
        }

    }

    public static void createBuyerGroupMember(Set<String> newBuyerMemberSet){
        List<BuyerGroupMember> bgms = new List<BuyerGroupMember>();

        for(String s : newBuyerMemberSet){
            List<String> buyerInfo = s.split('_');
            String buyerId = buyerInfo[0];
            String buyerGroupId = buyerInfo[1];

            BuyerGroupMember bgm = new BuyerGroupMember( 
                BuyerId = buyerId,
                BuyerGroupId = buyerGroupId
            );

            bgms.add(bgm);
        }

        insert bgms;
    }

    public static Map<String,String> getBuyerGroupInfo(){
        List<BuyerGroup> bgs = [SELECT Id, Name FROM BuyerGroup];
        Map<String,String> resultMap = new Map<String,String>();

        for(BuyerGroup bg : bgs){
            resultMap.put(bg.Name, bg.Id);
        }

        return resultMap;
    }

    public static void checkCreateBuyerAccount(Map<String,Object> accountMap, Set<String> existingBuyerAccount){
        Map<String,Object> newBGMap = new Map<String,Object>();

        for(String s : accountMap.keySet()){
            if(!existingBuyerAccount.contains(s)){
                newBGMap.put(s,accountMap.get(s));
            }
        }

        if(newBGMap.size()>0){
            createBuyerAccounts(newBGMap);
        }
    }

    public static void createBuyerAccounts(Map<String,Object> accountMap){
        List<BuyerAccount> buyerAccts = new List<BuyerAccount>();
        for(String s : accountMap.keySet()){
            Map<String,String> accountInfoMap = (Map<String,String>)accountMap.get(s);
            String accountId = s;
            String accountName = accountInfoMap.get('name');
            BuyerAccount ba = new BuyerAccount( 
               BuyerId = accountId, 
               Name = accountName, 
               IsActive = true
            );

            buyerAccts.add(ba);
        }

        insert buyerAccts;
    }

    public static Set<String> getExistingBuyerAccount(Set<String> accountIds){
        List<BuyerAccount> bas = [SELECT Id, BuyerId FROM BuyerAccount WHERE BuyerId in : accountIds];
        Set<String> resultSet = new Set<String>();
        for(BuyerAccount ba: bas){
            resultSet.add(ba.BuyerId);
        }

        return resultSet;
    }

    public static Set<String> getExistingBuyerGroupMember(Set<String> accountIds){
        List<BuyerGroupMember> bgms = [SELECT Id, BuyerId, BuyerGroupId FROM BuyerGroupMember WHERE BuyerId in : accountIds];
        Set<String> resultSet = new Set<String>();
        for(BuyerGroupMember bgm : bgms){
            resultSet.add(bgm.BuyerId + '_' + bgm.BuyerGroupId);
        }

        return resultSet;
    }

}
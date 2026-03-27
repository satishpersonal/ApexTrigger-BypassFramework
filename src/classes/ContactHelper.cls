/**
 * @Author           : Satish Inuganti
 * @Date             : 27-03-2026
 * @Description      : Generic Helper class for Contact, use this class to build SOQL of Contact or methods which are relavant on Contact Object
 * @User Story#      : 
 * @Revision(s)      : 
 * @Test Class Name  : 
**/
public with sharing class ContactHelper {
    public static Map<Id,Contact> getContactsByAccountIds(Set<Id> accountIds){
        Map<Id,Contact> contactsMap = new Map<Id,Contact>([SELECT Id,LastName,Account.Name,Description,Account.Description
                                                            FROM Contact WHERE AccountId IN :accountIds WITH SECURITY_ENFORCED]);
        return contactsMap;
    }
}
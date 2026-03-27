/**
 * @Author           : Satish Inuganti
 * @Date             : 27/03/2026
 * @Description      : This an example class on how to handle update and insert of related records. Don't forget to remove or delete if not needed.
 * @User Story#      : 
 * @Revision(s)      : 
 * @Test Class Name  : 
**/
public with sharing class AccountAfterUpdateTriggerHandler extends TriggerHandlerBase {
	public override void mainEntry(TriggerParameters tp) {
		updateContactLastNameWithAccountName((Map<Id,Account>)tp.oldMap, (Map<Id,Account>)tp.newMap);
		updateContactsDescription((Map<Id,Account>)tp.oldMap, (Map<Id,Account>)tp.newMap);
		createdLinkedOpportunity((Map<Id,Account>)tp.newMap);
		createdLinkedCases((Map<Id,Account>)tp.newMap);
	}
	
	public override void inProgressEntry(TriggerParameters tp) {
		System.debug('This is an example for reentrant code...');
	}

	public void updateContactLastNameWithAccountName(Map<Id,Account> oldAccountMap, Map<Id,Account> newAccountMap){
		Set<Id> namedUpdatedAccountIds = new Set<Id>();
		for(Account newAccount : newAccountMap.values()){
			Account oldAccount = oldAccountMap.get(newAccount.Id);
			if (oldAccount.Name != newAccount.Name) {
				namedUpdatedAccountIds.add(newAccount.Id);
			}
		}
		Map<Id,Contact> contactsToBeUpdated = ContactHelper.getContactsByAccountIds(namedUpdatedAccountIds);
		for(Contact contact: contactsToBeUpdated.values()){
			addToUpdate(contact,'LastName',contact.account.LastName);
		}
	}

	public void updateContactsDescription(Map<Id,Account> oldAccountMap, Map<Id,Account> newAccountMap){
		Set<Id> descriptionUpdatedAccountIds = new Set<Id>();
		for(Account newAccount : newAccountMap.values()){
			Account oldAccount = oldAccountMap.get(newAccount.Id);
			if (oldAccount.Description != newAccount.Description) {
				descriptionUpdatedAccountIds.add(newAccount.Id);
			}
		}
		Map<Id,Contact> contactsToBeUpdated = ContactHelper.getContactsByAccountIds(descriptionUpdatedAccountIds);
		for(Contact contact: contactsToBeUpdated.values()){
			addToUpdate(contact,'Description',contact.account.Description);
		}
	}
	
	public void createdLinkedOpportunity(Map<Id,Account> newAccountMap){
		List<Opportunity> newOpportunities = new List<Opportunity>();
		for(Account account : newAccountMap.values()){
			Opportunity opp = new Opportunity();
			opp.Name = account.Name+'Opportunity';
			opp.CloseDate = System.today()+7;
			opp.StageName = 'New';
			opp.AccountId = account.Id;
			newOpportunities.add(opp);
		}
		addToInsert((List<sObject>) newOpportunities);
	}
	public void createdLinkedCases(Map<Id,Account> newAccountMap){
		List<Case> newCases = new List<Case>();
		for(Account account : newAccountMap.values()){
			Case newCase = new Case();
			newCase.Status = 'New';
			newCase.AccountId = account.Id;
			newCase.Subject = account.Name+'Case';
			newCase.Description = account.Name+'CaseDescription';
			newCase.Origin = 'Web';
			newCases.add(newCase);
		}
		addToInsert((List<sObject>) newCases);
	}
}
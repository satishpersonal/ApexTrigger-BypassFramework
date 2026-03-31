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
		createdLinkedOpportunities_OppLineItems((Map<Id,Account>)tp.newMap);
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
			addToUpdate(contact,'LastName',contact.account.Name);
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
	
	public void createdLinkedOpportunities_OppLineItems(Map<Id,Account> newAccountMap){
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
		createOpportunityLinteItems((List<Opportunity>)newOpportunities);
	}
	public void createOpportunityLinteItems(List<Opportunity> newOpportunities){
		List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
		for(Opportunity opp : newOpportunities){
			OpportunityLineItem oppLineItem = new OpportunityLineItem();
			oppLineItem.OpportunityId = opp.Id;
			oppLineItem.Product2Id = '01tQy000006QES6IAO';
			oppLineItem.PricebookEntryId = '01uQy000001KyArIAK';
			oppLineItem.Quantity = 1;
			oppLineItem.UnitPrice = 100;
	        oppLineItems.add(oppLineItem);
		}
		addToInsert((List<sObject>) oppLineItems);
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

	/**
	* @description : When exception handling is required and you want to do something with the exception, 
	                override the method from TriggerHandlerBase Class. The below method is an example for overriding and handling exceptions
	* @author Satish Inuganti | 27-03-2026 
	**/
	public override void insertObjects(){
		Database.SaveResult[] insertResults = Database.insert(sObjectsToInsert, TRUE, AccessLevel.USER_MODE);
		for(Database.SaveResult insertResult : insertResults){
			List<Database.Error> errors = insertResult.getErrors();
			for(Database.Error error : errors){
				throw new HandledException(error.getFields()+'-'+error.getMessage());
			}
		}
	}
}
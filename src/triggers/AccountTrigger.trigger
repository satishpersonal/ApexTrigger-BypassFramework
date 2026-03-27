/**
 * @Author           : Satish Inuganti
 * @Date             : 
 * @Description      : 
 * @User Story#      : 
 * @Revision(s)      : 
 * @Test Class Name  : 
**/
trigger AccountTrigger on Account (after insert, after update, before insert, before update) {
	If(!FeatureManagement.checkPermission('BypassTriggers')){
		TriggerFactory.createTriggerDispatcher(Account.sObjectType);
	}else{
		//Do nothing
	}
}
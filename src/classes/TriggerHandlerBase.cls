/**
* @author Hari Krishnan
* @date 07/16/2013
* @description This class implements the ITriggerHandler to provide abstract/virtual methods for the interface methods
*				and so that the trigger handlers need to implement only the method that they have to. The only exception
*				is the mainEntry, which is mandatory for the trigger handlers to implement.
*/
public abstract class TriggerHandlerBase implements ITriggerHandler {
	protected Map<Id, SObject> sObjectsToUpdate = new Map<Id, SObject>();
	protected List<sObject> sObjectsToInsert = new List<sObject>();
	protected List<sObject> sObjectsToDelete = new List<sObject>();
	protected List<sObject> sObjectsToUndelete = new List<sObject>();
	/** 
	* @author Hari Krishnan
	* @date 07/16/2013
	* @description Called for the first time in the execution context. The trigger handlers need to implement
	*				this method.
	* @param TriggerParameters The trigger parameters such as the list of records before and after the update.
	*/
	public abstract void mainEntry(TriggerParameters tp);
	
	/** 
	* @author Hari Krishnan
	* @date 07/16/2013
	* @description Called for the subsequent times in the same execution context. The trigger handlers can chose
	*				to ignore if they don't need the reentrant feature.
	* @param TriggerParameters The trigger parameters such as the list of records before and after the update.
	*/
	public virtual void inProgressEntry(TriggerParameters tp) {
		
	}
	
	/** 
	* @author Hari Krishnan
	* @date 06/20/2013
	* @description Updates the objects, if any.
	*/
	public virtual void addToInsert(List<sObject> objectToBeInserted){
		sObjectsToInsert.addAll(objectToBeInserted);
	}
	public virtual void insertObjects() {
		if(sObjectsToInsert.size() > 0){
			Database.insert(sObjectsToInsert, AccessLevel.USER_MODE);
		}
	}
	public virtual void addToUpdate(sObject updatedObject, String updatedFieldName, Object newValue){
		if(sObjectsToUpdate.containsKey(updatedObject.Id)){
			sObject oldsObject = sObjectsToUpdate.get(updatedObject.Id);
			oldsObject.put(updatedFieldName, newValue);
			sObjectsToUpdate.put(oldsObject.Id, oldsObject);
		}else{
			updatedObject.put(updatedFieldName, newValue);
			sObjectsToUpdate.put(updatedObject.Id, updatedObject);
		}
	}
	public virtual void updateObjects() {
		if(sObjectsToUpdate.size() > 0){
			Database.update(sObjectsToUpdate.values(), AccessLevel.USER_MODE);
		}
	}
	public virtual void addToDelete(List<sObject> objectsToBeDeleted){
		sObjectsToDelete.addAll(objectsToBeDeleted);
	}
	public virtual void deleteObjects(){
		if(sObjectsToDelete.size() > 0){
			Database.delete(sObjectsToDelete, AccessLevel.USER_MODE);
		}
	} 
	public virtual void addToUndelete(List<sObject> objectsToBeUndeleted){
		sObjectsToUndelete.addAll(objectsToBeUndeleted);
	}
	public virtual void undeleteObjects(){
		if(sObjectsToUndelete.size() > 0){
			Database.undelete(sObjectsToUndelete, AccessLevel.USER_MODE);
		}
	} 
}
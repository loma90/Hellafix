trigger CaseTrigger on Case (before insert, before update) {
	if(Trigger.isInsert){
    CaseTriggerHandler.setEntitlement(Trigger.New);
  }
}
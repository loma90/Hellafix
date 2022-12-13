trigger ServiceAppointmentTrigger on ServiceAppointment__c (before insert, after insert, after update) {

  if(Trigger.isInsert){
    if(Trigger.IsBefore) {
      ServiceAppointmentTriggerHandler.updateAppointment(Trigger.New);
    }
    if(Trigger.isAfter){
      ServiceAppointmentTriggerHandler.handleEvent(Trigger.New, Trigger.oldMap);
    }
  }
  if(Trigger.isUpdate){
    ServiceAppointmentTriggerHandler.handleEvent(Trigger.New, Trigger.oldMap);
  }    
}
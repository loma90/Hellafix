public without sharing class ServiceAppointmentTriggerHandler {


  public static void updateAppointment(List<ServiceAppointment__c> listAppointments){
    Set<Id> caseIds = new Set<Id>();
    for(ServiceAppointment__c sA : listAppointments){
      caseIds.add(sA.Case__c);
    }
    Map<Id,Case> mapCase = new Map<Id,Case>([SELECT AccountId FROM Case WHERE ID IN:caseIds]);
    for(ServiceAppointment__c sA : listAppointments){
      sA.Account__c = mapCase.get(sA.Case__c).AccountId;
      sA.OwnerId = sA.AssignedTo__c;
    }
  }

  public static void handleEvent(List<ServiceAppointment__c> listAppointments, Map<Id, ServiceAppointment__c> oldMap){
    if(Trigger.isInsert){
      List<Event> listEvents = new List<Event>();
      List<CaseTeamMember> listCaseTeams = new List<CaseTeamMember>();
      Id teamRoleId = [SELECT Id FROM CaseTeamRole WHERE Name =: 'Service Person'].Id;

      Set<Id> caseIds = new Set<Id>();
      for(ServiceAppointment__c sA : listAppointments){
        caseIds.add(sA.Case__c);
      }
      Map<String,CaseTeamMember> mapExistingCaseTeam = new Map<String,CaseTeamMember>{};
      for(CaseTeamMember cTM : [SELECT ID,MemberId,ParentId FROM CaseTeamMember WHERE ParentId IN:caseIds]){
        mapExistingCaseTeam.put(cTM.ParentId + '_' + cTM.MemberId,cTM);
      }

      for(ServiceAppointment__c sA : listAppointments){
        listEvents.add(
          new Event(
            WhatId = sA.Id,
            StartDateTime = sA.StartDate__c,
            OwnerId = sA.AssignedTo__c,
            Subject = 'Meeting',
            EndDateTime = sA.EndDate__c
          )
        );
        if(mapExistingCaseTeam.get(sA.Case__c + '_' + sA.AssignedTo__c) == null){
          listCaseTeams.add(
            new CaseTeamMember(
              ParentId = sA.Case__c,
              MemberId = sA.AssignedTo__c,
              TeamRoleId = teamRoleId
            )
          );
        }
      }
      insert listEvents;
      insert listCaseTeams;
    }
    else if(Trigger.isUpdate){
      List<Event> listEvents = [SELECT ID,WhatId FROM Event WHERE WhatId IN:listAppointments];
      Map<Id,Event> mapSAEvent = new Map<Id,Event>();
      for(Event evt: listEvents){
        mapSAEvent.put(evt.WhatId,evt);
      }
      List<Event> listEventsToDelete = new List<Event>();
      List<Event> listEventsToUpdate = new List<Event>();

      Set<Id> caseIds = new Set<Id>();
      for(ServiceAppointment__c sA : listAppointments){
        caseIds.add(sA.Case__c);
      }
      Map<String,CaseTeamMember> mapExistingCaseTeam = new Map<String,CaseTeamMember>{};
      for(CaseTeamMember cTM : [SELECT ID,MemberId,ParentId FROM CaseTeamMember WHERE ParentId IN:caseIds]){
        mapExistingCaseTeam.put(cTM.ParentId + '_' + cTM.MemberId,cTM);
      }
      List<CaseTeamMember> listCaseTeamToDelete = new List<CaseTeamMember>();

      for(ServiceAppointment__c sA : listAppointments){
        if(
          oldMap.get(sA.Id).StartDate__c == sA.StartDate__c &&
          oldMap.get(sA.Id).Status__c == sA.Status__c &&
          oldMap.get(sA.Id).EndDate__c == sA.EndDate__c
        ) continue;
        Event evt = mapSAEvent.get(sA.Id);
        if(evt==null) continue;
        if(sA.Status__c == 'Declined') {
          listEventsToDelete.add(evt);
          if(mapExistingCaseTeam.get(sA.Case__c + '_' + sA.AssignedTo__c)!=null){
            listCaseTeamToDelete.add(mapExistingCaseTeam.get(sA.Case__c + '_' + sA.AssignedTo__c));
          }
        }else {
          evt.StartDateTime = sA.StartDate__c;
          evt.EndDateTime = sA.EndDate__c;
          listEventsToUpdate.add(evt);
        }
      }
      if(!listEventsToUpdate.isEmpty()) update listEventsToUpdate;
      if(!listEventsToDelete.isEmpty()) delete listEventsToDelete;
      if(!listCaseTeamToDelete.isEmpty()) delete listCaseTeamToDelete;
    }
  }
}
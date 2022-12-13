public without sharing class CheckAvailabilityCtrl {

  @AuraEnabled
  public static List<User> getUsers(Datetime startDate, Datetime endDate){
    Map<Id,User> allServicePersona = new Map<Id,User>([
      SELECT ID,Name,Email
      FROM User 
      WHERE Profile.Name = 'Service Persona'
    ]);

    List<Event> allEventsDay = [
      SELECT Id,OwnerId,StartDateTime,EndDateTime
      FROM Event 
      WHERE DAY_ONLY(StartDateTime) =:startDate.date()
    ];
    System.debug(allEventsDay);
    System.debug(startDate);
    Set<Id> userIds = new Set<Id>();
    for(Event evt : allEventsDay){
      System.debug(evt);
      if(
        (evt.StartDateTime <= startDate && evt.EndDateTime>startDate) ||
        (evt.StartDateTime < endDate && evt.EndDateTime>=endDate) || 
        (evt.StartDateTime > startDate && evt.EndDateTime<=endDate)
      ){  
        System.debug(evt);
        allServicePersona.remove(evt.OwnerId);
      }
    }
    return allServicePersona.values();
  }
}
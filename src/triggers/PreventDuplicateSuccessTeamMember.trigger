trigger PreventDuplicateSuccessTeamMember on Success_Team__c (before insert, before update) {
    
    // Set to store email ids
    Set <String> uniqueMemberKeySet = new Set<String>(); 
    Set <String> uniqueIdSet = new Set<String>(); 
    
    // Iterate through each Success_Team__c and add their uniquekey to their respective Sets
    for (Success_Team__c successTeam:trigger.new) {
        uniqueMemberKeySet.add(successTeam.Unique_Member_Key__c);
         uniqueIdSet.add(successTeam.Id);
    }
 
    // New list to store the found email or phone numbers
    List <Success_Team__c> successTeamList = new List<Success_Team__c>();
 
    // Populating the list using SOQL
    successTeamList = [SELECT Unique_Member_Key__c FROM Success_Team__c WHERE Unique_Member_Key__c  IN :uniqueMemberKeySet AND ID NOT IN :uniqueIdSet];
 
    // Iterating through each Success_Team__c record to see if the same email or phone was found
    for (Success_Team__c successTeam :trigger.new) {
        If (successTeamList.size() > 0) {
            // Displaying the error
            successTeam.Role__c.adderror( 'Duplicate Success Team Member Found!.' );
        }
    }
 
}
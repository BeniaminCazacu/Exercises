trigger primaryContact on SOBJECT (before insert) {
    Set<Id> setOfAccIds = new Set<Id>();
	for(Contact con : trigger.new){
		if(con.AccountId != null){
			setOfAccIds.add(con.AccountId);
		}
	}

//	Map<Id,Account> mapOfAccounts = new Map<Id,Account>([select (select id,Primary_Contact_Phone__c,Is_Primary_Contact__c from Contacts) where Id IN :setOfAccIds]);
	if(trigger.isBefore && trigger.isInsert){
		for(Contact con : trigger.new){
			if(con.AccountId != null && mapOfAccounts.containsKey(con.AccountId)){
				for(Contact childCon : mapOfAccounts.get(con.AccountId).Contacts){
					if(childCon.Is_Primary_Contact__c == true){
						con.addError('Contact cannot be created since Primary Contact already exist in the Account');
					}
				}
			}
		}
	}

	if(trigger.isAfter && trigger.isUpdate){
		List<Contact> listOfContactsToUpdate = new List<Contact>();
		for(Contact con : trigger.new){
			if(con.Is_Primary_Contact__c == true && con.Is_Primary_Contact__c != trigger.oldMap.get(con.id).Is_Primary_Contact__c && mapOfAccounts.containsKey(con.AccountId)){
				for(Contact childCon : mapOfAccounts.get(con.AccountId).Contacts){
					childCon.Primary_Contact_Phone__c = con.Primary_Contact_Phone__c;
					listOfContactsToUpdate.add(childCon);
				}
			}
		}

		if(listOfContactsToUpdate.size() > 0){
			update listOfContactsToUpdate;
		}
	}
}
@RestResource(urlMapping='/NewAccountHierarchy')
global with sharing class RestNewAccountHierarchy  {
	@HttpPost
	global static Structure showWithHierarchy(Id accId) {
		Structure structure = new Structure(accId);
		return structure;

	}

	global class Structure {
		List<Account> accs = new List<Account>();
		List<Contact> cons = new List<Contact>();
		Integer sizeCons;
		Integer sizeAccs;
		public Structure (Id accId) {
			accs = getAccounts(accId);
			cons = getContacts(accId);
			sizeCons = cons.size();
			sizeAccs = accs.size();
		}

		public List<Account> getAccounts(Id accId) {
			List<Account> accs = new List<Account>();
			boolean endOfStructure = false;
			List<Account> child  = new List<Account>();
			Set<ID> structureIDs = new Set<ID>();
			Set<ID> parentID = new Set<ID>();


			parentID.add(accId);
			while(!endOfStructure){

			//Abfrage der Untergeordneten Accounts, welche nicht Partner sind
			child = [SELECT ID, ParentId, (SELECT ID FROM Contacts) FROM Account WHERE ParentID in :parentID And IsPartner = false];

			if(child.size() == 0){
				endOfStructure = true;
				}else{
					parentID.clear();
					for(Integer i = 0; i < child.size(); i++){
						accs.add(child.get(i));
						structureIDs.add(child.get(i).ID);
						parentID.add(child.get(i).ID);
					}


				}
			}

			return accs;
		}

		public List<Contact> getContacts(Id accId) {
			List<Contact> cons = new List<Contact>();
			boolean endOfStructure = false;
			List<Account> child  = new List<Account>();
			Set<ID> structureIDs = new Set<ID>();
			Set<ID> parentID = new Set<ID>();


			parentID.add(accId);
			while(!endOfStructure){

			//Abfrage der Untergeordneten Accounts, welche nicht Partner sind
			child = [SELECT ID, ParentId, (SELECT ID FROM Contacts) FROM Account WHERE ParentID in :parentID And IsPartner = false];

			for(Account acc:child) {
				for(Contact con:acc.Contacts){
					cons.add(con);
				}
			}
			if(child.size() == 0){
				endOfStructure = true;
				}else{
					parentID.clear();
					for(Integer i = 0; i < child.size(); i++){
						structureIDs.add(child.get(i).ID);
						parentID.add(child.get(i).ID);
					}


				}
			}

			return cons;
		}
	}



}
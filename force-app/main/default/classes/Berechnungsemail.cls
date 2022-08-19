global class Berechnungsemail {
    public Berechnungsemail(){
        
    }
    public static void Berechnungsemail(Calculation__c calc1){

        
        List<Berechnungsemails__c> emailToInsert = new List<Berechnungsemails__c>();
        boolean neueMail = true;
        Realty_User__c immoUser;
        Calculation__c calc = calc1;
        Id oldID = null;
        Account maklerBetreuer;
        Contact con;
        String kundenName;
        kundenName = calc.Last_Name__c + ', ' + calc.First_Name__c;
        Boolean extern = false;
        Boolean isFirstInHierarchy = false;
        
        try{
            maklerBetreuer = Maklerbetreuer(calc.Agency__c);
            con = Maklerprov(maklerBetreuer.Externer_Maklerbetreuer__c);
            
            if(!con.HasOptedOutOfEmail){
                neueMail(emailToInsert, calc.Name, con.id, con.Email, calc.Brokers_Person__c, kundenName, calc.Property__c, calc.Appartment__c, calc.id, false);
            }
        }catch (Exception e){
            
            try{
                immoUser = [SELECT Contact__c FROM Realty_User__c WHERE id = :calc.Brokers_Person__c];
                con = Maklerprov(immoUser.Contact__c);
                Contact mBetreuerWH = [SELECT ID FROM Contact WHERE Email = :con.MaklerBetreuer_E_Mail__c Limit 1];
                if(!con.HasOptedOutOfEmail){
                    neueMail(emailToInsert, calc.Name, mBetreuerWH.id, con.MaklerBetreuer_E_Mail__c, calc.Brokers_Person__c, kundenName, calc.Property__c, calc.Appartment__c, calc.id, false);
                }
            }catch(Exception f){
                
            }
        }
        
        while (neueMail){
            try{
                maklerBetreuer = Maklerbetreuer(con.AccountID);
                if(oldId != maklerBetreuer.Externer_Maklerbetreuer__c)
                {
                    oldId = maklerBetreuer.Externer_Maklerbetreuer__c;
                    con = Maklerprov(maklerBetreuer.Externer_Maklerbetreuer__c);
                    neueMail(emailToInsert, calc.Name, con.id, con.Email, calc.Brokers_Person__c, kundenName, calc.Property__c, calc.Appartment__c, calc.id, true);
                }
                else
                {
                    throw new applicationException('Infinite Loop');
                }
            }catch(Exception e){
                neueMail = false;
                try{
                    immoUser = [SELECT Contact__c FROM Realty_User__c WHERE id = :calc.Brokers_Person__c];
                    
                    con = Maklerprov(immoUser.Contact__c);
                    Contact mBetreuerWH = [SELECT ID FROM Contact WHERE Email = :con.MaklerBetreuer_E_Mail__c Limit 1];
                    
                    if(con.MaklerBetreuer_E_Mail__c != null && mBetreuerWH.id != null && con.HasOptedOutOfEmail == false){
                        neueMail(emailToInsert, calc.Name, mBetreuerWH.id, con.MaklerBetreuer_E_Mail__c, calc.Brokers_Person__c, kundenName, calc.Property__c, calc.Appartment__c, calc.id, false);
                    }
                }catch(Exception f){
                    
                }
                
            }
        }
        
        if(!emailToInsert.isEmpty()){
            insert emailToInsert;
        }
        
    }
    
    public static void Berechnungsmail (){
        
    }
    
    public static Account Maklerbetreuer(Id AccountID){
            Account acc = [SELECT Externer_Maklerbetreuer__c, Maklerbetreuer_Wirtschaftshaus__c FROM Account WHERE Id = :AccountID];
            return acc;
    }
    
    public static Contact Maklerprov (Id ContactID){
            Contact con = [SELECT Id, Name, AccountID, Email, MaklerBetreuer_E_Mail__c, HasOptedOutOfEmail FROM Contact WHERE Id = :ContactID];
            if(con != null){
                if((con.Email == null || con.Email == '' || con.MaklerBetreuer_E_Mail__c == null || con.MaklerBetreuer_E_Mail__c == '')&& con.HasOptedOutOfEmail == false){
                    fehlerMail(con.Name);
                }
                
            }
            return con; 
    }
    
    public static void neueMail(List<Berechnungsemails__c> emailToInsert, String Name1, ID mailAn, String eMail, ID vonMakler, String Kunde, ID immo, ID app, ID berechnung, Boolean isExtern){
        emailToInsert.add(new Berechnungsemails__c( Name = 'E-Mail für Berechnugn: ' +Name1,
                                                    Benachrichtigung_an__c = mailAn,
                                                    An_E_Mail__c = eMail,
                                                    Berechnungsmakler__c = vonMakler,
                                                    Kunde__c = Kunde,
                                                    Immobilie__c = immo,
                                                    Teilobjekt__c = app,
                                                    Immo_Berechnung__c = berechnung,
                                                    Externe__c = isExtern));
    }
    
    public static void fehlerMail(String name){
        Messaging.Singleemailmessage mail = new Messaging.Singleemailmessage();
        String[] toAdress = new String[] {  'dr@wirtschaftshaus.de',
                                            'p.kredig@wirtschaftshaus.de'};
        mail.setToAddresses(toAdress);
        mail.setSubject('Bitte Email überprüfen');
        mail.setBccSender(false);
        mail.setPlainTextBody('Bitte überprüfen ob die E-Mail Adresse und die Makler Betreuer Email Adresse vom Kontakt: ' + name + ' angegeben ist');
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }
    
}
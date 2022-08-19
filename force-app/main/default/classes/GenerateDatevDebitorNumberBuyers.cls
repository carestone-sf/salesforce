/**
 * Created by frederikwitte on 02.11.20.
 */

public class GenerateDatevDebitorNumberBuyers {
    
    public void generateDatevDebitorNumberBuyers(List<Id> conIds) {
        try {
            List<Contact> cons = [SELECT DatevDebitorenKundennummerKaeufer__c FROM Contact WHERE Id IN :conIds];

            DatevDebitorennummerKaeufer__c datevDebitorennummerKaeuferSetting = DatevDebitorennummerKaeufer__c.getOrgDefaults();
            Decimal datevDebitorenNummerKaeufer = datevDebitorennummerKaeuferSetting.DatevDebitorennummerKaeufer__c;
            for (Contact con : cons) {
                if (con.DatevDebitorenKundennummerKaeufer__c == null) {
                    con.DatevDebitorenKundennummerKaeufer__c = String.valueOf((Integer) datevDebitorenNummerKaeufer);
                    datevDebitorenNummerKaeufer++;
                }
            }

            if (datevDebitorenNummerKaeufer != datevDebitorennummerKaeuferSetting.DatevDebitorennummerKaeufer__c) {
                datevDebitorennummerKaeuferSetting.DatevDebitorennummerKaeufer__c = datevDebitorenNummerKaeufer;
                update datevDebitorennummerKaeuferSetting;
                update cons;
            }

        } catch(Exception e) {
            throw e;
        }

    }

}
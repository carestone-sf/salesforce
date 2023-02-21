@isTest
public class PermissionSetsHandlerTest {
    private static string getUserId{ 
        get{
            return System.UserInfo.getUserId();       
        }
        set;
    }

    
    @isTest
    private static void chceckIfUserHasDefaultCustomPermissionSet () {
            boolean haspermission=PermissionSetsHandler.hasPermissionSet(PermissionSetsHandler.DEFAULT_CUSTOM_PERMISSION_SET_NAME);
            system.debug(PermissionSetsHandler.DEFAULT_CUSTOM_PERMISSION_SET_NAME);
            System.assertEquals(haspermission, true);
        
    }

    @isTest
    private static void chceckIfUserHasNotCustomPermissionSet(){
        boolean haspermission=PermissionSetsHandler.hasPermissionSet('NameOFPermissionSEtThatNotExist');
        System.assertEquals(haspermission, false);
    }


}
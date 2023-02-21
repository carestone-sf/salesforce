public class PermissionSetsHandler {
    @testVisible private static final String DEFAULT_CUSTOM_PERMISSION_SET_NAME='GodMode';
    private static  string diffrentPermissionSetName;

    private static string getUserId{ 
        get{
            return System.UserInfo.getUserId();       
        }
        set;
    }

    public static boolean hasPermissionSet(){

        if(System.FeatureManagement.checkPermission(DEFAULT_CUSTOM_PERMISSION_SET_NAME)){
            return true;
        }
        return false;
    }
    public static boolean hasPermissionSet(String permissionSetName){
        diffrentPermissionSetName=permissionSetName;
        if(System.FeatureManagement.checkPermission(diffrentPermissionSetName)){
            return true;
        }
        return false;
    }
}
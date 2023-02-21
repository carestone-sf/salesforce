public class PermissionSetsHandler {
    private static final String DEFAULT_PERMISSION_SET_NAME='Can_change_stage_status';
    private static  string diffrentPermissionSetName;

    private static string getUserId{ 
        get{
            return System.UserInfo.getUserId();       
        }
        set;
    }
    private static string getPermissionSetName{ 
        get{
            if(diffrentPermissionSetName==null||diffrentPermissionSetName==''){
                return DEFAULT_PERMISSION_SET_NAME;
            }
            return diffrentPermissionSetName;
        }
        set;
    }
    
    private static List<PermissionSetAssignment> getPermissionSetAssignments{
        get{
            if(getPermissionSetAssignments==null){
                getpermissionSetAssignments=[SELECT Id, PermissionSetId, PermissionSet.Name, AssigneeId 
                                             FROM PermissionSetAssignment 
                                             WHERE AssigneeId = :getUserId And PermissionSet.Name=:getPermissionSetName];
            }
            return getPermissionSetAssignments;
        }
        set;
    }

    public static boolean hasPermissionSet(){
        if(getPermissionSetAssignments.size()==0){
            return false;
        }
        return true;
    }
    public static boolean hasPermissionSet(String permissionSetName){
        diffrentPermissionSetName=permissionSetName;
        if(getPermissionSetAssignments.size()==0){
            return false;
        }
        return true;
    }
}

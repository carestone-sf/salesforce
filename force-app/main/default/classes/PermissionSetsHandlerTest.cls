@isTest
public class PermissionSetsHandlerTest {
    private static string getUserId{ 
        get{
            return System.UserInfo.getUserId();       
        }
        set;
    }
    private static List<PermissionSetAssignment> getAllUserPermissionSetAssignments{
        get{
            if(getAllUserPermissionSetAssignments==null){
                getAllUserPermissionSetAssignments=[SELECT Id, PermissionSetId, PermissionSet.Name, AssigneeId 
                                                    FROM PermissionSetAssignment 
                                                    WHERE AssigneeId = :getUserId ];
            }
            return getAllUserPermissionSetAssignments;
        }
        set;
    }

    
    @isTest
    private static void chceckAllUserPermissionSets () {
        List<PermissionSetAssignment> permissions=getAllUserPermissionSetAssignments;
        for(PermissionSetAssignment assignment :permissions){
            boolean haspermission=PermissionSetsHandler.hasPermissionSet(assignment.PermissionSet.Name);
            System.assertEquals(haspermission, true);
        }
    }
    @isTest
    private static void Check(){
        boolean haspermission=PermissionSetsHandler.hasPermissionSet('NameOFPermissionSEtThatNotExist');
        System.assertEquals(haspermission, false);
    }

}

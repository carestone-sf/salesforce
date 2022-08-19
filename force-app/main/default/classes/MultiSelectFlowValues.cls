global class MultiSelectFlowValues {
   
    @InvocableMethod
    public static List<list<string>> CheckValues(List<string> values) {
       if(!(values.isEmpty())){
           string tempStr = values[0];
           List<String> lstnew = tempStr.split(';');
           List<String> trimmedLstnew = new List<String>();
           for(String str:lstnew) {
               str = str.trim();
               trimmedLstnew.add(str);
           }
           list<list<string>> finalLst = new list<list<string>>();
           finalLst.add(trimmedLstnew);
           return finalLst;
       }
       else return null;
    }
 }
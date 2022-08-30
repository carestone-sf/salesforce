@IsTest
private class Utility_RowIteratorTest {

    @IsTest 
    private static void testUtilityRowIterator() {
        String csv = '"FirstName", "LastName"\n"TestName1", "Test1"\n"TestName2", "Test2"';
        List<String> names = new List<String>();
        Utility_RowIterator rowIterator = new Utility_RowIterator(csv, '\n');
        Iterator<String> iterator = rowIterator.iterator();
        while (iterator.hasNext()) {
            names.add(iterator.next());
        }
        System.assertEquals('"TestName1", "Test1"', names[1]);
    }
}

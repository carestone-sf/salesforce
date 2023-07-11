@IsTest
public with sharing class OposTest {
    
    @IsTest
    private static void testNegativeSum() {

        Test.startTest();
        Opos opos = new Opos('0,00', '396,00', '11.01.2022', 'b','test','test','test','test');
        System.assertEquals(opos.betrag, -396);
        Test.stopTest();
    }
}
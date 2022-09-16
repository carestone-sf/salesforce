@IsTest
public with sharing class OposTest {
    
    @IsTest
    private static void testNegativeSum() {
        Opos opos = new Opos('0,00', '396,00', '11.01.2022', 'b');
        System.assertEquals(opos.betrag, -396);
    }
}

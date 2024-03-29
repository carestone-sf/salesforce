public class Iban {

    public final static Integer MAGIC_NUMBER = 97;
    public final static Integer IBAN_MIN_SIZE = 15;
    public final static Integer IBAN_MAX_SIZE = 34;
    /* Iban validation steps - https://en.wikipedia.org/wiki/International_Bank_Account_Number
        1. Check that the total IBAN length is correct as per the country. If not, the IBAN is invalid
        2. Move the four initial characters to the end of the string
        3. Replace each letter in the string with two digits, thereby expanding the string, where A = 10, B = 11, ..., Z = 35
        4. Interpret the string as a decimal integer and compute the remainder of that number on division by 97
    */
    public static Boolean validate(String iban) { 
        iban = iban.deleteWhiteSpace().trim();
        
        if (iban.length() < IBAN_MIN_SIZE || iban.length() > IBAN_MAX_SIZE)
            return false;

        iban = iban.capitalize();
        
        String countryCode = iban.substring(0, 2);
        List<Iban_Format__mdt> ibanFormats = IbanFormatRepository.getByNationalBankCodes(new Set<String> { countryCode });
        if (ibanFormats.size() == 0)
            throw new Iban.CountryCodeNotConfiguredException('Country code invalid or not configured');

        Iban_Format__mdt ibanFormat = ibanFormats[0];
        if (ibanFormat.Characters__c != iban.length())
            return false;
        
        iban = iban.substring(4) + iban.substring(0, 4);
        
        String ibanNumber = convertCharsToNumbers(iban);
        Integer remainer = 0;
        while (ibanNumber.length() >= 7) {
            remainer = Math.mod(Integer.valueOf(remainer + ibanNumber.substring(0, 7)), 97);
            ibanNumber = ibanNumber.substring(7);
        }
        remainer = Math.mod(Integer.valueOf(remainer + ibanNumber), 97);
        return remainer == 1;
    }

    private static String convertCharsToNumbers(String iban) {
        final Integer diff = 55; // used specific for the iban calculation. The char diff between the hashcode and iban is 55.
        String temp = '';
        for (Integer i = 0; i < iban.length(); i++){
            String character = iban.substring(i, i + 1);
            temp += !character.isNumeric() ? String.valueOf(character.hashCode() - diff) : character;
        }
        System.debug(temp);
        return temp;
    }

    public class CountryCodeNotConfiguredException extends Exception {}

    @InvocableMethod(label='Validate IBANs' description='Validates the ibans taken as input string.')
    public static List<Results> validateIbans(List<Requests> requests) {
        List<String> ibans = new List<String>();
        List<Results> results = new List<Results>();

        for(Requests request: requests) {
            if(request.iban != null) {
                ibans.add(request.iban);
            }
        }

        for(String i:ibans) {
            Results result = new Results();
            result.ibanValid = Iban.validate(i);
            results.add(result);
        }

        return results;
    }

    public class Requests {
        @InvocableVariable(label='IBAN to validate' required=true)
        public String iban;
    }

    public class Results {
        @InvocableVariable(label='IBAN valid?' description='If true, the IBAN is valid' required=true)
        public Boolean ibanValid;
    }
}
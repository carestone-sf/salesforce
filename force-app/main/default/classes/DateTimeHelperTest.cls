@isTest
private class DateTimeHelperTest {

	@isTest static void test_method_one() {
		DateTimeHelper dth = new DateTimeHelper();
		DateTime dt = DateTime.now();

		DateTimeHelper.getDateTime();
		DateTimeHelper.getDateTime(3, 'days');
		DateTimeHelper.checkAndSetDateTimeIfWeekend(dt);
	}

}
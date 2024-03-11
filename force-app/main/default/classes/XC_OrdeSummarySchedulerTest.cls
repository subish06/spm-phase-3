@isTest
public without sharing class XC_OrdeSummarySchedulerTest {
    @isTest
    public static void testScheduler() {
        Test.startTest();
        XC_OrdeSummaryScheduler ors = new XC_OrdeSummaryScheduler();
        System.schedule('testBasicScheduledApex','0 0 0 15 3 ? 2023', new XC_OrdeSummaryScheduler());
        Test.stopTest();
    }
}
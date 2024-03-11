@isTest
public without sharing class XC_OpportunityApprovalRequestControlTest 
{
    @isTest
    public static void testFields()
    {
        Test.startTest();

        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'New/Forecast';
        opp.CloseDate = Date.today().addDays(2);

        insert opp;

        XC_OpportunityApprovalRequestController curControl = new XC_OpportunityApprovalRequestController();
        curControl.recordId = opp.Id;

        System.assert(curControl.approvalURL.contains(opp.Id));
        System.assert(curControl.detailLink.contains(opp.Id));
        System.assertEquals(opp.Id, curControl.opp.Id);
        System.assertEquals('', curControl.approvalComments);
        System.assertEquals(0, curControl.oppProducts.size());

        Test.stopTest();
    }
}
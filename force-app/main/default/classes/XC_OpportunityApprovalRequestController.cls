public without sharing class XC_OpportunityApprovalRequestController 
{
    public String recordId {get; set;}

    public String approvalURL {
        get{
            return URL.getSalesforceBaseUrl().toExternalForm() + '/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + recordId;
        } 
        set;
    }

    public String detailLink {
        get{
            return URL.getSalesforceBaseUrl().toExternalForm() + '/' + recordId;
        } 
        set;
    }

    public Opportunity opp {
        get{
            if(opp == null)
            {
                opp = [SELECT Account.Name, Owner.Name
                            FROM Opportunity
                            WHERE Id = :recordId LIMIT 1];
            }
            
            return opp;
        }
        set;
    }

    public List<OpportunityLineItem> oppProducts {
        get{
            if(oppProducts == null)
            {
                oppProducts =  [SELECT Product2.Name
                                        FROM OpportunityLineItem
                                        WHERE OpportunityId = :recordId];
                
            }

            return oppProducts;
        }
        set;
    }

    public String approvalComments
    {
        get {
            if(approvalComments == null)
            {
                try 
                {
                    ProcessInstance curProcess = [SELECT Id FROM ProcessInstance WHERE TargetObjectId = :recordId ORDER BY CreatedDate DESC LIMIT 1];

                    ProcessInstanceStep curProcessStep = [SELECT Id, Comments FROM ProcessInstanceStep WHERE ProcessInstanceId = :curProcess.Id ORDER BY CreatedDate DESC LIMIT 1];

                    approvalComments = curProcessStep.Comments;
                } 
                catch (Exception e) 
                {
                    approvalComments = '';
                }
            }

            return approvalComments;
        }
        set;
    }
}
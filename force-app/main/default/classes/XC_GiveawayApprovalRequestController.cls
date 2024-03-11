public without sharing class XC_GiveawayApprovalRequestController 
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

    public XC_Giveaway__c giveaway {
        get{
            if(giveaway == null)
            {
                giveaway = [SELECT XC_Contact__r.Name, XC_SubmittedForApprovalBy__r.Name
                            FROM XC_Giveaway__c
                            WHERE Id = :recordId LIMIT 1];
            }
            
            return giveaway;
        }
        set;
    }

    public List<XC_GiveawayProduct__c> giveawayProducts {
        get{
            if(giveawayProducts == null)
            {
                giveawayProducts =  [SELECT XC_Product__r.Name
                                        FROM XC_GiveawayProduct__c
                                        WHERE XC_Giveaway__c = :recordId];
                
            }

            return giveawayProducts;
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
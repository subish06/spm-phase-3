trigger OrderCommitmentTrigger on Order_Commitment__c (after insert, after update) {
    OrderCommitmentController.updateTargetCommitStats(Trigger.new);
}
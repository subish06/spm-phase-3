global class XC_AssignAccountBuyerGroupSchedule implements Schedulable {
    global void execute(SchedulableContext sc){
        XC_AssignBuyerMembersBatch myBatchObject = new XC_AssignBuyerMembersBatch(); 
        Id batchId = Database.executeBatch(myBatchObject);
    }
}
global class XC_OrdeSummaryScheduler implements Schedulable {
    global void execute(SchedulableContext sc){
        XC_OrderSummaryCreationCtrl myBatchObject = new XC_OrderSummaryCreationCtrl(); 
        Id batchId = Database.executeBatch(myBatchObject);
    }
}
trigger OrderItemTrigger on OrderItem (before update, before insert, after insert,after update) {
    
    if(Trigger.isInsert && Trigger.isAfter) {
        OrderItemController.createActuals(Trigger.newMap);       
    }
    
    if(Trigger.isUpdate && Trigger.isAfter){
        OrderItemController.updateActualsOnOrderItemUpdate(Trigger.newMap, Trigger.oldMap); 
    }
    
}
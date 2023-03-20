trigger PaymentTrigger on PaymentC__c (before insert, before update, after update, after insert) {
    //update Final Amount = Amount khi Status = 'Done'
    //cảnh báo ko đc chuyển Status từ 'Done' sang giá trị khác
    if(Trigger.isBefore && Trigger.isUpdate) {
        PaymentClass.updateAmount(Trigger.New, Trigger.OldMap);
    }

    //Tạo task cho owner khi Payment method = 'chuyen khoan'
    if(Trigger.isAfter && Trigger.isUpdate) {
        PaymentClass.createTaskAfterUpdate(Trigger.New);
    }

    //Tạo task cho owner khi tạo new Payment vs Payment method = 'chuyen khoan'
    if(Trigger.isAfter && Trigger.isInsert) {
        PaymentClass.createTaskAfterInsert(Trigger.New);
    }

    //Khi Payment method:'chuyen khoan' -> giá trị khác. Del all task named start with 'chuyen khoan'
    if(Trigger.isAfter && Trigger.isUpdate) {
        paymentClass.delTask(Trigger.New, Trigger.OldMap);
    }
}
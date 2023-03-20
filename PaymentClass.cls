public class PaymentClass {
    //1.Update Final Amount = Amount khi Status= Done và cảnh báo không được chuyển status từ Done sang các giá trị khác
    public static void onBeforeUpdate(List<PaymentC__c> newPayments, Map<Id, PaymentC__c> oldMap) {
        for(PaymentC__c payment: newPayments) {
            // 1.1.update Final Amount = Amount khi Status= Done
            if(payment.Status__c == 'Done') {
                payment.Amount__c = payment.Final_Amount__c;
            }
            // 1.2.cảnh báo không được chuyển status từ Done sang các giá trị khác
            else if(oldMap.get(payment.Id).Status__c == 'Done' && payment.Status__c != 'Done') {
                payment.Status__c.addError('Cannot change Status');
            }
        }
    }
    
    //2.tạo task cho owner khi payment method chuyển thành 'chuyen khoan'
    public static void onAfterUpdate(List<PaymentC__c> newPayments) {
        createTask(newPayments);
    }
    
    //3.tạo task cho owner khi một payment được tạo ra với payment method là 'Chuyen khoan'
    public static void onAfterInsert(List<PaymentC__c> newPayments) {
        createTask(newPayments);
    }
    
    private static void createTask(List<PaymentC__c> newPayments) {
        List<TaskC__c> taskList = new List<TaskC__c>(); 
        for (PaymentC__c payment : newPayments) {
            if (payment.Payment_method__c == 'Chuyen khoan') {
                taskList.add(new TaskC__c(
                    Name = 'Chuyen khoan ' + payment.Name,
                    Subject__c = 'Chuyen khoan ' + payment.Name,
                    Priority__c = 'High',
                    Status__c = 'Not Started',
                    Ownerid = UserInfo.getUserId(),
                    Related_To__c = payment.Id,
                    Due_Date__c = payment.Payment_Date__c.addDays(1)
                ));
            }
        }
        insert taskList;
    }

    //4.Del all task start = 'chuyen khoan' khi payment method chuyen tu 'chuyen khoan' sang gtri khac  
    public static void delTask(List<PaymentC__c> newPayments, Map<Id, PaymentC__c> oldMap) {
        deleteTask(newPayments, oldMap);
    }

    private static void deleteTask(List<PaymentC__c> newPayments, Map<Id, PaymentC__c> oldMap) {
        List<TaskC__c> tasksToDel = new List<TaskC__c>();
        for(PaymentC__c pay: newPayments){
            if(pay.Payment_method__c != 'Chuyen khoan'){
                List<TaskC__c> tasks = [SELECT Id FROM TaskC__c WHERE Name LIKE 'Chuyen khoan %' AND Related_To__c = :pay.Id];
            tasksToDel.addAll(tasks);
            }
        }
        if(tasksToDel.size()>0){
            delete tasksToDel;
        }
    }
}

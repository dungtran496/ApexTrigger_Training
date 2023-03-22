public class PaymentClass {
    //1.Update Final Amount = Amount khi Status= 'Done' và cảnh báo không được chuyển status từ 'Done' sang các giá trị khác
    public static void updateAmount(List<PaymentC__c> newPayments, Map<Id, PaymentC__c> oldMap) {
        for(PaymentC__c payment: newPayments) {
            // 1.1.update Final Amount = Amount khi Status= Done
            if(oldMap.get(payment.Id).Status__c != 'Done' && payment.Status__c == 'Done') {
                 payment.Final_Amount__c = payment.Amount__c;
            }
            // 1.2.cảnh báo không được chuyển status từ Done sang các giá trị khác
            else if(oldMap.get(payment.Id).Status__c == 'Done' && payment.Status__c != 'Done') {
                payment.Status__c.addError('Cannot change Status');
            }
        }
    }
    
    //2.tạo task cho owner khi payment method chuyển thành 'ChuyenKhoan'
    public static void createTaskAfterUpdate(List<PaymentC__c> newPayments) {
        createTask(newPayments);
    }
    
    //3.tạo task cho owner khi một payment được tạo ra với payment method là 'ChuyenKhoan'
    public static void createTaskAfterInsert(List<PaymentC__c> newPayments) {
        createTask(newPayments);
    }
    
    private static void createTask(List<PaymentC__c> newPayments) {
        List<TaskC__c> taskList = new List<TaskC__c>(); 
        for (PaymentC__c payment : newPayments) {
            if (payment.Payment_method__c == 'ChuyenKhoan') {
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
        Set<Id> paymentId = new Set<Id>();
        for(PaymentC__c pay: newPayments){
            if(oldMap.get(pay.Id).Payment_method__c == 'ChuyenKhoan' && pay.Payment_method__c != 'ChuyenKhoan'){
                paymentId.add(pay.Id);
            }
        }
        if(paymentId.size()>0){
            List<TaskC__c> tasks = [
                SELECT Id 
                FROM TaskC__c 
                WHERE Related_To__c IN :paymentId
                AND Subject__c Like 'Chuyen khoan%'
            ];
            delete tasks;
        }
    }
}
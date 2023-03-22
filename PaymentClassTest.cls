@isTest
public class PaymentClassTest {
    @testSetup
    static void createDataPayment() {
        // insert record payment
        PaymentC__c newPm = new PaymentC__c();
        newPm.Name = 'test PM';
        newPm.Status__c = 'New';
        newPm.Payment_method__c = 'ChuyenKhoan';
        newPm.Amount__c = 300000;
        newPm.Payment_Date__c= Date.today();
        insert newPm;
        
        // insert record task relating to payment
        TaskC__c newTask = new TaskC__c();
        newTask.Name = 'test Task';
        newTask.Subject__c = 'Chuyen khoan'+ newPm.Name ;
        newTask.Related_To__c = newPm.Id;
        insert newTask;
    }
    
    @isTest   //Case 1: Test update Final Amount = Amount khi Status = 'Done'
    static void updateAmountTest_1(){
        //  start test method
        PaymentC__c currPm = [select Id, Status__c from  PaymentC__c limit 1];  //Lấy giá trị để test
        currPm.Status__c = 'Done';
        Test.startTest();
        update currPm;
        Test.stopTest();
        PaymentC__c afterPm = [select Id, Status__c, Amount__c, Final_Amount__c from PaymentC__c limit 1];   
        system.assert(afterPm.Final_Amount__c == afterPm.Amount__c);    // check Final_Amount__c = Amount__c
    }
    
    @isTest   //Case 2: Test cảnh báo ko đc chuyển Status từ 'Done' sang giá trị khác
    static void updateAmountTest_2(){
        //  start test method
        PaymentC__c currPm = [select Id, Status__c from PaymentC__c limit 1];
        currPm.Status__c = 'Done';
        Test.startTest();
        update currPm;                       // 
        currPm.Status__c = 'New';            //
        try{  
            update currPm;
        } catch(exception e) {
            system.Assert(e.getMessage().contains('Cannot change Status'));  // check add error 
        }
        Test.stopTest();
    }
    
    @isTest  //Case 3: Test Khi Payment method:'ChuyenKhoan' -> giá trị khác. Del all task named start with 'chuyen khoan'
    static void delTaskTest() {
        //  start test method
        PaymentC__c currPm = [select Id, Payment_method__c from PaymentC__c limit 1]; 
        List<TaskC__c> lsTaskBefore = [Select id, Name, Related_To__c, Subject__c from TaskC__c];
        system.debug('lsTaskBefore: '+ lsTaskBefore);    // Đặt debug để kiểm tra nếu có lỗi
        System.Assert(lsTaskBefore.size() == 2);     // == 2 vì 1 task đc tạo ra khi payment method = Chuyen khoan và 1 task đc khai báo
        Test.startTest();
        currPm.Payment_method__c = 'money';
        update currPm;
        Test.stopTest();
        List<TaskC__c> lsTask = [Select id, Name, Related_To__c, Subject__c from TaskC__c];  
        system.debug(lsTask);               // Đặt debug để kiểm tra nếu có lỗi
        System.Assert(lsTask.size() == 0);         
    }
}
# ApexTrigger_Training

## Tạo 2 customer object: PaymentC__c và TaskC__c.

**1.** tự động update Final Amount = Amount khi Status chuyển thành Done nếu Final Amount không được nhập dữ. 

**2.** Trên object Payment__c cảnh báo cho người dùng không được phép chuyển status từ Done sang các giá trị. 

**3.** Trên object Payment tự động tạo task cho owner khi một payment được tạo ra với payment method là 'Chuyen khoan' với các thông tin sau: 
* Subject: “Verify payment” + Payment name
* Priority: High
* Owner: Payment Owner
* Due date: 1 day sau Payment Date
* Status: Not Started
* Related To: Payment

**4.** Khi Payment method chuyển từ 'Chuyen khoan' sang giá trị khác. Xóa tất cả các task có tên bắt đầu với 'Chuyen khoan ....'

## instruction
**1.** Trong PaymentC tạo các customer field:
* Amount
* Final Amount: always requiment
* Payment Date: Date
* Payment Method: Picklist: Chuyen khoan, Tien mat, QR code, ...
* Status: Picklist: New, Progress, Done, Cancelled

**2.** Trong TaskC tạo các customer field:
* Due Date: Date
* Priority: Picklist: High, Normal, Low
* Status: Picklist: Not Started, In Progress, Completed, Waiting on someone else.
* Subject: Text
* Related To: Lookup(PaymentC) 

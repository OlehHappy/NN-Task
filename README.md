# NN-Task

to run this script execute anounymous Apex:
```java
// Schedule the job to run every day at midnight
String schedule = '0 0 0 * * ?';
System.schedule('Update Countries Info', schedule, new CountriesInfoUpdaterScheduler());
```
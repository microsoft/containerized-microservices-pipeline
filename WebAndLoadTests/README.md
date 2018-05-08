# Web and Load Test

## Prerequisites
1. Visual Studio
	- [Download and install Visual Studio](https://www.visualstudio.com/downloads/)
2. VSTS Account
    - [Create VSTS Account](https://docs.microsoft.com/en-us/vsts/accounts/create-account-msa-or-work-student?view=vsts)

## Setting Up Config Values in [app.config](https://github.com/Microsoft/containerized-microservices-pipeline/blob/master/WebAndLoadTests/WebAndLoadTests/app.config) 
- Input the value of the base URL for the app in Line 11 of ```app.config```. Example: ```<value>URL</value>```.
- Input the value of the base URL for the middle tier API in Line 14 of ```app.config```. Example: ```<value>URL</value>```.
- Input the value of the username of the admin user that has the access to delete users in Line 17 of ```app.config```. Example: ```<value>USERNAME</value>```.
- Input the value of the password of the admin user that has the access to delete users in Line 20 of ```app.config```. Example: ```<value>PASSWORD</value>```.

## Web Test
### Running and Debugging Web Test
- Right click on the WebTest class and select ```Run Coded Web Performance Test``` to run your web test or select ```Debug Coded Web Performance Test```  to run your web test.

## Executing the Load Test
- [More information on editing load test scenarios.](https://docs.microsoft.com/en-us/visualstudio/test/edit-load-test-scenarios)
### Load Test Locally
- Running your Load Test Locally
    1. Open ```Local.testsettings``` file
    2. In ```General```, under ```Test run location:```, make sure you select ```Run tests using local computer or a test controller```.
### Cloud-based Load Test with VSTS
- [Getting started on Load Test in the cloud using Visual Studio and VSTS](https://docs.microsoft.com/en-us/vsts/load-test/getting-started-with-performance-testing?view=vsts)
- Running your Load Test with VSTS
    1. Open ```Local.testsettings``` file
    2. In ```General```, under ```Test run location:```, make sure you select ```Run tests using Visual Studio Team Services```.
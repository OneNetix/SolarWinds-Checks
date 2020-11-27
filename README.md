# SolarWinds-Checks


### Introduction
The aim of this project is to allow anyone using SolarWinds to see their utilisation primarily for licensing and clean up.
We take the principles shown to us in Orion under Admin/Details/License Details, enhance them and then bring them into csv format to allow us to share 
with other users who dont have access to Orion or if we need to collaboratively clean up the system. 
Taking what ive learnt from being an onsite engineer in different enviroments, the first thin we did was a "health check" which consisted of looking through the elements (an element in SolarWinds consists of the node with its interfaces and volumes), SAM templates and and other potentially unused or unmaintened system sections. 

We also break this down further into a granular file that shows what templates are assiged to each node

### Technoligies
In this we will be primarily using PowerShell, on our system we are using version 5, it is recormended to use V5 or above. You can find your version by opening a PowerShell window and entering $PSVersionTable.PSVersion

We also use the SolarWinds API for PowerShell called SwisAPI this can be found here for more reference https://github.com/solarwinds/OrionSDK/wiki/PowerShell

### How to run
1. To run this script download it and add it anywhere on your machine that has the SolarWinds API installed. 
2. Next you will need to make sure you have a directory set up to store the output files, in this example we use #### C:\Scripts\Automation\logs\
Make sure that path is set up on your system
3. Execute either with PowerShell or ISE to debug/modify the code
4. You will be prompted for the username and password makes sure this is an admin for SolarWinds, you can either use one you have already or create an SDK specific one
5. After details have been entered you will then be prompted to enter the details of the target server enter this in the window provided when prompted and hit enter to move on
6. Provided you've got the directories set up the scipt will run and create 2 files system checks $(timestamp).csv and Node checks.csv

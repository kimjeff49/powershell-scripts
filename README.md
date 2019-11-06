# powershell-scripts

## Generate-Xml
### Purpose
I created this at my old internship to map out our test directory into XML. The purpose was to have separate functions within the PowerShell script to allow for reusability. However, the only drawback (possibly the greatest drawback) is that the script reads all of the files in a nested hashtable, meaning that there __CANNOT__ be duplicates or the PowerShell script will __freak__ out. Unfortunately since I am not as adept in PowerShell I did not add any error handling, sorry!

### Why PowerShell?
Our build and integration environment was TFS and PowerShell integrated perfectly with that environment. Maybe, in the potential future, I will also rewrite the Selenium Grid TFS integration that we had created during the internship and post that in this repository as well. However, I am not sure if my company will find that, then sue me for intellectual disputes. Even so, I am not sure how I will be able to test that script without setting up a mock TFS build environment. Oh well ¯\\\_(ツ)_/¯
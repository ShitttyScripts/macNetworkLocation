# macNetworkLocation
###### Determines if a Mac is On or Off the Corporate Network for use when scoping policies

___

**Copyright (c) 2016, JAMF Software, LLC.  All rights reserved.**

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
* Neither the name of the JAMF Software, LLC nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY JAMF SOFTWARE, LLC "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JAMF SOFTWARE, LLC BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
___
This script was designed to be used in conjunction with an extension attribute in Jamf Pro that will be able to help us identify whether a macOS device is on the network or not.

Requirements:
* Jamf Pro
* macLocation Extension Attribute Created (Screenshot Below)
* Policy created for this Script w/ a trigger of networkStateChange
* Smart Computer Group to use for exluding off network computers from policies
* API user w/ the following permissions:
 * Read & Update permission for Computer Objects
 * Read permission for Computer Extension Attributes

Exit Codes:
* 0 - Everything is Successful
* 1 - Jamf Pro is not reachable
* 2 - Unable to update network location on Jamf Pro


Written by: Joshua Roskos | Professional Services Engineer | Jamf

Created On: October 24th, 2016 | Updated On: October 24th, 2016

___

**macLocation Extension Attribute**

![alt text](/imgs/macLocation-EA.png)

*Create an extension attribute exactly as shown!*


**macLocation Extension Attribute**

![alt text](/imgs/macOSDevicesOffNetwork-SG.png)

*Create a Smart Group as shown to be able to use for scoping.*


**Check Network Location Policy*

![alt text](/imgs/checkNetworkLocation-Policy.png)

*Create a Policy as shown here.*

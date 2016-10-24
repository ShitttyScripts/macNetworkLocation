#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
#
# Copyright (c) 2016, JAMF Software, LLC.  All rights reserved.
#
#       Redistribution and use in source and binary forms, with or without
#       modification, are permitted provided that the following conditions are met:
#               * Redistributions of source code must retain the above copyright
#                 notice, this list of conditions and the following disclaimer.
#               * Redistributions in binary form must reproduce the above copyright
#                 notice, this list of conditions and the following disclaimer in the
#                 documentation and/or other materials provided with the distribution.
#               * Neither the name of the JAMF Software, LLC nor the
#                 names of its contributors may be used to endorse or promote products
#                 derived from this software without specific prior written permission.
#
#       THIS SOFTWARE IS PROVIDED BY JAMF SOFTWARE, LLC "AS IS" AND ANY
#       EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#       WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
#       DISCLAIMED. IN NO EVENT SHALL JAMF SOFTWARE, LLC BE LIABLE FOR ANY
#       DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#       (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#       LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#       ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#       (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
#       SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# 
# This script was designed to be used in conjunction with an extension attribute in Jamf Pro
# that will be able to help us identify whether a macOS device is on the network or not.
#
# To accomplish this the following will be performed:
#			- Upon NetworkStateChange ping designated local server
#			- If a response is received, report Internal
#			- If no response is received, report External
#
# REQUIREMENTS:
#			- Jamf Pro
#			- macLocation Extension Attribute Created
#			- Policy created for this Script w/ a Trigger of NetworkStateChange
#			- Smart Computer Group to use for exluding off network computers from policies
#			- API User w/ the following permissions:
#				- Read & Update Permssion for Computer Objects
#				- Read Permission for Computer Extension Attributes
#
# EXIT CODES:
#			0 - Everything is Successful
#			1 - Jamf Pro is not reachable
#			2 - Unable to update network location on Jamf Pro
#
# For more information, visit https://github.com/jamfprofessionalservices
#
#
# Written by: Joshua Roskos | Professional Services Engineer | Jamf
#
# Created On: October 24th, 2016
# Updated On: October 24th, 2016
# 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# VARIABLES
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

# URL of the Jamf Pro server (ie. https://jamf.acme.com:8443)
jamfProURL=""

# API user account in Jamf Pro w/ Update permission
apiUser=""

# Password for above API user account
apiPass=""

# IP address of local server that in not available externally
localServer=""

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# CHECK IF JAMF PRO IS AVAILABLE
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

echo ""
echo "=====Checking Network Location====="
echo "Checking if Jamf Pro is available..."
/usr/local/jamf/bin/jamf checkJSSConnection -retry 30 > /dev/null 2>&1

if [[ $? != 0 ]]; then
	echo "   > Jamf Pro is unavailable..."
	echo "=====Exiting Check====="
	exit 1
else
	echo "   > Jamf Pro is available!"
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# CHECK IF EXTENSION ATTRIBUTE IS INSTALLED
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

# Name of extension Attribute in Jamf Pro
eaName="macLocation"
eaID=$( /usr/bin/curl -s -u ${apiUser}:${apiPass} ${jamfProURL}/JSSResource/computerextensionattributes/name/${eaName} | perl -lne 'BEGIN{undef $/} while (/<id>(.*?)<\/id>/sg){print $1}' )

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# CHECK IF ${localServer} IS AVAILABLE
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

# Ping ${localServer} to see if available
echo "Checking if on the corporate network..."
ping -c 3 -o ${localServer} > /dev/null 2>&1

# Check if ping was successfull or not
if [[ $? != 0 ]]; then
	result="External"
	echo "   > Computer is currently outside the corporate network."
else
	result="Internal"
	echo "   > Computer is currently on the corporate network."
fi

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# LOOKUP JSS COMPUTER ID
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

macSerial=$( system_profiler SPHardwareDataType | grep Serial |  awk '{print $NF}' )
jamfProId=$( /usr/bin/curl -s -u ${apiUser}:${apiPass} ${jamfProURL}/JSSResource/computers/serialnumber/${macSerial}/subset/general | perl -lne 'BEGIN{undef $/} while (/<id>(.*?)<\/id>/sg){print $1}' )

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# SEND NETWORK LOCATION TO JAMF PRO SERVER
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

echo "Sending network location to Jamf Pro..."
/usr/bin/curl -sfku ${apiUser}:${apiPass} -X PUT -H "Content-Type: text/xml" -d "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?> <computer> <extension_attributes> <extension_attribute> <id>${eaID}</id> <value>${result}</value> </extension_attribute> </extension_attributes> </computer>" ${jamfProURL}/JSSResource/computers/id/${jamfProId} > /dev/null

if [ "$?" != "0" ]; then
	echo "   > Error updating network location on Jamf Pro."
	echo "=====Exiting Check====="
	exit 2
else
	echo "   > Successfully updated network location on Jamf Pro"
fi

echo "=====Completed Check Successfully====="

exit 0
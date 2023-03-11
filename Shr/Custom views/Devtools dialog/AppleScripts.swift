//
//  AppleScripts.swift
//  Shr
//
//  Created by Christopher Inegbedion on 11/03/2023.
//

import Foundation

struct AppleScripts {
    static var startDaemon = """
-- Define the path to the daemon executable
set daemonPath to "/Users/chrisineg/Desktop/go-shr/go-shr"

-- Define the path to the plist file for the daemon
set plistFile to "/Library/LaunchDaemons/com.shr.shr_d.plist"

-- Define the path to the log file for the daemon
set logFile to "/Users/chrisineg/Desktop/go-shr/shr.log"

-- Create the plist file for the daemon
set plistContent to "<?xml version='1.0' encoding='UTF-8'?>
<!DOCTYPE plist PUBLIC \'-//Apple//DTD PLIST 1.0//EN\' \'http://www.apple.com/DTDs/PropertyList-1.0.dtd\'>
<plist version=\'1.0\'>
<dict>
    <key>Label</key>
    <string>com.shr.shr_d</string>
    <key>ProgramArguments</key>
    <array>
        <string>" & daemonPath & "</string>
    </array>
    <key>StandardErrorPath</key>
    <string>" & logFile & "</string>
    <key>StandardOutPath</key>
    <string>" & logFile & "</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>UserName</key>
    <string>root</string>
</dict>
</plist>"

-- Write the plist content to the file using plutil
do shell script "echo " & quoted form of plistContent & " | plutil -convert xml1 -o " & quoted form of plistFile & " -" with administrator privileges

-- Set the permissions for the plist file
do shell script "chmod 644 " & quoted form of plistFile with administrator privileges

-- Load the daemon
do shell script "launchctl load " & quoted form of plistFile with administrator privileges

-- Start the daemon
do shell script "launchctl start com.shr.shr_d" with administrator privileges
"""
    
    static var stopDaemon = """
                        set daemonLabel to "com.shr.shr_d"
                       
                       -- Unload the daemon
                       do shell script "sudo launchctl bootout system /Library/LaunchDaemons/" & daemonLabel & ".plist" with administrator privileges
                       
                       
                       -- Remove the daemon's plist file
                       try
                       do shell script "sudo rm -f /Library/LaunchDaemons/" & daemonLabel & ".plist" with administrator privileges
                       on error errorMessage
                       display alert "Error removing plist file" message errorMessage buttons {"OK"} default button "OK"
                       end try
"""
}

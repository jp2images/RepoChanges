A collection of PowerShell scripts that will query the Beckhoff Azure DevOps project repos for the Tunnel project and then query the GitLab project repos for other changes.
A simple way to stay up to date with what code changes have been made.

To use, simply run the "changes" command at the PowerShell prompt.

NOTE: To run the scripts easily the PowerShell profile script, "Microsoft.PowerShell_profile.ps1" will have to be modified. Use the one from the repo–customized for me, Jeff Patterson–or modify your own. The one in the repo has a call to an additional PowerShell add-on called oh-my-posh which provides a nicer prompt than the default.

The file Microsoft.PowerShell_profile.ps1 runs automatically whenever PowerShell starts for the first time. To restart the script without closing and reopening PowerShell: from the PS prompt type ". $PROFILE" from the profile script location. (must include the . in the command to tell PowerShell to look in the current directory.)

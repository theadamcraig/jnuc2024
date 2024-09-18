# JNUC-2024
For JNUC 2024 Tick Tock Tech Presentation:

## ProfileAction

A bash function with several strategic uses to control the installation or removal of Jamf Configuration profiles with a script.

 - “Custom Triggers” for profiles.
 - Automate individual installs/removals of profiles.
 - Check conditions before installing a profile.
 - Have a pre/post-install script for a profile.
 - Strategically Roll Out or Verify profile changes.


### ProfileAction Extension Attribute

Take the ProfileAction - EA.sh script and set it up in your jamf pro instance as an extension attribute

![ProfileAction ExtensionAttribute](https://github.com/theadamcraig/jnuc2024/blob/main/images/profileActions_extensionattribute.png)

### ProfileAction Smart Groups

You can use this extension attribute to make smart groups.

One group to control the installation
![ProfileAction Install Example](https://github.com/theadamcraig/jnuc2024/blob/main/images/profileActions_installexample.png)

I also like to include the ProfileName criteria in this group so that computers that have the profile installed remain in scope.
Note that if you do this then renaming the profile could break the scoping and have an impact on your end users.


One group to control the removal
![ProfileAction Remove Example](https://github.com/theadamcraig/jnuc2024/blob/main/images/profileActions_removeexample.png)


### ProfileAction Configuration Profile scoping

Scope the configuration profile to the INSTALL: smart group and exclude the REMOVE: smart group.

### ProfileAction Function

Once this is set up you can now use the ProfileAction function in a script to install or remove the configuration profile from within a script.

This command accepts a number of different functions:

 – install : writes an INSTALL command
 – remove : writes a REMOVE command
 – empty : removes previous commands from this script
 – check : echo out the current commands from this script
 – forceNoRecon : disables inventory update

Remember that you want to use your recons responsibly, so forceNoRecon is a good option when you are stringing multiple actions together, or if you are using profileAction to do a targeted install/removal but not an urgent one.

You can also save on recons by checking to see if a command is already there (in examples where a script may run multiple times)

You can also pair this with the waitForProfileInstall or the waitForProfileRemoval script.

```
profileName="JNUC 2024 Exampe"

commandCheck="$(profileAction --check )"

if [[ "$commandCheck" != "REMOVE: $profileName" ]] ; then
    profileAction --remove "$profileName"
fi

waitForProfileRemoval "$profileName"

echo "Now we know the profile is gone and can do the rest of the stuff we want to do."

profileAction --empty --forceNoRecon
```


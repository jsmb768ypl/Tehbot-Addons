<h4>CombatAnoms - Behavior</h4>

- [X] Initial Release 
- [ ] Add the ability to dock up when needed
    - [ ] Check if we need to reload drones, dock up and reload drones
    - [ ] Check if we need to repair, if we do dock up and repair
- [ ] Add the ability to use something other than drone boats

<p>
This was originally written by Elusif, I have modified it and am trying to get it working 100%. Currently it can repair, undock and run the anoms you set it run, dock up if local has unfriendlies and undock after they leave. It currently can't reload drones or repair while running. I have modified this to only work with drone boats. 
</p>

Settings:
* Check the box that says "Use Drones"
* Check the box that says "Drone Boat?"
* Bottom left box is to set your home station bookmark.
*  Use the tab at the top to pick your location, then set the priority of what you want to run. Priority 1 - Highest, 3 - Lowest, 0 - Disabled

Requirements:
* Issues can be logged here to me and not on the main Tehbot github allowing me to work on them at my pace.
* You can form this and not worry about messing up any of the core Tehbot files

Required Addons:
* (Standard Addons) LocalCheck, TargetManager, LavishNavTest, WatchDog, ISXSQLiteTest
* DroneControlCA

<p>
After placing these files in their respective folders, you will need to update the main bot file "Tehbot.iss" <br />
You will need to add the following lines of code with the other minimodes:
  
```
#include minimode/DroneControlCA.iss
#include behavior/CombatAnoms2.iss
declarevariable DroneControlCA obj_DroneControlCA script
declarevariable CombatAnoms2 obj_CombatAnoms2 script
```
</p>

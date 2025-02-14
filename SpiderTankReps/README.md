<h4>SpiderRepTank - Minimode</h4>

- [X] Initial Release
- [ ] Add the ability to only use a certain number of reps on our rep target leaving the other reps free to use as needed on anyone who needs them.
    - [ ] Add the ability to set a threshold for when to rep others
    - [ ] Add the ability to set if we should only rep those found in the participant list or anyone within range in fleet.
- [ ] Add the ability to say if we are using cap transfer or not

<p>
This minimode will add each user that is running this minimode to a sqlite list, it will then as the name suggests lock and begin repping the person below them in the list, if they are the last person in the list then they will lock and rep the first person in the list. It will detect if you have shield or armor reps and use all of them on the specific target. It will also assume you have cap transfer and use all of those as well. You must be cap stable, we do not turn reps on and off based on cap we only activate and leave running the reps & cap transfer. You have to either manually pilot or use some way to pilot the ships, we do nothing to make sure we are in range of our specified rep target, this minimode is strictly for handling the assignment of the spidertank position and keeping the reps on them. 
<br />
</p>
<p>After placing in your minimode folder, you will need to update the main bot file "Tehbot.iss" <br />
You will need to add the following lines of code with the other minimodes:

```
#include minimode/SpiderTankReps.iss
declarevariable SpiderTankReps obj_SpiderTankReps script
```
</p>

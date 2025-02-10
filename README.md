<a id="readme-top"></a>

  <h3 align="center">Tehbot - Behviors & Minimodes</h3>

  <p align="center">
    Here you will find behaviors and addons that you can download and add to your Tehbot, this is not a full working version of Tehbot and only meant for me to keep my Behaviors and Minimodes updated.
    <br />
    <a href="https://github.com/othneildrew/Best-README-Template/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    &middot;
    <a href="https://github.com/othneildrew/Best-README-Template/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>

<!-- ABOUT THE PROJECT -->
## About The Project

I wanted to contribute to the Behaviors & Minimodes being written for Tehbot to help grow the use of it without having to submit pull requests for each update and without having to add to the creators plate of then supporting my additional code.

Here's why:
* If I ever stop supporting the code it will not be on the Tehbot creator to then pickup where I left off.
* Issues can be logged here to me and not on the main Tehbot github allowing me to work on them at my pace.
* You can form this and not worry about messing up any of the core Tehbot files

### Built With

Below you will find a link to Tehbot fork we are using when writing these, some are using sqlite and that is why I choose to use the forked version over the core version (along with a bunch of other quality of life changes).

* [Tehbot Fork](https://github.com/Francisco-Franks/Tehbot)
* [ISXSQLite Repo](https://github.com/isxGames/isxSQLite)

<!-- GETTING STARTED -->
## Getting Started

Each script listed below will have inside of it the required files in the same structure as Tehbot. All you have to do is download the folder you want and then copy its contents into Tehbots root folder.

## Scripts & Their Roadmaps

<h4>SpiderRepTank - Minimode</h4>
<p>
This minimode will add each user that is running this minimode to a sqlite list, it will then as the name suggests lock and begin repping the person below them in the list, if they are the last person in the list then they will lock and rep the first person in the list. It will detect if you have shield or armor reps and use all of them on the specific target. It will also assume you have cap transfer and use all of those as well. You must be cap stable, we do not turn reps on and off based on cap we only activate and leave running the reps & cap transfer. You have to either manually pilot or use some way to pilot the ships, we do nothing to make sure we are in range of our specified rep target, this minimode is strictly for handling the assignment of the spidertank position and keeping the reps on them. 
<br />
</p>

- [X] Initial Release
- [ ] Add the ability to only use a certain number of reps on our rep target leaving the other reps free to use as needed on anyone who needs them.
    - [ ] Add the ability to set a threshold for when to rep others
    - [ ] Add the ability to set if we should only rep those found in the participant list or anyone within range in fleet.
- [ ] Add the ability to say if we are using cap transfer or not

<h4>StructureKiller - Behavior</h4>
<p>
This behavior allows you to set who your leaders is, it will then begin approching the leader, if you are the leader then it will orbit the target structure. This will begin locking and firing on the closest structure available to us (Citadels & Customs Offices). This currently is specific to the Triglavian ships (Tested so far using Kiki and Vedmaks)
<br />
</p>

- [ ] Initial Release (Unknown if it will be publically released)
- [ ] Add the ability to monitor for non fleet members
    - [ ] Add options for how to handle non fleet members on grid with us (Run or try to fight)
    - [ ] Handle ammo changes based on target ranges if fighting
    - [ ] Add the ability to go to a specific bookmark or structure if we want to run away.
- [ ] Add the ability to set the target structure in advance
    - [ ] Add the ability to return to a structure or bookmark when the the target structure no longer exists
- [ ] Add the ability to use drone boats instead of triglavian ships
    - [ ] Add the ability to assign the drones to the leader for fighting purposes



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement".

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

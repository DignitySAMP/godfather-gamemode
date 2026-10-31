# The Godfather

The original Godfather LS/SF roleplay gamemode, with up to date includes, plugins and fully modularized and modernized, before GTA 6.

This has been fully tested on an open.mp server with a 0.3.7 client. It utilises PawnPlus tasks for queries, dialogs and pp-hooks for hooks. MySQL is added with a migration per table. I've added a prebuilt `godfather.sql` with the original release's data (houses, businesses, ...). 

Passwords are now encrypted using bcrypt and all saved data changes on demand. Replaced strcmp and strtok with SmartCMD and sscanf but kept the original names and parameters where it matters. I've started adding menuboxes for lists and choices but got bored, although most should be supported.

Over 140 bugs were fixed and some outdated features were changed to support later SA-MP versions (the addition of auth dialogs, tutorial SetCameraPos, drive-by support, and more, see changelog below)

## Building and running

You need [sampctl](https://github.com/Southclaws/sampctl), the [open.mp server](https://github.com/openmultiplayer/open.mp/releases) (1.6.7 or newer) and MariaDB or MySQL.

Build the gamemode:

```
sampctl ensure
sampctl build linux
```

Or `sampctl build` on Windows.. 

Set up the server:

1. Unpack the open.mp server somewhere and copy `gamemodes/`, `scriptfiles/` and `config.json` from this repo into that folder.
2. Make sure your plugins folder has the following dependencies: crashdetect 4.22, PawnPlus 1.5.3, streamer 2.9.6, MySQL R41-4 and samp_bcrypt 0.4.1.
3. Put sscanf 2.13.8 in `components/`. Copy any extra files a plugin's release ships with, like the MySQL plugin's libraries on Windows.
4. Set your own `rcon.password` in `config.json`.

Set up the database:

1. Create an empty database and a user for it.
2. Import the data and structure from `godfather.sql`
3. Rename `mysql-example.ini` to `mysql.ini` in the server folder and fill it in.

Start it with `./omp-server` (or `omp-server.exe`) and connect with a 0.3.7 client on port 7777.

## Changes and fixes

### Server and infra
- Built with and tested on open.mp 0.3.7
- Added MySQL and improved saving to happen on demand (if something changes => save it)
- Properly modularized every single feature using modern practices
- Kept the original (albeit shitty) sentences but fixed some inelligible words, some spacing and capitals.
- Added basic anti driver drive-by and blocked desert eagle and sawn off shotgun drive-by's + basic anticheat to reset weapon to fists
- Added bcrypt for passwords
- Re-added and fixed the armour, health, parachute and info pickups placed in the world like the original release
- Fixed OnRconCommand returning 1 for everything, so console commands like kick, ban and exit actually work again
- Fixed weapons, health and positions not saving
- Fixed pickup hints getting cancelled by other players triggering the pickup (they weren't per-player previously)
- Fixed idlekick kicking players who just connected
- Fixed /irc kick announcing the admin's name instead of the player's
- Fixed /w, /suspect, /sellgun, /contract, /heal and the staff lookups printing "65535 is not an active player." for a missing target
- Removed /map, /modcar, /modst and /modlr from /help and /househelp as these commands did not exist(?)


### Authentication
- Originally, /login and /register was used for auth. This is arguably unsafe, so I added dialogs. The commands remain for nostalgia's sake but are not recommended.
- Origin and gender are now picked from a custom serverside menu. Birth date is entered through an input dialog, although typing the answer in chat still works, again for nostalgia sake.
- Proper password encryption, validation requirements and incorrect password caps.
- Security for /login and /register (command log masks it, and chat is no longer written to the server log. Nothing typed reaches other players.)
- Added a proper tutorial camera flow to the tutorial
- Fixed saved positions never updating
- Fixed /upgrade writing past its buffer on a long upgrade name
- Fixed /upgrade never showing the Level 4 perks line
- Fixed /upgrade refusing with "You Have 0 Upgrade Points" when you still had points left
- Fixed /buylevel saying "You gave %d unspent Upgrade Points" as a default response

### Money and payday
- Apparently money wasn't saved. It is now.
- Turned off stunt bonusses.
- Removed the dodgy anti moneycheat admin warning.
- /sellbiz previously only paid out from the till, now it also gives half of the business's price.
- Fixed payday never actually charging you for tax, electricity or rent.
- Fixed PayDay charging the electricity bill to players that don't own a house or business
- Fixed /settax changing the state vault instead of the actual tax
- Fixed the $500 hospital bill getting charged on every spawn instead of once after dying
- Fixed /stats reading money from the client (it's serverside now)
- Fixed /pay and /transfer printing "65535 is not an active player." when the target doesn't exist

### Houses
- Added DisableInteriorEnterExits
- Added 70 extra houses, as well as Sweet's, Ryder's, and Og Loc's house.
- Fixed the SFPD not having a front door
- Fixed houses and businesses not having their own virtual world (houses 10000, businesses 20000 + key)
- Fixed /exit not resetting the world properly
- Fixed interiors at inconsistent heights (lil probe inn, truck stop dinner, ... anything behind the Sherman Dam) making you fall out of the map
- Fixed HouseLevel and CHouseLevel returning 0 for houses 32 and 33
- Fixed /buyhouse and /rentroom refusing you when you have exactly the price
- Fixed /evictall only kicking the first tenant despite telling you everyone was evicted
- Fixed /setrentable validation, passing an empty buffer would set the house rent to 0 previously
- Fixed the 5 day house rule breaking at New Year
- Fixed repossession leaving the old owner a key


### Businesses and shops
- Added 122 extra businesses around SA
- A State owned shop (no owner) now never runs out of stock, has no till, and is always open and free to enter
- Kept the original Godfather economy, but expanded it to cover products, tills, extortions and the /open command
- Changed barber and food businesses to cost 250k and require level 3
- Changed 24/7, bar, clothes and other types to cost 500k and require level5
- Changed ammunation to cost 1.5m and require level 7
- Other businesses require 5m.
- Synced /buy, /drink, /clothes and /buygun to their right types, and kept the original texts and prices
- Fixed purchased items not adding the price to the till and depleting it's stock
- Fixed /edit and /asellbiz not working on the typed businesses
- Fixed /enter at special businesses comparing your key with the wrong number (only 10 and 11 did anything)
- Fixed /buybiz setting your key to the house with the same ID
- Fixed an infinite loop with /prodprice, /bizfee and /bizname 
- Fixed /buybiz and /carupgrade refusing you when you have exactly the price
- Fixed the rental boss check looking at the two gun shops instead of the Car Renting businesses
- Fixed /buy showing -$1000 for a $7500 scratch card, charging chickens and hamburgers twice, 
- Fixed /lock clearing everyone's hire key
- Fixed /buygun writing past its buffer on a long weapon name
- Fixed /buygun giving you the weapon before checking your money, and listing the wrong prices
- Fixed /drink taking your money without a cash check and always healing you

### Vehicles and fuel
- Fixed street cars above id 253 never respawning (higher ids went out of bounds previously)
- Fixed an infinite loop with /carcolor and fixed it charging you after "You can't afford that"
- Fixed /carupgrade writing past its buffer on a long name
- Fixed /givekey taking the player's key before checking the target
- Fixed /hirecar accepting any id as a hire car
- Fixed a failed /fill making the next player who refuels pay for it (lol)
- Fixed rental cars telling you to type /exit despite /exit not doing anything
- Fixed bought speedometers not saving every time you log out
- Fixed renting a car being free until someone set /bizfee (100 by default now)


### Law and police
- Fixed the wanted level decaying once per online player and never actually reaching 0
- Fixed the wanted colour staying orange after your wanted level hit 0
- Fixed /take printing empty names and the wrong usage line when not passing proper params
- Fixed a long /suspect reason overflowing into the next crime line
- Fixed /arrest taking more cash than the suspect had, and saying nothing when the suspect was out of reach
- Fixed /camera 6 sending you to your usual spawn instead of the panel
- Fixed /uncuff, /ticket, /clear, /deliver, /ram and /accept lawyer so police, FBI and National Guard leaders can actually use them
- Fixed multiple typo's and inconsistencies in /frisk 
- Fixed INVALID_PLAYER_ID killerid's death out of bounds

### Factions
- Fixed /exit not working for the Hitman HQ
- Fixed the medic on duty count when a medic /q's
- Fixed Fire/Ambulance leaders who weren't members getting kicked out of fire trucks
- Fixed /giverank accepting targets outside your faction and defaulting to rank 0 when no param for rankid is passed
- Fixed /duty refusing police leaders

### Families and turfs
- Fixed gang zone colours being passed as text, which caused turfs to stay grey
- Fixed /giveturf's color not showing the new colour until a player respawned
- Fixed /adjust name and /adjust MOTD overflowing
- Fixed /adjust color writing the colour into the MOTD
- Fixed /adjust invite, uninvite and rank not having validation
- Fixed offline members being stuck with an unused ID when a family gets deleted
- Fixed a family without a spawn putting its members at 0, 0, 0

### Jobs
- Fixed the boxing ring by placing both fighters into the challenger's world.
- Fixed boxing reading the health native's return value, so both fighters were always exhausted
- Fixed the boxer job id's being hardcoed (it was 12 in one place and 10 in another)
- Fixed the winner's game text saying "~r~You won" when the first boxer lost
- Fixed /boxstats printing an empty title above skill 400
- Fixed taxi passengers paying the first fare unit twice
- Fixed /cancel taxi and /cancel bus doing nothing once a call was accepted
- Fixed passengers keeping a running meter after their driver /q'd
- Fixed a hitman's news post staying marked as placed after a rank 4 deleted it
- Fixed a hitman leaving with a hit assigned keeping the victim marked until they relogged
- Fixed /accept sex always adding the health bonus
- Fixed the STD message saying 4, 8 and 12 health while taking 5, 12 and 20
- Fixed a playerid overflow for offers (didn't properly clean the vars)
- Fixed /accept (sex, bodyguard, repair, refill, car, drugs), /get drugs, /materials get and /bail refusing you when you have exactly the price
- Fixed distance and self checks for /sellgun buyers BEFORE storing the gun
- Fixed the two /sellgun help blocks listing the Desert Eagle at 150 and 200 (it's 150)
- Fixed /accept drugs taking grams from a dealer that didn't have them anymore
- Fixed /deliver for paper boys saying nothing when the target was more than 8m away
- Fixed /eat never being able to print its "health is high enough" message
- Fixed /cook pizza taking its weight from the hamburgers
- Fixed the fishing cooldown ending at the first tick after the first cooldown
- Fixed cooked dishes being called "Baken Pizza" and "Baken Hamburger".....

### Phone and news
- Fixed ring and SMS tones never playing.
- Fixed phone billing array going out of bounds on the 911 to 914 lines
- Fixed a refused /call or /txt leaving you stuck on a call
- Fixed /hangup doing nothing during a 911 call
- Fixed a player whose caller disconnected keeping a line to whoever got that slot next
- Fixed a live interview partner disconnecting and leaving the other player frozen
- Fixed /news working in vehicles 97, 98 and 99 while refusing the actual news chopper
- Fixed /ad and /advertise charging different amounts for the same text

### Marriage and CK
- Fixed refusing a marriage leaving both players stuck in the ceremony
- Fixed a woman proposing to a man getting no announcement
- Fixed /accept divorce printing the Marriage Witness texts
- Fixed /divorce and /witness saying "You cannot Propose to yourself!"
- Fixed /cks accept never pairing anyone
- Fixed a CK target keeping the pending flag when the requester left
- Fixed the CK check testing the victim twice and never the killer
- Fixed /cks accept saying "Killer or Dieer"

### Events
- Fixed the paintball and karting round announcements only reaching the first player that joined
- Fixed paintball never lowering its player count when a round ended
- Fixed failing a mission on spawn wiping your completed mission number
- Fixed /mk text, game, cp, usecp and reward never printing their usage line
- Fixed the Paintball Arena and Kart Track saying "Closed" until someone bought them and used /open
- Removed the dodgy .mis(?) files by saving missions to the database

### Staff
- Added `/createhouse`, `/createbiz`, `/movehouse`, `/movebiz`, `/deletehouse`, `/deletebiz` and `/nearestinterior` for admins level 4.
- Added `/createhouse` and `/createbiz` to place a house or typed business at your feet with the nearest SA interior of a fitting size.
- Improved `/deletehouse` and `/deletebiz` to refuse owned property, the original businesses and houses with a house car.
- Fixed `/goto` and `/gethere` by making them copy the target's world.
- Fixed /destroycars destroying world vehicles 1 to 99 instead of the spawned ones
- Fixed /veh overflowing after 100 vehicles
- Fixed /freeze reading the admin level of a target that doesn't exist
- Fixed /asellbiz, /asellsbiz, /asellhouse, /house, /houseo, /biz and /sbiz not having proper validation for types
- Fixed /tv and /recon incorrectly iterating over players without a house
- Fixed a refused /tv leaving your virtual world at 255
- Fixed /gotocar, /getcar and /entercar accepting vehicle ids that don't exist
- Fixed /sethp, /setarmor, /money and /givemoney defaulting a missing value as 0
- Fixed /makeadmin, /makeleader and /setteam defaulting a missing value as 0
- Fixed /makeadmin accepting any number as an admin level
- Fixed /setteam accepting any number as a team, and its usage hint being wrong
- Fixed /tod accepting hours outside 0 to 23
- Fixed /setstat code 11 storing any number as a family member
- Fixed the /setstat usage line listing code 20 and leaving out 11
- Fixed the /makeleader and /giverank usage lines listing the wrong ranges
- Fixed /ahelp headings being off by one, listing /sp, /cam, /oldcar and /sellsbiz, and added about 30 missing staff commands

# Original Release

From the original release topic by FeaR (23.07.2007):

Static Factions:
- Police Department
- FBI/ATF Team.
- National Guard.
- Medical Department (Ambulances & Firemen).
- La Cosa Nostra.
- Yakuza.
- Mayor.
- Hitman Agency.
- CNN Studio.
- Taxi Cab Company.
- School Instructors (License system).

Tutorial:
- Will react only if you registered a new account.
- You must fill in your Sex (Male / Female).
- You must fill in your birthdate (Will automaticly calculate what age you are).
- You must fill in your Origin (Based on this, you will spawn somewhere in SA).
- After all the filling in options, you will get a tutorial containing rules etc..

Leader System (Dynamic):
- Admin can appoint a player that will then Lead a Faction (of above).
- Leader can invite Civilians (With faulty check system in it).
- Leader can kick players out.
- Leader can assign Ranks to his Members.
- As soon a Leader invites a Civilian, it will check what that Civilian will become and teleports him somewhere, where the Civilian can choose a skin that comes with that Faction.

Family System (Dynamic):
- This is done by the 2 Organisation Leader (La Cosa Nostra & Yakuza).
- Both the Organisations can recruit 5 families.
- Both the Organisations can delete their own Families.
- Players can check which families are created, and who's the Leader of it.
- Players can check which players are in a family.
- Leaders of a Family can adjust anything they like (Name / MOTD / Color / Spawn).
- Leaders can Invite / Uninvite players or give them a Rank.

Turf System (Needs some tweaks..) (Dynamic):
- There are several turfs that can be given to Families by Organistaion Leaders.
- As soon a Family get's a Turf, it will become their Color (Not fully working i think as they keep being grey).

House System:
- Still in because it was so nicely created by Astro.

Business System (Looks like Astro's, but is rewritten plus different functions):
- Uses products instead of Components & Products.
- Owner name will be shown when entering the icon.
- Extortioner name will be shown when entering the icon.
- Coordinates of going in and out will be saved.
- Level requirement active aswell.
- Basicly some of the stuff that Astro had, only i reduced it and went to Products and added Extortion.

Extortion System:
- Owners of a Business can assign a player as the business's extortioner.
- Owners of a Business can also delete the extortioner of their business.
- As soon a Business earns money, and it has an extortioner it will check if the extortioner is online and will give him 10% of the earnings the Business is about to get.

Karting System (Business):
- Located at the docks, and as soon 2 players or more are in a kart, there will be a message after 15 seconds that a race will start (Message will only be send who is in a kart).
- Automatictly ends the Kart Round after 4 minutes (Just some extra security).
- Checks whoever gets 1st / 2nd / 3rd.
- Checks if more then 2 people are still racing during a Kart Round, if not, the Round will be ended.

Paintball System (Business):
- Located at San Fierro, and as soon 2 players or more are in the Painball Arena, there will be a message after 15 seconds that a fight will start (Message will only be send who is in the area).
- Automatictly ends the Paintball Round after 4 minutes and will announce the Winner.

IRC System (NO not real, just for private channels) (Dynamic):
- Admins can assign a Channel to any player, and that player will then lead that Channel.
- Leader of a channel can set the MOTD / Set a Password / Set if a a Password is needed to come in or not / Lock the Channel / Kick someone.
- As soon you try to join a Channel, it will check if you need a Password or not.
- If you join or leave, everyone in that Channel will receive a message.
- Players can check how many players are in a Channel, and who the leader is of a Channel.
- Players use /i to talk in their Channel.

Mayor System:
- Only 1 mayor, assigned by an Admin.
- Mayor can set the Tax, that will be paid by every player online at PayDay.
- Mayor can give some of the Tax away to every online Cop / FBI / National Guard automaticly (Since Cops etc... have a bad income).

Prison System (Area51):
- Cops / FBI / National Guard can "deliver" players to Fort Demorgan (Area51) and that players is in jail for 1 hour at least.
- Players can't leave the Fort (Should be adjusted perhaps for more fun).
- National Guard (they were guarding the Fort in Godfather Server) can use the Security Building and use 6 cameras for activity.

Marriage System:
- Players can marry each other and share their House & Business.
- Players can divorce each other (One of them will have no House & Business).
- Players can propose to other players.
- Players need a witness in order to Marry.
- Players marry at the church in San Fierro.

Newpaper System (Dynamic):
- A maximum of 10 papers can be created.
- The Newspaper Faction can create a title and lines as a newspaper and it will be saved automaticly.
- Paper Boys can deliver created Newspapers at the Paper Building to players.
- Paper Boys & Newspaper Faction can check if there are any Newspapers.
- Players can read a Newspaper.

Skill System:

Job System:
- Scatterd around LS and SF their are several locations where Civilians can get a job.
- The Job information and name will be shown as soon you walk into the icon.
- You can only get a job if you don't have one yet, and are not in a Family / Faction.
- As soon you accept the job, you get a Job Contract, which you have to forfill for at least 5 hours (ingame time) untill you can quit it.
- When you have a Job, you have access to several commands.

Detective: /find.
Lawyer: /free.
Whore: /sex.
Drugs Dealer: /selldrugs.
Car Jacker: Jack any car & /dropcar (sell a car).
Car Mechanic: /repair /refill /duty.
Bodyguard: /guard.
Arms Dealer: /materials /sellgun.
Car Dealer: /sellcar.
Boxer: /boxstats /fight.
Paperboy: /papers /bring /deliver.

CK (Character Kill) System (Dynamic):
- There are only 10 spaces available, if full the CK can't be requested.
- Players can request a Character Kill on someone else, and must be accepted by an Admin.
- Admins can delete the CK out of the list if they don't agree.
- As soon an Admin allows a CK, the system will check if both those players are online.
- If the player kills the other player that he / she wanted to CK, that player is CK'd and can't login on that account anymore.
- If the player that is about to be CK'd, but kills the player that requested the CK, that player instead is CK'd and got pwned and has same result as above.

License System (An idea by someone on the Godfather Forum, thats why it's created this way, noy my own way):
- License Faction can RP their lessons, and eventually give one of the Licenses available (Driving / Flying / Sailing / Fishing / Weapon).
- License Faction can start a lesson (Car / Plane) with a player so he / she can enter that vehicle (Else that vehicle is locked).
- License Faction can easily stop the lesson.
- Cops / FBI / National Guard can take away players Licenses.
- Players can show their Licenses to other players.

Drinking System:
- Players can drink at several pubs and special places.
- Players can choose several things to drink.
- Drinks that contain alcohol can eventually get you drunk for a while.
- If a player is drunk, he will walk drunk every xx seconds (Can be adjusted if you like).
- If a player is drunk and drives the car will change position every xx seconds.

Boxing System:
- Players that have the Boxing job can fight against each other.
- It checks if the ring is not taken at the moment.
- If players win, they will earn Points in their Boxing Skill.
- Players can get several titles the more they fight (Can be adjusted if you like).
- Players can check how many fights they won & lost, and see who is the current champion.
- If a player beats the current champion, there will be a News Message that he's the new champion.
- As soon the champion will fight, the fight will be announced in a News Message and the waiting time for the round to begin will be 60 seconds (normally it's 20 seconds).

Service System:
- Players can call for a Taxi / Bus / Medic / Mechanic to help them out.
- System checks if the Faction that is being called, if anyone is on duty.
- Those Factions that can be called, can choose if they accept the call or not.
- As soon a call get's accepted, the accepter get's a checkpoint to the caller untill he reached that player.

Tie & Tazer System:
- Only Family Members / Leaders can use the Tie and Untie functions.
- You can only Tie someone while both the players are in a car (Just RP the player in, point a gun or something).
- If the player that's being tied is tied for 3 minutes, the rope will get lose and the player is free.
- Only Cops / FBI / National Guard can use the Tazing function.
- If a player get's tazed he will be stunned for x seconds + after effect (bit weird walking).

Taxi & Bus System:
- Check if you are in one of the 2 factions and are in a Taxi or a Bus.
- Busses can only use a static fare, that will be paid immediately when a player enters the bus.
- Bus Driver and the passenger will both get a message they paid, and how much.
- Taxi's can set a fare, that will be paid every xx seconds, since taxi's use a taxi meter in real life too.
- Fare and new fare increasing time will be shown on top of the screen.
- The total fare amount will be paid to the Taxi Driver as soon the passenger steps out.

Hit Contract System:
- Hitman Agency faction can use a portable computer to: See news / Get a contract / Assign a contract to a hitman (Rank needed) / Order a weapon package / Check the ranks of online Hitmen.
- Before a contract can be given to a Hitman, there needs to be searched for a contract (automaticly search).

Weapon Creation System:
- The Arms Dealer job can gather packages, that can later be transformed into Materials.
- With Materials Arms Dealers can create weapons, and sell them to players.

Fishing (An idea of Cops & Robbers):
- Checks if you have a fishing License or not, or you will commit a crime.
- Checks if you have caught to many fishes in to little time, since you can sell the fishes and players will do this all the time to get rich.
- Checks what Level your Fishing Skill is, based on this you can catch better fishes.
- You can see how many fishes you have caught and which.
- You can throw back your last caught fish.
- You can throw all your caught fishes away.
- You can release your last caught fish.

Cooking:
- You can cook several things, like fishes and stuff from the 24/7.
- You can see what you have cooked and how many space you have left.
- You can eat whatever you have cooked.

Ingame Mission Creating System (Dynamic):
- Works only if you are an Admin.
- Admins can easily save and load a new Mission.
- You can create text messages & Game text messages.
- You can save the coordinates where players need to go to.
- You can give a title to your Mission.
- You can give a reward to your Mission if a player succeeds to finish it.
- You can choose if the players will receive checkpoints, or not (If not then they really have to search and it's all based on RP).
- Players can only do a mission once, even if the mission get's reloaded, since the number of the mission get's saved into the players account.
- When a new Mission get's loaded, players can go to the Mission Building and start their Mission.

Premium Account System (Bonus Features for players):
- Your Interest Rate (for each PayDay payment) goes up.
- Your Gas Can (from /get fuel) will be saved into your account.
- You can block Whispers.
- You can turn your Phone on / off.
- You spawn with full health.
- You can quit a job at 1 hour played, instead of 5.
- You are able to get better house cars.
- You will receive your saved weapons on login and after using /tv.
- Every 5 PayDay's you have you'll get an extra Respect Point.
- If you use /buylevel and you have more Respect Points then the level costs, you will get them back to advance youself to the process of the next level.
- On every PayDay, you will get your normal PayCheck, plus half of it as a Bonus.

## Credits

- Fear, for The Godfather.
- Astro (Denver), for PEN1.
- Tratulla for the `.ini` functions, Morph for the name tag timer, and the author of the fuel
  system on the SA-MP forums.
- open.mp, IS4 (PawnPlus), AGraber (pawn-plus-mysql), Y_Less (sscanf), Yashas (SmartCMD),
  Sreyas (samp-bcrypt), Incognito (streamer), Zeex (crashdetect), Slice (strlib)


/*
    TEDDY - General graphics application library
    Copyright (C) 1999, 2000, 2001  Timo Suoranta
    tksuoran@cc.helsinki.fi

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

/*!

\page p_plan Planned features for glElite
  
\section s_todo Todo


  blending
  polygon modes
  glDrawElements
  glPointSize


\section s_brief_review Brief review of features in original Elite:


Player can be in space or docked. While in-space, player can
fly in space, combat with other ships, attempt docking, crash
to planet, jump to another solar system, jump to another galaxy,
collect cargo with fuel scoop, collect fuel near stars with
fuel scoop and shoot asteroids to collectable minerals.

While docked player can buy or sell cargo and buy equipment.
Docked or in space, player can browse local or galaxy maps,
view information on planets and choose hyperspace destination.

The trading system is based on products and credits. Products'
prices and availabilities are based on planet type, modified
with some fluctuation.

Player can fly only one ship, although a carge space expansion
could be bought.


\section s_extended_base Extended base feature in glElite:


Player will manage bases and shipfleets. Player can establish
base by buying, renting or building one. Building requires a
place for base. This place can be rented, bought, or simply
taken, if nobody objects. Base can be used to store goods and
ships, maybe other things as well. A small base on not so hot
place is cheap to rent. A small base will cost some money to
build; an unimportant place costs nothing to be taken. A hot
planet might not have free places at all, so cost to rent or
buy a base or place will be high.

There will be public bases that provide basic services like
maintainance and storage for proper rent. Bases' main purpose
is to provide storage and services. Most common public service
are kept by fuel companies; ships can dock/land on fuel companys
public base and fill up their fuel tanks.

Another service is trading, though in glElite there will be no
single credit system. Not all system share single currency unit,
and some places only use exchanging of goods for trade, without
money.

Services can of course be combined, such that in the same place
you can do trading, buy equipment and fill your fuel tank. But it
is likely that hot places have specialized bases for different
purposes. And some goods must be delivered to specific companies
bases or even specific bases to be able to trade it.

In hot places, there will be a huge amount of bases. There will
be specific navigation utilities to help find, locate and bookmark
favorite or otherwise interesting places.

Player can also rent his places and bases. To gain wealth in
systems that do not use money, storing goods in bases is only
option.

Base must be either protected or secret - otherwise it is a
good target for pirates. Hot places have public protection
which cames with the price you pay for it, but you can also
add your own defensive equipment. This is recommended especially
if you have valuable content in your base, and there is no
public protection.

Keeping a base secret will require high skill and knowledge.

Some systems may have strict regulations for bases, and there
may be monopoly such that you are not allowed to have private
bases or places at all. Special arrangements are still possible,
and if you manage to keep your base really secret, nobody can
complain about it.


\section s_space_combat Space combat in glElite


The normal dogfight style combat will not be present in glElite.
I assume that technology will make manual sighting and other
dogfight operations silly. Combat in glElite is more based on
technology. And since player can control not only a single ship
but fleets of ships, the combat will be different anyway.

All of the combat action will happen near places - usually, maybe
always bases - that are not moving, or have pretty fixed routes.

Although player can control large fleets in glElite, the game
is designed in such way that only by using brute force player
will not gain success. Much more success is gained by having
small, even single ship fleets in strategic places. There will
be many other fleets in the game, the player will not be alone
there, and important key to success is influencing other fleets;
player who tries to do things alone is doomed. Spending a long
time to build a large fleet will be a waste of time, time which
is much better spent by making allies.


\section s_role_playing Role-playing elements in glElite:


Player is encouraged to make allies. I plan that significant
part of the game content will be unaccessible (or really hard
to do) if player does not use company.


However, nobody will be absolute friend or enemy. Each fleet is
controlled by social group. Groups have properties, which define
why, how, and what the group does. These groups will be dynamic.

Some important large groups may be set to be immortal, such that
they can be reduced and changed, but they will never completely
change or disappear. I have planned 9 different alien races to
interact in the local space; The races will always remain there.


\section s_equipment Equipment in glElite:


Technology plays very important role in glElite.


\subsection s_tech_list Technology and equipment ideas


All equipment will have 'technology angle'. Different
races have different tech angle. Equipment is only
effective to same angled equipment. The effectiveness
factor is cos( difference of angles ) when devices
interoperate.

Different angles can be combined, but converters and adapters
are very high cost and rare technology. The angle of race
and device is totally hidden from the player. Player can only
experiment and observe the results.

Many equipment can not be used with heavy shielding, or their
effect is limited. Shielded equipment is much harder to scan as
well. Shielding can be equipment specific, or less precise, but
in both cases shielding can usually be altered on the fly.

All equipment has power consumption, space and environmental
requirenments. Most devices have anti-devices (which ara not
listed).

<ul>
<li>computer database
<li>navigation computer
<li>combat computer
<li>scanner
<li>targetting system
<li>holograph projector
<li>communication relay satellita
<li>intelligence probe satellite
<li>drive
<li>translation weapon/tool
<li>rotation weapon/tool
<li>EM field transformator (antigravity, tracktor beam etc.)
<li>EMP weapon (tool)
<li>laser beam/pulse
<li>missile
<li>mine
<li>shield
<li>hull
<li>turret weapon droid/satellite
<li>intelligence droid/satellite
<li>portable/satellite shield generator
</ul>


\section s_flight_modes Flight modes


There will be no time acceleration, and no jump
systems. All drives translate ships in realtime.
Light is considered to have unlimeted speed.

Some drives use acceleration to move ship by
traditional mechanics, but others completely
bypass them and use more advanced technology.

Gravity and other forces can affect spaceships,
but ships can have equipment to nullify, lessen
or transform these effects.

As result, navigation inside solarsystems is greatly
easier than known real life. Equipment can still use
gravity and other forces to gain interesting or otherwise
useful effects.


\section s_navigation_ideas Navigation ideas

	
All interesting action will happen near planets or other
usually large) bodies. Orientation and state of ship,
local space and nearby bodies must be provided.

<ul>
<li>sector: longtitude, latitude, altitude; deltas, components
<li>speed, angular velocity, roll, pitch; deltas, components
<li>gravity, atmosphere density; range visualizations
<li>equipment status and control
</ul>

Finding targets and understanding relations is important.
Thus target sector and distance to target must be provided.

Near-large-body navigation is different from deep space
navigation. Ships must be able to orbit. Sling-shot effect
must be able to be utilized. Nothing from the other side of
large body can be seen or even known at all, without intelligence
and relay satellites. Thus by nagiating close enough, a large
body can be used as effective cloak.

On the other hand, gravity and atmosphere density will cost
fuel and shielding at lower altitudes.

Different altitudes in atmosphere can have very different
proporties. A wind of few hundred kilometers per hour in
one level can provide nice lift, or a really hard obstacle.
Different altitudes and storm/cyclode centers must be
identifiable.

Still, glElite is not meant as atmosphere flight game.
Space, near large bodies but usually not at lowest
altitudes will have the most role.

Planet orbits, and near-large-body-space in general, could
be resources on active (high population) places.

Investigate possibility of submarine like flight models for
planets with liquid 'atmosphere'.

Navigation autopilot operations:

<ul>
<li>face target
<li>match/keep speed
<li>match/keep distance
<li>match/keep position
<li>match/keep roll
<li>move to target
<li>stop translation
<li>stop rotation
</ul>


\section s_encounters Encounters and combat


Combat will not be random encounters like it used to
be in Elite, Frontier and Frontier: First Encounters.
Action is tried to make less dog-fight and more high-tech,
and less lethal. If you get into combat, you are more
likely to survive it, but you may lose parts of what you
have. Part of the game idea is that to achieve some things
you have to 'lose' on purpose.

Most encounters will not try to destroy you. Usual
behaviour is to ignore or avoid contact. This is very
common when alien races meat each other, as 'you will
never really know them'.

When you encounter someone, it is possible that they
attach a tracking device to you.

If you try to completely destroy someone, it is highly
likely that cargo they leave is trapped.

When ship is neutralized (disabled), it is possible that
it does a self destruction (especially when meeting alien
races - they newer let you get their technology).

Pirates seldom destroy you; instead they will steal
part of your cargo (and probably rob you next time
as well). Why to cut the feeding hand?)

Usually defensive equipment is much more efficient
than offensive.

Lone ships and small groups are not only encounters.
There will be large convoys as well.


\section s_environment Environment


Events will be taking place in a local space. The area
is much smaller than Frontier or even Elite galaxy. Units
are not realistic, so I can not give measures in lightyear
or anything.

The local space will contain solar systems, but distances
in and between solarsystems are made 'interesting', not
realistic.

Different areas in the environment will be different, such
that safe systems can be quite safe, while other places can
be very lethal (without proper skills and equipment).

There will be a social system.


\section s_bases Bases


Player not only controls a ship, but also has a home base.
(or several bases). Player can also rent, buy or construct new
bases, if he has suitable place and resources. Different places
for bases have different properties. A well-known planet with
good protection will be a safe but highcost place for base. On
the otherhand, a small rock inside a huge asteroid field costs
nothing, but has to rely on its own protection (though little
protection is needed if you can keep that base undetected).


\section s_trading Trading


No single 'credit' currency is acceptable all over
the local space. Instead, trading will be based on
good old 'goods exchange'. Player wealth is collected
by (trading and) collecting cargo. Since ships' cargo
spaces are limited, bases are important as you can store
cargo in them.

Pirates can track you to your base and rob your base.
Player can also like this approach, as it gives lots of
excitement and wealth quickly.

Resource production is limited, and many resources have
regulated. Taking important goods to other than primary
destinations may be illegal.

Large companies may control trading. Instead of making
profit for yourself directly, you may have to sign
trading contract for other company. In that case your
profit will be much smaller, as your job is only to
transport goods.

There will also be guilds for specific kinds of good.
They are usually only local though.


\section s_bodies Large and other bodies


<ul>
<li>planet
<li>moon
<li>asteroid
<li>comet
<li>gas/? cloud
<li>satellite
<li>ship
<li>dropship
<li>cruiser
<li>carrier
<li>transporter
<li>generation/explorer ship
<li>docking station
<li>planet defence grid
<li>space place
<li>floating city
<li>death star
<li>hollow planet
<li>planet vessel
<li>star-ship
<li>blackhole-ship
<li>kvasar-ship
<li>travel agency
<li>mining
<li>storing company
<li>defence, security comp
</ul>


\section s_mission_ideas Mission ideas


Each missing will have antimission, such that the mission
is to nullify the other mission. Player can also ask someone
else to do any of these missions for him (delegation. Missions
can also be combined with several objectives. Player can also
agree to take the mission with no intentions to actually
accomplish it. For such reasons, important missions usually
should have backup missions (non-player characters or other
players could take them). Player may also try to provide
false information about him/her/itself, as the one who is
offering the mission usually checks background.

Player may or may not know if he is doing the main mission
or the backup mission. The mission objective may also change
during the mission.

<ul>
<li>rent/loan room, storage, space that you own
<li>rent/loan equipment

<li>work as relay station
<li>interference communications
<li>interference equipment

<li>escort, protect target
<li>rescue ships, evacuate ships, stations

<li>kidnap
<li>tow ship
<li>steal ship

<li>perform research operation
<li>test new or other equipment
<li>set up outpost, base, station
<li>diplomacy
<li>bribe
<li>recruit
<li>mine asteroids, other mineraldeposits
<li>trigger environmental event

<li>trade goods, equipment, information etc.
<li>transport cargo
	<ul>
	<li>what? where? why?
	<li>type of cargo? equipment? other ships? troops? passangers? message?
	<li>intentionally false or real cargo?
	<li>from small to large business
	<li>might only pay for delivery
	<li>possibility to steal the cargo
	<li>may include tracking device
		<ul>
		<li>which could be disabled
		</ul>
	<li>player may also hire other ships to transport cargo
	</ul>
<li>destroy cargo
<li>steal cargo / item (from ship / convoy / base)
<li>relocate cargo
<li>replace cargo

<li>intelligence, spy
<li>false information as anti-intelligence
<li>project false event (special projector equipment, hologram)
<li>patrol area
	<ul>
	<li>rules of engagement?
	<li>reports? report requirements?
	<ul>
	  <li>observe situation, balance
	</ul>
	<li>collect samples?
	</ul>
<li>delay ship / convoy
<li>block traffic
<li>control traffic - traffic control

<li>disable - destroy ship / convoy / base
<li>relocate (hostile?) targets
<li>seek and destroy, assasination
<li>secure area

<li>backup mission
<li>

</ul>


\section s_plot Plot idea list


<ul>
<li>local fleets, groups of ship
<li>best, top pilots ranking system, list (local)
</ul>


The gaming area is split into 9 sectors, named
A - I as in below chart:

<pre>
A B C    <-- Rough map of game space
D E F
G H I
</pre>

Each sector is populated by one race. Each race has
very specific and different properties.

Important role in the game is information. Information
in game is provided in computer databases. In the beginning
player is given a limited set of computer databases. Later
player can obtain (with various methods; trade, steal,
discovery) new databases. Information contained in the
databases may not be exact, or correct at all. Many things
will change as player finds out a very different information
that is not originally provided.

Below each sector and associated races are described. There
are also few special races not specifically related to any
sector, listed after sectors.


\section s_sector_a  SECTOR A - Filled with deadly debris and gas clouds


This sector is not accessible without special equipment.
The religous humanoid race in this sector is only known
by sector-I-race in the beginning. The race has high
technology, hidden deep inside home planet, but they keep
it hidden and do not enter space at all.

Very little about sector is made known in the beginning.
The humanoid race is kept hidden until quite later part
of the game. Accessing this sector will require high
technology which will be only avaible in the game after
research events.


\section s_sectors_b_c SECTORS B & C - Divided medium technology race


A single race occupies both sectors, but it has diveded,
and is in labil situation. A civil war has taken place
before the beginning, but it is holding when the game
starts.

The race is little interest to any other races, except
for race from sector E, which keeps sending intrusion
fleets. More about war situation, and other relations
between races will be explained after sector descriptions.


\section s_sector_d SECTOR D - Giant alien race


Normally races in the game are not called 'alien', simply
just races. This race is called alien, because it does not
originate from this part of universe. The race, together
with whole home solar system, simply 'appeared' to this
area few thousand years before the game starts.

The origin of this race is not known. The race itself
insists that they did not make the transition event to
happen themselves, and that they do not know anything
about how or why it did happen. They also have not
told much what their origin was like - it has been
assumed to be peaceful and dull place. They also say
that they have not been able to locate anything they
knew in the place where they came - this would mean
that they come from a place very, very far away.

Race has special property of having huge indivuals
which appear to be slow. Their space ships are also
huge and slow. Still, their technology level appears
to be 'yours or above'. Due to their huge size, they
are almost immune to any known technology. They move
and react a bit slow, but the technolgy they use assists
them.

The race likes to be alone, and can not easily be
persuaded to communicate. They will not kill hostile
encounters, they will simple relocate annoying visitors
to safe distance. This 'displacement' technology is not
understood by other races.

Rumor says that their displacement technology could have
been used to displace their whole home solar system when
it originally just popped up where it now is.

Another rumor says that their appearing few thousand
years ago was rare natural event, and that some day
similar event will occur and will take the whole system
back to where it came from.
	
What is not told about them: They are not slow at all -
they hide their real speed on purpose. They would never
reveal this though. They know quite a lot about the
game universe, but not everything - They could, but they
are not very interested. They actually spend time on
researching technology 'how to get back home'. The dispacement
event which translated them to this part of universe indeed
was a natural event, and the counter-effect will happen just
by itself during the game.


\section s_sector_e SECTOR E - Aggressive expansionist race


This sector contains a number of planets which are fully
filled with mining and war specialiced factories. The
populating race is aggressive and expansionist. They are
not exactly smartest race though, and their technology is only
little better than medium technology, so they are not so huge
threat.

Still, their resources are remarkable, and no-one has real
interest on massive intrusion to their space, so there is
no large-scale war between other races.


\section s_sector_f SECTOR F - High technology, corrupted race



\section s_sector_g SECTOR G - Player home


Medium technology


\section s_sector_h SECTOR H - Civilwar medium technology rece


Physically and mentally powerful beings populate
this sector. They are, unfortunately, in middle of
long, deadly civilwar, and have been degrading for
hundreds of years. They have technology theyy no longer
understand, and some of it is plain forgotten.

Each party mostly concentrate on the civilwar. However
they do business with other races, and they are only
hostile to alike enemies.


\section s_sector_i SECTOR I - Mystery race


Individuals of this race are tiny insectoid-like,
very flat beings. They are flat, because their homeworld
has large gravityforce. Individuals are not that smart,
but they usually form collective being by connecting to
each other.

They are very secretive and very little communication
has succeeded with them. Only long range observations
have been made about their worlds, as they do not allow
any intruders. Nobody has been able to get even close
to these worlds. Their technology seems to be superior,
and any contact is recommended to be avoided.

Luckily, they have not been found anywhere outside
their own sector. (This is because others do not yet
have proper technology to detect them).


\section s_sector_h RACE J - Second mystery race


This race can normally only be reached through
specific individuals of sector-H-race, who relay
suspicious dealings with J: high technology at
high cost.

(While the technology is superior, it has has a
severe backdoors and once too much of this equipment
is collected, utilizer turns into borg-like being.)
				

\section s_detail_map Detail map sectors


<pre>
    ###################################################
    #. . . . . . . . . . . . . . . . . . . . . . . . .#
    #.       .       .       .       .       .       .#
    #.       .       .       .       .       .       .#
    #.       .       .       .       .       .       .#
    #. . . . A . . . . . . . B . . . . . . . C . . . .#
    #.       .       .       .       .       .       .#
    #.       .       .       .       .       .       .#
    #.       .       .       .       .       .       .#
    #. . . . . . . . . . . . . . . . . . . . . . . . .#
    #.       .       .       .       .       .       .#
    #.       .       .       .       .       .       .#
    #.       .       .       .       .       .       .#
    #. . . . D . . . . . . . E . . . . . . . F . . . .#
    #.       .       .       .       .       .       .#
    #.       .       .       .       .       .       .#
    #.       .       .       .       .       .       .#
    #. . . . . . . . . . . . . . . . . . . . . . . . .#
    #.       .       .       .       .       .       .#
    #.       .       .       .       .       .       .#
    #.       .       .       .       .       .       .#
    #. . . . G . . . . . . . H . . . . . . . I . . . .#
    #.       .       .       .       .       .       .#
    #.       .       .       .       .       .       .#
    #.       .       .       .       .       .       .#
    #. . . . . . . . . . . . . . . . . . . . . . . . .#
    ###################################################


	DETAIL MAP 


     #       #       #       #       #      #        #
    ###################################################		. -- Unpopulated Planet
   ##.................................................##    o -- Populated Planet
    #:                                 .             :#     O -- Race Homeworld planet
    #: ~~~~~~~~~~~~~~~~~~~~~~ .               .      :#     ~ -- Deadly debris and gas clouds, radiation
    #:      ~~~~~~~~~~~~~~                        .  :#     и -- Deadly debris
   ##:    ~~~~O~~~~~~~~~        O    .     .         :##    
    #:    ~~~~~~~~~ ~~            o                  :#
    #:      ~~~~~~~~ ~   .    o       o  O           :#
    #:  ~~~ ~~~~~~~             o                 .  :#
   ##:  ~~~~~~~~~~~~ ~     ииии.    .                :##
    #:~~~~~~~~~ ~     .      иииии    и  .   o       :#
    #:~~ ~~~~ ~~  ии .   o o         ии         o    :#
    #:~~~~~      ии ии   o O   o    ииии   o o       :#
   ##:~~~~~~o    .                .  иии     o       :##
    #:  o             и    o   o          o  o  O    :#
    #:       O       и                               :#
    #:             ииииии .      .     .     o       :#
   ##:      .        иииииииииии                .    :##
    #:  .       .       .иииииииии                   :#
    #:      o               o ии ии .                :#
    #:        o                         o         o  :#
   ##:     O      .     o       o   иии       o      :##
    #:                                     o     o   :#
    #:        .          .  o      ии  .       O     :#
    #:                                               :#
   ##:...............................................:##
    ###################################################
     #       #       #       #       #      #        #



	                   Average    Variation

	Cool - Hot         1          1
	War skills         10		  2
	Diplomacy - War    1		  4
	Trading			   1		  5
	Self vs community  10		  5

</pre>


/section About weapons

<pre>






the flight model that elite iv should have...


 Timo K Suoranta <tksuoran@cc.helsinki.fi> wrote:
  
 : I will make following things probably options:


	Henry Segerman
  
  
 You'll need something for docking in this list I'd guess.
    
 Galileo's solution is to have no weapons which travel instantly
 (ie no lasers), so theres always some chance to dodge.
    
 The problem is that its very easy to do very good shooting AI with
 an absolute minimum of AI (well its a very small algorithm to
 take something's position and velocity and shoot ahead of it so itll
 hit dead-on assuming the target carries on). For a dogfight situation,
 this sort of extrapolation is not easy to dodge. 
  
 The other route would be to allow the algorithm less information. Problem
 with this is that the algorithm then gets far harder to write, and probably
 more complex.
  
 Or, you could deliberately put random errors into either the input or the
 output of the algorithm. Euurgh. ;-)
    
 It's a problem with beam lasers. Pulse lasers and slower moving
 turrets aren't too bad a solution (or unrealistic slow moving
 laser bolts). There could be good arguements for having only
 weak lasers in turrets, too.
  
 How about some kind of power limitation - lots of turrets would
 be quite a drain on power resources wouldn't they?  So keep them
 low powered, and have the turret AI powered with ZX Spectrums.  :)
  
  
 Heh, yeah that would be good - IMHO capships should have numerous weak
 turrets, that surround the ship with a rain of low powered laser bolts.
 Doesn't matter if they all hit - a moving ship is bound to collide with
 them sooner or later.  :)
  
 Most certainly they should stop single ships sitting dead still behind the capship and slowing blowing it away.  :P
  
 Slightly OT but still talking about protection, the vipers in ffe could be fixed, if they were forced to go straight
 ahead without turning for a predefined amount of time, that way they would be out of the hangar before
 attempting to take you out.
  
 Most of their casualties are caused by the hangar walls.
  
  
 Stone-D
 -- 
 Get my jjffe mod chffe at :
 http://www.geocities.com/lp2d/search/StoneSearch.htm
 =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 =|          Remove "DISABUSE" to EMail me          |=
 =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
 
 
 "Henry Segerman" <sjoh0780@sable.ox.ac.uk> wrote in message news:8n1vci$7d$2@news.ox.ac.uk...
 > Laga Mahesa <stone@disabuse.link.net.id> wrote:
 >
 > The problem is that its very easy to do very good shooting AI with
 > an absolute minimum of AI (well its a very small algorithm to
 > take something's position and velocity and shoot ahead of it so
 > itll hit dead-on assuming the target carries on).
  
 What can you do is use the same control systems for the AI ships and players and simulate things like
 oversteering and indecision for the AIs in order to counter the "perfect aim syndrome".
  
 Paul J
 Crytek Studios / DNA Interactive
 AI c0de m0nkey
 
 
 I-War is an excellent flight model. It's  newtonian but done in an intelligent way. No stupid fucking (sorry)
 speed limits (that's the most annoying stupid bloody effing thing that you could ever place ina ny effing space
 game ever, without question), and the speeds never get so that you can't understand what's happening, as it
 uses the three stage model (normal flight, interplanetary, intesystem).
 No speed limits (barring the speed of light....), no 'drag' (in space, come on, it's so negligable that it's not worth
 considering unless you've got a three hundred mile sun sail).
 It should all depend on forces, as in real life, so there for you'll probably base it on acceleration. It feels and
 playes better. I mean, have you tried X? It's just.... wrong. I-War is right, FFE is right.
 if speeds get up to interplanetary sizes, then ensure that you can get your speed relative to your target's so you
 know what's happening. Oh, and I'd like control over my lateral thrusters.
 Oh, and the interface, any chance you can set that up like I-War's? With it's list of contacts and stuff (have a
 go of the game, you'll understand) and controlled the same way?
 Anyway, that's a ranting two cents, pence, small monetary thingmajigger. 
  
  
 --
 ARG out
 www.deepblack.dial.pipex.com (now wiith article on what I think an elite
 genre game needs)
 ICQ# 69481914
 
 
 Space doesn't have drag, because there's no (or very, very little) friction. However, at certain speeds the
 
 
 probability of drag gained from floating matter (such as dust and particles, exhaust from engines, etc.) will
 inevitably increase.
  
 I'm not sure but I think if you reach certain speeds, as you pass planets their gravitational pull may inflict
 strange forces on your ships mass - gravitational turbulence so to speak  :o) lol
  
  
 Andy.
 
 Hi Timo,
  
 > I will make following things probably options:
 >    - Does space have drag?
 >    - Does ships have maximum speed?
 >    - Will it be possible to instantly change speed (eg. stop)
 >    - Should ships be controlled by acceleration or speed?
 >      For both translation and rotation
 >    - any other ideas?
  
 Drag, maximum speed, slowing down, and acceleration/speed all go together. You'll find that if you have a
 certain percentage of drag to your velocity, and a maximum thrust, the object will have a natural maximum
 speed (and it's easy to calculate what it is).  If you stop thrusting the drag will reduce your speed to zero.  Use
 forces and mass.
  
 Everyone seems to be hung up on recreating the exact conditions in our current perception of space.  i.e.
 nothing to stop you so you should be able to approach the speed of light.  From a gameplay perspective this
 doesn't seem right.  I'm not sure how I-war and FFE would handle it, but imagine in a multiplayer game
 where you are just putting along going to dock with something, and out of nowhere a ship travelling at
 exorbital speeds collides with you, ripping you apart.  Doesn't sound like fun.  In the game I'm working on I'm
 planning to have a "variable" amount of drag.  Ok guys you are going to have to use some imagination here.  I
 know Star Wars has the concept of S-foils, which I think tap into ethereal space to steer their ships with
 greater agility during a dogfight.  I plan to make engines able to adjust a slider between high speed/low agility
 (low drag), and low speed/high agility (high drag) in a similar way.  You may have to pay to upgrade to this
 kind of flexibility though.. we'll see.  Anyway, with this you can determine dynamically how your flight model
 goes.  The engine has a level of ethereal tap.  And before everyone starts ranting how that's rediculous,
 remember its just a game, not a simulation of what we currently know.  I'm not trying to degrade people who
 enjoy purely Newtonian space games, just giving my perspective.
  
 If you've tried to program a guided missile you'll know that it's pretty difficult to make it effective with zero
 drag.  You have to compensate exactly for the momentum of the missile, as well as leading a possibly erratic
 target.  At low speeds its not so hard, but up the ante and watch your missiles zip right past the target. 
 Introduce 50% per second drag and the missiles hit almost every time on the first pass.
  
  
 > I can make ships turn, and fly towards some point:
 >    - Hunt player:
 >      Choose point as player location, or estimation where it will
 >      be, or even better, nearby, not exactly (to not to crash)
 >    - Fly in formation
 >      (choose point relative to wing leader)
 >    - Evasive actions
 >      Choose point behind those who shoot you
 >    - etc. If you have any other ideas, let me know
 >
 > IMHO, technology will be that advanced anyway that autotargetting
 > will shoot deadly precisily, so I'm wondering what kind of dogfight
 > would be even nearly realistic. Especially if turrets can be aimed
 > while ship can face other direction, weapons will become way too
 > deadly. It is not realistic to assume that player would need to
 > aim turrets manually (unless autotarget is damaged or something)
  
 My AI faces toward the target lead, and fires when the angle to that is sufficiently small.  It's effective, but it
 doesn't have a 100% hit ratio because the other target is moving and steering, and the projectiles have finite
 speed.
  
 So far I haven't got beam lasers in my game, but turrets which fire plasma lasers (that have finite speed), have
 a fairly high but reasonable accuracy. If you dodge and weave the turrets get thrown off, but if you travel in a
 straight line they'll nail you, which is how it should be.  For beam lasers you could, as suggested, introduce some
 error, or perhaps slow the rate of turn of the turret when firing.  There are many possibilities.
  
 Tim
  
 http://www.tne.net.au/astro/projects/spacegame/index.html
 
 
 
 Tim Auld <astro@tne.net.au> wrote in message news:yk4l5.44$kX1.5439@nsw.nnrp.telstra.net...
 > Hi Timo,
 >
 > > I will make following things probably options:
 > >    - Does space have drag?
 > >    - Does ships have maximum speed?
 > >    - Will it be possible to instantly change speed (eg. stop)
 > >    - Should ships be controlled by acceleration or speed?
 > >      For both translation and rotation
 > >    - any other ideas?
 >
 > Drag, maximum speed, slowing down, and acceleration/speed all go together.
 > You'll find that if you have a certain percentage of drag to your velocity,
 > and a maximum thrust, the object will have a natural maximum speed (and it's
 > easy to calculate what it is).  If you stop thrusting the drag will reduce
 > your speed to zero.  Use forces and mass.
 >
 > Everyone seems to be hung up on recreating the exact conditions in our
 > current perception of space.  i.e. nothing to stop you so you should be able
 > to approach the speed of light.  From a gameplay perspective this doesn't
 > seem right.  I'm not sure how I-war and FFE would handle it, but imagine in
 > a multiplayer game where you are just putting along going to dock with
 > something, and out of nowhere a ship travelling at exorbital speeds collides
 > with you, ripping you apart.  Doesn't sound like fun.
  
 Doesn't sound very likely, either. Things are rather unlikely to collide in space, unless they are deliberately
 right near each other. There's no reason why a ship going that fast should be anywhere near a space station. 
  
 The thing about making a game realistic is that it greatly increases the feeling that you are there, doing
 something "real", as opposed to sitting at a computer playing a game. The more unrealistic bits tend to nag at
 an intelligent player after a while.
  
 > In the game I'm
 > working on I'm planning to have a "variable" amount of drag.  Ok guys you
 > are going to have to use some imagination here.  I know Star Wars has the
 > concept of S-foils, which I think tap into ethereal space to steer their
 > ships with greater agility during a dogfight.
  
 Star Wars hardly has any say in "real" situations. It's purely entertainment (although there isn't all that much
 that's too terrible in the films, apart from noise).
  
 > I plan to make engines able
 > to adjust a slider between high speed/low agility (low drag), and low
 > speed/high agility (high drag) in a similar way.  You may have to pay to
 > upgrade to this kind of flexibility though.. we'll see.  Anyway, with this
 > you can determine dynamically how your flight model goes.  The engine has a
 > level of ethereal tap.  And before everyone starts ranting how that's
 > rediculous, remember its just a game, not a simulation of what we currently
 > know.  I'm not trying to degrade people who enjoy purely Newtonian space
 > games, just giving my perspective.
  
 If you want "just a game" then don't bother trying to do anything realistic. You won't impress either the simple
 shoot-em-up fans or the more sophisticated Elite players. A good designer should be able to make it both fun
 an realistic.
  
 > If you've tried to program a guided missile you'll know that it's pretty
 > difficult to make it effective with zero drag.  You have to compensate
 > exactly for the momentum of the missile, as well as leading a possibly
 > erratic target.  At low speeds its not so hard, but up the ante and watch
 > your missiles zip right past the target.  Introduce 50% per second drag and
 > the missiles hit almost every time on the first pass.
  
 Only if your missile only has one thruster, which is pretty stupid for one operating in space. A missile designed
 purely for space use wouldn't look much like the long pointy things used in atmospheres. The only reason Elite
 has them looking like that is so you can recognise them as missiles.
  
 --
 Simon Challands, creator of:
 The Acorn Elite Pages - http://elite.acornarcade.com/
 Three Dimensional Encounters - http://www.3dfrontier.fsnet.co.uk/
 The Stunt Racer 2000 League - http://www.3dfrontier.fsnet.co.uk/srleague/
 
 
 > Star Wars hardly has any say in "real" situations. It's purely
 entertainment
 > (although there isn't all that much that's too terrible in the films,
 > apart from noise).
  
 What is a game but entertainment?  I surely don't propose any restraints on how real and immersive a game
 can be.  I'm a big fan of "realistic" first person shooters, and space games for that matter.  A game should be as
 immersive as possible.  My point is that there may be problems with an extremely realistic game.  Not
 necessarily because of the nature of reality, but because people will abuse the abilities it offers, and innocent
 players may bear the consequences.  In a single player game it makes little difference.  In a multiplayer game,
 where there are juvenile players, I would anticipate problems like this, especially when traffic about popular
 stations arrises.  In UO there would ideally be no PKers, but there are. 
  
 > If you want "just a game" then don't bother trying to do anything
 > realistic. You won't impress either the simple shoot-em-up fans or
 > the more sophisticated Elite players. A good designer should be able
 > to make it both fun an realistic.
  
 Are you saying that you absolutely cannot have a compromise between the two extremes?
  
 Don't you have a rather selective view of what's realistic?  You can go from 0 km/h to 3000 km/h in a few
 seconds against the pull of gravity in Frontier, without killing yourself.  Shouldn't your laser beams go on
 forever until they hit something?  That would mean you could take out a target at long range.  That would
 include missiles as well.  So in a perfect simulation of reality there would rarely be a dogfight, just long range
 bombardment (look at the military strategies of the US).  Shouldn't you have one and only one life?  Reality is
 harsh.  In a single player game that's ok, because the game is driven by the person who experiences the
 consequences of his actions, and you can program AI to be sensible. Restrictions may sometimes have to be
 placed to channel gameplay and make things sensible.
  
 I'm not saying that my suggestion is the only way either. If I implemented physics as you wanted them and it
 turned out to be fun, appropriate and safe I wouldn't hesitate to use that method.  Whatever works.  There is
 certainly an attraction to having a game being as realistic as possible.  I agree that it does increase
 immersiveness.
  
 > Only if your missile only has one thruster, which is pretty stupid for
 > one operating in space. A missile designed purely for space use wouldn't
 > look much like the long pointy things used in atmospheres. The only
 > reason Elite has them looking like that is so you can recognise them
 > as missiles.
  
 In a practical design, because you want the missile to have greater speed/acceleration than its target in order to
 catch it, you would want a large directional force.  Having many such high powered engines may be
 impractical (increased mass, difficulty in wing attachment/storage, etc.). I think Elite has them like that
 because they're just a whole lot cooler. :) 
  
  
 Tim
 
 
 Tim Auld <astro@tne.net.au> wrote in message news:P1el5.34$V32.4123@nsw.nnrp.telstra.net...
  
 >
 > > If you want "just a game" then don't bother trying to do anything
 > > realistic. You won't impress either the simple shoot-em-up fans or
 > > the more sophisticated Elite players. A good designer should be able
 > > to make it both fun an realistic.
 >
 > Are you saying that you absolutely cannot have a compromise between the two
 > extremes?
  
 By and large, yes. Having it realistic confuses the easily confused who like games to work along the lines of
 "point and shoot", and simplifying it reduces the fun for people who like their games intelligent.
 Compromises usually end up satisying few people. Besides, there's much more satisfaction in mastering
 something that takes genuine skill. Most people on here are fed up of simple games that only take ten seconds
 to get the hang of.
  
 > Don't you have a rather selective view of what's realistic?  You can go from
 > 0 km/h to 3000 km/h in a few seconds against the pull of gravity in
 > Frontier, without killing yourself.
  
 You've got to have a few unrealistic things, such as hyperspace. Artificial gravity is another, and once you've
 got that your ship's acceleration doesn't matter, because the artificial gravity can compensate for it. 
  
 > Shouldn't your laser beams go on
 > forever until they hit something?  That would mean you could take out a
 > target at long range.  That would include missiles as well.  So in a perfect
 > simulation of reality there would rarely be a dogfight, just long range
 > bombardment (look at the military strategies of the US).
  
 Pretend your laser beams do go on forever, if you want. Since they can't be 100% coherent the power will drop
 off with range. In any case it's pretty hard hitting something smaller than an Imperial Explorer at 7km or so,
 so greater range lasers would have no effect at all on gameplay. Missiles can't go on forever because they would
 run out of fuel sooner or later. FE2 has a rather weak arguement for having them blow up after a set time. So
 long range bombardment, of other ships at least, wouldn't work.
  
 > Shouldn't you have
 > one and only one life?  Reality is harsh.  In a single player game that's
 > ok, because the game is driven by the person who experiences the
 > consequences of his actions, and you can program AI to be sensible.
 > Restrictions may sometimes have to be placed to channel gameplay and make
 > things sensible.
  
 Just one life isn't a problem. Elite is actually more fun to play if you don't re-load when you die - it makes it
 much more exciting, and suddenly equipment like the escape pod becomes useful!
  
 > I'm not saying that my suggestion is the only way either. If I implemented
 > physics as you wanted them and it turned out to be fun, appropriate and safe
 > I wouldn't hesitate to use that method.  Whatever works.  There is certainly
 > an attraction to having a game being as realistic as possible.  I agree that
 > it does increase immersiveness.
  
 Which is a greater benefit than being able to do everything after five minutes of playing IMO.
  
 > > Only if your missile only has one thruster, which is pretty stupid for
 > > one operating in space. A missile designed purely for space use wouldn't
 > > look much like the long pointy things used in atmospheres. The only
 > > reason Elite has them looking like that is so you can recognise them
 > > as missiles.
 >
 > In a practical design, because you want the missile to have greater
 > speed/acceleration than its target in order to catch it, you would want a
 > large directional force.  Having many such high powered engines may be
 > impractical (increased mass, difficulty in wing attachment/storage, etc.).
 > I think Elite has them like that because they're just a whole lot cooler. :)
  
 One main engine, numerous smaller ones (most likely five other thrusters). 
 
 
 
 Tim Auld <astro@tne.net.au> wrote:
  
 : Everyone seems to be hung up on recreating the exact conditions in our
 : current perception of space.  i.e. nothing to stop you so you should be able
 : to approach the speed of light.  From a gameplay perspective this doesn't
 : seem right.  I'm not sure how I-war and FFE would handle it, but imagine in
 : a multiplayer game where you are just putting along going to dock with
 : something, and out of nowhere a ship travelling at exorbital speeds collides
 : with you, ripping you apart.  Doesn't sound like fun.  In the game I'm
  
 Well yeah, this sort of thing could be a problem. There are ways round this sort of thing though. Have a flight
 computer which automatically checks using the sensors for if something is on a collision course, and alerts you
 if there is, even if its at enormous speeds.
  
 : level of ethereal tap.  And before everyone starts ranting how that's
 : rediculous, remember its just a game, not a simulation of what we currently
 : know.  I'm not trying to degrade people who enjoy purely Newtonian space
 : games, just giving my perspective.
  
 Of course, it is a matter of preference.
  
 : If you've tried to program a guided missile you'll know that it's pretty
 : difficult to make it effective with zero drag.  You have to compensate
 : exactly for the momentum of the missile, as well as leading a possibly
 : erratic target.  At low speeds its not so hard, but up the ante and watch
 : your missiles zip right past the target.  Introduce 50% per second drag and
 : the missiles hit almost every time on the first pass.
  
 Well it does need a bit of maths to do it yes. I do these things continuously rather than incrementally so its
 sortof different.
  
 -- 
  ,-.  Henry Segerman
  |/                
  |,--.  /\ |\  |/\,--.   ,
 /|   |  \/ | \ | /\  |   |/
  '   `--'\/|  \| \/  `--'|
                         /|
        uewJ363S hJu3H  `-'
</pre>


*/
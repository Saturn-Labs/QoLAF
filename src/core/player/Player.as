package core.player
{
	import com.greensock.TweenMax;
	import core.artifact.Artifact;
	import core.artifact.ArtifactFactory;
	import core.artifact.ArtifactStat;
	import core.friend.Friend;
	import core.group.Group;
	import core.hud.components.chat.MessageLog;
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.scene.Game;
	import core.scene.SceneBase;
	import core.ship.PlayerShip;
	import core.ship.ShipFactory;
	import core.solarSystem.Body;
	import core.spawner.Spawner;
	import core.states.StateMachine;
	import core.states.gameStates.RoamingState;
	import core.states.player.Killed;
	import core.states.player.Landed;
	import core.states.player.Roaming;
	import core.text.TextParticle;
	import core.weapon.Beam;
	import core.weapon.Cloak;
	import core.weapon.Damage;
	import core.weapon.Teleport;
	import core.weapon.Weapon;
	import core.weapon.WeaponDataHolder;
	import data.DataLocator;
	import data.IDataManager;
	import debug.Console;
	import facebook.Action;
	import movement.Heading;
	import playerio.Message;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.core.Starling;
	import starling.display.Image;
	
	public class Player
	{
		public static const SLOT_WEAPON_COST_TYPE:String = "flpbTKautkC1QzjWT28gkw";
		
		public static const SLOT_ARTIFACT_COST_TYPE:String = "flpbTKautkC1QzjWT28gkw";
		
		public static const SLOT_CREW_COST_TYPE:String = "flpbTKautkC1QzjWT28gkw";
		
		public static const SLOT_WEAPON:String = "slotWeapon";
		
		public static const SLOT_ARTIFACT:String = "slotArtifact";
		
		public static const SLOT_CREW:String = "slotCrew";
		
		public static const RESPAWN_TIME:Number = 10000;
		
		public static const RESPAWN_TIME_PVP:Number = 3000;
		
		public static const SUPPORTER_ICON_ASCII:String = "<font color='#ffff66'>&#9733;</font>";
		
		public static const EXPBOOSTBONUS_MISSION:Number = 0.3;
		
		public static var friends:Vector.<Friend>;
		
		public static var onlineFriends:Vector.<Friend>;
		
		public static const SLOT_WEAPON_UNLOCK_COST:Array = [0, 0, 200, 1000, 5000];
		
		public static const SLOT_ARTIFACT_UNLOCK_COST:Array = [0, 1000, 2000, 10000, 25000];
		
		public static const SLOT_CREW_UNLOCK_COST:Array = [0, 0, 250, 5000, 25000];
		
		public static const ARTIFACT_CAPACITY:Array = [250, 400, 600, 800];
		
		private var _name:String;
		
		public var isMe:Boolean = false;
		
		public var id:String;
		
		public var inviter_id:String = "";
		
		public var ship:PlayerShip;
		
		public var mirror:PlayerShip;
		
		public var stateMachine:StateMachine;
		
		public var currentBody:Body;
		
		public var lastBody:Body;
		
		public var xp:int = 0;
		
		public var reputation:int = 0;
		
		public var split:String = "";
		
		private var _team:int = -1;
		
		public var respawnNextReady:Number = 0;
		
		public var spree:int = 0;
		
		public var techPoints:int = 0;
		
		public var clanId:String = "";
		
		public var clanApplicationId:String = "";
		
		public var troons:int = 0;
		
		public var rating:int = 0;
		
		public var ranking:int = 0;
		
		private var activeWeapon:String;
		
		public var techSkills:Vector.<TechSkill>;
		
		public var weapons:Array;
		
		public var weaponsState:Array;
		
		public var weaponsHotkeys:Array;
		
		public var weaponData:Vector.<WeaponDataHolder>;
		
		public var selectedWeaponIndex:int = 0;
		
		public var unlockedWeaponSlots:int;
		
		public var artifactCount:int = 0;
		
		public var compressorLevel:int = 0;
		
		public var artifactCapacityLevel:int = 0;
		
		public var artifactAutoRecycleLevel:int = 0;
		
		public var activeSkin:String = "";
		
		public var unlockedArtifactSlots:int;
		
		public var artifacts:Vector.<Artifact>;
		
		public var activeArtifactSetup:int;
		
		public var artifactSetups:Array;
		
		public var unlockedCrewSlots:int;
		
		public var rotationSpeedMod:Number = 1;
		
		public var KOTSIsReady:Boolean = false;
		
		public var fleet:Vector.<FleetObj>;
		
		public var nrOfUpgrades:Vector.<int>;
		
		private var _level:int = 1;
		
		private var _inSafeZone:Boolean = false;
		
		private var _isWarpJumping:Boolean = false;
		
		public var playerKills:int = 0;
		
		public var enemyKills:int = 0;
		
		public var playerDeaths:int = 0;
		
		public var expBoost:Number = 0;
		
		public var tractorBeam:Number = 0;
		
		private var tractorBeamActive:Boolean = true;
		
		public var xpProtection:Number = 0;
		
		public var cargoProtection:Number = 0;
		
		private var cargoProtectionActive:Boolean = true;
		
		public var supporter:Number = 0;
		
		public var beginnerPackage:Boolean = false;
		
		public var powerPackage:Boolean = false;
		
		public var megaPackage:Boolean = false;
		
		public var explores:Vector.<Explore>;
		
		public var missions:Vector.<Mission>;
		
		public var dailyMissions:Array;
		
		public var crewMembers:Vector.<CrewMember>;
		
		public var encounters:Vector.<String>;
		
		public var triggeredMissions:Vector.<String>;
		
		public var completedMissions:Object;
		
		public var warpPathLicenses:Array;
		
		public var solarSystemLicenses:Array;
		
		public var guest:Boolean = false;
		
		public var fbLike:Boolean = false;
		
		public var showIntro:Boolean = true;
		
		public var kongRated:Boolean = false;
		
		public var isDeveloper:Boolean = false;
		
		public var isTester:Boolean = false;
		
		public var isModerator:Boolean = false;
		
		public var isTranslator:Boolean = false;
		
		private var _group:Group = null;
		
		private var _isHostile:Boolean = false;
		
		public var pickUpLog:Vector.<TextParticle>;
		
		public var disableLeave:Boolean;
		
		private var isTakingOff:Boolean = false;
		
		public var clanLogo:Image;
		
		public var clanName:String;
		
		public var clanRankName:String;
		
		public var clanLogoColor:uint;
		
		public var freeResets:int;
		
		public var freePaintJobs:int;
		
		public var factions:Vector.<String>;
		
		public var landedBodies:Vector.<LandedBody>;
		
		public var tosVersion:int;
		
		private var g:Game;
		
		private var updateInterval:int;
		
		public var isLanded:Boolean = false;
		
		public function Player(param1:Game, param2:String)
		{
			stateMachine = new StateMachine();
			techSkills = new Vector.<TechSkill>();
			weapons = [];
			weaponsState = [];
			weaponsHotkeys = [];
			artifacts = new Vector.<Artifact>();
			artifactSetups = [];
			fleet = new Vector.<FleetObj>();
			nrOfUpgrades = Vector.<int>([0, 0, 0, 0, 0, 0, 0]);
			explores = new Vector.<Explore>();
			missions = new Vector.<Mission>();
			dailyMissions = [];
			crewMembers = new Vector.<CrewMember>();
			encounters = new Vector.<String>();
			triggeredMissions = new Vector.<String>();
			completedMissions = {};
			pickUpLog = new Vector.<TextParticle>();
			factions = new Vector.<String>();
			landedBodies = new Vector.<LandedBody>();
			super();
			this.g = param1;
			this.id = param2;
			disableLeave = false;
		}
		
		public static function getSkinTechLevel(param1:String, param2:String):int
		{
			var _loc5_:IDataManager = DataLocator.getService();
			var _loc4_:Object = _loc5_.loadKey("Skins", param2);
			for each (var _loc3_:* in _loc4_.upgrades)
			{
				if (_loc3_.tech == param1)
				{
					return _loc3_.level;
				}
			}
			return 0;
		}
		
		public function get artifactLimit():int
		{
			return ARTIFACT_CAPACITY[artifactCapacityLevel];
		}
		
		public function get activeArtifacts():Array
		{
			return artifactSetups[activeArtifactSetup] as Array;
		}
		
		public function get group():Group
		{
			return _group;
		}
		
		public function set group(param1:Group):void
		{
			_group = param1;
			if (ship != null)
			{
				ship.group = param1;
			}
		}
		
		public function get isHostile():Boolean
		{
			return _isHostile;
		}
		
		public function get hasCorrectTOSVersion():Boolean
		{
			if (Login.currentState === "steam")
			{
				return true;
			}
			return tosVersion == 3;
		}
		
		public function set hasCorrectTOSVersion(param1:Boolean):void
		{
			if (param1)
			{
				tosVersion = 3;
			}
			else
			{
				tosVersion = -1;
			}
		}
		
		public function set isHostile(param1:Boolean):void
		{
			_isHostile = param1;
			if (ship != null)
			{
				ship.isHostile = param1;
			}
		}
		
		public function init(param1:Message, param2:int):int
		{
			var _loc12_:Heading = null;
			var _loc11_:int = 0;
			_name = param1.getString(param2++);
			inviter_id = param1.getString(param2++);
			tosVersion = param1.getInt(param2++);
			isDeveloper = param1.getBoolean(param2++);
			isTester = param1.getBoolean(param2++);
			isModerator = param1.getBoolean(param2++);
			isTranslator = param1.getBoolean(param2++);
			level = param1.getInt(param2++);
			xp = param1.getInt(param2++);
			techPoints = param1.getInt(param2++);
			isHostile = param1.getBoolean(param2++);
			rotationSpeedMod = param1.getNumber(param2++);
			reputation = param1.getInt(param2++);
			var _loc13_:String = param1.getString(param2++);
			split = param1.getString(param2++);
			var _loc4_:String = param1.getString(param2++);
			spree = param1.getInt(param2++);
			var _loc3_:int = param1.getInt(param2++);
			var _loc5_:int = 0;
			var _loc14_:int = 0;
			var _loc9_:int = 0;
			var _loc8_:int = 0;
			var _loc7_:Number = 0;
			var _loc10_:Number = 0;
			if (_loc3_ != -1)
			{
				_loc14_ = param1.getInt(param2++);
				_loc5_ = param1.getInt(param2++);
				_loc9_ = param1.getInt(param2++);
				_loc8_ = param1.getInt(param2++);
				_loc7_ = param1.getNumber(param2++);
				_loc10_ = param1.getNumber(param2++);
				_loc12_ = new Heading();
				param2 = _loc12_.parseMessage(param1, param2);
			}
			unlockedWeaponSlots = param1.getInt(param2++);
			unlockedArtifactSlots = param1.getInt(param2++);
			unlockedCrewSlots = param1.getInt(param2++);
			compressorLevel = param1.getInt(param2++);
			artifactCapacityLevel = param1.getInt(param2++);
			artifactAutoRecycleLevel = param1.getInt(param2++);
			playerKills = param1.getInt(param2++);
			playerDeaths = param1.getInt(param2++);
			enemyKills = param1.getInt(param2++);
			showIntro = param1.getBoolean(param2++);
			expBoost = param1.getNumber(param2++);
			tractorBeam = param1.getNumber(param2++);
			xpProtection = param1.getNumber(param2++);
			cargoProtection = param1.getNumber(param2++);
			supporter = param1.getNumber(param2++);
			beginnerPackage = param1.getBoolean(param2++);
			powerPackage = param1.getBoolean(param2++);
			megaPackage = param1.getBoolean(param2++);
			guest = param1.getBoolean(param2++);
			clanId = param1.getString(param2++);
			clanApplicationId = param1.getString(param2++);
			troons = param1.getNumber(param2++);
			freeResets = param1.getInt(param2++);
			freePaintJobs = param1.getInt(param2++);
			artifactCount = param1.getInt(param2++);
			var _loc15_:int = param1.getInt(param2++);
			_loc11_ = 0;
			while (_loc11_ < _loc15_)
			{
				factions.push(param1.getString(param2++));
				_loc11_++;
			}
			param2 = initFleetFromMessage(param1, param2);
			if (isMe)
			{
				param2 = initEncountersFromMessage(param1, param2);
				param2 = initCompletedMissionsFromMessage(param1, param2);
				param2 = initFinishedExploresFromMessage(param1, param2);
				param2 = initExploresFromMessage(param1, param2);
				param2 = initMissionsFromMessage(param1, param2);
				param2 = g.dailyManager.initDailyMissionsFromMessage(param1, param2);
				param2 = initTriggeredMissionsFromMessage(param1, param2);
				param2 = initCrewFromMessage(param1, param2);
				param2 = initLandedBodiesFromMessage(param1, param2);
				param2 = initArtifactsFromMessage(param1, param2);
				param2 = SceneBase.settings.init(param1, param2);
				SceneBase.settings.setPlayerValues(g);
				g.parallaxManager.refresh();
				param2 = g.tutorial.init(param1, param2);
				param2 = initWarpPathLicensesFromMessage(param1, param2);
				param2 = initSolarSystemLicensesFromMessage(param1, param2);
				kongRated = param1.getBoolean(param2++);
				fbLike = param1.getBoolean(param2++);
				g.friendManager.init(this);
			}
			var _loc6_:Body = g.bodyManager.getBodyByKey(_loc4_);
			if (_loc6_ != null)
			{
				ship = ShipFactory.createPlayer(g, this, new PlayerShip(g), weapons);
				startLanded(_loc6_);
				isLanded = true;
			}
			else
			{
				loadShip(_loc14_, _loc5_, _loc9_, _loc8_);
				ship.id = _loc3_;
				loadCourse(_loc12_);
				enterRoaming();
				MessageLog.writeChatMsg("join_leave", _name + " has entered the system.");
			}
			if (!isMe && _loc5_ != 0)
			{
				ship.shieldHpMax = _loc14_;
				ship.hpMax = _loc5_;
				ship.armorThreshold = _loc9_;
				ship.shieldRegen = _loc8_;
				ship.level = level;
				ship.updateLabel();
				ship.engine.speed = _loc7_;
				ship.engine.acceleration = _loc10_;
			}
			if (supporter)
			{
				Game.trackEvent("logged in", "supporter");
			}
			else
			{
				Game.trackEvent("logged in", "not supporter");
			}
			g.groupManager.autoJoinOrCreateGroup(this, _loc13_);
			return param2;
		}
		
		public function requestLikeReward():void
		{
			if (Login.hasFacebookLiked && !fbLike)
			{
				g.send("fbLike");
			}
		}
		
		public function requestInviteReward():void
		{
			g.send("requestInviteReward");
		}
		
		public function requestRewardsOnLogin():void
		{
			g.rpc("requestRewardsOnLogin", requestResult);
		}
		
		public function sendKongRated():void
		{
			kongRated = true;
			g.send("kongRated");
		}
		
		public function requestResult():void
		{
		}
		
		public function getExploreByKey(param1:String):Explore
		{
			for each (var _loc2_:* in explores)
			{
				if (_loc2_.areaKey == param1)
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		public function loadShip(param1:int, param2:int, param3:int, param4:int):void
		{
			var _loc5_:int = 0;
			ship = null;
			ship = ShipFactory.createPlayer(g, this, g.shipManager.getPlayerShip(), weapons);
			_loc5_ = 0;
			while (_loc5_ < ship.weapons.length)
			{
				if (ship.weapons[_loc5_].key == activeWeapon)
				{
					selectedWeaponIndex = _loc5_;
					if (isMe)
					{
						g.hud.weaponHotkeys.highlightWeapon(ship.weapons[_loc5_].hotkey);
					}
					break;
				}
				_loc5_++;
			}
			activateShip();
			if (param2 != 0)
			{
				ship.shieldHp = param1;
				ship.hp = param2;
				ship.armorThreshold = param3;
				ship.shieldRegen = param4;
				ship.level = level;
				ship.updateLabel();
			}
			if (spree > 4 && ship != null)
			{
				ship.startKillingSpreeEffect();
			}
		}
		
		private function activateShip():void
		{
			g.shipManager.activatePlayerShip(ship);
			if (isMe)
			{
				autoSetHotkeysForWeapons();
				g.camera.focusTarget = ship.movieClip;
			}
			ship.player = this;
			ship.enterRoaming();
		}
		
		public function unloadShip():void
		{
			if (ship == null)
			{
				return;
			}
			ship.destroy(false);
			if (mirror != null)
			{
				mirror.destroy(false);
				mirror = null;
			}
		}
		
		public function update():void
		{
			if (isMe)
			{
				updateInterval++;
				if (updateInterval == 1)
				{
					// QoLAF
					//g.hud.bossHealth.update();
				}
				else if (updateInterval == 2)
				{
					g.hud.powerBar.update();
					updateInterval = 0;
				}
			}
			stateMachine.update();
		}
		
		public function setSpree(param1:int):void
		{
			if (spree != param1)
			{
				spree = param1;
				if (spree > 15)
				{
					MessageLog.writeChatMsg("death", _name + " is Godlike! With a " + spree + " frag long killing frenzy!");
				}
				else if (spree > 10)
				{
					MessageLog.writeChatMsg("death", _name + " is on a Rampage! " + spree + " frag long killing frenzy!");
				}
				else if (spree > 4)
				{
					MessageLog.writeChatMsg("death", _name + " is on a " + spree + " frag long killing frenzy!");
				}
				if (spree == 4 && ship != null)
				{
					ship.startKillingSpreeEffect();
				}
			}
		}
		
		public function getExploredAreas(param1:Body, param2:Function):void
		{
			var body:Body = param1;
			var callback:Function = param2;
			if (body.obj.exploreAreas == null)
			{
				callback([]);
				return;
			}
			try
			{
				g.client.bigDB.loadRange("Explores", "ByPlayerAndBodyAndArea", [id, body.key], null, null, 100, function(param1:Array):void
				{
					callback(param1);
				});
			}
			catch (e:Error)
			{
				g.client.errorLog.writeError(e.toString(), "Something went wrong when loading explores: pid: " + id + " bid:" + body.key, e.getStackTrace(), {});
			}
		}
		
		public function levelUp():void
		{
			var effect:Vector.<Emitter>;
			var effect2:Vector.<Emitter>;
			var soundManager:ISound;
			level += 1;
			if (ship == null)
			{
				return;
			}
			if (level >= 10 && Login.currentState == "facebook")
			{
				g.tutorial.showFacebookInviteHint();
			}
			setLevelBonusStats();
			if (g.camera.isCircleOnScreen(ship.x, ship.y, 300))
			{
				effect = EmitterFactory.create("wrycG8hPkEGYgMkWXyd6FQ", g, 0, 0, ship, false);
				effect2 = EmitterFactory.create("6SRymw3GLkqIn6YvIGoLrw", g, 0, 0, ship, false);
				if (isMe)
				{
					if (g.me.split != "")
					{
						Game.trackEvent("AB Splits", "player flow", g.me.split + ": reached level " + level);
					}
					soundManager = SoundLocator.getService();
					soundManager.preCacheSound("5wAlzsUCPEKqX7tAdCw3UA", function():void
					{
						for each (var _loc2_:* in effect)
						{
							_loc2_.play();
						}
						for each (var _loc1_:* in effect2)
						{
							_loc1_.play();
						}
						g.textManager.createLevelUpText(level);
						g.textManager.createLevelUpDetailsText();
					});
					g.updateServiceRoom();
					Action.levelUp(level);
					if (inviter_id != "" && level == 10)
					{
						if (level == 10 || level == 2)
						{
							g.sendToServiceRoom("requestUpdateInviteReward", inviter_id);
						}
						if (level % 10 == 0)
						{
							if (Login.currentState == "facebook")
							{
								Game.trackEvent("FBinvite", "invite feedback", "reached level " + level, 1);
							}
							else if (Login.currentState == "kongregate")
							{
								Game.trackEvent("KONGinvite", "invite feedback", "joined game", 1);
							}
						}
					}
				}
				else
				{
					MessageLog.write("<FONT COLOR='#44ff44'>" + name + " reached level " + level + ".</FONT>");
				}
			}
		}
		
		private function setLevelBonusStats():void
		{
			var _loc6_:int = 0;
			var _loc5_:Number = NaN;
			var _loc3_:* = NaN;
			var _loc4_:Number = NaN;
			var _loc2_:Number = NaN;
			var _loc1_:int = 0;
			if (ship != null)
			{
				_loc6_ = level;
				_loc5_ = level;
				_loc3_ = _loc3_;
				_loc4_ = _loc3_ / 200000;
				_loc5_ += _loc4_;
				if (g.solarSystem.isPvpSystemInEditor)
				{
					_loc5_ = 100;
				}
				if (level == 2)
				{
					_loc2_ = 8;
				}
				else
				{
					_loc2_ = (100 + 8 * (_loc5_ - 1)) / (100 + 8 * (_loc5_ - 2)) * 100 - 100;
				}
				_loc1_ = ship.hpBase * _loc2_ / 100;
				ship.hpBase += _loc1_;
				ship.hpMax += _loc1_;
				_loc1_ = ship.shieldHpBase * _loc2_ / 100;
				ship.shieldHpBase += _loc1_;
				ship.shieldHpMax += _loc1_;
				_loc1_ = ship.armorThresholdBase * _loc2_ / 100;
				ship.armorThresholdBase += _loc1_;
				ship.armorThreshold += _loc1_;
				_loc2_ = (100 + 1 * (_loc5_ - 1)) / (100 + 1 * (_loc5_ - 2)) * 100 - 100;
				_loc1_ = ship.shieldRegenBase * _loc2_ / 100;
				ship.shieldRegenBase += _loc1_;
				ship.shieldRegen += _loc1_;
				if (level == 2)
				{
					_loc2_ = 8;
				}
				else
				{
					_loc2_ = (100 + 8 * (_loc5_ - 1)) / (100 + 8 * (_loc5_ - 2)) * 100 - 100;
				}
				refreshWeapons();
				level = _loc6_;
			}
		}
		
		public function increaseXp(param1:int, param2:int):void
		{
			xp = param2;
			while (xp > levelXpMax)
			{
				levelUp();
			}
			if (isMe)
			{
				g.textManager.createXpText(param1);
			}
		}
		
		public function decreaseXp(param1:int, param2:int):void
		{
			xp = param2;
			if (isMe)
			{
				g.textManager.createXpText(-param1);
			}
		}
		
		public function updateReputation(param1:int, param2:int):void
		{
			reputation = param2;
			Login.submitKongregateStat("Reputation", param1);
			if (ship == null)
			{
				return;
			}
			if (param1 != 0)
			{
				g.textManager.createReputationText(param1, ship);
			}
		}
		
		public function get levelXpMax():int
		{
			if (level >= 100)
			{
				return int((level + 2) * level * 500 * Math.pow(1.06, level - 99));
			}
			return (level + 2) * level * 500;
		}
		
		public function get levelXpMin():int
		{
			if (level >= 100)
			{
				return int((level + 1) * (level - 1) * 500 * Math.pow(1.06, level - 100));
			}
			if (level == 1)
			{
				return 0;
			}
			return (level + 1) * (level - 1) * 500;
		}
		
		public function loadCourse(param1:Heading):void
		{
			if (ship != null)
			{
				ship.course = param1;
			}
		}
		
		public function get hasExpBoost():Boolean
		{
			if (isModerator)
			{
				return true;
			}
			return expBoost > g.time;
		}
		
		public function set level(param1:int):void
		{
			_level = param1;
			if (ship != null)
			{
				ship.level = param1;
				ship.updateLabel();
			}
		}
		
		public function get level():int
		{
			return _level;
		}
		
		public function initRoaming(param1:Message, param2:int, param3:Boolean = true):int
		{
			if (stateMachine.inState(RoamingState))
			{
				return param2;
			}
			unloadShip();
			level = param1.getInt(param2++);
			xp = param1.getInt(param2++);
			techPoints = param1.getInt(param2++);
			isHostile = param1.getBoolean(param2++);
			var _loc6_:String = param1.getString(param2++);
			var _loc5_:int = param1.getInt(param2++);
			var _loc8_:int = param1.getInt(param2++);
			var _loc7_:int = param1.getInt(param2++);
			var _loc12_:int = param1.getInt(param2++);
			var _loc11_:int = param1.getInt(param2++);
			var _loc9_:Number = param1.getNumber(param2++);
			var _loc10_:Number = param1.getNumber(param2++);
			var _loc4_:Heading = new Heading();
			param2 = _loc4_.parseMessage(param1, param2);
			playerKills = param1.getInt(param2++);
			playerDeaths = param1.getInt(param2++);
			enemyKills = param1.getInt(param2++);
			showIntro = param1.getBoolean(param2++);
			clanId = param1.getString(param2++);
			clanApplicationId = param1.getString(param2++);
			troons = param1.getNumber(param2++);
			param2 = initFleetFromMessage(param1, param2);
			loadShip(_loc8_, _loc7_, _loc12_, _loc11_);
			ship.id = _loc5_;
			loadCourse(_loc4_);
			if (isMe)
			{
				applyArtifactStats();
				ship.shieldHp = _loc8_;
				ship.hp = _loc7_;
				g.hud.weaponHotkeys.refresh();
				g.hud.abilities.refresh();
				g.hud.healthAndShield.update();
				g.hud.powerBar.update();
				if (param3)
				{
					g.fadeIntoState(new RoamingState(g));
				}
			}
			else
			{
				ship.engine.speed = _loc9_;
				ship.engine.acceleration = _loc10_;
			}
			enterRoaming();
			g.groupManager.autoJoinOrCreateGroup(this, _loc6_);
			return param2;
		}
		
		public function enterRoaming():void
		{
			isLanded = false;
			isTakingOff = false;
			if (!stateMachine.inState(Roaming))
			{
				stateMachine.changeState(new Roaming(this, g));
			}
		}
		
		public function startLanded(param1:Body):void
		{
			if (stateMachine.inState(Landed))
			{
				return;
			}
			stateMachine.changeState(new Landed(this, param1, g));
		}
		
		public function land(param1:Body):void
		{
			var that:Player;
			var toRot:Number;
			var body:Body = param1;
			if (stateMachine.inState(Landed))
			{
				return;
			}
			isLanded = true;
			that = this;
			toRot = 0;
			if (ship.rotation > 3.1)
			{
				toRot = 6.2;
			}
			ship.engine.stop();
			if (!isMe)
			{
				TweenMax.to(ship, 1.2, {"x": body.x, "y": body.y, "scaleX": 0.5, "scaleY": 0.5, "rotation": toRot, "onComplete": function():void
				{
					stateMachine.changeState(new Landed(that, body, g));
					ship.removeFromCanvas();
					ship.land();
				}});
				return;
			}
			g.camera.zoomFocus(3, 25);
			TweenMax.to(ship, 1.2, {"x": body.x, "y": body.y, "scaleX": 0.5, "scaleY": 0.5, "rotation": toRot, "onComplete": function():void
			{
				stateMachine.changeState(new Landed(g.me, body, g));
				g.enterLandedState();
				ship.land();
				TweenMax.delayedCall(0.5, function():void
				{
					g.camera.zoomFocus(1, 1);
				});
			}});
		}
		
		public function enterKilled(param1:Message):void
		{
			if (g.solarSystem.isPvpSystemInEditor)
			{
				respawnNextReady = g.time + 3000;
			}
			else
			{
				respawnNextReady = g.time + 10000;
			}
			stateMachine.changeState(new Killed(this, g, param1));
		}
		
		public function hasExploredArea(param1:String):Boolean
		{
			for each (var _loc2_:* in explores)
			{
				if (param1 == _loc2_.areaKey && _loc2_.finished && _loc2_.lootClaimed)
				{
					return true;
				}
			}
			return false;
		}
		
		public function leaveBody():void
		{
			if (!isTakingOff)
			{
				Console.write("Leaving body");
				isTakingOff = true;
				g.send("leaveBody");
			}
		}
		
		public function initMissionsFromMessage(param1:Message, param2:int):int
		{
			Console.write("Init missions");
			missions = new Vector.<Mission>();
			var _loc3_:int = param1.getInt(param2);
			var _loc4_:int = param2 + 1;
			while (_loc3_ > 0)
			{
				_loc4_ = addMission(param1, _loc4_);
				_loc3_--;
			}
			return _loc4_;
		}
		
		public function addMission(param1:Message, param2:int):int
		{
			var _loc3_:Mission = new Mission();
			_loc3_.id = param1.getString(param2++);
			_loc3_.missionTypeKey = param1.getString(param2++);
			_loc3_.type = param1.getString(param2++);
			_loc3_.majorType = param1.getString(param2++);
			_loc3_.count = param1.getInt(param2++);
			_loc3_.viewed = param1.getBoolean(param2++);
			_loc3_.finished = param1.getBoolean(param2++);
			_loc3_.claimed = param1.getBoolean(param2++);
			_loc3_.created = param1.getNumber(param2++);
			_loc3_.expires = param1.getNumber(param2++);
			missions.push(_loc3_);
			return param2;
		}
		
		public function hasMission(param1:String):Boolean
		{
			for each (var _loc2_:* in missions)
			{
				if (_loc2_.id == param1)
				{
					return true;
				}
			}
			return false;
		}
		
		public function removeMission(param1:Mission):void
		{
			var _loc2_:int = 0;
			_loc2_ = 0;
			while (_loc2_ < missions.length)
			{
				if (missions[_loc2_].missionTypeKey == param1.missionTypeKey)
				{
					missions.splice(_loc2_, 1);
					return;
				}
				_loc2_++;
			}
		}
		
		public function initFinishedExploresFromMessage(param1:Message, param2:int):int
		{
			var _loc3_:String = null;
			var _loc7_:int = 0;
			var _loc4_:Explore = null;
			explores = new Vector.<Explore>();
			var _loc5_:int = param1.getInt(param2);
			var _loc8_:int = param2 + 1;
			var _loc6_:Object = g.dataManager.loadTable("BodyAreas");
			while (_loc5_ > 0)
			{
				_loc3_ = param1.getString(_loc8_++);
				_loc7_ = int(_loc6_[_loc3_] != null ? _loc6_[_loc3_].size : 0);
				_loc7_ = _loc7_ + 4;
				_loc4_ = new Explore();
				_loc4_.key = "";
				_loc4_.areaKey = _loc3_;
				_loc4_.bodyKey = "";
				_loc4_.failed = false;
				_loc4_.failTime = 0;
				_loc4_.finished = true;
				_loc4_.finishTime = 0;
				_loc4_.lootClaimed = true;
				_loc4_.playerKey = id;
				_loc4_.startEvent = 0;
				_loc4_.startTime = 0;
				_loc4_.successfulEvents = _loc7_;
				explores.push(_loc4_);
				_loc5_--;
			}
			return _loc8_;
		}
		
		public function initExploresFromMessage(param1:Message, param2:int):int
		{
			var _loc3_:Explore = null;
			var _loc4_:int = param1.getInt(param2);
			var _loc5_:int = param2 + 1;
			while (_loc4_ > 0)
			{
				_loc3_ = new Explore();
				_loc3_.key = param1.getString(_loc5_++);
				_loc3_.areaKey = param1.getString(_loc5_++);
				_loc3_.bodyKey = param1.getString(_loc5_++);
				_loc3_.failed = param1.getBoolean(_loc5_++);
				_loc3_.failTime = param1.getNumber(_loc5_++);
				_loc3_.finished = param1.getBoolean(_loc5_++);
				_loc3_.finishTime = param1.getNumber(_loc5_++);
				_loc3_.lootClaimed = param1.getBoolean(_loc5_++);
				_loc3_.playerKey = param1.getString(_loc5_++);
				_loc3_.startEvent = param1.getInt(_loc5_++);
				_loc3_.startTime = param1.getNumber(_loc5_++);
				_loc3_.successfulEvents = param1.getInt(_loc5_++);
				explores.push(_loc3_);
				_loc4_--;
			}
			return _loc5_;
		}
		
		public function initLandedBodiesFromMessage(param1:Message, param2:int):int
		{
			var _loc4_:int = 0;
			landedBodies = new Vector.<LandedBody>();
			var _loc3_:int = param1.getInt(param2);
			_loc4_ = param2 + 1;
			while (_loc4_ < param2 + _loc3_ * 2 + 1)
			{
				landedBodies.push(new LandedBody(param1.getString(_loc4_), param1.getBoolean(_loc4_ + 1)));
				_loc4_ += 2;
			}
			return _loc4_;
		}
		
		public function initEncountersFromMessage(param1:Message, param2:int):int
		{
			var _loc4_:int = 0;
			encounters = new Vector.<String>();
			var _loc3_:int = param1.getInt(param2);
			_loc4_ = param2 + 1;
			while (_loc4_ < param2 + _loc3_ + 1)
			{
				encounters.push(param1.getString(_loc4_));
				_loc4_++;
			}
			return _loc4_;
		}
		
		public function initCompletedMissionsFromMessage(param1:Message, param2:int):int
		{
			var _loc4_:int = 0;
			completedMissions = {};
			var _loc3_:int = param1.getInt(param2);
			_loc4_ = param2 + 1;
			while (_loc4_ < param2 + _loc3_ * 2 + 1)
			{
				completedMissions[param1.getString(_loc4_)] = param1.getNumber(_loc4_ + 1);
				_loc4_ += 2;
			}
			return _loc4_;
		}
		
		public function initTriggeredMissionsFromMessage(param1:Message, param2:int):int
		{
			var _loc4_:int = 0;
			triggeredMissions = new Vector.<String>();
			var _loc3_:int = param1.getInt(param2);
			_loc4_ = param2 + 1;
			while (_loc4_ < param2 + _loc3_ + 1)
			{
				triggeredMissions.push(param1.getString(_loc4_));
				_loc4_++;
			}
			return _loc4_;
		}
		
		public function initCrewFromMessage(param1:Message, param2:int):int
		{
			var _loc7_:int = 0;
			var _loc5_:CrewMember = null;
			var _loc3_:Array = null;
			var _loc6_:Array = null;
			crewMembers = new Vector.<CrewMember>();
			var _loc4_:int = param1.getInt(param2);
			_loc7_ = param2 + 1;
			while (_loc7_ < param2 + _loc4_ * 30 + 1)
			{
				_loc5_ = new CrewMember(g);
				_loc5_.seed = param1.getInt(_loc7_++);
				_loc5_.key = param1.getString(_loc7_++);
				_loc5_.name = param1.getString(_loc7_++);
				_loc5_.solarSystem = param1.getString(_loc7_++);
				_loc5_.area = param1.getString(_loc7_++);
				_loc5_.body = param1.getString(_loc7_++);
				_loc5_.imageKey = param1.getString(_loc7_++);
				_loc5_.injuryEnd = param1.getNumber(_loc7_++);
				_loc5_.injuryStart = param1.getNumber(_loc7_++);
				_loc5_.trainingEnd = param1.getNumber(_loc7_++);
				_loc5_.trainingType = param1.getInt(_loc7_++);
				_loc5_.artifactEnd = param1.getNumber(_loc7_++);
				_loc5_.artifact = param1.getString(_loc7_++);
				_loc5_.missions = param1.getInt(_loc7_++);
				_loc5_.successMissions = param1.getInt(_loc7_++);
				_loc5_.rank = param1.getInt(_loc7_++);
				_loc5_.fullLocation = param1.getString(_loc7_++);
				_loc5_.skillPoints = param1.getInt(_loc7_++);
				_loc3_ = [];
				_loc3_.push(param1.getNumber(_loc7_++));
				_loc3_.push(param1.getNumber(_loc7_++));
				_loc3_.push(param1.getNumber(_loc7_++));
				_loc5_.skills = _loc3_;
				_loc6_ = [];
				_loc6_.push(param1.getNumber(_loc7_++));
				_loc6_.push(param1.getNumber(_loc7_++));
				_loc6_.push(param1.getNumber(_loc7_++));
				_loc6_.push(param1.getNumber(_loc7_++));
				_loc6_.push(param1.getNumber(_loc7_++));
				_loc6_.push(param1.getNumber(_loc7_++));
				_loc6_.push(param1.getNumber(_loc7_++));
				_loc6_.push(param1.getNumber(_loc7_++));
				_loc6_.push(param1.getNumber(_loc7_++));
				_loc5_.specials = _loc6_;
				crewMembers.push(_loc5_);
				_loc7_ += 0;
			}
			return _loc7_;
		}
		
		public function initFleetFromMessage(param1:Message, param2:int):int
		{
			var _loc6_:int = 0;
			var _loc4_:FleetObj = null;
			fleet.length = 0;
			activeSkin = param1.getString(param2++);
			var _loc5_:int = param1.getInt(param2++);
			var _loc3_:* = param2;
			_loc6_ = 0;
			while (_loc6_ < _loc5_)
			{
				_loc4_ = new FleetObj();
				_loc3_ = _loc4_.initFromMessage(param1, _loc3_);
				if (_loc4_.skin == activeSkin)
				{
					techSkills = _loc4_.techSkills;
					weapons = _loc4_.weapons;
					weaponsState = _loc4_.weaponsState;
					weaponsHotkeys = _loc4_.weaponsHotkeys;
					nrOfUpgrades = _loc4_.nrOfUpgrades;
					activeArtifactSetup = _loc4_.activeArtifactSetup;
					activeWeapon = _loc4_.activeWeapon;
				}
				fleet.push(_loc4_);
				_loc6_++;
			}
			return _loc3_;
		}
		
		public function addNewSkin(param1:String):void
		{
			if (hasSkin(param1))
			{
				return;
			}
			var _loc2_:FleetObj = new FleetObj();
			_loc2_.initFromSkin(param1);
			fleet.push(_loc2_);
		}
		
		private function initWarpPathLicensesFromMessage(param1:Message, param2:int):int
		{
			var _loc4_:int = 0;
			var _loc3_:int = param1.getInt(param2++);
			warpPathLicenses = [];
			_loc4_ = 0;
			while (_loc4_ < _loc3_)
			{
				warpPathLicenses.push(param1.getString(param2++));
				_loc4_++;
			}
			return param2;
		}
		
		private function initSolarSystemLicensesFromMessage(param1:Message, param2:int):int
		{
			var _loc4_:int = 0;
			var _loc3_:int = param1.getInt(param2++);
			solarSystemLicenses = [];
			_loc4_ = 0;
			while (_loc4_ < _loc3_)
			{
				solarSystemLicenses.push(param1.getString(param2++));
				_loc4_++;
			}
			return param2;
		}
		
		private function initArtifactsFromMessage(param1:Message, param2:int):int
		{
			var setups:int;
			var keysToLoad:Array;
			var setup:Array;
			var count:int;
			var artifactId:String;
			var m:Message = param1;
			var startIndex:int = param2;
			artifacts = g.dataManager.getArtifacts();
			artifactSetups.length = 0;
			setups = m.getInt(startIndex++);
			keysToLoad = [];
			while (setups > 0)
			{
				setup = [];
				count = m.getInt(startIndex++);
				while (count > 0)
				{
					artifactId = m.getString(startIndex++);
					setup.push(artifactId);
					if (keysToLoad.indexOf(artifactId) == -1 && getArtifactById(artifactId) == null)
					{
						keysToLoad.push(artifactId);
					}
					count--;
				}
				artifactSetups.push(setup);
				setups--;
			}
			if (keysToLoad.length != 0)
			{
				ArtifactFactory.createArtifacts(keysToLoad, g, this, function():void
				{
					applyArtifactStats();
				});
			}
			else
			{
				Starling.juggler.delayCall(applyArtifactStats, 1);
			}
			return startIndex;
		}
		
		private function applySkinArtifact():void
		{
			var _loc1_:Object = DataLocator.getService().loadKey("Skins", activeSkin);
			addArtifactStat(ArtifactFactory.createArtifactFromSkin(_loc1_), false);
		}
		
		private function applyArtifactStats():void
		{
			var _loc1_:Artifact = null;
			if (ship == null)
			{
				return;
			}
			applySkinArtifact();
			for each (var _loc2_:* in activeArtifacts)
			{
				_loc1_ = getArtifactById(_loc2_);
				if (_loc1_ != null)
				{
					addArtifactStat(_loc1_, false);
				}
			}
			ship.hp = ship.hpMax;
			ship.shieldHp = ship.shieldHpMax;
		}
		
		public function changeArtifactSetup(param1:int):void
		{
			var _loc4_:* = null;
			var _loc2_:Artifact = null;
			var _loc5_:int = 0;
			var _loc3_:FleetObj = null;
			for each (_loc4_ in activeArtifacts)
			{
				_loc2_ = getArtifactById(_loc4_);
				if (_loc2_ != null)
				{
					removeArtifactStat(_loc2_, false);
				}
			}
			activeArtifactSetup = param1;
			_loc5_ = 0;
			while (_loc5_ < fleet.length)
			{
				_loc3_ = fleet[_loc5_];
				if (_loc3_.skin == activeSkin)
				{
					_loc3_.activeArtifactSetup = param1;
					break;
				}
				_loc5_++;
			}
			for each (_loc4_ in activeArtifacts)
			{
				_loc2_ = getArtifactById(_loc4_);
				if (_loc2_ != null)
				{
					addArtifactStat(_loc2_, false);
				}
			}
		}
		
		private function loadArtifactsFromMessage(param1:Message, param2:int, param3:Boolean = false):int
		{
			var id:String;
			var m:Message = param1;
			var startIndex:int = param2;
			var isLoot:Boolean = param3;
			var nrOfArtifacts:int = m.getInt(startIndex++);
			var i:int = 0;
			while (i < nrOfArtifacts)
			{
				id = m.getString(startIndex++);
				ArtifactFactory.createArtifact(id, g, this, function(param1:Artifact):void
				{
					if (param1 == null)
					{
						return;
					}
					if (isLoot)
					{
						MessageLog.writeChatMsg("loot", "<FONT COLOR='#4488ff'>You found a new artifact: " + param1.name + ".</FONT>");
						g.textManager.createDropText("You found a new Artifact!", 1, 20, 5000, 4491519);
					}
					artifacts.push(param1);
				});
				i++;
			}
			return startIndex;
		}
		
		public function addWeapon(param1:String):void
		{
			weapons.push({"weapon": param1});
			addTechSkill(name, "Weapons", param1);
			refreshWeapons();
		}
		
		public function pickupArtifacts(param1:Message):void
		{
			g.hud.artifactsButton.hintNew();
			loadArtifactsFromMessage(param1, 0, true);
			artifactCount += param1.getInt(0);
			if (artifactCount >= artifactLimit)
			{
				g.hud.showArtifactLimitText();
			}
		}
		
		public function pickupArtifact(param1:Message):void
		{
			g.hud.artifactsButton.hintNew();
			loadArtifactsFromMessage(param1, 0, true);
			artifactCount += 1;
			if (artifactCount >= artifactLimit)
			{
				g.hud.showArtifactLimitText();
			}
		}
		
		public function checkPickupMessage(param1:Message, param2:int):void
		{
			var _loc6_:String = null;
			var _loc3_:String = null;
			var _loc7_:String = null;
			var _loc4_:int = 0;
			var _loc13_:Boolean = false;
			var _loc10_:Boolean = false;
			if (!isMe)
			{
				return;
			}
			var _loc12_:Boolean = param1.getBoolean(param2);
			var _loc5_:Boolean = param1.getBoolean(param2 + 1);
			var _loc9_:Boolean = param1.getBoolean(param2 + 2);
			param2 += 3;
			if (_loc5_)
			{
				g.hud.artifactsButton.hintNew();
				param2 = loadArtifactsFromMessage(param1, param2, true);
				artifactCount += 1;
				if (artifactCount >= artifactLimit)
				{
					g.hud.showArtifactLimitText();
				}
			}
			if (_loc12_)
			{
				MessageLog.writeChatMsg("loot", "<FONT COLOR='#4488ff'>You found a Crate</FONT>");
			}
			if (_loc9_)
			{
				MessageLog.writeChatMsg("loot", "<FONT COLOR='#ffcc44'>Auto recycled artifact</FONT>");
			}
			var _loc11_:int = param1.getInt(param2++);
			var _loc8_:int = param2 + _loc11_ * 6;
			param2;
			while (param2 < _loc8_)
			{
				_loc6_ = param1.getString(param2);
				_loc3_ = param1.getString(param2 + 1);
				_loc7_ = param1.getString(param2 + 2);
				_loc4_ = param1.getInt(param2 + 3);
				_loc13_ = param1.getBoolean(param2 + 4);
				_loc10_ = param1.getBoolean(param2 + 5);
				if (_loc3_ == "Weapons")
				{
					MessageLog.writeChatMsg("loot", "<FONT COLOR='#ff3322'>You found a new weapon: " + _loc6_ + "</FONT>");
					g.textManager.createDropText("You found the " + _loc6_ + "!", 1, 20, 5000, 16724770);
				}
				else if (_loc12_)
				{
					g.textManager.createDropText(_loc6_, _loc4_, 20, 5000, 16777096);
					MessageLog.writeChatMsg("loot", _loc6_ + " x" + _loc4_);
					g.myCargo.addItem(_loc3_, _loc7_, _loc4_);
				}
				else if (_loc9_)
				{
					g.textManager.createDropText(_loc6_, _loc4_, 14, 5000, 16763972);
					g.myCargo.addItem(_loc3_, _loc7_, _loc4_);
				}
				else
				{
					g.textManager.createDropText(_loc6_, _loc4_);
					g.myCargo.addItem(_loc3_, _loc7_, _loc4_);
				}
				g.hud.cargoButton.update();
				g.hud.resourceBox.update();
				g.hud.cargoButton.flash();
				if (_loc13_)
				{
					weapons.push({"weapon": _loc7_});
					refreshWeapons();
				}
				if (_loc10_)
				{
					addTechSkill(_loc6_, _loc3_, _loc7_);
				}
				param2 += 6;
			}
		}
		
		public function addTechSkill(param1:String, param2:String, param3:String):void
		{
			techSkills.push(new TechSkill(param1, param3, param2, 0));
		}
		
		private function refreshWeapons(param1:Boolean = true):void
		{
			if (ship != null)
			{
				ship.weaponIsChanging = true;
				ShipFactory.CreatePlayerShipWeapon(g, this, 0, weapons, ship);
				if (isMe)
				{
					if (param1)
					{
						autoSetHotkeysForWeapons();
					}
					g.hud.weaponHotkeys.refresh();
				}
				ship.weaponIsChanging = false;
			}
		}
		
		private function autoSetHotkeysForWeapons():void
		{
			var _loc2_:Vector.<Weapon> = ship.weapons;
			for each (var _loc1_:* in _loc2_)
			{
				if (_loc1_.hotkey == 0)
				{
					g.playerManager.trySetActiveWeapons(this, -1, _loc1_.key);
				}
			}
		}
		
		public function nrOfActiveArtifacts():int
		{
			return activeArtifacts.length;
		}
		
		public function getArtifactById(param1:String):Artifact
		{
			var _loc2_:int = 0;
			_loc2_ = 0;
			while (_loc2_ < artifacts.length)
			{
				if (artifacts[_loc2_].id === param1)
				{
					return artifacts[_loc2_];
				}
				_loc2_++;
			}
			return null;
		}
		
		public function isActiveArtifact(param1:Artifact):Boolean
		{
			return activeArtifacts.indexOf(param1.id) != -1;
		}
		
		public function isArtifactInSetup(param1:Artifact):Boolean
		{
			for each (var _loc2_:* in artifactSetups)
			{
				if (_loc2_.indexOf(param1.id) != -1)
				{
					return true;
				}
			}
			return false;
		}
		
		public function addArtifactStat(param1:Artifact, param2:Boolean = true):void
		{
			addRemoveArtifactStat(param1, true, param2);
		}
		
		public function removeArtifactStat(param1:Artifact, param2:Boolean = true):void
		{
			addRemoveArtifactStat(param1, false, param2);
		}
		
		public function toggleArtifact(param1:Artifact, param2:Boolean = true):void
		{
			var _loc3_:int = int(activeArtifacts.indexOf(param1.id));
			if (_loc3_ != -1)
			{
				activeArtifacts.splice(_loc3_, 1);
				removeArtifactStat(param1, param2);
			}
			else
			{
				activeArtifacts.push(param1.id);
				addArtifactStat(param1, param2);
			}
		}
		
		private function addRemoveArtifactStat(param1:Artifact, param2:Boolean, param3:Boolean = true):void
		{
			var _loc6_:Number = NaN;
			var _loc4_:* = null;
			var _loc7_:int = 0;
			if (ship == null)
			{
				return;
			}
			if (param3)
			{
				g.send("toggleArtifact", param1.id);
			}
			for each (var _loc5_:* in param1.stats)
			{
				_loc6_ = 1;
				if (!param2)
				{
					_loc6_ = -1;
				}
				if (_loc5_.type == "healthAdd" || _loc5_.type == "healthAdd2" || _loc5_.type == "healthAdd3")
				{
					ship.removeConvert();
					ship.hpMax += int(_loc6_ * 2 * _loc5_.value);
					ship.addConvert();
				}
				else if (_loc5_.type == "healthMulti")
				{
					ship.removeConvert();
					ship.hpMax += int(_loc6_ * ship.hpBase * (1.35 * _loc5_.value) / 100);
					ship.addConvert();
				}
				else if (_loc5_.type == "armorAdd" || _loc5_.type == "armorAdd2" || _loc5_.type == "armorAdd3")
				{
					ship.armorThreshold += int(_loc6_ * 7.5 * _loc5_.value);
				}
				else if (_loc5_.type == "armorMulti")
				{
					ship.armorThreshold += int(_loc6_ * ship.armorThresholdBase * _loc5_.value / 100);
				}
				else if (_loc5_.type == "shieldAdd" || _loc5_.type == "shieldAdd2" || _loc5_.type == "shieldAdd3")
				{
					ship.removeConvert();
					ship.shieldHpMax += int(_loc6_ * 1.5 * _loc5_.value);
					ship.shieldRegen += int(_loc6_ * ship.shieldRegenBase * (0.0025 * _loc5_.value) / 100);
					ship.addConvert();
				}
				else if (_loc5_.type == "shieldMulti")
				{
					ship.removeConvert();
					ship.shieldHpMax += int(_loc6_ * ship.shieldHpBase * (1.35 * _loc5_.value) / 100);
					ship.shieldRegen += int(_loc6_ * ship.shieldRegenBase * (0.25 * _loc5_.value) / 100);
					ship.addConvert();
				}
				else if (_loc5_.type == "shieldRegen")
				{
					ship.removeConvert();
					ship.shieldRegen += int(_loc6_ * ship.shieldRegenBase * _loc5_.value / 100);
					ship.addConvert();
				}
				else if (_loc5_.type == "corrosiveAdd" || _loc5_.type == "corrosiveAdd2" || _loc5_.type == "corrosiveAdd3")
				{
					for each (_loc4_ in ship.weapons)
					{
						_loc4_.dmg.addDmgInt(int(_loc6_ * 4 * _loc5_.value), 2);
						if (_loc4_.multiNrOfP > 1)
						{
							_loc4_.debuffValue.addDmgInt(int(1.5 / _loc4_.multiNrOfP * 4 * _loc6_ * _loc5_.value), 2);
							_loc4_.debuffValue2.addDmgInt(int(1.5 / _loc4_.multiNrOfP * 4 * _loc6_ * _loc5_.value), 2);
						}
						else
						{
							_loc4_.debuffValue.addDmgInt(int(_loc6_ * 4 * _loc5_.value), 2);
							_loc4_.debuffValue2.addDmgInt(int(_loc6_ * 4 * _loc5_.value), 2);
						}
					}
				}
				else if (_loc5_.type == "corrosiveMulti")
				{
					for each (_loc4_ in ship.weapons)
					{
						_loc4_.dmg.addDmgPercent(_loc6_ * _loc5_.value, 2);
						_loc4_.debuffValue.addDmgPercent(_loc6_ * _loc5_.value, 2);
						_loc4_.debuffValue2.addDmgPercent(_loc6_ * _loc5_.value, 2);
					}
				}
				else if (_loc5_.type == "energyAdd" || _loc5_.type == "energyAdd2" || _loc5_.type == "energyAdd3")
				{
					for each (_loc4_ in ship.weapons)
					{
						_loc4_.dmg.addDmgInt(int(_loc6_ * 4 * _loc5_.value), 1);
						if (_loc4_.multiNrOfP > 1)
						{
							_loc4_.debuffValue.addDmgInt(int(1.5 / _loc4_.multiNrOfP * _loc6_ * 4 * _loc5_.value), 1);
							_loc4_.debuffValue2.addDmgInt(int(1.5 / _loc4_.multiNrOfP * _loc6_ * 4 * _loc5_.value), 1);
						}
						else
						{
							_loc4_.debuffValue.addDmgInt(int(_loc6_ * 4 * _loc5_.value), 1);
							_loc4_.debuffValue2.addDmgInt(int(_loc6_ * 4 * _loc5_.value), 1);
						}
					}
				}
				else if (_loc5_.type == "energyMulti")
				{
					for each (_loc4_ in ship.weapons)
					{
						_loc4_.dmg.addDmgPercent(_loc6_ * _loc5_.value, 1);
						_loc4_.debuffValue.addDmgPercent(_loc6_ * _loc5_.value, 1);
						_loc4_.debuffValue2.addDmgPercent(_loc6_ * _loc5_.value, 1);
					}
				}
				else if (_loc5_.type == "kineticAdd" || _loc5_.type == "kineticAdd2" || _loc5_.type == "kineticAdd3")
				{
					for each (_loc4_ in ship.weapons)
					{
						_loc4_.dmg.addDmgInt(int(_loc6_ * 4 * _loc5_.value), 0);
						if (_loc4_.multiNrOfP > 1)
						{
							_loc4_.debuffValue.addDmgInt(int(1.5 / _loc4_.multiNrOfP * _loc6_ * 4 * _loc5_.value), 0);
							_loc4_.debuffValue2.addDmgInt(int(1.5 / _loc4_.multiNrOfP * _loc6_ * 4 * _loc5_.value), 0);
						}
						else
						{
							_loc4_.debuffValue.addDmgInt(int(_loc6_ * 4 * _loc5_.value), 0);
							_loc4_.debuffValue2.addDmgInt(int(_loc6_ * 4 * _loc5_.value), 0);
						}
					}
				}
				else if (_loc5_.type == "kineticMulti")
				{
					for each (_loc4_ in ship.weapons)
					{
						_loc4_.dmg.addDmgPercent(_loc6_ * _loc5_.value, 0);
						_loc4_.debuffValue.addDmgPercent(_loc6_ * _loc5_.value, 0);
						_loc4_.debuffValue2.addDmgPercent(_loc6_ * _loc5_.value, 0);
					}
				}
				else if (_loc5_.type == "allAdd" || _loc5_.type == "allAdd2" || _loc5_.type == "allAdd3")
				{
					for each (_loc4_ in ship.weapons)
					{
						_loc4_.dmg.addDmgInt(int(_loc6_ * 1.5 * _loc5_.value), 5);
						if (_loc4_.multiNrOfP > 1)
						{
							_loc4_.debuffValue.addDmgInt(int(1.5 / _loc4_.multiNrOfP * _loc6_ * 1.5 * _loc5_.value), 5);
							_loc4_.debuffValue2.addDmgInt(int(1.5 / _loc4_.multiNrOfP * _loc6_ * 1.5 * _loc5_.value), 5);
						}
						else
						{
							_loc4_.debuffValue.addDmgInt(int(_loc6_ * 1.5 * _loc5_.value), 5);
							_loc4_.debuffValue2.addDmgInt(int(_loc6_ * 1.5 * _loc5_.value), 5);
						}
					}
				}
				else if (_loc5_.type == "allMulti")
				{
					for each (_loc4_ in ship.weapons)
					{
						_loc4_.dmg.addDmgPercent(_loc6_ * 1.5 * _loc5_.value, 5);
						_loc4_.debuffValue.addDmgPercent(_loc6_ * 1.5 * _loc5_.value, 5);
						_loc4_.debuffValue2.addDmgPercent(_loc6_ * 1.5 * _loc5_.value, 5);
					}
				}
				else if (_loc5_.type == "allResist")
				{
					_loc7_ = 0;
					while (_loc7_ < 5)
					{
						var _loc9_:* = _loc7_;
						var _loc8_:* = ship.resistances[_loc9_] + _loc6_ * _loc5_.value * Damage.stats[5][_loc7_];
						ship.resistances[_loc9_] = _loc8_;
						if (ship.resistances[_loc7_] < 0)
						{
							ship.resistances[_loc7_] = 0;
						}
						_loc7_++;
					}
				}
				else if (_loc5_.type == "kineticResist")
				{
					var _loc11_:int = 0;
					var _loc10_:* = ship.resistances[_loc11_] + _loc6_ * _loc5_.value;
					ship.resistances[_loc11_] = _loc10_;
					if (ship.resistances[0] < 0)
					{
						ship.resistances[0] = 0;
					}
				}
				else if (_loc5_.type == "energyResist")
				{
					var _loc13_:int = 1;
					var _loc12_:* = ship.resistances[_loc13_] + _loc6_ * _loc5_.value;
					ship.resistances[_loc13_] = _loc12_;
					if (ship.resistances[1] < 0)
					{
						ship.resistances[1] = 0;
					}
				}
				else if (_loc5_.type == "corrosiveResist")
				{
					var _loc15_:int = 2;
					var _loc14_:* = ship.resistances[_loc15_] + _loc6_ * _loc5_.value;
					ship.resistances[_loc15_] = _loc14_;
					if (ship.resistances[2] < 0)
					{
						ship.resistances[2] = 0;
					}
				}
				else if (_loc5_.type == "speed" || _loc5_.type == "speed2" || _loc5_.type == "speed3")
				{
					ship.engine.speed /= 1 + ship.aritfact_speed;
					ship.aritfact_speed += _loc6_ * 0.001 * 2 * _loc5_.value;
					ship.engine.speed *= 1 + ship.aritfact_speed;
				}
				else if (_loc5_.type == "refire" || _loc5_.type == "refire2" || _loc5_.type == "refire3")
				{
					_loc7_ = 0;
					while (_loc7_ < ship.weapons.length)
					{
						if (ship.weapons[_loc7_] is Teleport)
						{
							ship.weapons[_loc7_].speed /= 1 + 0.5 * ship.aritfact_refire;
						}
						else if (!(ship.weapons[_loc7_] is Cloak))
						{
							ship.weapons[_loc7_].reloadTime *= 1 + ship.aritfact_refire;
							ship.weapons[_loc7_].heatCost *= 1 + ship.aritfact_refire;
						}
						_loc7_++;
					}
					ship.aritfact_refire += _loc6_ * 3 * 0.001 * _loc5_.value;
					_loc7_ = 0;
					while (_loc7_ < ship.weapons.length)
					{
						if (ship.weapons[_loc7_] is Teleport)
						{
							ship.weapons[_loc7_].speed *= 1 + 0.5 * ship.aritfact_refire;
						}
						else if (!(ship.weapons[_loc7_] is Cloak))
						{
							ship.weapons[_loc7_].reloadTime /= 1 + ship.aritfact_refire;
							ship.weapons[_loc7_].heatCost /= 1 + ship.aritfact_refire;
						}
						_loc7_++;
					}
				}
				else if (_loc5_.type == "convHp")
				{
					ship.removeConvert();
					ship.aritfact_convAmount -= _loc6_ * 0.001 * _loc5_.value;
					ship.addConvert();
				}
				else if (_loc5_.type == "convShield")
				{
					ship.removeConvert();
					ship.aritfact_convAmount += _loc6_ * 0.001 * _loc5_.value;
					ship.addConvert();
				}
				else if (_loc5_.type == "powerReg" || _loc5_.type == "powerReg2" || _loc5_.type == "powerReg3")
				{
					ship.powerRegBonus += _loc6_ * 0.001 * 1.5 * _loc5_.value;
					ship.weaponHeat.setBonuses(ship.maxPower + ship.aritfact_powerMax, ship.powerRegBonus + ship.aritfact_poweReg);
				}
				else if (_loc5_.type == "powerMax")
				{
					ship.aritfact_powerMax += _loc6_ * 0.01 * 1.5 * _loc5_.value;
					ship.weaponHeat.setBonuses(ship.maxPower + ship.aritfact_powerMax, ship.powerRegBonus + ship.aritfact_poweReg);
				}
				else if (_loc5_.type == "cooldown" || _loc5_.type == "cooldown2" || _loc5_.type == "cooldown3")
				{
					_loc7_ = 0;
					while (_loc7_ < ship.weapons.length)
					{
						if (ship.weapons[_loc7_] is Teleport || ship.weapons[_loc7_] is Cloak)
						{
							ship.weapons[_loc7_].reloadTime *= 1 + ship.aritfact_cooldownReduction;
						}
						_loc7_++;
					}
					ship.aritfact_cooldownReduction += _loc6_ * 0.001 * _loc5_.value;
					_loc7_ = 0;
					while (_loc7_ < ship.weapons.length)
					{
						if (ship.weapons[_loc7_] is Teleport || ship.weapons[_loc7_] is Cloak)
						{
							ship.weapons[_loc7_].reloadTime /= 1 + ship.aritfact_cooldownReduction;
						}
						_loc7_++;
					}
				}
			}
			if (isMe)
			{
				if (!g.hud.isLoaded)
				{
					return;
				}
				g.hud.healthAndShield.update();
				g.hud.weaponHotkeys.refresh();
				g.hud.abilities.refresh();
			}
		}
		
		public function hasTechSkill(param1:String, param2:String):Boolean
		{
			for each (var _loc3_:* in techSkills)
			{
				if (_loc3_.table == param1 && _loc3_.tech == param2)
				{
					return true;
				}
			}
			return false;
		}
		
		public function changeWeapon(param1:Message, param2:int):void
		{
			var _loc8_:int = 0;
			var _loc6_:FleetObj = null;
			var _loc3_:Weapon = null;
			var _loc4_:int = param1.getInt(param2 + 1);
			var _loc5_:String = param1.getString(param2 + 2);
			if (_loc5_ != null && _loc5_ != "")
			{
				activeWeapon = _loc5_;
				_loc8_ = 0;
				while (_loc8_ < fleet.length)
				{
					_loc6_ = fleet[_loc8_];
					if (_loc6_.skin == activeSkin)
					{
						_loc6_.activeWeapon = _loc5_;
						break;
					}
					_loc8_++;
				}
			}
			if (ship == null)
			{
				return;
			}
			selectedWeaponIndex = _loc4_;
			ship.weaponIsChanging = false;
			for each (var _loc7_:* in weapons)
			{
				if (_loc7_ is Weapon)
				{
					_loc3_ = _loc7_ as Weapon;
					_loc3_.fire = false;
				}
			}
			if (isMe)
			{
				g.hud.weaponHotkeys.highlightWeapon(ship.weapons[_loc4_].hotkey);
			}
		}
		
		public function sendChangeWeapon(param1:int):void
		{
			var _loc3_:int = 0;
			if (param1 != 0 && ship != null)
			{
				_loc3_ = 0;
				while (_loc3_ < ship.weapons.length)
				{
					if (ship.weapons[_loc3_].active && ship.weapons[_loc3_].hotkey == param1)
					{
						ship.weaponIsChanging = true;
						for each (var _loc2_:* in ship.weapons)
						{
							_loc2_.fire = false;
						}
						selectedWeaponIndex = _loc3_;
						g.send("changeWeapon", _loc3_);
						return;
					}
					_loc3_++;
				}
			}
		}
		
		public function tryUnlockSlot(param1:String, param2:int, param3:Function):void
		{
			var type:String = param1;
			var index:int = param2;
			var callback:Function = param3;
			if (type == "slotCrew" && index + 1 < 4)
			{
				return;
			}
			g.rpc("tryUnlockSlot", function(param1:Message):void
			{
				var _loc4_:String = param1.getString(0);
				var _loc2_:int = param1.getInt(1);
				var _loc5_:int = 0;
				var _loc3_:String = "";
				if (_loc4_ == "slotWeapon")
				{
					_loc5_ = int(SLOT_WEAPON_UNLOCK_COST[_loc2_ - 1]);
					_loc3_ = "flpbTKautkC1QzjWT28gkw";
					unlockedWeaponSlots = _loc2_;
					if (ship != null)
					{
						ship.unlockedWeaponSlots = _loc2_;
					}
				}
				else if (_loc4_ == "slotArtifact")
				{
					_loc5_ = int(SLOT_ARTIFACT_UNLOCK_COST[_loc2_ - 1]);
					_loc3_ = "flpbTKautkC1QzjWT28gkw";
					unlockedArtifactSlots = _loc2_;
				}
				else if (_loc4_ == "slotCrew")
				{
					_loc5_ = int(SLOT_CREW_UNLOCK_COST[_loc2_ - 1]);
					_loc3_ = "flpbTKautkC1QzjWT28gkw";
					unlockedCrewSlots = _loc2_;
				}
				g.myCargo.removeMinerals(_loc3_, _loc5_);
				callback();
			}, type, index);
		}
		
		public function get team():int
		{
			return _team;
		}
		
		public function set team(param1:int):void
		{
			_team = param1;
			if (ship != null)
			{
				ship.team = param1;
				ship.updateLabel();
			}
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function set name(param1:String):void
		{
			_name = param1;
		}
		
		public function get inSafeZone():Boolean
		{
			return _inSafeZone;
		}
		
		public function set inSafeZone(param1:Boolean):void
		{
			_inSafeZone = param1;
		}
		
		public function set isWarpJumping(param1:Boolean):void
		{
			_isWarpJumping = param1;
		}
		
		public function get isWarpJumping():Boolean
		{
			return _isWarpJumping;
		}
		
		public function get invulnarable():Boolean
		{
			if (_inSafeZone || _isWarpJumping)
			{
				return true;
			}
			return false;
		}
		
		public function saveWeaponData(param1:Vector.<Weapon>):void
		{
			var _loc4_:WeaponDataHolder = null;
			var _loc3_:String = "";
			weaponData = new Vector.<WeaponDataHolder>();
			for each (var _loc2_:* in param1)
			{
				_loc3_ = _loc2_.getDescription(_loc2_ is Beam);
				_loc4_ = new WeaponDataHolder(_loc2_.key, _loc3_);
				weaponData.push(_loc4_);
			}
		}
		
		public function get commandable():Boolean
		{
			if (ship == null || !ship.alive || isLanded || isWarpJumping)
			{
				return false;
			}
			return true;
		}
		
		public function getWeaponByHotkey(param1:int):Weapon
		{
			if (ship == null)
			{
				return null;
			}
			for each (var _loc2_:* in ship.weapons)
			{
				if (_loc2_.active && _loc2_.hotkey == param1)
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		public function getCrewMember(param1:String):CrewMember
		{
			for each (var _loc2_:* in crewMembers)
			{
				if (_loc2_.key == param1)
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		public function getCrewMembersBySolarSystem(param1:String):Vector.<CrewMember>
		{
			var _loc3_:Vector.<CrewMember> = new Vector.<CrewMember>();
			for each (var _loc2_:* in crewMembers)
			{
				if (_loc2_.solarSystem == param1)
				{
					_loc3_.push(_loc2_);
				}
			}
			return _loc3_;
		}
		
		public function isFriendWith(param1:Player):Boolean
		{
			for each (var _loc2_:* in friends)
			{
				if (_loc2_.id == param1.id)
				{
					return true;
				}
			}
			return false;
		}
		
		public function removeMissionById(param1:String):void
		{
			var _loc2_:Mission = getMissionById(param1);
			if (_loc2_ != null)
			{
				removeMission(_loc2_);
			}
		}
		
		private function getMissionById(param1:String):Mission
		{
			for each (var _loc2_:* in missions)
			{
				if (_loc2_.id == param1)
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		public function updateMission(param1:Message, param2:int):void
		{
			var missionType:Object;
			var m:Message = param1;
			var i:int = param2;
			var id:String = m.getString(i);
			var missionTypeKey:String = m.getString(i + 1);
			var mission:Mission = getMissionById(id);
			if (mission == null)
			{
				return;
			}
			if (missionTypeKey == "KG4YJCr9tU6IH0rJRYo7HQ")
			{
				g.hud.compas.clear();
				TweenMax.delayedCall(1.5, function():void
				{
					var _loc1_:Boolean = false;
					for each (var _loc3_:* in g.bodyManager.bodies)
					{
						if (_loc3_.key == "SWqDETtcD0i6Wc3s81yccQ" || _loc3_.key == "U8PYtFoC5U6c2A_gar9j2A" || _loc3_.key == "TLYpHghGOU6FaZtxDiVXBA")
						{
							for each (var _loc2_:* in _loc3_.spawners)
							{
								if (_loc2_.alive)
								{
									_loc1_ = true;
									g.hud.compas.addHintArrowByKey(_loc3_.key);
									break;
								}
							}
							if (_loc1_)
							{
								break;
							}
						}
					}
				});
			}
			if (missionTypeKey == "s1l0zM-6lkq9l1jlGDBy4w")
			{
				g.hud.compas.clear();
			}
			g.hud.missionsButton.flash();
			mission.count = m.getInt(i + 2);
			missionType = mission.getMissionType();
			if (missionType != null && missionType.value != null)
			{
				g.textManager.createMissionUpdateText(mission.count, missionType.value);
			}
			mission.finished = m.getBoolean(i + 3);
			if (mission.finished)
			{
				g.hud.missionsButton.hintFinished();
				g.textManager.createMissionFinishedText();
				if (missionType.completeDescription != null)
				{
					g.tutorial.showMissionCompleteText(mission, missionType.drop, missionType.completeDescription);
				}
			}
			if (missionTypeKey == "puc60G5hKUypAIaEB4cAaA" || missionTypeKey == "mZsWmk4BUkunoD6w35aOjg" || missionTypeKey == "TYs2gVcB8UmyxfXqtIvTQA" || missionTypeKey == "m1gVvWQOGUmrFE6k4U9HOQ")
			{
				g.hud.compas.clear();
			}
		}
		
		public function toggleTractorBeam():void
		{
			tractorBeamActive = !tractorBeamActive;
		}
		
		public function isTractorBeamActive():Boolean
		{
			if (!hasTractorBeam())
			{
				return false;
			}
			return tractorBeamActive;
		}
		
		public function hasTractorBeam():Boolean
		{
			if (g.time == 0)
			{
				return false;
			}
			if (isModerator)
			{
				return true;
			}
			return tractorBeam > g.time;
		}
		
		public function hasXpProtection():Boolean
		{
			if (g.time == 0)
			{
				return false;
			}
			if (level <= 15)
			{
				return true;
			}
			if (isModerator)
			{
				return true;
			}
			return xpProtection > g.time;
		}
		
		public function toggleCargoProtection():void
		{
			cargoProtectionActive = !cargoProtectionActive;
		}
		
		public function isCargoProtectionActive():Boolean
		{
			if (!hasCargoProtection())
			{
				return false;
			}
			return cargoProtectionActive;
		}
		
		public function hasCargoProtection():Boolean
		{
			if (g.time == 0)
			{
				return false;
			}
			if (isModerator)
			{
				return true;
			}
			return cargoProtection > g.time;
		}
		
		public function hasSupporter():Boolean
		{
			if (g.time == 0)
			{
				return false;
			}
			if (isModerator)
			{
				return true;
			}
			return supporter > g.time;
		}
		
		public function changeSkin(param1:String):void
		{
			var _loc3_:int = 0;
			var _loc2_:FleetObj = null;
			_loc3_ = 0;
			while (_loc3_ < fleet.length)
			{
				_loc2_ = fleet[_loc3_];
				if (param1 == _loc2_.skin)
				{
					activeSkin = param1;
					g.send("changeSkin", param1);
					techSkills = _loc2_.techSkills;
					weapons = _loc2_.weapons;
					weaponsState = _loc2_.weaponsState;
					weaponsHotkeys = _loc2_.weaponsHotkeys;
					nrOfUpgrades = _loc2_.nrOfUpgrades;
					activeArtifactSetup = _loc2_.activeArtifactSetup;
					activeWeapon = _loc2_.activeWeapon;
					selectedWeaponIndex = 0;
					_loc2_.lastUsed = g.time;
					unloadShip();
					ship = ShipFactory.createPlayer(g, this, g.shipManager.getPlayerShip(), weapons);
					applyArtifactStats();
					return;
				}
				_loc3_++;
			}
		}
		
		public function respawnReady():Boolean
		{
			return respawnNextReady < g.time && respawnNextReady > 0;
		}
		
		public function hasSkin(param1:String):Boolean
		{
			for each (var _loc2_:* in fleet)
			{
				if (param1 == _loc2_.skin)
				{
					return true;
				}
			}
			return false;
		}
		
		public function addEncounter(param1:Message):void
		{
			var _loc3_:Object = null;
			var _loc4_:String = param1.getString(0);
			var _loc2_:int = param1.getInt(1);
			if (_loc4_.search("enemy_") != -1)
			{
				_loc3_ = DataLocator.getService().loadKey("Enemies", _loc4_.replace("enemy_", ""));
				if (_loc3_.hasOwnProperty("miniBoss") && _loc3_.miniBoss)
				{
					Game.trackEvent("encounters", _loc3_.name, name, level);
				}
			}
			else if (_loc4_.search("boss_") != -1)
			{
				_loc3_ = DataLocator.getService().loadKey("Bosses", _loc4_.replace("boss_", ""));
				Game.trackEvent("encounters", _loc3_.name, name, level);
			}
			encounters.push(_loc4_);
			Action.encounter(_loc4_);
			MessageLog.write("<FONT COLOR='#44ff44'>New Encounter!</FONT>");
			MessageLog.write(_loc3_.name);
			MessageLog.write("+" + _loc2_ + " bonus xp");
			g.hud.encountersButton.flash();
			g.hud.encountersButton.hintNew();
			g.textManager.createBonusXpText(_loc2_);
		}
		
		public function getFleetObj(param1:String):FleetObj
		{
			for each (var _loc2_:* in fleet)
			{
				if (_loc2_.skin == param1)
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		public function getActiveFleetObj():FleetObj
		{
			return getFleetObj(activeSkin);
		}
		
		public function addCompletedMission(param1:String, param2:Number):void
		{
			completedMissions[param1] = param2;
			g.textManager.createMissionBestTimeText();
		}
		
		public function addTriggeredMission(param1:String):void
		{
			triggeredMissions.push(param1);
		}
		
		public function hasTriggeredMission(param1:String):Boolean
		{
			for each (var _loc2_:* in triggeredMissions)
			{
				if (_loc2_ == param1)
				{
					return true;
				}
			}
			return false;
		}
		
		public function dispose():void
		{
			g = null;
			ship = null;
			stateMachine = null;
			currentBody = null;
			lastBody = null;
			weaponsHotkeys = null;
			weapons = null;
			weaponsState = null;
			weaponData = null;
			techSkills = null;
			artifacts = null;
			explores = null;
			missions = null;
			crewMembers = null;
			encounters = null;
			nrOfUpgrades = null;
			warpPathLicenses = null;
			solarSystemLicenses = null;
			pickUpLog = null;
			landedBodies = null;
			encounters = null;
			clanLogo = null;
		}
	}
}

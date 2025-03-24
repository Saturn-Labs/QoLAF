package core.player {
	import com.greensock.TweenMax;
	import core.hud.components.cargo.Cargo;
	import core.hud.components.chat.MessageLog;
	import core.hud.components.credits.FBInvite;
	import core.hud.components.credits.KongInvite;
	import core.hud.components.dialogs.CreditGainBox;
	import core.hud.components.dialogs.CrewJoinOffer;
	import core.hud.components.dialogs.DailyRewardMessage;
	import core.hud.components.dialogs.PopupMessage;
	import core.hud.components.pvp.DominationManager;
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.projectile.Projectile;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import core.solarSystem.Body;
	import core.spawner.Spawner;
	import core.states.gameStates.IntroState;
	import core.states.gameStates.WarpJumpState;
	import core.states.gameStates.missions.MissionsList;
	import core.unit.Unit;
	import core.weapon.Beam;
	import core.weapon.Heat;
	import core.weapon.Teleport;
	import core.weapon.Weapon;
	import data.DataLocator;
	import data.IDataManager;
	import debug.Console;
	import facebook.Action;
	import flash.utils.Dictionary;
	import generics.Localize;
	import joinRoom.IJoinRoomManager;
	import joinRoom.JoinRoomLocator;
	import movement.Heading;
	import playerio.Message;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	public class PlayerManager extends EventDispatcher {
		public static var banMinutes:int = 0;
		
		public static var isAllChannels:Boolean = false;
		
		private var _me:Player;
		
		private var _playersById:Dictionary;
		
		private var _players:Vector.<Player>;
		
		private var _enemyPlayers:Vector.<Player>;
		
		private var g:Game;
		
		public function PlayerManager(g:Game) {
			super();
			this.g = g;
			_players = new Vector.<Player>();
			_enemyPlayers = new Vector.<Player>();
			_playersById = new Dictionary();
		}
		
		public function addMessageHandlers() : void {
			g.addMessageHandler("reputationChange",reputationChange);
			g.addMessageHandler("playerKilled",killed);
			g.addMessageHandler("spawnDrop",spawnDrop);
			g.addMessageHandler("playerLanded",landed);
			g.addMessageHandler("playerEnterRoaming",initRoaming);
			g.addMessageHandler("playerLandFailed",landFailed);
			g.addMessageHandler("heatLockout",heatLockout);
			g.addMessageHandler("playerWeaponChangeFailed",weaponChangeFailed);
			g.addMessageHandler("playerEnterWarpJump",initWarpJump);
			g.addMessageHandler("payVaultCreditGain",payVaultCreditGain);
			g.addServiceMessageHandler("clientPrintMsg",printMsg);
			g.addServiceMessageHandler("modWarpToUser",modWarpToUser);
			g.addServiceMessageHandler("chatMsg",chatMsg);
			g.addMessageHandler("chatMsg",chatMsg);
			g.addMessageHandler("clientPrintMsg",printMsg);
			g.addServiceMessageHandler("chatBan",handleChatBan);
			g.addServiceMessageHandler("kicked",handleKicked);
			g.addMessageHandler("syncHeat",syncHeat);
			g.addMessageHandler("changeSkin",changeSkin);
			g.addMessageHandler("newMission",addNewMission);
			g.addMessageHandler("missionExpired",removeMission);
			g.addMessageHandler("addCompletedMission",m_AddCompletedMission);
			g.addMessageHandler("triggerMission",m_TriggerMission);
			g.addMessageHandler("addMissionArtifacts",m_MissionArtifacts);
			g.addMessageHandler("freeCrewJoinOffer",crewJoinOffer);
			g.addMessageHandler("killedPlayerTooManyTimes",tooManyKillsNotify);
			g.addMessageHandler("addWeapon",addWeapon);
			g.addMessageHandler("addSkin",addSkin);
			g.addMessageHandler("playerRotationSpeedChanged",setRotationSpeed);
			g.addMessageHandler("playerSpeedChanged",setSpeed);
			g.addMessageHandler("newEncounter",newEncounter);
			g.addMessageHandler("teleportToPosition",m_teleportToPosition);
			g.addMessageHandler("playerUpdate",onPlayerUpdate);
			g.addMessageHandler("pvpTimeoutWarning",m_pvpTimeout);
			g.addMessageHandler("newWeapon",m_newWeapon);
			g.addMessageHandler("pvpArtifact",m_pickupArtifact);
			g.addServiceMessageHandler("requestUpdateInviteReward",m_requestUpdateInviteReward);
			g.addMessageHandler("addFaction",m_AddFaction);
			g.addMessageHandler("removeFaction",m_RemoveFaction);
			g.addMessageHandler("dropJunk",m_DropJunk);
			g.addMessageHandler("receivedFlux",m_receivedFlux);
			g.addMessageHandler("GiftFlux",m_GiftFlux);
			g.addMessageHandler("uberUpdate",m_UberUpdate);
			g.addMessageHandler("startCloakSelf",m_startCloakSelf);
			g.addMessageHandler("endCloakSelf",m_endCloakSelf);
			g.addMessageHandler("startCloak",m_startCloak);
			g.addMessageHandler("endCloak",m_endCloak);
			g.addMessageHandler("updateCredits",m_updateCredits);
			g.addMessageHandler("softDisconnect",m_softDisconnect);
		}
		
		private function handleChatBan(m:Message) : void {
			var _local2:int = m.getInt(0);
			isAllChannels = m.getBoolean(1);
			banMinutes = _local2;
			TweenMax.delayedCall(60,reduceBanMinutes);
		}
		
		private function handleKicked(m:Message) : void {
			g.showMessageDialog("You were kicked out of the game by a moderator");
			g.disconnect();
		}
		
		private function showInvitePopup() : void {
			var invButton:FBInvite;
			var invButton2:KongInvite;
			var popup:PopupMessage = new PopupMessage(Localize.t("No thanks!"));
			popup.text = "The game is more fun if played with friends! Would you like to invite someone to join your epic adventure?\n\n\n";
			if(Login.currentState == "facebook") {
				invButton = new FBInvite(g);
				invButton.x = g.stage.stageWidth / 2 - 85;
				invButton.y = g.stage.stageHeight / 2;
				invButton.width = 150;
				popup.addChild(invButton);
			} else if(Login.currentState == "kongregate") {
				invButton2 = new KongInvite(g);
				invButton2.x = g.stage.stageWidth / 2 - 85;
				invButton2.y = g.stage.stageHeight / 2;
				invButton2.width = 150;
				popup.addChild(invButton2);
			}
			g.addChildToOverlay(popup);
			g.creditManager.refresh();
			popup.addEventListener("close",(function():* {
				var closePopup:Function;
				return closePopup = function(param1:Event):void {
					g.removeChildFromOverlay(popup);
					popup.removeEventListeners();
				};
			})());
		}
		
		private function m_GiftFlux(m:Message) : void {
			var type:String;
			var value:int;
			var value2:int;
			var popup:PopupMessage;
			if(g.me != null) {
				type = m.getString(0);
				value = m.getInt(1);
				value2 = m.getInt(2);
				if(type == "testRecp") {
					popup = new PopupMessage();
					popup.text = "Congratulations Captain! \n\nWell done reaching " + value2 + "! Have " + value + " Flux for free! \nGet yourself something nice! :)";
					g.addChildToOverlay(popup);
					g.creditManager.refresh();
					popup.addEventListener("close",(function():* {
						var closePopup:Function;
						return closePopup = function(param1:Event):void {
							g.removeChildFromOverlay(popup);
							popup.removeEventListeners();
							if(Login.currentState == "facebook" || Login.currentState == "kongregate") {
								TweenMax.delayedCall(5,showInvitePopup);
							}
						};
					})());
				}
			}
			g.creditManager.refresh();
		}
		
		private function m_receivedFlux(m:Message) : void {
			var popup:PopupMessage;
			var value:int;
			if(g.me != null) {
				popup = new PopupMessage();
				value = m.getInt(0);
				popup.text = Localize.t("You have received your " + value + " bonus flux!");
				g.addChildToOverlay(popup);
				g.creditManager.refresh();
				popup.addEventListener("close",(function():* {
					var closePopup:Function;
					return closePopup = function(param1:Event):void {
						g.removeChildFromOverlay(popup);
						popup.removeEventListeners();
					};
				})());
			}
		}
		
		private function reduceBanMinutes() : void {
			banMinutes--;
			if(banMinutes < 1) {
				return;
			}
			TweenMax.delayedCall(60,reduceBanMinutes);
		}
		
		private function heatLockout(m:Message) : void {
			var _local2:Heat = null;
			var _local3:Player = g.me;
			if(_local3.ship != null) {
				_local2 = _local3.ship.weaponHeat;
				_local2.pause(m.getNumber(0));
				_local2.setHeat(m.getNumber(1));
			}
		}
		
		private function m_startCloak(m:Message) : void {
			var _local2:Heading = null;
			var _local3:Player = playersById[m.getString(0)];
			if(_local3 != null && _local3.ship != null) {
				_local3.ship.isTeleporting = true;
				_local2 = _local3.ship.course;
				_local2.pos.x = 824124;
				_local2.pos.y = -725215;
				_local3.ship.course = _local2;
				_local3.ship.x = 824124;
				_local3.ship.y = -725215;
			}
		}
		
		private function m_endCloak(m:Message) : void {
			var _local2:Heading = null;
			var _local3:Player = playersById[m.getString(0)];
			if(_local3 != null && _local3.ship != null) {
				_local2 = new Heading();
				_local3.ship.isTeleporting = false;
				_local2.parseMessage(m,1);
				_local3.ship.course = _local2;
				_local3.ship.x = _local2.pos.x;
				_local3.ship.y = _local2.pos.y;
				_local3.ship.addToCanvasForReal();
			}
		}
		
		private function m_startCloakSelf(m:Message) : void {
			var _local2:Heat = null;
			trace("startSelfCloak");
			var _local3:Player = g.me;
			if(_local3.ship != null) {
				_local2 = _local3.ship.weaponHeat;
				_local2.setHeat(m.getNumber(0));
				_local3.ship.alpha = 0.1;
			}
		}
		
		private function m_endCloakSelf(m:Message) : void {
			trace("endSelfCloak");
			var _local2:Player = g.me;
			if(_local2.ship != null) {
				_local2.ship.alpha = 1;
			}
		}
		
		public function update() : void {
			for each(var _local2 in _players) {
				_local2.update();
				if(!(_local2.ship == null || _local2.ship.course == null)) {
					if(!(!_local2.ship.isAddedToCanvas || _local2.isLanded)) {
						if(g.pvpManager == null || !(g.pvpManager is DominationManager)) {
							_local2.inSafeZone = false;
							for each(var _local1 in g.bodyManager.bodies) {
								_local1.setInSafeZone(_local2);
							}
						}
					}
				}
			}
		}
		
		private function m_requestUpdateInviteReward(m:Message) : void {
			g.send("requestInviteReward");
		}
		
		private function m_pickupArtifact(m:Message) : void {
			g.me.pickupArtifact(m);
		}
		
		public function listAll() : void {
			for each(var _local1 in _players) {
				if(!(_local1.isDeveloper || _local1.isModerator)) {
					MessageLog.writeChatMsg("list","lvl " + _local1.level,_local1.id,_local1.name);
				}
			}
		}
		
		private function addMe(id:String) : Player {
			_me = new Player(g,id);
			_me.isMe = true;
			g.myCargo = new Cargo(g,id);
			g.myCargo.reloadCargoView();
			_playersById[_me.id] = _me;
			_players.push(_me);
			return _me;
		}
		
		private function addPlayer(id:String) : Player {
			var _local2:Player = new Player(g,id);
			_playersById[id] = _local2;
			_players.push(_local2);
			_enemyPlayers.push(_local2);
			return _local2;
		}
		
		public function initPlayer(m:Message, i:int = 0) : int {
			var _local4:Player = null;
			var _local3:String = m.getString(i++);
			if(_local3 == g.client.connectUserId) {
				_local4 = addMe(_local3);
			} else {
				_local4 = addPlayer(_local3);
			}
			return _local4.init(m,i);
		}
		
		public function m_pvpTimeout(m:Message) : void {
			var _local2:Number = m.getNumber(0);
			g.textManager.createPvpText("Not enough players",0,30);
			g.textManager.createPvpText("Match ending in " + int(_local2) + " seconds",-35,30);
		}
		
		public function m_newWeapon(m:Message) : void {
			var _local2:String = m.getString(0);
			Action.unlockWeapon(_local2);
		}
		
		public function removePlayer(m:Message) : void {
			var _local2:int = 0;
			var _local3:String = m.getString(0);
			var _local4:Player = _playersById[_local3];
			var _local5:Boolean = m.getBoolean(2);
			if(!_local5) {
				MessageLog.writeSysInfo(m.getString(1) + " has left the system.");
			}
			if(_local4 != null) {
				_local4.unloadShip();
				delete _playersById[_local3];
				_local2 = 0;
				while(_local2 < _players.length) {
					if(_players[_local2] == _local4) {
						_players.splice(_local2,1);
						break;
					}
					_local2++;
				}
				_local2 = 0;
				while(_local2 < _enemyPlayers.length) {
					if(_enemyPlayers[_local2] == _local4) {
						_enemyPlayers.splice(_local2,1);
						break;
					}
					_local2++;
				}
				_local4.dispose();
			}
		}
		
		private function tooManyKillsNotify(m:Message) : void {
			var _local2:String = m.getString(0);
			MessageLog.writeChatMsg("death","You have killed " + _local2 + " more than four times in a row, " + _local2 + " can not give more experince untill you kill someone else.");
		}
		
		private function setRotationSpeed(m:Message) : void {
			var _local2:String = m.getString(0);
			var _local3:Player = _playersById[_local2];
			if(_local3 != null) {
				_local3.rotationSpeedMod = m.getNumber(1);
				if(_local3.ship != null && _local3.ship.engine != null) {
					_local3.ship.engine.rotationMod = _local3.rotationSpeedMod;
				}
			}
		}
		
		private function setSpeed(m:Message) : void {
			var _local2:String = m.getString(0);
			var _local3:Player = _playersById[_local2];
			if(_local3 != null) {
				_local3.ship.engine.speed = m.getNumber(1);
			}
		}
		
		private function addWeapon(m:Message) : void {
			var _local3:String = m.getString(0);
			var _local4:Player = _playersById[_local3];
			var _local2:String = m.getString(1);
			if(_local4 != null) {
				_local4.addWeapon(_local2);
			}
		}
		
		private function addSkin(m:Message) : void {
			var _local3:String = m.getString(0);
			var _local4:Player = _playersById[_local3];
			var _local2:String = m.getString(1);
			if(_local4 != null) {
				_local4.addNewSkin(_local2);
			}
		}
		
		private function spawnDrop(m:Message) : void {
			if(g.dropManager != null) {
				g.dropManager.spawn(m,0);
			}
		}
		
		private function killed(m:Message) : void {
			if(m == null) {
				return;
			}
			if(m.length < 4) {
				return;
			}
			var _local4:String = m.getString(0);
			var _local5:String = m.getString(1);
			var _local2:String = m.getString(2);
			var _local6:String = m.getString(3);
			var _local3:int = m.getInt(4);
			if(g.dropManager != null) {
				g.dropManager.spawn(m,5);
			}
			var _local7:Player = _playersById[_local4];
			if(_local7 == null) {
				return;
			}
			if(_local7.ship == null) {
				return;
			}
			MessageLog.writeDeathNote(_local7,_local5,_local2);
			if(_local7.spree == 4) {
				MessageLog.writeChatMsg("death",_local7.name + " died after killing 4.");
			} else if(_local7.spree > 4 && _local2 != "suicide") {
				MessageLog.writeChatMsg("death",_local5 + " ended " + _local7.name + "s " + _local7.spree + " kills long frenzy!");
			}
			if(_local7.isMe && g.solarSystem.isPvpSystemInEditor && _local2 != "" && _local2 != "Death Line") {
				Game.trackEvent("pvp",g.solarSystem.type + " killedBy",_local2,_local7.level);
			}
			_local7.enterKilled(m);
		}
		
		public function xpGain(m:Message, i:int) : void {
			var _local4:int = 0;
			var _local3:int = 0;
			var _local7:int = 0;
			var _local5:String = null;
			var _local6:String = m.getString(i);
			var _local8:Player = _playersById[_local6];
			if(_local8 != null) {
				_local4 = m.getInt(i + 1);
				_local3 = m.getInt(i + 2);
				_local8.increaseXp(_local4,_local3);
				_local7 = m.getInt(i + 3);
				_local8.setSpree(_local7);
				_local5 = m.getString(i + 5);
				if(_local8 == g.me && _local5 != "") {
					if(_local7 > 15) {
						g.textManager.createKillText("You killed " + _local5 + "! Godlike!",50,5000,0xffffff);
					} else if(_local7 > 10) {
						g.textManager.createKillText("You killed " + _local5 + "! Rampage!",40,5000,0xffffff);
					} else if(_local7 > 4) {
						g.textManager.createKillText("You killed " + _local5 + "! Killing Spree!",38,5000,0xffffff);
					} else {
						g.textManager.createKillText("You killed " + _local5 + "!",35,5000,0xffffff);
					}
				}
			}
		}
		
		private function reputationChange(m:Message) : void {
			var _local2:int = 0;
			var _local4:int = 0;
			var _local3:String = m.getString(0);
			var _local5:Player = _playersById[_local3];
			if(_local5 != null) {
				_local2 = m.getInt(1);
				_local4 = m.getInt(2);
				_local5.updateReputation(_local2,_local4);
			}
		}
		
		public function xpLoss(m:Message, i:int) : void {
			var _local6:int = 0;
			var _local3:int = 0;
			var _local4:String = m.getString(i);
			var _local5:Player = _playersById[_local4];
			if(_local5 != null) {
				_local6 = m.getInt(i + 1);
				_local3 = m.getInt(i + 2);
				_local5.decreaseXp(_local6,_local3);
			}
		}
		
		private function payVaultCreditGain(m:Message) : void {
			var creditBox:CreditGainBox;
			var pods:int;
			var type:String = m.getString(1);
			var name:String = "";
			if(m.length > 3) {
				name = m.getString(3);
			}
			if(type == "daily") {
				creditBox = new DailyRewardMessage(g,m.getInt(0),m.getInt(2));
			} else if(type == "missions" || type == "level") {
				pods = m.getInt(0);
				creditBox = new CreditGainBox(g,0,pods,type);
				if(pods > 0) {
					creditBox.callback = function():void {
						g.removeChildFromOverlay(creditBox);
						g.rpc("getPodCount",function(param1:Message):void {
							g.hud.updatePodCount(param1.getInt(0));
						});
					};
				}
			} else if(type == "pvp") {
				name = m.getString(2);
				creditBox = new CreditGainBox(g,m.getInt(0),0,type,name);
			} else {
				creditBox = new CreditGainBox(g,m.getInt(0),0,type,name);
			}
			g.addChildToOverlay(creditBox);
			if(type == "fbLike") {
				g.me.fbLike = true;
			}
			creditBox.addEventListener("close",(function():* {
				var close:Function;
				return close = function(param1:Event):void {
					g.creditManager.refresh();
					g.hud.buyFluxButton.flash();
					g.removeChildFromOverlay(creditBox);
				};
			})());
		}
		
		private function modWarpToUser(m:Message) : void {
			var _local2:IJoinRoomManager = null;
			var _local3:String = m.getString(0);
			var _local4:String = m.getString(1);
			if(_local3 != null && _local3 != "" && _local4 != null) {
				MessageLog.writeChatMsg("join_leave","Warping to system: " + _local3,"system");
				_local2 = JoinRoomLocator.getService();
				_local2.desiredRoomId = null;
				_local2.desiredSystemType = "friendly";
				_local2.desiredRoomId = _local3;
				g.send("modWarp","Hyperion");
			}
		}
		
		private function printMsg(m:Message) : void {
			var _local2:String = "system";
			if(m.length > 1) {
				_local2 = m.getString(1);
			}
			MessageLog.write(m.getString(0),_local2);
		}
		
		private function chatMsg(m:Message) : void {
			if(m.length <= 2) {
				return printMsg(m);
			}
			var _local7:int = 0;
			var _local3:String = m.getString(_local7++);
			var _local2:String = m.getString(_local7++);
			var _local4:String = m.getString(_local7++);
			var _local5:String = m.getString(_local7++);
			var _local6:String = m.getString(_local7++);
			var _local8:Boolean = m.getBoolean(_local7++);
			MessageLog.writeChatMsg(_local3,_local2,_local4,_local5,_local6,_local8);
			if(_local3 == "private" && _local4 != me.id) {
				g.chatInput.lastPrivateReceived = _local5;
			}
		}
		
		public function dmgBoost(m:Message, i:int) : void {
			var _local4:String = m.getString(i);
			var _local5:Player = _playersById[_local4];
			if(_local5 == null || _local5.isMe) {
				return;
			}
			var _local3:PlayerShip = _local5.ship;
			if(_local3 == null) {
				return;
			}
			_local3.usingDmgBoost = true;
			_local3.dmgBoostEndTime = g.time + _local3.dmgBoostDuration;
			_local3.damageBoostEffect();
		}
		
		public function hardenShield(m:Message, i:int) : void {
			var _local4:String = m.getString(i);
			var _local5:Player = _playersById[_local4];
			if(_local5 == null || _local5.isMe) {
				return;
			}
			var _local3:PlayerShip = _local5.ship;
			if(_local3 == null) {
				return;
			}
			_local3.usingHardenedShield = true;
			_local3.hardenEndTimer = g.time + _local3.hardenDuration;
			_local3.hardenShieldEffect();
		}
		
		public function convShield(m:Message, i:int) : void {
			var _local5:String = m.getString(i);
			var _local6:Player = _playersById[_local5];
			var _local3:int = m.getInt(i + 1);
			var _local7:int = m.getInt(i + 2);
			if(_local6 == null) {
				return;
			}
			var _local4:PlayerShip = _local6.ship;
			if(_local4 == null) {
				return;
			}
			_local4.shieldHp -= _local3;
			_local4.hp += _local7;
			if(_local6.ship.hp > _local4.hpMax) {
				_local7 -= _local4.hp - _local4.hpMax;
				_local4.hp = _local4.hpMax;
			}
			_local4.converShieldEffect();
			g.textManager.createDmgText(-_local7,_local4);
			if(_local6.isMe && g.hud != null) {
				g.hud.healthAndShield.update();
			}
		}
		
		public function powerUpHeal(m:Message, i:int) : void {
			var _local6:String = null;
			var _local3:int = 0;
			var _local5:int = 0;
			var _local4:String = m.getString(i++);
			var _local7:Player = _playersById[_local4];
			if(_local7 != null && _local7.ship != null) {
				_local6 = m.getString(i++);
				_local3 = m.getInt(i++);
				_local5 = m.getInt(i++);
				_local7.ship.hp = m.getInt(i++);
				_local7.ship.shieldHp = m.getInt(i++);
				if(_local6 == "health" || _local6 == "healthSmall") {
					g.textManager.createDmgText(-_local3,_local7.ship,false);
				} else {
					g.textManager.createDmgText(-_local5,_local7.ship,true);
				}
				if(_local7.isMe) {
					g.hud.healthAndShield.update();
				}
			}
		}
		
		public function damaged(m:Message, i:int) : void {
			var _local4:int = 0;
			var _local6:int = 0;
			var _local3:String = m.getString(i);
			var _local5:Player = _playersById[_local3];
			if(_local5 != null && _local5.ship != null) {
				_local4 = m.getInt(i + 1);
				_local6 = m.getInt(i + 2);
				_local5.ship.shieldHp = m.getInt(i + 3);
				_local5.ship.hp = m.getInt(i + 4);
				_local5.ship.takeDamage(_local6);
				if(m.getBoolean(i + 5)) {
					_local5.ship.doDOTEffect(m.getInt(i + 6),m.getString(i + 7),m.getInt(i + 8),m.getString(i + 9));
				}
				if(_local5.isMe) {
					g.hud.healthAndShield.update();
				}
			}
		}
		
		private function landed(m:Message) : void {
			var _local3:String = m.getString(0);
			var _local5:Player = _playersById[_local3];
			var _local2:String = m.getString(1);
			if(g.bodyManager == null) {
				Console.write("Land failed! Too early g == null");
				return;
			}
			if(_local5 == null) {
				Console.write("Land failed! Player is null, id: " + _local3);
				return;
			}
			if(_local5.ship == null) {
				Console.write("ship is null");
				return;
			}
			var _local4:Body = g.bodyManager.getBodyByKey(_local2);
			if(_local4 == null) {
				Console.write("Land failed! Body is null, bodyKey: " + _local2);
				return;
			}
			_local5.land(_local4);
		}
		
		private function initRoaming(m:Message) : void {
			var _local2:String = m.getString(0);
			var _local3:Player = _playersById[_local2];
			if(_local3 != null) {
				_local3.initRoaming(m,1);
			} else {
				Console.write("No player on initRoaming!");
			}
		}
		
		private function landFailed(m:Message) : void {
			var _local3:String = m.getString(0);
			var _local4:Player = _playersById[_local3];
			var _local2:Heading = new Heading();
			_local2.parseMessage(m,1);
			_local4.loadCourse(_local2);
			_local4.enterRoaming();
		}
		
		public function get me() : Player {
			return _me;
		}
		
		public function get players() : Vector.<Player> {
			return _players;
		}
		
		public function get enemyPlayers() : Vector.<Player> {
			return _enemyPlayers;
		}
		
		public function get playersById() : Dictionary {
			return _playersById;
		}
		
		public function weaponChanged(m:Message, i:int) : void {
			var _local4:Dictionary = g.playerManager.playersById;
			var _local3:String = m.getString(i);
			var _local5:Player = _local4[_local3];
			if(_local5 == null) {
				return;
			}
			_local5.changeWeapon(m,i);
		}
		
		private function weaponChangeFailed(m:Message) : void {
			var _local3:Dictionary = g.playerManager.playersById;
			var _local2:String = m.getString(0);
			var _local4:Player = _local3[_local2];
			if(_local4 == null || _local4.ship == null) {
				return;
			}
			_local4.ship.weaponIsChanging = false;
		}
		
		public function trySetActiveWeapons(player:Player, slot:int, key:String) : void {
			var _local8:Weapon = null;
			var _local9:int = 0;
			var _local5:int = 0;
			if(player == null || player.ship == null) {
				return;
			}
			player.ship.weaponIsChanging = true;
			var _local10:* = -1;
			var _local11:Vector.<Weapon> = player.ship.weapons;
			var _local4:int = 0;
			var _local7:Array = [];
			_local9 = 0;
			while(_local9 < player.unlockedWeaponSlots) {
				_local7.push(_local9 + 1);
				_local9++;
			}
			_local9 = 0;
			while(_local9 < _local11.length) {
				_local8 = _local11[_local9];
				if(_local8.hotkey > 0) {
					_local5 = int(_local7.indexOf(_local8.hotkey));
					if(_local5 != -1) {
						_local7.splice(_local5,1);
					}
					_local4++;
				}
				if(_local8.key == key) {
					_local10 = _local9;
				}
				_local9++;
			}
			_local9 = 0;
			while(_local9 < _local11.length) {
				_local8 = _local11[_local9];
				if(_local8.hotkey == slot && _local9 != _local10) {
					_local7.push(slot);
					_local8.setActive(player.ship,false);
					_local8.hotkey = 0;
					player.weaponsHotkeys[_local9] = 0;
					player.weaponsState[_local9] = false;
				}
				_local9++;
			}
			if(slot == -1 && _local7.length > 0) {
				slot = int(_local7[0]);
			}
			if(_local10 < 0 || _local10 >= _local11.length || slot < 0 || slot > player.unlockedWeaponSlots) {
				player.ship.weaponIsChanging = false;
				return;
			}
			var _local6:Weapon = null;
			if(_local10 < _local11.length) {
				_local6 = _local11[_local10];
			}
			if(_local6 == null) {
				Console.write("Weapon index is null when tried to set it to active.");
				player.ship.weaponIsChanging = false;
				return;
			}
			if(_local6.active) {
				_local6.setActive(player.ship,false);
				_local6.hotkey = 0;
				player.weaponsHotkeys[_local10] = 0;
				player.weaponsState[_local10] = false;
			}
			if(_local6.setActive(player.ship,true)) {
				_local6.hotkey = slot;
				player.weaponsHotkeys[_local10] = slot;
				player.weaponsState[_local10] = true;
				player.selectedWeaponIndex = _local10;
				Console.write("slot: " + slot," Weapon index: " + _local10," key: " + key);
			}
			var _local12:Message = g.createMessage("trySetActiveWeapons");
			_local12.add(_local10);
			_local12.add(slot);
			_local12.add(true);
			g.sendMessage(_local12);
		}
		
		public function fire(m:Message, i:int = 0, len:int = 0) : void {
			var _local4:int = 0;
			var _local7:Beam = null;
			var _local6:int = 0;
			var _local12:String = m.getString(i);
			var _local8:int = m.getInt(i + 1);
			var _local11:Boolean = m.getBoolean(i + 2);
			var _local14:Player = playersById[_local12];
			if(_local14 == null) {
				return;
			}
			var _local5:PlayerShip = _local14.ship;
			if(_local5 == null) {
				return;
			}
			var _local13:Vector.<Weapon> = _local14.ship.weapons;
			if(_local13 == null) {
				return;
			}
			if(_local8 > -1 && _local8 < _local13.length) {
				_local14.selectedWeaponIndex = _local8;
			}
			var _local9:Unit = null;
			if(m.length > len) {
				_local4 = m.getInt(i + 3);
				if(_local4 != -1) {
					_local9 = g.unitManager.getTarget(_local4);
				}
			}
			if(m.length > len) {
				if(_local5.weaponHeat == null) {
					return;
				}
				_local5.weaponHeat.setHeat(m.getNumber(i + 4));
			}
			var _local10:Weapon = _local5.weapon;
			if(_local10 == null) {
				return;
			}
			_local10.fire = _local11;
			_local10.target = _local9;
			if(_local10 is Beam) {
				_local7 = _local10 as Beam;
				_local7.secondaryTargets = new Vector.<Unit>();
				_local6 = i + 5;
				while(_local6 < len) {
					_local9 = g.unitManager.getTarget(m.getInt(_local6));
					if(_local9 != null) {
						_local7.secondaryTargets.push(_local9);
					}
					_local6++;
				}
			} else if(m.length > len && len > 5 && !(_local10 is Teleport)) {
				_local10.reloadTime = m.getNumber(i + 5);
			}
		}
		
		private function initWarpJump(m:Message) : void {
			var _local9:String = m.getString(0);
			var _local2:Player = playersById[_local9];
			if(_local2 == null || _local2.isWarpJumping) {
				return;
			}
			_local2.isWarpJumping = true;
			var _local6:int = _local2.initRoaming(m,1,false);
			var _local4:String = m.getString(_local6);
			var _local8:String = m.getString(_local6 + 1);
			var _local5:String = m.getString(_local6 + 2);
			var _local7:IDataManager = DataLocator.getService();
			var _local3:Object = _local7.loadKey("SolarSystems",_local4);
			MessageLog.writeChatMsg("join_leave",_local2.name + " warp jumped to " + _local3.name);
			if(_local2.isMe) {
				g.fadeIntoState(new WarpJumpState(g,_local4,_local8,_local5));
			} else {
				_local2.ship.enterWarpJump();
			}
		}
		
		public function updateMission(m:Message, i:int) : void {
			var _local3:String = m.getString(i);
			var _local4:Player = _playersById[_local3];
			if(_local4 != null && _local4.isMe) {
				_local4.updateMission(m,i + 1);
			}
		}
		
		public function updatePlayerStats(m:Message, i:int) : void {
			var _local3:PlayerShip = null;
			var _local4:String = m.getString(i);
			var _local5:Player = _playersById[_local4];
			if(_local5 != null && _local5.ship != null) {
				if(_local5.isMe) {
					return;
				}
				_local3 = _local5.ship;
				_local3.hpMax = m.getInt(i + 1);
				_local3.shieldHpMax = m.getInt(i + 2);
				_local3.shieldRegen = m.getInt(i + 3);
				_local3.armorThreshold = m.getInt(i + 4);
			}
		}
		
		private function syncHeat(m:Message) : void {
			var _local3:String = m.getString(0);
			var _local4:Player = playersById[_local3];
			if(_local4 == null) {
				return;
			}
			var _local2:PlayerShip = _local4.ship;
			if(_local2 == null) {
				return;
			}
			_local2.weaponHeat.setHeat(m.getNumber(1));
		}
		
		private function crewJoinOffer(m:Message) : void {
			var _local3:int = 0;
			var _local4:CrewMember = new CrewMember(g);
			var _local2:Array = [];
			_local2.push(m.getInt(0));
			_local2.push(m.getInt(1));
			_local2.push(m.getInt(2));
			_local4.skills = _local2;
			_local2 = [];
			_local3 = 0;
			while(_local3 < 9) {
				_local2.push(0);
				_local3++;
			}
			_local4.specials = _local2;
			new CrewJoinOffer(g,_local4,null,m.getString(3));
		}
		
		private function addNewMission(m:Message) : void {
			var _local2:Boolean = false;
			var _local5:String = m.getString(1);
			if(me.hasMission(m.getString(0))) {
				return;
			}
			me.addMission(m,0);
			if(_local5 == "KG4YJCr9tU6IH0rJRYo7HQ") {
				_local2 = false;
				for each(var _local3 in g.bodyManager.bodies) {
					if(_local3.key == "SWqDETtcD0i6Wc3s81yccQ" || _local3.key == "U8PYtFoC5U6c2A_gar9j2A" || _local3.key == "TLYpHghGOU6FaZtxDiVXBA") {
						for each(var _local4 in _local3.spawners) {
							if(_local4.alive) {
								_local2 = true;
								g.hud.compas.addHintArrowByKey(_local3.key);
								break;
							}
						}
						if(_local2) {
							break;
						}
					}
				}
			} else if(_local5 == "9XyiJ1g9cESeNd0Nlr1FQQ") {
				g.hud.compas.addHintArrowByKey("oFryHqwA-0-_rwKhqFdiCA");
			} else if(_local5 == "adD2AhOuRkSzHkV3WrO3xQ") {
				g.hud.compas.addHintArrowByKey("aRJ7Qhctpkyq1FyiXQ8uSQ");
			} else if(_local5 == "YJ_P6Mr6L0CsKYagk-PCDw") {
				g.hud.compas.addHintArrowByKey("Yy5Xu1GjZU6fxe8yqNjEFQ");
			} else if(_local5 == "R162TWIx1kCr-sH6dLC-Ew" || _local5 == "LTtEVCP7IUm_qk6vrlhSmg") {
				g.hud.compas.addHintArrowByKey("fkytuRMpyUSciHkBfVXLYw");
			} else if(_local5 == "FTnXLOVBJEOeutHvbkV1nw") {
				g.hud.compas.addHintArrowByKey("tsKIlfSL9EG0CgVY3A5f_A");
			} else if(_local5 == "zNhe7EvwDk-uh_QVxSQKng" || _local5 == "fnXpQicG8Ee36-y67_gWDA") {
				g.hud.compas.clear();
			}
			if(g.gameStateMachine.inState(IntroState)) {
				return;
			}
			g.hud.showNewMissionsButton();
			MissionsList.reload();
		}
		
		private function removeMission(m:Message) : void {
			var _local2:String = m.getString(0);
			me.removeMissionById(_local2);
		}
		
		private function changeSkin(m:Message) : void {
			var _local2:String = m.getString(0);
			var _local3:Player = playersById[_local2];
			if(_local3 == null) {
				return;
			}
			_local3.activeSkin = m.getString(1);
		}
		
		private function newEncounter(m:Message) : void {
			g.me.addEncounter(m);
		}
		
		private function onPlayerUpdate(m:Message) : void {
			var _local12:Unit = null;
			var _local7:Boolean = false;
			var _local3:int = 0;
			var _local2:Weapon = null;
			var _local5:int = 0;
			var _local8:String = m.getString(_local5++);
			var _local11:Player = playersById[_local8];
			if(_local11 == null) {
				return;
			}
			var _local6:PlayerShip = _local11.ship;
			if(_local6 == null) {
				return;
			}
			_local6.hp = m.getInt(_local5++);
			_local6.shieldHp = m.getInt(_local5++);
			if(_local6.hp < _local6.hpMax || _local6.shieldHp < _local6.shieldHpMax) {
				_local6.isInjured = true;
			}
			if(m.length <= _local5) {
				return;
			}
			var _local9:Vector.<Weapon> = _local11.ship.weapons;
			if(_local9 == null) {
				return;
			}
			for each(var _local4 in _local9) {
				_local4.fire = false;
				_local4.target = null;
			}
			var _local10:int = m.getInt(_local5++);
			if(_local10 > -1 && _local10 < _local9.length) {
				_local11.selectedWeaponIndex = _local10;
				_local6.weaponHeat.setHeat(m.getNumber(_local5++));
				_local12 = null;
				_local7 = m.getBoolean(_local5++);
				_local3 = m.getInt(_local5++);
				if(_local3 != -1) {
					_local12 = g.unitManager.getTarget(_local3);
				}
				_local2 = _local6.weapon;
				_local2.fire = _local7;
				_local2.target = _local12;
			}
		}
		
		private function m_teleportToPosition(m:Message) : void {
			var line:int;
			var playerId:String;
			var channelingEnd:Number;
			var player:Player;
			var ship:PlayerShip;
			var w:Weapon;
			var p:Projectile;
			var tele:Teleport;
			var stopCourse:Heading;
			var i:int;
			var heading:Heading;
			var timeDiff:Number;
			var emitters:Vector.<Emitter>;
			if(g.isLeaving) {
				return;
			}
			line = 0;
			try {
				playerId = m.getString(0);
				channelingEnd = m.getNumber(1);
				player = playersById[playerId];
				if(player == null) {
					return;
				}
				line++;
				ship = player.ship;
				if(ship == null) {
					return;
				}
				ship.isTeleporting = true;
				if(ship.weapon && ship.weapon.fire) {
					ship.weapon.fire = false;
				}
				line++;
				for each(w in ship.weapons) {
					for each(p in w.projectiles) {
						p.ttl = 0;
					}
				}
				if(ship.weapon is Teleport) {
					tele = ship.weapon as Teleport;
					tele.updateCooldown();
				}
				line++;
				ship.channelingEnd = channelingEnd;
				stopCourse = new Heading();
				i = stopCourse.parseMessage(m,2);
				ship.course = stopCourse;
				line++;
				heading = new Heading();
				heading.parseMessage(m,i);
				line++;
				timeDiff = (channelingEnd - g.time) / 1000;
				EmitterFactory.create("UZ3AiNHAEUmBD4ev0Itu0A",g,ship.pos.x,ship.pos.y,ship,true);
				line++;
				emitters = EmitterFactory.create("5BSaDIEYj0mEuVkMVp1JGw",g,heading.pos.x,heading.pos.y,null,true);
				TweenMax.delayedCall(timeDiff,function():void {
					g.emitterManager.clean(ship);
					line++;
					EmitterFactory.create("CBZIObPQ40uaMZGvEcHvjw",g,ship.pos.x,ship.pos.y,ship,true);
					TweenMax.delayedCall(0.24000000000000002,function():void {
						line++;
						for each(var _local1 in emitters) {
							_local1.killEmitter();
						}
						line++;
						ship.course = heading;
						ship.isTeleporting = false;
						line++;
						if(ship == g.me.ship) {
							g.focusGameObject(g.me.ship,true);
							EmitterFactory.create("CBZIObPQ40uaMZGvEcHvjw",g,ship.pos.x,ship.pos.y,ship,true);
						}
						line++;
					});
				});
			}
			catch(e:Error) {
				g.client.errorLog.writeError(e.toString(),"teleport failed",e.getStackTrace(),{"line":line});
			}
		}
		
		private function m_AddCompletedMission(m:Message) : void {
			var _local3:String = m.getString(0);
			var _local2:int = m.getNumber(1);
			g.me.addCompletedMission(_local3,_local2);
		}
		
		private function m_AddFaction(m:Message) : void {
			if(g.me != null) {
				g.me.factions.push(m.getString(0));
			}
		}
		
		private function m_RemoveFaction(m:Message) : void {
			var _local3:Player = null;
			var _local2:String = null;
			var _local4:int = 0;
			if(g.me != null) {
				_local3 = g.me;
				_local2 = m.getString(0);
				_local4 = 0;
				while(_local4 < _local3.factions.length) {
					if(_local3.factions[_local4] == _local2) {
						_local3.factions.splice(_local4,1);
						return;
					}
					_local4++;
				}
			}
		}
		
		private function m_TriggerMission(m:Message) : void {
			var _local2:String = m.getString(0);
			g.me.addTriggeredMission(_local2);
			var _local3:Object = g.dataManager.loadKey("MissionTypes",_local2);
			if(_local3.majorType == "time") {
				g.tutorial.showFoundNewTimeMission(_local3);
			} else {
				g.tutorial.showFoundNewStaticMission(_local3);
			}
		}
		
		public function troonGain(m:Message, i:int) : void {
			var playerKey:String = m.getString(i++);
			var player:Player = playersById[playerKey];
			var troons:Number = m.getNumber(i++);
			player.troons += troons;
			if(!player.isMe) {
				return;
			}
			TweenMax.delayedCall(1.2,function():void {
				g.textManager.createTroonsText(troons);
			});
		}
		
		private function m_MissionArtifacts(m:Message) : void {
			me.pickupArtifacts(m);
		}
		
		private function m_DropJunk(m:Message) : void {
			g.dropManager.spawn(m);
		}
		
		private function m_UberUpdate(m:Message) : void {
			g.hud.uberStats.update(m);
		}
		
		private function m_updateCredits(m:Message) : void {
			g.creditManager.refresh();
		}
		
		private function m_softDisconnect(m:Message) : void {
			g.softDisconnect(m.getString(0));
		}
	}
}


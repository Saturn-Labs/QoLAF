package core.player
{
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
	
	public class PlayerManager extends EventDispatcher
	{
		public static var banMinutes:int = 0;
		
		public static var isAllChannels:Boolean = false;
		
		private var _me:Player;
		
		private var _playersById:Dictionary;
		
		private var _players:Vector.<Player>;
		
		private var _enemyPlayers:Vector.<Player>;
		
		private var g:Game;
		
		public function PlayerManager(param1:Game)
		{
			super();
			this.g = param1;
			_players = new Vector.<Player>();
			_enemyPlayers = new Vector.<Player>();
			_playersById = new Dictionary();
		}
		
		public function addMessageHandlers():void
		{
			g.addMessageHandler("reputationChange", reputationChange);
			g.addMessageHandler("playerKilled", killed);
			g.addMessageHandler("spawnDrop", spawnDrop);
			g.addMessageHandler("playerLanded", landed);
			g.addMessageHandler("playerEnterRoaming", initRoaming);
			g.addMessageHandler("playerLandFailed", landFailed);
			g.addMessageHandler("heatLockout", heatLockout);
			g.addMessageHandler("playerWeaponChangeFailed", weaponChangeFailed);
			g.addMessageHandler("playerEnterWarpJump", initWarpJump);
			g.addMessageHandler("payVaultCreditGain", payVaultCreditGain);
			g.addServiceMessageHandler("clientPrintMsg", printMsg);
			g.addServiceMessageHandler("modWarpToUser", modWarpToUser);
			g.addServiceMessageHandler("chatMsg", chatMsg);
			g.addMessageHandler("chatMsg", chatMsg);
			g.addMessageHandler("clientPrintMsg", printMsg);
			g.addServiceMessageHandler("chatBan", handleChatBan);
			g.addServiceMessageHandler("kicked", handleKicked);
			g.addMessageHandler("syncHeat", syncHeat);
			g.addMessageHandler("changeSkin", changeSkin);
			g.addMessageHandler("newMission", addNewMission);
			g.addMessageHandler("missionExpired", removeMission);
			g.addMessageHandler("addCompletedMission", m_AddCompletedMission);
			g.addMessageHandler("triggerMission", m_TriggerMission);
			g.addMessageHandler("addMissionArtifacts", m_MissionArtifacts);
			g.addMessageHandler("freeCrewJoinOffer", crewJoinOffer);
			g.addMessageHandler("killedPlayerTooManyTimes", tooManyKillsNotify);
			g.addMessageHandler("addWeapon", addWeapon);
			g.addMessageHandler("addSkin", addSkin);
			g.addMessageHandler("playerRotationSpeedChanged", setRotationSpeed);
			g.addMessageHandler("playerSpeedChanged", setSpeed);
			g.addMessageHandler("newEncounter", newEncounter);
			g.addMessageHandler("teleportToPosition", m_teleportToPosition);
			g.addMessageHandler("playerUpdate", onPlayerUpdate);
			g.addMessageHandler("pvpTimeoutWarning", m_pvpTimeout);
			g.addMessageHandler("newWeapon", m_newWeapon);
			g.addMessageHandler("pvpArtifact", m_pickupArtifact);
			g.addServiceMessageHandler("requestUpdateInviteReward", m_requestUpdateInviteReward);
			g.addMessageHandler("addFaction", m_AddFaction);
			g.addMessageHandler("removeFaction", m_RemoveFaction);
			g.addMessageHandler("dropJunk", m_DropJunk);
			g.addMessageHandler("receivedFlux", m_receivedFlux);
			g.addMessageHandler("GiftFlux", m_GiftFlux);
			g.addMessageHandler("uberUpdate", m_UberUpdate);
			g.addMessageHandler("startCloakSelf", m_startCloakSelf);
			g.addMessageHandler("endCloakSelf", m_endCloakSelf);
			g.addMessageHandler("startCloak", m_startCloak);
			g.addMessageHandler("endCloak", m_endCloak);
			g.addMessageHandler("updateCredits", m_updateCredits);
			g.addMessageHandler("softDisconnect", m_softDisconnect);
		}
		
		private function handleChatBan(param1:Message):void
		{
			var _loc2_:int = param1.getInt(0);
			isAllChannels = param1.getBoolean(1);
			banMinutes = _loc2_;
			TweenMax.delayedCall(60, reduceBanMinutes);
		}
		
		private function handleKicked(param1:Message):void
		{
			g.showMessageDialog("You were kicked out of the game by a moderator");
			g.disconnect();
		}
		
		private function showInvitePopup():void
		{
			var invButton:FBInvite;
			var invButton2:KongInvite;
			var popup:PopupMessage = new PopupMessage(Localize.t("No thanks!"));
			popup.text = "The game is more fun if played with friends! Would you like to invite someone to join your epic adventure?\n\n\n";
			if (Login.currentState == "facebook")
			{
				invButton = new FBInvite(g);
				invButton.x = g.stage.stageWidth / 2 - 85;
				invButton.y = g.stage.stageHeight / 2;
				invButton.width = 150;
				popup.addChild(invButton);
			}
			else if (Login.currentState == "kongregate")
			{
				invButton2 = new KongInvite(g);
				invButton2.x = g.stage.stageWidth / 2 - 85;
				invButton2.y = g.stage.stageHeight / 2;
				invButton2.width = 150;
				popup.addChild(invButton2);
			}
			g.addChildToOverlay(popup);
			g.creditManager.refresh();
			popup.addEventListener("close", (function():*
			{
				var closePopup:Function;
				return closePopup = function(param1:Event):void
				{
					g.removeChildFromOverlay(popup);
					popup.removeEventListeners();
				};
			})());
		}
		
		private function m_GiftFlux(param1:Message):void
		{
			var type:String;
			var value:int;
			var value2:int;
			var popup:PopupMessage;
			var m:Message = param1;
			if (g.me != null)
			{
				type = m.getString(0);
				value = m.getInt(1);
				value2 = m.getInt(2);
				if (type == "testRecp")
				{
					popup = new PopupMessage();
					popup.text = "Congratulations Captain! \n\nWell done reaching " + value2 + "! Have " + value + " Flux for free! \nGet yourself something nice! :)";
					g.addChildToOverlay(popup);
					g.creditManager.refresh();
					popup.addEventListener("close", (function():*
					{
						var closePopup:Function;
						return closePopup = function(param1:Event):void
						{
							g.removeChildFromOverlay(popup);
							popup.removeEventListeners();
							if (Login.currentState == "facebook" || Login.currentState == "kongregate")
							{
								TweenMax.delayedCall(5, showInvitePopup);
							}
						};
					})());
				}
			}
			g.creditManager.refresh();
		}
		
		private function m_receivedFlux(param1:Message):void
		{
			var popup:PopupMessage;
			var value:int;
			var m:Message = param1;
			if (g.me != null)
			{
				popup = new PopupMessage();
				value = m.getInt(0);
				popup.text = Localize.t("You have received your " + value + " bonus flux!");
				g.addChildToOverlay(popup);
				g.creditManager.refresh();
				popup.addEventListener("close", (function():*
				{
					var closePopup:Function;
					return closePopup = function(param1:Event):void
					{
						g.removeChildFromOverlay(popup);
						popup.removeEventListeners();
					};
				})());
			}
		}
		
		private function reduceBanMinutes():void
		{
			banMinutes--;
			if (banMinutes < 1)
			{
				return;
			}
			TweenMax.delayedCall(60, reduceBanMinutes);
		}
		
		private function heatLockout(param1:Message):void
		{
			var _loc3_:Heat = null;
			var _loc2_:Player = g.me;
			if (_loc2_.ship != null)
			{
				_loc3_ = _loc2_.ship.weaponHeat;
				_loc3_.pause(param1.getNumber(0));
				_loc3_.setHeat(param1.getNumber(1));
			}
		}
		
		private function m_startCloak(param1:Message):void
		{
			var _loc3_:Heading = null;
			var _loc2_:Player = playersById[param1.getString(0)];
			if (_loc2_ != null && _loc2_.ship != null)
			{
				_loc2_.ship.isTeleporting = true;
				_loc3_ = _loc2_.ship.course;
				_loc3_.pos.x = 824124;
				_loc3_.pos.y = -725215;
				_loc2_.ship.course = _loc3_;
				_loc2_.ship.x = 824124;
				_loc2_.ship.y = -725215;
			}
		}
		
		private function m_endCloak(param1:Message):void
		{
			var _loc3_:Heading = null;
			var _loc2_:Player = playersById[param1.getString(0)];
			if (_loc2_ != null && _loc2_.ship != null)
			{
				_loc3_ = new Heading();
				_loc2_.ship.isTeleporting = false;
				_loc3_.parseMessage(param1, 1);
				_loc2_.ship.course = _loc3_;
				_loc2_.ship.x = _loc3_.pos.x;
				_loc2_.ship.y = _loc3_.pos.y;
				_loc2_.ship.addToCanvasForReal();
			}
		}
		
		private function m_startCloakSelf(param1:Message):void
		{
			var _loc3_:Heat = null;
			var _loc2_:Player = g.me;
			if (_loc2_.ship != null)
			{
				_loc3_ = _loc2_.ship.weaponHeat;
				_loc3_.setHeat(param1.getNumber(0));
				_loc2_.ship.alpha = 0.1;
			}
		}
		
		private function m_endCloakSelf(param1:Message):void
		{
			var _loc2_:Player = g.me;
			if (_loc2_.ship != null)
			{
				_loc2_.ship.alpha = 1;
			}
		}
		
		public function update():void
		{
			for each (var _loc2_:* in _players)
			{
				_loc2_.update();
				if (!(_loc2_.ship == null || _loc2_.ship.course == null))
				{
					if (!(!_loc2_.ship.isAddedToCanvas || _loc2_.isLanded))
					{
						if (g.pvpManager == null || !(g.pvpManager is DominationManager))
						{
							_loc2_.inSafeZone = false;
							for each (var _loc1_:* in g.bodyManager.bodies)
							{
								_loc1_.setInSafeZone(_loc2_);
							}
						}
					}
				}
			}
		}
		
		private function m_requestUpdateInviteReward(param1:Message):void
		{
			g.send("requestInviteReward");
		}
		
		private function m_pickupArtifact(param1:Message):void
		{
			g.me.pickupArtifact(param1);
		}
		
		public function listAll():void
		{
			for each (var _loc1_:* in _players)
			{
				if (!(_loc1_.isDeveloper || _loc1_.isModerator))
				{
					MessageLog.writeChatMsg("list", "lvl " + _loc1_.level, _loc1_.id, _loc1_.name);
				}
			}
		}
		
		private function addMe(param1:String):Player
		{
			_me = new Player(g, param1);
			_me.isMe = true;
			g.myCargo = new Cargo(g, param1);
			g.myCargo.reloadCargoView();
			_playersById[_me.id] = _me;
			_players.push(_me);
			return _me;
		}
		
		private function addPlayer(param1:String):Player
		{
			var _loc2_:Player = new Player(g, param1);
			_playersById[param1] = _loc2_;
			_players.push(_loc2_);
			_enemyPlayers.push(_loc2_);
			return _loc2_;
		}
		
		public function initPlayer(param1:Message, param2:int = 0):int
		{
			var _loc4_:Player = null;
			var _loc3_:String = param1.getString(param2++);
			if (_loc3_ == g.client.connectUserId)
			{
				_loc4_ = addMe(_loc3_);
			}
			else
			{
				_loc4_ = addPlayer(_loc3_);
			}
			return _loc4_.init(param1, param2);
		}
		
		public function m_pvpTimeout(param1:Message):void
		{
			var _loc2_:Number = param1.getNumber(0);
			g.textManager.createPvpText("Not enough players", 0, 30);
			g.textManager.createPvpText("Match ending in " + int(_loc2_) + " seconds", -35, 30);
		}
		
		public function m_newWeapon(param1:Message):void
		{
			var _loc2_:String = param1.getString(0);
			Action.unlockWeapon(_loc2_);
		}
		
		public function removePlayer(param1:Message):void
		{
			var _loc5_:int = 0;
			var _loc2_:String = param1.getString(0);
			var _loc3_:Player = _playersById[_loc2_];
			var _loc4_:Boolean = param1.getBoolean(2);
			if (!_loc4_)
			{
				MessageLog.writeSysInfo(param1.getString(1) + " has left the system.");
			}
			if (_loc3_ != null)
			{
				_loc3_.unloadShip();
				delete _playersById[_loc2_];
				_loc5_ = 0;
				while (_loc5_ < _players.length)
				{
					if (_players[_loc5_] == _loc3_)
					{
						_players.splice(_loc5_, 1);
						break;
					}
					_loc5_++;
				}
				_loc5_ = 0;
				while (_loc5_ < _enemyPlayers.length)
				{
					if (_enemyPlayers[_loc5_] == _loc3_)
					{
						_enemyPlayers.splice(_loc5_, 1);
						break;
					}
					_loc5_++;
				}
				_loc3_.dispose();
			}
		}
		
		private function tooManyKillsNotify(param1:Message):void
		{
			var _loc2_:String = param1.getString(0);
			MessageLog.writeChatMsg("death", "You have killed " + _loc2_ + " more than four times in a row, " + _loc2_ + " can not give more experince untill you kill someone else.");
		}
		
		private function setRotationSpeed(param1:Message):void
		{
			var _loc2_:String = param1.getString(0);
			var _loc3_:Player = _playersById[_loc2_];
			if (_loc3_ != null)
			{
				_loc3_.rotationSpeedMod = param1.getNumber(1);
				if (_loc3_.ship != null && _loc3_.ship.engine != null)
				{
					_loc3_.ship.engine.rotationMod = _loc3_.rotationSpeedMod;
				}
			}
		}
		
		private function setSpeed(param1:Message):void
		{
			var _loc2_:String = param1.getString(0);
			var _loc3_:Player = _playersById[_loc2_];
			if (_loc3_ != null)
			{
				_loc3_.ship.engine.speed = param1.getNumber(1);
			}
		}
		
		private function addWeapon(param1:Message):void
		{
			var _loc2_:String = param1.getString(0);
			var _loc3_:Player = _playersById[_loc2_];
			var _loc4_:String = param1.getString(1);
			if (_loc3_ != null)
			{
				_loc3_.addWeapon(_loc4_);
			}
		}
		
		private function addSkin(param1:Message):void
		{
			var _loc2_:String = param1.getString(0);
			var _loc3_:Player = _playersById[_loc2_];
			var _loc4_:String = param1.getString(1);
			if (_loc3_ != null)
			{
				_loc3_.addNewSkin(_loc4_);
			}
		}
		
		private function spawnDrop(param1:Message):void
		{
			if (g.dropManager != null)
			{
				g.dropManager.spawn(param1, 0);
			}
		}
		
		private function killed(param1:Message):void
		{
			if (param1 == null)
			{
				return;
			}
			if (param1.length < 4)
			{
				return;
			}
			var _loc3_:String = param1.getString(0);
			var _loc6_:String = param1.getString(1);
			var _loc5_:String = param1.getString(2);
			var _loc7_:String = param1.getString(3);
			var _loc2_:int = param1.getInt(4);
			if (g.dropManager != null)
			{
				g.dropManager.spawn(param1, 5);
			}
			var _loc4_:Player = _playersById[_loc3_];
			if (_loc4_ == null)
			{
				return;
			}
			if (_loc4_.ship == null)
			{
				return;
			}
			MessageLog.writeDeathNote(_loc4_, _loc6_, _loc5_);
			if (_loc4_.spree == 4)
			{
				MessageLog.writeChatMsg("death", _loc4_.name + " died after killing 4.");
			}
			else if (_loc4_.spree > 4 && _loc5_ != "suicide")
			{
				MessageLog.writeChatMsg("death", _loc6_ + " ended " + _loc4_.name + "s " + _loc4_.spree + " kills long frenzy!");
			}
			if (_loc4_.isMe && g.solarSystem.isPvpSystemInEditor && _loc5_ != "" && _loc5_ != "Death Line")
			{
				Game.trackEvent("pvp", g.solarSystem.type + " killedBy", _loc5_, _loc4_.level);
			}
			_loc4_.enterKilled(param1);
		}
		
		public function xpGain(param1:Message, param2:int):void
		{
			var _loc8_:int = 0;
			var _loc7_:int = 0;
			var _loc4_:int = 0;
			var _loc6_:String = null;
			var _loc3_:String = param1.getString(param2);
			var _loc5_:Player = _playersById[_loc3_];
			if (_loc5_ != null)
			{
				_loc8_ = param1.getInt(param2 + 1);
				_loc7_ = param1.getInt(param2 + 2);
				_loc5_.increaseXp(_loc8_, _loc7_);
				_loc4_ = param1.getInt(param2 + 3);
				_loc5_.setSpree(_loc4_);
				_loc6_ = param1.getString(param2 + 5);
				if (_loc5_ == g.me && _loc6_ != "")
				{
					if (_loc4_ > 15)
					{
						g.textManager.createKillText("You killed " + _loc6_ + "! Godlike!", 50, 5000, 16777215);
					}
					else if (_loc4_ > 10)
					{
						g.textManager.createKillText("You killed " + _loc6_ + "! Rampage!", 40, 5000, 16777215);
					}
					else if (_loc4_ > 4)
					{
						g.textManager.createKillText("You killed " + _loc6_ + "! Killing Spree!", 38, 5000, 16777215);
					}
					else
					{
						g.textManager.createKillText("You killed " + _loc6_ + "!", 35, 5000, 16777215);
					}
				}
			}
		}
		
		private function reputationChange(param1:Message):void
		{
			var _loc4_:int = 0;
			var _loc5_:int = 0;
			var _loc2_:String = param1.getString(0);
			var _loc3_:Player = _playersById[_loc2_];
			if (_loc3_ != null)
			{
				_loc4_ = param1.getInt(1);
				_loc5_ = param1.getInt(2);
				_loc3_.updateReputation(_loc4_, _loc5_);
			}
		}
		
		public function xpLoss(param1:Message, param2:int):void
		{
			var _loc6_:int = 0;
			var _loc5_:int = 0;
			var _loc3_:String = param1.getString(param2);
			var _loc4_:Player = _playersById[_loc3_];
			if (_loc4_ != null)
			{
				_loc6_ = param1.getInt(param2 + 1);
				_loc5_ = param1.getInt(param2 + 2);
				_loc4_.decreaseXp(_loc6_, _loc5_);
			}
		}
		
		private function payVaultCreditGain(param1:Message):void
		{
			var creditBox:CreditGainBox;
			var pods:int;
			var m:Message = param1;
			var type:String = m.getString(1);
			var name:String = "";
			if (m.length > 3)
			{
				name = m.getString(3);
			}
			if (type == "daily")
			{
				creditBox = new DailyRewardMessage(g, m.getInt(0), m.getInt(2));
			}
			else if (type == "missions" || type == "level")
			{
				pods = m.getInt(0);
				creditBox = new CreditGainBox(g, 0, pods, type);
				if (pods > 0)
				{
					creditBox.callback = function():void
					{
						g.removeChildFromOverlay(creditBox);
						g.rpc("getPodCount", function(param1:Message):void
						{
							g.hud.updatePodCount(param1.getInt(0));
						});
					};
				}
			}
			else if (type == "pvp")
			{
				name = m.getString(2);
				creditBox = new CreditGainBox(g, m.getInt(0), 0, type, name);
			}
			else
			{
				creditBox = new CreditGainBox(g, m.getInt(0), 0, type, name);
			}
			g.addChildToOverlay(creditBox);
			if (type == "fbLike")
			{
				g.me.fbLike = true;
			}
			creditBox.addEventListener("close", (function():*
			{
				var close:Function;
				return close = function(param1:Event):void
				{
					g.creditManager.refresh();
					g.hud.buyFluxButton.flash();
					g.removeChildFromOverlay(creditBox);
				};
			})());
		}
		
		private function modWarpToUser(param1:Message):void
		{
			var _loc4_:IJoinRoomManager = null;
			var _loc3_:String = param1.getString(0);
			var _loc2_:String = param1.getString(1);
			if (_loc3_ != null && _loc3_ != "" && _loc2_ != null)
			{
				MessageLog.writeChatMsg("join_leave", "Warping to system: " + _loc3_, "system");
				_loc4_ = JoinRoomLocator.getService();
				_loc4_.desiredRoomId = null;
				_loc4_.desiredSystemType = "friendly";
				_loc4_.desiredRoomId = _loc3_;
				g.send("modWarp", "Hyperion");
			}
		}
		
		private function printMsg(param1:Message):void
		{
			var _loc2_:String = "system";
			if (param1.length > 1)
			{
				_loc2_ = param1.getString(1);
			}
			MessageLog.write(param1.getString(0), _loc2_);
		}
		
		private function chatMsg(param1:Message):void
		{
			if (param1.length <= 2)
			{
				return printMsg(param1);
			}
			var _loc8_:int = 0;
			var _loc6_:String = param1.getString(_loc8_++);
			var _loc7_:String = param1.getString(_loc8_++);
			var _loc5_:String = param1.getString(_loc8_++);
			var _loc3_:String = param1.getString(_loc8_++);
			var _loc4_:String = param1.getString(_loc8_++);
			var _loc2_:Boolean = param1.getBoolean(_loc8_++);
			MessageLog.writeChatMsg(_loc6_, _loc7_, _loc5_, _loc3_, _loc4_, _loc2_);
			if (_loc6_ == "private" && _loc5_ != me.id)
			{
				g.chatInput.lastPrivateReceived = _loc3_;
			}
		}
		
		public function dmgBoost(param1:Message, param2:int):void
		{
			var _loc3_:String = param1.getString(param2);
			var _loc4_:Player = _playersById[_loc3_];
			if (_loc4_ == null || _loc4_.isMe)
			{
				return;
			}
			var _loc5_:PlayerShip = _loc4_.ship;
			if (_loc5_ == null)
			{
				return;
			}
			_loc5_.usingDmgBoost = true;
			_loc5_.dmgBoostEndTime = g.time + _loc5_.dmgBoostDuration;
			_loc5_.damageBoostEffect();
		}
		
		public function hardenShield(param1:Message, param2:int):void
		{
			var _loc3_:String = param1.getString(param2);
			var _loc4_:Player = _playersById[_loc3_];
			if (_loc4_ == null || _loc4_.isMe)
			{
				return;
			}
			var _loc5_:PlayerShip = _loc4_.ship;
			if (_loc5_ == null)
			{
				return;
			}
			_loc5_.usingHardenedShield = true;
			_loc5_.hardenEndTimer = g.time + _loc5_.hardenDuration;
			_loc5_.hardenShieldEffect();
		}
		
		public function convShield(param1:Message, param2:int):void
		{
			var _loc3_:String = param1.getString(param2);
			var _loc4_:Player = _playersById[_loc3_];
			var _loc6_:int = param1.getInt(param2 + 1);
			var _loc7_:int = param1.getInt(param2 + 2);
			if (_loc4_ == null)
			{
				return;
			}
			var _loc5_:PlayerShip = _loc4_.ship;
			if (_loc5_ == null)
			{
				return;
			}
			_loc5_.shieldHp -= _loc6_;
			_loc5_.hp += _loc7_;
			if (_loc4_.ship.hp > _loc5_.hpMax)
			{
				_loc7_ -= _loc5_.hp - _loc5_.hpMax;
				_loc5_.hp = _loc5_.hpMax;
			}
			_loc5_.converShieldEffect();
			g.textManager.createDmgText(-_loc7_, _loc5_);
			if (_loc4_.isMe && g.hud != null)
			{
				g.hud.healthAndShield.update();
			}
		}
		
		public function powerUpHeal(param1:Message, param2:int):void
		{
			var _loc7_:String = null;
			var _loc5_:int = 0;
			var _loc3_:int = 0;
			var _loc4_:String = param1.getString(param2++);
			var _loc6_:Player = _playersById[_loc4_];
			if (_loc6_ != null && _loc6_.ship != null)
			{
				_loc7_ = param1.getString(param2++);
				_loc5_ = param1.getInt(param2++);
				_loc3_ = param1.getInt(param2++);
				_loc6_.ship.hp = param1.getInt(param2++);
				_loc6_.ship.shieldHp = param1.getInt(param2++);
				if (_loc7_ == "health" || _loc7_ == "healthSmall")
				{
					g.textManager.createDmgText(-_loc5_, _loc6_.ship, false);
				}
				else
				{
					g.textManager.createDmgText(-_loc3_, _loc6_.ship, true);
				}
				if (_loc6_.isMe)
				{
					g.hud.healthAndShield.update();
				}
			}
		}
		
		public function damaged(param1:Message, param2:int):void
		{
			var _loc6_:int = 0;
			var _loc4_:int = 0;
			var _loc3_:String = param1.getString(param2);
			var _loc5_:Player = _playersById[_loc3_];
			if (_loc5_ != null && _loc5_.ship != null)
			{
				_loc6_ = param1.getInt(param2 + 1);
				_loc4_ = param1.getInt(param2 + 2);
				_loc5_.ship.shieldHp = param1.getInt(param2 + 3);
				_loc5_.ship.hp = param1.getInt(param2 + 4);
				_loc5_.ship.takeDamage(_loc4_);
				if (param1.getBoolean(param2 + 5))
				{
					_loc5_.ship.doDOTEffect(param1.getInt(param2 + 6), param1.getString(param2 + 7), param1.getInt(param2 + 8), param1.getString(param2 + 9));
				}
				if (_loc5_.isMe)
				{
					g.hud.healthAndShield.update();
				}
			}
		}
		
		private function landed(param1:Message):void
		{
			var _loc2_:String = param1.getString(0);
			var _loc4_:Player = _playersById[_loc2_];
			var _loc5_:String = param1.getString(1);
			if (g.bodyManager == null)
			{
				Console.write("Land failed! Too early g == null");
				return;
			}
			if (_loc4_ == null)
			{
				Console.write("Land failed! Player is null, id: " + _loc2_);
				return;
			}
			if (_loc4_.ship == null)
			{
				Console.write("ship is null");
				return;
			}
			var _loc3_:Body = g.bodyManager.getBodyByKey(_loc5_);
			if (_loc3_ == null)
			{
				Console.write("Land failed! Body is null, bodyKey: " + _loc5_);
				return;
			}
			_loc4_.land(_loc3_);
		}
		
		private function initRoaming(param1:Message):void
		{
			var _loc2_:String = param1.getString(0);
			var _loc3_:Player = _playersById[_loc2_];
			if (_loc3_ != null)
			{
				_loc3_.initRoaming(param1, 1);
			}
			else
			{
				Console.write("No player on initRoaming!");
			}
		}
		
		private function landFailed(param1:Message):void
		{
			var _loc3_:String = param1.getString(0);
			var _loc4_:Player = _playersById[_loc3_];
			var _loc2_:Heading = new Heading();
			_loc2_.parseMessage(param1, 1);
			_loc4_.loadCourse(_loc2_);
			_loc4_.enterRoaming();
		}
		
		public function get me():Player
		{
			return _me;
		}
		
		public function get players():Vector.<Player>
		{
			return _players;
		}
		
		public function get enemyPlayers():Vector.<Player>
		{
			return _enemyPlayers;
		}
		
		public function get playersById():Dictionary
		{
			return _playersById;
		}
		
		public function weaponChanged(param1:Message, param2:int):void
		{
			var _loc4_:Dictionary = g.playerManager.playersById;
			var _loc3_:String = param1.getString(param2);
			var _loc5_:Player = _loc4_[_loc3_];
			if (_loc5_ == null)
			{
				return;
			}
			_loc5_.changeWeapon(param1, param2);
		}
		
		private function weaponChangeFailed(param1:Message):void
		{
			var _loc3_:Dictionary = g.playerManager.playersById;
			var _loc2_:String = param1.getString(0);
			var _loc4_:Player = _loc3_[_loc2_];
			if (_loc4_ == null || _loc4_.ship == null)
			{
				return;
			}
			_loc4_.ship.weaponIsChanging = false;
		}
		
		public function trySetActiveWeapons(param1:Player, param2:int, param3:String):void
		{
			var _loc5_:Weapon = null;
			var _loc12_:int = 0;
			var _loc11_:int = 0;
			if (param1 == null || param1.ship == null)
			{
				return;
			}
			param1.ship.weaponIsChanging = true;
			var _loc9_:* = -1;
			var _loc8_:Vector.<Weapon> = param1.ship.weapons;
			var _loc4_:int = 0;
			var _loc6_:Array = [];
			_loc12_ = 0;
			while (_loc12_ < param1.unlockedWeaponSlots)
			{
				_loc6_.push(_loc12_ + 1);
				_loc12_++;
			}
			_loc12_ = 0;
			while (_loc12_ < _loc8_.length)
			{
				_loc5_ = _loc8_[_loc12_];
				if (_loc5_.hotkey > 0)
				{
					_loc11_ = int(_loc6_.indexOf(_loc5_.hotkey));
					if (_loc11_ != -1)
					{
						_loc6_.splice(_loc11_, 1);
					}
					_loc4_++;
				}
				if (_loc5_.key == param3)
				{
					_loc9_ = _loc12_;
				}
				_loc12_++;
			}
			_loc12_ = 0;
			while (_loc12_ < _loc8_.length)
			{
				_loc5_ = _loc8_[_loc12_];
				if (_loc5_.hotkey == param2 && _loc12_ != _loc9_)
				{
					_loc6_.push(param2);
					_loc5_.setActive(param1.ship, false);
					_loc5_.hotkey = 0;
					param1.weaponsHotkeys[_loc12_] = 0;
					param1.weaponsState[_loc12_] = false;
				}
				_loc12_++;
			}
			if (param2 == -1 && _loc6_.length > 0)
			{
				param2 = int(_loc6_[0]);
			}
			if (_loc9_ < 0 || _loc9_ >= _loc8_.length || param2 < 0 || param2 > param1.unlockedWeaponSlots)
			{
				param1.ship.weaponIsChanging = false;
				return;
			}
			var _loc7_:Weapon = null;
			if (_loc9_ < _loc8_.length)
			{
				_loc7_ = _loc8_[_loc9_];
			}
			if (_loc7_ == null)
			{
				Console.write("Weapon index is null when tried to set it to active.");
				param1.ship.weaponIsChanging = false;
				return;
			}
			if (_loc7_.active)
			{
				_loc7_.setActive(param1.ship, false);
				_loc7_.hotkey = 0;
				param1.weaponsHotkeys[_loc9_] = 0;
				param1.weaponsState[_loc9_] = false;
			}
			if (_loc7_.setActive(param1.ship, true))
			{
				_loc7_.hotkey = param2;
				param1.weaponsHotkeys[_loc9_] = param2;
				param1.weaponsState[_loc9_] = true;
				param1.selectedWeaponIndex = _loc9_;
				Console.write("slot: " + param2, " Weapon index: " + _loc9_, " key: " + param3);
			}
			var _loc10_:Message = g.createMessage("trySetActiveWeapons");
			_loc10_.add(_loc9_);
			_loc10_.add(param2);
			_loc10_.add(true);
			g.sendMessage(_loc10_);
		}
		
		public function fire(param1:Message, param2:int = 0, param3:int = 0):void
		{
			var _loc7_:int = 0;
			var _loc11_:Beam = null;
			var _loc8_:int = 0;
			var _loc10_:String = param1.getString(param2);
			var _loc6_:int = param1.getInt(param2 + 1);
			var _loc9_:Boolean = param1.getBoolean(param2 + 2);
			var _loc4_:Player = playersById[_loc10_];
			if (_loc4_ == null)
			{
				return;
			}
			var _loc5_:PlayerShip = _loc4_.ship;
			if (_loc5_ == null)
			{
				return;
			}
			var _loc14_:Vector.<Weapon> = _loc4_.ship.weapons;
			if (_loc14_ == null)
			{
				return;
			}
			if (_loc6_ > -1 && _loc6_ < _loc14_.length)
			{
				_loc4_.selectedWeaponIndex = _loc6_;
			}
			var _loc13_:Unit = null;
			if (param1.length > param3)
			{
				_loc7_ = param1.getInt(param2 + 3);
				if (_loc7_ != -1)
				{
					_loc13_ = g.unitManager.getTarget(_loc7_);
				}
			}
			if (param1.length > param3)
			{
				if (_loc5_.weaponHeat == null)
				{
					return;
				}
				_loc5_.weaponHeat.setHeat(param1.getNumber(param2 + 4));
			}
			var _loc12_:Weapon = _loc5_.weapon;
			if (_loc12_ == null)
			{
				return;
			}
			_loc12_.fire = _loc9_;
			_loc12_.target = _loc13_;
			if (_loc12_ is Beam)
			{
				_loc11_ = _loc12_ as Beam;
				_loc11_.secondaryTargets = new Vector.<Unit>();
				_loc8_ = param2 + 5;
				while (_loc8_ < param3)
				{
					_loc13_ = g.unitManager.getTarget(param1.getInt(_loc8_));
					if (_loc13_ != null)
					{
						_loc11_.secondaryTargets.push(_loc13_);
					}
					_loc8_++;
				}
			}
			else if (param1.length > param3 && param3 > 5 && !(_loc12_ is Teleport))
			{
				_loc12_.reloadTime = param1.getNumber(param2 + 5);
			}
		}
		
		private function initWarpJump(param1:Message):void
		{
			var _loc3_:String = param1.getString(0);
			var _loc4_:Player = playersById[_loc3_];
			if (_loc4_ == null || _loc4_.isWarpJumping)
			{
				return;
			}
			_loc4_.isWarpJumping = true;
			var _loc9_:int = _loc4_.initRoaming(param1, 1, false);
			var _loc8_:String = param1.getString(_loc9_);
			var _loc5_:String = param1.getString(_loc9_ + 1);
			var _loc2_:String = param1.getString(_loc9_ + 2);
			var _loc7_:IDataManager = DataLocator.getService();
			var _loc6_:Object = _loc7_.loadKey("SolarSystems", _loc8_);
			MessageLog.writeChatMsg("join_leave", _loc4_.name + " warp jumped to " + _loc6_.name);
			if (_loc4_.isMe)
			{
				g.fadeIntoState(new WarpJumpState(g, _loc8_, _loc5_, _loc2_));
			}
			else
			{
				_loc4_.ship.enterWarpJump();
			}
		}
		
		public function updateMission(param1:Message, param2:int):void
		{
			var _loc3_:String = param1.getString(param2);
			var _loc4_:Player = _playersById[_loc3_];
			if (_loc4_ != null && _loc4_.isMe)
			{
				_loc4_.updateMission(param1, param2 + 1);
			}
		}
		
		public function updatePlayerStats(param1:Message, param2:int):void
		{
			var _loc4_:PlayerShip = null;
			var _loc3_:String = param1.getString(param2);
			var _loc5_:Player = _playersById[_loc3_];
			if (_loc5_ != null && _loc5_.ship != null)
			{
				if (_loc5_.isMe)
				{
					return;
				}
				_loc4_ = _loc5_.ship;
				_loc4_.hpMax = param1.getInt(param2 + 1);
				_loc4_.shieldHpMax = param1.getInt(param2 + 2);
				_loc4_.shieldRegen = param1.getInt(param2 + 3);
				_loc4_.armorThreshold = param1.getInt(param2 + 4);
			}
		}
		
		private function syncHeat(param1:Message):void
		{
			var _loc2_:String = param1.getString(0);
			var _loc3_:Player = playersById[_loc2_];
			if (_loc3_ == null)
			{
				return;
			}
			var _loc4_:PlayerShip = _loc3_.ship;
			if (_loc4_ == null)
			{
				return;
			}
			_loc4_.weaponHeat.setHeat(param1.getNumber(1));
		}
		
		private function crewJoinOffer(param1:Message):void
		{
			var _loc3_:int = 0;
			var _loc2_:CrewMember = new CrewMember(g);
			var _loc4_:Array = [];
			_loc4_.push(param1.getInt(0));
			_loc4_.push(param1.getInt(1));
			_loc4_.push(param1.getInt(2));
			_loc2_.skills = _loc4_;
			_loc4_ = [];
			_loc3_ = 0;
			while (_loc3_ < 9)
			{
				_loc4_.push(0);
				_loc3_++;
			}
			_loc2_.specials = _loc4_;
			new CrewJoinOffer(g, _loc2_, null, param1.getString(3));
		}
		
		private function addNewMission(param1:Message):void
		{
			var _loc2_:Boolean = false;
			var _loc5_:String = param1.getString(1);
			if (me.hasMission(param1.getString(0)))
			{
				return;
			}
			me.addMission(param1, 0);
			if (_loc5_ == "KG4YJCr9tU6IH0rJRYo7HQ")
			{
				_loc2_ = false;
				for each (var _loc4_:* in g.bodyManager.bodies)
				{
					if (_loc4_.key == "SWqDETtcD0i6Wc3s81yccQ" || _loc4_.key == "U8PYtFoC5U6c2A_gar9j2A" || _loc4_.key == "TLYpHghGOU6FaZtxDiVXBA")
					{
						for each (var _loc3_:* in _loc4_.spawners)
						{
							if (_loc3_.alive)
							{
								_loc2_ = true;
								g.hud.compas.addHintArrowByKey(_loc4_.key);
								break;
							}
						}
						if (_loc2_)
						{
							break;
						}
					}
				}
			}
			else if (_loc5_ == "9XyiJ1g9cESeNd0Nlr1FQQ")
			{
				g.hud.compas.addHintArrowByKey("oFryHqwA-0-_rwKhqFdiCA");
			}
			else if (_loc5_ == "adD2AhOuRkSzHkV3WrO3xQ")
			{
				g.hud.compas.addHintArrowByKey("aRJ7Qhctpkyq1FyiXQ8uSQ");
			}
			else if (_loc5_ == "YJ_P6Mr6L0CsKYagk-PCDw")
			{
				g.hud.compas.addHintArrowByKey("Yy5Xu1GjZU6fxe8yqNjEFQ");
			}
			else if (_loc5_ == "R162TWIx1kCr-sH6dLC-Ew" || _loc5_ == "LTtEVCP7IUm_qk6vrlhSmg")
			{
				g.hud.compas.addHintArrowByKey("fkytuRMpyUSciHkBfVXLYw");
			}
			else if (_loc5_ == "FTnXLOVBJEOeutHvbkV1nw")
			{
				g.hud.compas.addHintArrowByKey("tsKIlfSL9EG0CgVY3A5f_A");
			}
			else if (_loc5_ == "zNhe7EvwDk-uh_QVxSQKng" || _loc5_ == "fnXpQicG8Ee36-y67_gWDA")
			{
				g.hud.compas.clear();
			}
			if (g.gameStateMachine.inState(IntroState))
			{
				return;
			}
			g.hud.showNewMissionsButton();
			MissionsList.reload();
		}
		
		private function removeMission(param1:Message):void
		{
			var _loc2_:String = param1.getString(0);
			me.removeMissionById(_loc2_);
		}
		
		private function changeSkin(param1:Message):void
		{
			var _loc3_:String = param1.getString(0);
			var _loc2_:Player = playersById[_loc3_];
			if (_loc2_ == null)
			{
				return;
			}
			_loc2_.activeSkin = param1.getString(1);
		}
		
		private function newEncounter(param1:Message):void
		{
			g.me.addEncounter(param1);
		}
		
		private function onPlayerUpdate(param1:Message):void
		{
			var _loc7_:Unit = null;
			var _loc11_:Boolean = false;
			var _loc10_:int = 0;
			var _loc6_:Weapon = null;
			var _loc12_:int = 0;
			var _loc3_:String = param1.getString(_loc12_++);
			var _loc4_:Player = playersById[_loc3_];
			if (_loc4_ == null)
			{
				return;
			}
			var _loc5_:PlayerShip = _loc4_.ship;
			if (_loc5_ == null)
			{
				return;
			}
			_loc5_.hp = param1.getInt(_loc12_++);
			_loc5_.shieldHp = param1.getInt(_loc12_++);
			if (_loc5_.hp < _loc5_.hpMax || _loc5_.shieldHp < _loc5_.shieldHpMax)
			{
				_loc5_.isInjured = true;
			}
			if (param1.length <= _loc12_)
			{
				return;
			}
			var _loc9_:Vector.<Weapon> = _loc4_.ship.weapons;
			if (_loc9_ == null)
			{
				return;
			}
			for each (var _loc2_:* in _loc9_)
			{
				_loc2_.fire = false;
				_loc2_.target = null;
			}
			var _loc8_:int = param1.getInt(_loc12_++);
			if (_loc8_ > -1 && _loc8_ < _loc9_.length)
			{
				_loc4_.selectedWeaponIndex = _loc8_;
				_loc5_.weaponHeat.setHeat(param1.getNumber(_loc12_++));
				_loc7_ = null;
				_loc11_ = param1.getBoolean(_loc12_++);
				_loc10_ = param1.getInt(_loc12_++);
				if (_loc10_ != -1)
				{
					_loc7_ = g.unitManager.getTarget(_loc10_);
				}
				_loc6_ = _loc5_.weapon;
				_loc6_.fire = _loc11_;
				_loc6_.target = _loc7_;
			}
		}
		
		private function m_teleportToPosition(param1:Message):void
		{
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
			var m:Message = param1;
			if (g.isLeaving)
			{
				return;
			}
			line = 0;
			try
			{
				playerId = m.getString(0);
				channelingEnd = m.getNumber(1);
				player = playersById[playerId];
				if (player == null)
				{
					return;
				}
				line++;
				ship = player.ship;
				if (ship == null)
				{
					return;
				}
				ship.isTeleporting = true;
				if (ship.weapon && ship.weapon.fire)
				{
					ship.weapon.fire = false;
				}
				line++;
				for each (w in ship.weapons)
				{
					for each (p in w.projectiles)
					{
						p.ttl = 0;
					}
				}
				if (ship.weapon is Teleport)
				{
					tele = ship.weapon as Teleport;
					tele.updateCooldown();
				}
				line++;
				ship.channelingEnd = channelingEnd;
				stopCourse = new Heading();
				i = stopCourse.parseMessage(m, 2);
				ship.course = stopCourse;
				line++;
				heading = new Heading();
				heading.parseMessage(m, i);
				line++;
				timeDiff = (channelingEnd - g.time) / 1000;
				EmitterFactory.create("UZ3AiNHAEUmBD4ev0Itu0A", g, ship.pos.x, ship.pos.y, ship, true);
				line++;
				emitters = EmitterFactory.create("5BSaDIEYj0mEuVkMVp1JGw", g, heading.pos.x, heading.pos.y, null, true);
				TweenMax.delayedCall(timeDiff, function():void
				{
					g.emitterManager.clean(ship);
					line++;
					EmitterFactory.create("CBZIObPQ40uaMZGvEcHvjw", g, ship.pos.x, ship.pos.y, ship, true);
					TweenMax.delayedCall(0.24000000000000002, function():void
					{
						line++;
						for each (var _loc1_:* in emitters)
						{
							_loc1_.killEmitter();
						}
						line++;
						ship.course = heading;
						ship.isTeleporting = false;
						line++;
						if (ship == g.me.ship)
						{
							g.focusGameObject(g.me.ship, true);
							EmitterFactory.create("CBZIObPQ40uaMZGvEcHvjw", g, ship.pos.x, ship.pos.y, ship, true);
						}
						line++;
					});
				});
			}
			catch (e:Error)
			{
				g.client.errorLog.writeError(e.toString(), "teleport failed", e.getStackTrace(), {"line": line});
			}
		}
		
		private function m_AddCompletedMission(param1:Message):void
		{
			var _loc2_:String = param1.getString(0);
			var _loc3_:int = param1.getNumber(1);
			g.me.addCompletedMission(_loc2_, _loc3_);
		}
		
		private function m_AddFaction(param1:Message):void
		{
			if (g.me != null)
			{
				g.me.factions.push(param1.getString(0));
			}
		}
		
		private function m_RemoveFaction(param1:Message):void
		{
			var _loc3_:Player = null;
			var _loc2_:String = null;
			var _loc4_:int = 0;
			if (g.me != null)
			{
				_loc3_ = g.me;
				_loc2_ = param1.getString(0);
				_loc4_ = 0;
				while (_loc4_ < _loc3_.factions.length)
				{
					if (_loc3_.factions[_loc4_] == _loc2_)
					{
						_loc3_.factions.splice(_loc4_, 1);
						return;
					}
					_loc4_++;
				}
			}
		}
		
		private function m_TriggerMission(param1:Message):void
		{
			var _loc3_:String = param1.getString(0);
			g.me.addTriggeredMission(_loc3_);
			var _loc2_:Object = g.dataManager.loadKey("MissionTypes", _loc3_);
			if (_loc2_.majorType == "time")
			{
				g.tutorial.showFoundNewTimeMission(_loc2_);
			}
			else
			{
				g.tutorial.showFoundNewStaticMission(_loc2_);
			}
		}
		
		public function troonGain(param1:Message, param2:int):void
		{
			var m:Message = param1;
			var i:int = param2;
			var playerKey:String = m.getString(i++);
			var player:Player = playersById[playerKey];
			var troons:Number = m.getNumber(i++);
			player.troons += troons;
			if (!player.isMe)
			{
				return;
			}
			TweenMax.delayedCall(1.2, function():void
			{
				g.textManager.createTroonsText(troons);
			});
		}
		
		private function m_MissionArtifacts(param1:Message):void
		{
			me.pickupArtifacts(param1);
		}
		
		private function m_DropJunk(param1:Message):void
		{
			g.dropManager.spawn(param1);
		}
		
		private function m_UberUpdate(param1:Message):void
		{
			g.hud.uberStats.update(param1);
		}
		
		private function m_updateCredits(param1:Message):void
		{
			g.creditManager.refresh();
		}
		
		private function m_softDisconnect(param1:Message):void
		{
			g.softDisconnect(param1.getString(0));
		}
	}
}

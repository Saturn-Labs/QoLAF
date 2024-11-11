package core.sync
{
	import core.scene.Game;
	import debug.Console;
	import playerio.Message;

	public class MessagePackHandler
	{
		private var g:Game;
		private const PLAYER_COURSE:String = "a";

		private const PLAYER_FIRE:String = "b";

		private const AI_STATE_CHANGED:String = "c";

		private const PLAYER_SPEED_BOOST:String = "d";

		private const PLAYER_CONV_SHIELD:String = "e";

		private const PLAYER_DMG_BOOST:String = "f";

		private const PLAYER_HARDEN_SHIELD:String = "g";

		private const PLAYER_XP_GAIN:String = "h";

		private const PLAYER_XP_LOSS:String = "i";

		private const PLAYER_DAMAGED:String = "j";

		private const ENEMY_DAMAGED:String = "k";

		private const TURRET_DAMAGED:String = "l";

		private const SPAWNER_DAMAGED:String = "m";

		private const BEAM_PICKUP:String = "n";

		private const PICKUP:String = "o";

		private const ENEMY_FIRE:String = "p";

		private const TURRET_FIRE:String = "q";

		private const ENEMY_KILLED:String = "r";

		private const TURRET_KILLED:String = "s";

		private const SPAWNER_KILLED:String = "t";

		private const SPAWN_DROPS:String = "u";

		private const PLAYER_POWERUP:String = "v";

		private const PLAYER_TROON_GAIN:String = "x";

		private const AI_TELEPORT:String = "z";

		public function MessagePackHandler(param1:Game)
		{
			super();
			this.g = param1;
		}

		public function addMessageHandlers():void
		{
			g.addMessageHandler("msgPack", handleMessagePack);
		}

		private function handleMessagePack(param1:Message):void
		{
			var _loc3_:String = null;
			var _loc2_:int = 0;
			var _loc4_:int = 0;
			try
			{
				_loc2_ = 0;
				_loc4_ = 0;
				while (_loc4_ < param1.length - 2)
				{
					_loc3_ = param1.getString(_loc4_);
					_loc2_ = param1.getInt(_loc4_ + 1);
					switch (_loc3_)
					{
						case "missionUpdate":
							g.playerManager.updateMission(param1, _loc4_ + 2);
							break;
						case "statsChanged":
							g.playerManager.updatePlayerStats(param1, _loc4_ + 2);
							break;
						case "bossComponentDamaged":
							g.bossManager.damaged(param1, _loc4_ + 2);
							break;
						case "bossComponentKilled":
							g.bossManager.killed(param1, _loc4_ + 2);
							break;
						case "aiBoucning":
							g.projectileManager.handleBouncing(param1, _loc4_ + 2);
							break;
						case "t":
							g.spawnManager.killed(param1, _loc4_ + 2);
							break;
						case "s":
							g.turretManager.killed(param1, _loc4_ + 2);
							break;
						case "r":
							g.shipManager.killed(param1, _loc4_ + 2);
							break;
						case "h":
							g.playerManager.xpGain(param1, _loc4_ + 2);
							break;
						case "i":
							g.playerManager.xpLoss(param1, _loc4_ + 2);
							break;
						case "j":
							g.playerManager.damaged(param1, _loc4_ + 2);
							break;
						case "k":
							g.shipManager.damaged(param1, _loc4_ + 2);
							break;
						case "m":
							g.spawnManager.damaged(param1, _loc4_ + 2);
							break;
						case "l":
							g.turretManager.damaged(param1, _loc4_ + 2);
							break;
						case "b":
							g.playerManager.fire(param1, _loc4_ + 2, _loc2_);
							break;
						case "a":
							g.shipManager.shipSync.playerCourse(param1, _loc4_ + 2);
							break;
						case "p":
							g.shipManager.enemyFire(param1, _loc4_ + 2);
							break;
						case "q":
							g.turretManager.turretFire(param1, _loc4_ + 2);
							break;
						case "c":
							g.shipManager.shipSync.aiStateChanged(param1, _loc4_ + 2);
							break;
						case "n":
							g.dropManager.tryBeamPickup(param1, _loc4_ + 2);
							break;
						case "o":
							g.dropManager.tryPickup(param1, null, _loc4_ + 2);
							break;
						case "playerWeaponChanged":
							g.playerManager.weaponChanged(param1, _loc4_ + 2);
							break;
						case "AICharge":
							g.shipManager.shipSync.aiCharge(param1, _loc4_ + 2);
							break;
						case "g":
							g.playerManager.hardenShield(param1, _loc4_ + 2);
							break;
						case "d":
							g.shipManager.shipSync.playerUsedBoost(param1, _loc4_ + 2);
							break;
						case "e":
							g.playerManager.convShield(param1, _loc4_ + 2);
							break;
						case "f":
							g.playerManager.dmgBoost(param1, _loc4_ + 2);
							break;
						case "u":
							g.dropManager.spawn(param1, _loc4_ + 2, _loc2_ - 2);
							break;
						case "v":
							g.playerManager.powerUpHeal(param1, _loc4_ + 2);
							break;
						case "x":
							g.playerManager.troonGain(param1, _loc4_ + 2);
							break;
						case "z":
							g.bossManager.aiTeleport(param1, _loc4_ + 2);
							break;
						default:
							Console.write("Error: invalid message type " + _loc3_);
							_loc4_ = param1.length;
					}
					_loc4_ += _loc2_;
				}
			}
			catch (e:Error)
			{
				g.client.errorLog.writeError("MSG PACK: " + e.toString(), "Type: " + _loc3_, e.getStackTrace(), {});
			}
		}

		private function increaseMessageCounter(param1:String):void
		{
			switch (param1)
			{
				case "t":
					g.increaseMessageCounter("spawner killed");
					break;
				case "s":
					g.increaseMessageCounter("turret killed");
					break;
				case "r":
					g.increaseMessageCounter("enemy killed");
					break;
				case "h":
					g.increaseMessageCounter("player xp gain");
					break;
				case "i":
					g.increaseMessageCounter("player xp loss");
					break;
				case "j":
					g.increaseMessageCounter("player damaged");
					break;
				case "k":
					g.increaseMessageCounter("enemy damaged");
					break;
				case "m":
					g.increaseMessageCounter("spawner damaged");
					break;
				case "l":
					g.increaseMessageCounter("turret damaged");
					break;
				case "b":
					g.increaseMessageCounter("player fire");
					break;
				case "a":
					g.increaseMessageCounter("player course");
					break;
				case "p":
					g.increaseMessageCounter("enemy fire");
					break;
				case "q":
					g.increaseMessageCounter("turret fire");
					break;
				case "c":
					g.increaseMessageCounter("ai state change");
					break;
				case "n":
					g.increaseMessageCounter("beam pickup");
					break;
				case "o":
					g.increaseMessageCounter("pickup");
					break;
				case "g":
					g.increaseMessageCounter("harden shield");
					break;
				case "d":
					g.increaseMessageCounter("speed boost");
					break;
				case "e":
					g.increaseMessageCounter("convert shield");
					break;
				case "f":
					g.increaseMessageCounter("damage boost");
					break;
				case "u":
					g.increaseMessageCounter("spawn drops");
					break;
				default:
					g.increaseMessageCounter(param1);
			}
		}
	}
}

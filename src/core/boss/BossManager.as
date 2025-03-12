package core.boss
{
	import core.scene.Game;
	import core.solarSystem.Body;
	import core.unit.Unit;
	import debug.Console;
	import flash.geom.Point;
	import movement.Heading;
	import playerio.Message;
	import sound.SoundLocator;
	
	public class BossManager
	{
		private var g:Game;
		
		public var bosses:Vector.<Boss>;
		
		public var callbackMessages:Vector.<Message>;
		
		public var callbackFunctions:Vector.<Function>;
		
		public function BossManager(param1:Game)
		{
			super();
			this.g = param1;
			bosses = new Vector.<Boss>();
			callbackMessages = new Vector.<Message>();
			callbackFunctions = new Vector.<Function>();
		}
		
		public function update():void
		{
			var _loc1_:Boss = null;
			var _loc2_:int = 0;
			_loc2_ = bosses.length - 1;
			while (_loc2_ >= 0)
			{
				_loc1_ = bosses[_loc2_];
				_loc1_.update();
				_loc2_--;
			}
		}
		
		public function forceUpdate():void
		{
			var _loc1_:Boss = null;
			var _loc2_:int = 0;
			_loc2_ = bosses.length - 1;
			while (_loc2_ >= 0)
			{
				_loc1_ = bosses[_loc2_];
				_loc1_.nextDistanceCalculation = 0;
				_loc2_--;
			}
		}
		
		public function addMessageHandlers():void
		{
			g.addMessageHandler("aiBossTargetChanged", aiBossTargetChanged);
			g.addMessageHandler("aiBossCourse", aiBossCourse);
			g.addMessageHandler("aiBossFireAtBody", aiBossFireAtBody);
			g.addMessageHandler("initBoss", initSyncBoss);
			g.addMessageHandler("bossKilled", bossKilled);
			g.addMessageHandler("spawnBoss", spawnBoss);
		}
		
		public function initBosses(param1:Message, param2:int, param3:int):void
		{
			var _loc6_:String = null;
			var _loc8_:String = null;
			var _loc4_:* = null;
			var _loc9_:Number = NaN;
			var _loc7_:Number = NaN;
			var _loc5_:int = (param3 - 2) / 4;
			if (_loc5_ == 0)
			{
				return;
			}
			param2;
			while (param2 < param3)
			{
				_loc6_ = param1.getString(param2);
				_loc8_ = param1.getString(param2 + 1);
				_loc9_ = param1.getNumber(param2 + 2);
				_loc7_ = param1.getNumber(param2 + 3);
				createBoss(_loc6_, _loc8_, _loc9_, _loc7_);
				param2 += 4;
			}
		}
		
		public function spawnBoss(param1:Message):void
		{
			var _loc2_:String = null;
			var _loc4_:String = null;
			var _loc6_:int = 0;
			var _loc5_:Number = NaN;
			var _loc3_:Number = NaN;
			_loc6_ = 0;
			while (_loc6_ < param1.length - 1)
			{
				_loc2_ = param1.getString(_loc6_);
				_loc4_ = param1.getString(_loc6_ + 1);
				_loc5_ = param1.getNumber(_loc6_ + 2);
				_loc3_ = param1.getNumber(_loc6_ + 3);
				createBoss(_loc2_, _loc4_, _loc5_, _loc3_);
				_loc6_ += 4;
			}
		}
		
		public function createBoss(param1:String, param2:String, param3:Number, param4:Number):void
		{
			var _loc5_:Body = g.bodyManager.getBodyByKey(param2);
			if (_loc5_ == null)
			{
				return;
			}
			var _loc6_:Boss = BossFactory.createBoss(param1, _loc5_, _loc5_.wpArray, param2, g);
			_loc6_.course.pos.x = param3;
			_loc6_.course.pos.y = param4;
			_loc6_.x = param3;
			_loc6_.y = param4;
			g.bossManager.add(_loc6_);
			if (g.gameStartedTime != 0 && g.time - g.gameStartedTime > 10000 && g.me.level > 1)
			{
				g.textManager.createBossSpawnedText(_loc6_.name + " has spawned");
				SoundLocator.getService().play("q0CoOEzFYk2yFBRYQtfYvw");
			}
		}
		
		private function bossKilled(param1:Message):void
		{
			var _loc2_:Boss = getBossFromKey(param1.getString(0));
			if (_loc2_ != null)
			{
				killBoss(_loc2_);
			}
		}
		
		private function killBoss(param1:Boss):void
		{
			param1.destroy();
			g.hud.radar.remove(param1);
			param1.removeFromCanvas();
			bosses.splice(bosses.indexOf(param1), 1);
			Console.write("BOSS killed!");
		}
		
		public function aiTeleport(param1:Message, param2:int):void
		{
			var _loc3_:Boss = g.bossManager.getBossFromKey(param1.getString(param2));
			if (_loc3_ == null)
			{
				return;
			}
			_loc3_.teleportExitPoint = new Point(param1.getNumber(param2 + 1), param1.getNumber(param2 + 2));
			_loc3_.teleportExitTime = param1.getNumber(param2 + 3);
			_loc3_.startTeleportEffect();
		}
		
		public function aiBossFireAtBody(param1:Message):void
		{
			var _loc2_:Boss = g.bossManager.getBossFromKey(param1.getString(0));
			if (_loc2_ == null)
			{
				callbackMessages.push(param1);
				callbackFunctions.push(aiBossFireAtBody);
				return;
			}
			_loc2_.bodyTarget = g.bodyManager.getBodyByKey(param1.getString(1));
			_loc2_.bodyDestroyStart = param1.getNumber(2);
			_loc2_.bodyDestroyEnd = param1.getNumber(3);
		}
		
		public function aiBossCourse(param1:Message):void
		{
			var _loc5_:int = 0;
			var _loc2_:Boss = g.bossManager.getBossFromKey(param1.getString(0));
			if (_loc2_ == null)
			{
				callbackMessages.push(param1);
				callbackFunctions.push(aiBossCourse);
				return;
			}
			var _loc7_:Heading = new Heading();
			var _loc6_:int = param1.getInt(1);
			if (_loc6_ != 0 && (_loc2_.currentWaypoint == null || _loc6_ != _loc2_.currentWaypoint.id))
			{
				_loc5_ = 0;
				while (_loc5_ < _loc2_.waypoints.length)
				{
					if (_loc6_ == _loc2_.waypoints[_loc5_].id)
					{
						_loc2_.currentWaypoint = _loc2_.waypoints[_loc5_];
						break;
					}
					_loc5_++;
				}
			}
			var _loc4_:int = param1.getInt(2);
			var _loc3_:Unit = g.unitManager.getTarget(_loc4_);
			_loc2_.target = _loc3_;
			_loc7_.parseMessage(param1, 3);
			_loc2_.setConvergeTarget(_loc7_);
		}
		
		public function aiBossTargetChanged(param1:Message):void
		{
			var _loc3_:Boss = g.bossManager.getBossFromKey(param1.getString(0));
			var _loc2_:Unit = g.shipManager.getShipFromId(param1.getInt(1));
			if (_loc3_ == null)
			{
				callbackMessages.push(param1);
				callbackFunctions.push(aiBossTargetChanged);
				return;
			}
			_loc3_.target = _loc2_;
		}
		
		public function getBossFromKey(param1:String):Boss
		{
			for each (var _loc2_:* in bosses)
			{
				if (_loc2_.key == param1)
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		public function getComponentById(param1:int):Unit
		{
			for each (var _loc3_:* in bosses)
			{
				for each (var _loc2_:* in _loc3_.allComponents)
				{
					if (_loc2_.syncId == param1)
					{
						return _loc2_;
					}
				}
			}
			return null;
		}
		
		public function add(param1:Boss):void
		{
			var _loc4_:int = 0;
			var _loc3_:Message = null;
			var _loc2_:Function = null;
			bosses.push(param1);
			g.hud.radar.add(param1);
			param1.addToCanvas();
			_loc4_ = callbackMessages.length - 1;
			while (_loc4_ > -1)
			{
				if (callbackFunctions[_loc4_] == initSyncBoss)
				{
					callbackFunctions.shift();
					_loc3_ = callbackMessages.shift();
					initSyncBoss(_loc3_);
				}
				_loc4_--;
			}
			_loc4_ = callbackMessages.length - 1;
			while (_loc4_ > -1)
			{
				_loc3_ = callbackMessages.shift();
				_loc2_ = callbackFunctions.shift();
				_loc2_(_loc3_);
				_loc4_--;
			}
		}
		
		public function killed(param1:Message, param2:int):void
		{
			var _loc3_:int = param1.getInt(param2);
			var _loc4_:Unit = getComponentById(_loc3_);
			if (_loc4_ == null)
			{
				Console.write("No bc to kill by id: " + _loc3_);
				return;
			}
			_loc4_.destroy();
		}
		
		public function damaged(param1:Message, param2:int):void
		{
			var _loc3_:int = param1.getInt(param2 + 1);
			var _loc5_:Unit = getComponentById(_loc3_);
			if (_loc5_ == null)
			{
				return;
			}
			var _loc4_:int = param1.getInt(param2 + 2);
			_loc5_.takeDamage(_loc4_);
			_loc5_.shieldHp = param1.getInt(param2 + 3);
			_loc5_.hp = param1.getInt(param2 + 4);
			if (param1.getBoolean(param2 + 5))
			{
				_loc5_.doDOTEffect(param1.getInt(param2 + 6), param1.getString(param2 + 7));
			}
		}
		
		public function initSyncBoss(param1:Message):void
		{
			var _loc6_:int = 0;
			var _loc3_:Unit = null;
			Console.write("SYNC BOSS!");
			var _loc8_:int = 0;
			var _loc4_:Boss = getBossFromKey(param1.getString(_loc8_));
			if (_loc4_ == null)
			{
				callbackMessages.push(param1);
				callbackFunctions.push(initSyncBoss);
				return;
			}
			_loc4_.awaitingActivation = false;
			_loc4_.target = g.unitManager.getTarget(param1.getInt(_loc8_ + 1));
			_loc4_.alive = param1.getBoolean(_loc8_ + 2);
			var _loc7_:int = param1.getInt(_loc8_ + 3);
			_loc6_ = 0;
			while (_loc6_ < _loc4_.waypoints.length)
			{
				if (_loc4_.waypoints[_loc6_].id == _loc7_)
				{
					_loc4_.currentWaypoint = _loc4_.waypoints[_loc6_];
					break;
				}
				_loc6_++;
			}
			_loc4_.rotationForced = param1.getBoolean(_loc8_ + 4);
			_loc4_.rotationSpeed = param1.getNumber(_loc8_ + 5);
			var _loc2_:Heading = new Heading();
			_loc8_ = _loc2_.parseMessage(param1, _loc8_ + 6);
			_loc4_.course = _loc2_;
			var _loc5_:int = param1.getInt(_loc8_);
			_loc8_++;
			_loc6_ = 0;
			while (_loc6_ < _loc5_)
			{
				_loc3_ = _loc4_.getComponent(param1.getInt(_loc8_));
				_loc3_.id = param1.getInt(_loc8_ + 1);
				_loc3_.hp = param1.getInt(_loc8_ + 2);
				_loc3_.shieldHp = param1.getInt(_loc8_ + 3);
				_loc3_.invulnerable = param1.getBoolean(_loc8_ + 4);
				_loc3_.active = param1.getBoolean(_loc8_ + 5);
				_loc3_.alive = param1.getBoolean(_loc8_ + 6);
				_loc3_.triggersToActivte = param1.getInt(_loc8_ + 7);
				Console.write("----------- Sync boss part --------------");
				Console.write(_loc3_.name);
				Console.write("sync id: ", _loc3_.syncId);
				Console.write("id: ", _loc3_.id);
				Console.write("hp: ", _loc3_.hp);
				Console.write("shiledHp: ", _loc3_.shieldHp);
				Console.write("invulnerable", _loc3_.invulnerable);
				Console.write("active", _loc3_.active);
				Console.write("alive", _loc3_.alive);
				Console.write("triggersToActivte", _loc3_.triggersToActivte);
				if (!_loc3_.alive)
				{
					_loc3_.destroy();
				}
				_loc3_.nextDistanceCalculation = 0;
				_loc3_.distanceToCamera = 0;
				_loc8_ += 8;
				_loc6_++;
			}
		}
	}
}

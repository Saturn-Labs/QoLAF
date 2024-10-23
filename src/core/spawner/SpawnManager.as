package core.spawner
{
	import core.scene.Game;
	import debug.Console;
	import playerio.Message;
	import qolaf.target.TargetSystem;
	
	public class SpawnManager
	{
		public var spawners:Vector.<Spawner>;
		
		private var g:Game;
		
		private var id:int = 0;
		
		public function SpawnManager(param1:Game)
		{
			super();
			this.g = param1;
			spawners = new Vector.<Spawner>();
		}
		
		public function addMessageHandlers():void
		{
			g.addMessageHandler("spawnerUpdate", onSpawnerUpdate);
		}
		
		public function addEarlyMessageHandlers():void
		{
			g.addMessageHandler("spawnerKilled", killed);
			g.addMessageHandler("spawnerRebuild", rebuild);
		}
		
		public function syncSpawners(param1:Message, param2:int, param3:int):void
		{
			var _loc5_:* = 0;
			var _loc4_:Spawner = null;
			_loc5_ = param2;
			while (_loc5_ < param3)
			{
				_loc4_ = getSpawnerByKey(param1.getString(_loc5_));
				if (_loc4_ == null || _loc4_.isBossUnit)
				{
					Console.write("Spawner is null, something went wrong while syncing.");
				}
				else
				{
					_loc4_.id = param1.getInt(_loc5_ + 1);
					_loc4_.rotationSpeed = param1.getNumber(_loc5_ + 2);
					_loc4_.orbitAngle = param1.getNumber(_loc5_ + 3);
					_loc4_.alive = param1.getBoolean(_loc5_ + 4);
					if (!_loc4_.hidden)
					{
						g.unitManager.add(_loc4_, g.canvasSpawners);
						if (!_loc4_.alive)
						{
							_loc4_.destroy(false);
						}
					}
				}
				_loc5_ += 5;
			}
		}
		
		public function update():void
		{
		}
		
		public function getSpawner(param1:String):Spawner
		{
			var _loc2_:Spawner = null;
			if (param1 == "organic")
			{
				_loc2_ = new OrganicSpawner(g);
			}
			else
			{
				_loc2_ = new Spawner(g);
			}
			spawners.push(_loc2_);
			return _loc2_;
		}
		
		public function removeSpawner(param1:Spawner):void
		{
			spawners.splice(spawners.indexOf(param1), 1);
		}
		
		public function getSpawnerByKey(param1:String):Spawner
		{
			for each (var _loc2_:* in spawners)
			{
				if (_loc2_.key == param1)
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		public function getSpawnerById(param1:int):Spawner
		{
			for each (var _loc2_:* in spawners)
			{
				if (_loc2_.id == param1)
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		public function damaged(param1:Message, pointer:int):void
		{
			var spawnerKey:String = param1.getString(pointer);
			var spawner:Spawner = getSpawnerByKey(spawnerKey);
			if (spawner == null)
			{
				Console.write("No spawner to damage by key: " + spawnerKey);
				return;
			}
			var damage:int = param1.getInt(pointer + 2);
			var sh:int = param1.getInt(pointer + 3);
			var hp:int = param1.getInt(pointer + 4);
			if (param1.getBoolean(pointer + 5))
			{
				spawner.doDOTEffect(param1.getInt(pointer + 6), param1.getString(pointer + 7), param1.getInt(pointer + 8));
			}
			
			// QoLAF
			if (Game.instance.playerManager.me != null && Game.instance.playerManager.me.ship != null && TargetSystem.GetDistance(Game.instance.playerManager.me.ship, spawner) < 600)
				Game.instance.targetSystem.SetCurrentUnit(spawner);
			
			spawner.takeDamage(damage);
			spawner.shieldHp = sh;
			if (spawner.shieldHp == 0)
			{
				if (spawner.shieldRegenCounter > -1000)
				{
					spawner.shieldRegenCounter = -1000;
				}
			}
			spawner.hp = hp;
		}
		
		private function onSpawnerUpdate(param1:Message):void
		{
			var _loc4_:int = 0;
			var _loc3_:String = param1.getString(_loc4_++);
			var _loc2_:Spawner = getSpawnerByKey(_loc3_);
			if (_loc2_ == null)
			{
				Console.write("No spawner to update, key: " + _loc3_);
				return;
			}
			_loc2_.hp = param1.getInt(_loc4_++);
			_loc2_.shieldHp = param1.getInt(_loc4_++);
			if (_loc2_.hp < _loc2_.hpMax || _loc2_.shieldHp < _loc2_.shieldHpMax)
			{
				_loc2_.isInjured = true;
			}
		}
		
		public function killed(param1:Message, param2:int):void
		{
			var _loc4_:String = param1.getString(param2);
			var _loc3_:Spawner = getSpawnerByKey(_loc4_);
			if (_loc3_ == null)
			{
				Console.write("No spawner to kill by key: " + _loc4_);
				return;
			}
			_loc3_.destroy();
		}
		
		public function rebuild(param1:Message):void
		{
			var _loc3_:String = param1.getString(0);
			var _loc2_:Spawner = getSpawnerByKey(_loc3_);
			if (_loc2_ == null)
			{
				Console.write("No spawner to rebuild by key: " + _loc3_);
				return;
			}
			_loc2_.rebuild();
		}
		
		public function dispose():void
		{
			for each (var _loc1_:* in spawners)
			{
				_loc1_.reset();
				_loc1_.removeFromCanvas();
			}
			spawners = null;
		}
	}
}

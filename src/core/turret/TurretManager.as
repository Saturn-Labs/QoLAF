package core.turret
{
	import core.scene.Game;
	import debug.Console;
	import playerio.Message;
	
	public class TurretManager
	{
		public var turrets:Vector.<Turret>;
		
		private var g:Game;
		
		public function TurretManager(param1:Game)
		{
			super();
			this.g = param1;
			turrets = new Vector.<Turret>();
		}
		
		public function addMessageHandlers():void
		{
			g.addMessageHandler("turretChangedTarget", turretChangedTarget);
			g.addMessageHandler("turretUpdate", onTurretUpdate);
		}
		
		public function addEarlyMessageHandlers():void
		{
			g.addMessageHandler("turretKilled", killed);
		}
		
		public function syncTurret(param1:Message, param2:int, param3:int):void
		{
			var _loc5_:* = 0;
			var _loc4_:Turret = null;
			_loc5_ = param2;
			while (_loc5_ < param3)
			{
				_loc4_ = getTurretsByParentAndSyncId(param1.getInt(_loc5_), param1.getInt(_loc5_ + 1));
				if (_loc4_ == null || _loc4_.isBossUnit)
				{
					Console.write("Turret is null, failed sync.");
				}
				else
				{
					_loc4_.id = param1.getInt(_loc5_ + 2);
					_loc4_.alive = param1.getBoolean(_loc5_ + 3);
					g.unitManager.add(_loc4_, g.canvasTurrets, false);
				}
				_loc5_ += 5;
			}
		}
		
		public function syncTurretTarget(param1:Message, param2:int, param3:int):void
		{
			var _loc5_:* = 0;
			var _loc4_:Turret = null;
			_loc5_ = param2;
			while (_loc5_ < param3 - 3)
			{
				_loc4_ = getTurretById(param1.getInt(_loc5_));
				if (_loc4_ != null)
				{
					_loc4_.target = g.shipManager.getShipFromId(param1.getInt(_loc5_ + 1));
					_loc4_.rotation = param1.getNumber(_loc5_ + 2);
					if (_loc4_.weapon != null)
					{
						_loc4_.weapon.fire = param1.getBoolean(_loc5_ + 3);
					}
				}
				else
				{
					Console.write("ERROR: Missing turret with id: " + param1.getInt(_loc5_));
				}
				_loc5_ += 4;
			}
		}
		
		public function turretChangedTarget(param1:Message):void
		{
			var _loc3_:int = 0;
			var _loc2_:Turret = null;
			_loc3_ = 0;
			while (_loc3_ < param1.length)
			{
				_loc2_ = getTurretById(param1.getInt(_loc3_));
				if (_loc2_ != null)
				{
					_loc2_.target = g.shipManager.getShipFromId(param1.getInt(_loc3_ + 1));
				}
				else
				{
					Console.write("Error bad turret id: " + param1.getInt(_loc3_ + 1));
				}
				_loc3_ += 2;
			}
		}
		
		private function onTurretUpdate(param1:Message):void
		{
			var _loc3_:int = 0;
			var _loc2_:Turret = getTurretById(param1.getInt(_loc3_++));
			if (_loc2_ == null)
			{
				return;
			}
			_loc2_.hp = param1.getInt(_loc3_++);
			_loc2_.shieldHp = param1.getInt(_loc3_++);
			if (_loc2_.hp < _loc2_.hpMax || _loc2_.shieldHp < _loc2_.shieldHpMax)
			{
				_loc2_.isInjured = true;
			}
			_loc2_.target = g.shipManager.getShipFromId(param1.getInt(_loc3_++));
			_loc2_.rotation = param1.getNumber(_loc3_++);
			if (_loc2_.weapon != null)
			{
				_loc2_.weapon.fire = param1.getBoolean(_loc3_++);
			}
		}
		
		public function update():void
		{
		}
		
		public function turretFire(param1:Message, param2:int = 0):void
		{
			var _loc4_:int = 0;
			var _loc3_:int = param1.getInt(param2);
			var _loc6_:Boolean = param1.getBoolean(param2 + 1);
			var _loc5_:Turret = g.turretManager.getTurretById(_loc3_);
			if (_loc5_ != null && _loc5_.weapon != null)
			{
				_loc5_.weapon.fire = _loc6_;
				if (param1.length > 2)
				{
					_loc4_ = param1.getInt(param2 + 2);
					_loc5_.weapon.target = g.shipManager.getShipFromId(_loc4_);
				}
				return;
			}
		}
		
		public function getTurret():Turret
		{
			var _loc1_:Turret = new Turret(g);
			_loc1_.reset();
			turrets.push(_loc1_);
			return _loc1_;
		}
		
		public function removeTurret(param1:Turret):void
		{
			turrets.splice(turrets.indexOf(param1), 1);
		}
		
		public function getTurretById(param1:int):Turret
		{
			for each (var _loc2_:* in turrets)
			{
				if (_loc2_.id == param1)
				{
					return _loc2_;
				}
			}
			Console.write("Error: missing turret");
			return null;
		}
		
		public function getTurretsByParentAndSyncId(param1:int, param2:int):Turret
		{
			for each (var _loc3_:* in turrets)
			{
				if (_loc3_.parentObj != null && _loc3_.parentObj.id == param1 && _loc3_.syncId == param2)
				{
					return _loc3_;
				}
			}
			Console.write("Error: missing turret in sync");
			return null;
		}
		
		public function damaged(param1:Message, param2:int):void
		{
			var _loc3_:int = param1.getInt(param2 + 1);
			var _loc6_:Turret = getTurretById(_loc3_);
			if (_loc6_ == null)
			{
				Console.write("No turret to damage by id: " + _loc3_);
				return;
			}
			var _loc4_:int = param1.getInt(param2 + 2);
			var _loc7_:int = param1.getInt(param2 + 3);
			if (_loc6_.shieldHp == 0)
			{
				if (_loc6_.shieldRegenCounter > -1000)
				{
					_loc6_.shieldRegenCounter = -1000;
				}
			}
			var _loc5_:int = param1.getInt(param2 + 4);
			if (param1.getBoolean(param2 + 5))
			{
				_loc6_.doDOTEffect(param1.getInt(param2 + 6), param1.getString(param2 + 7), param1.getInt(param2 + 8));
			}
			if (_loc6_.isAddedToCanvas)
			{
				_loc6_.takeDamage(_loc4_);
			}
			_loc6_.shieldHp = _loc7_;
			_loc6_.hp = _loc5_;
		}
		
		public function killed(param1:Message, param2:int):void
		{
			var _loc3_:int = param1.getInt(param2);
			var _loc4_:Turret = getTurretById(_loc3_);
			if (_loc4_ == null)
			{
				Console.write("No turret to kill by id: " + _loc3_);
				return;
			}
			_loc4_.destroy();
		}
	}
}

package core.turret {
	import core.scene.Game;
	import debug.Console;
	import playerio.Message;
	
	public class TurretManager {
		public var turrets:Vector.<Turret>;
		
		private var g:Game;
		
		public function TurretManager(g:Game) {
			super();
			this.g = g;
			turrets = new Vector.<Turret>();
		}
		
		public function addMessageHandlers() : void {
			g.addMessageHandler("turretChangedTarget",turretChangedTarget);
			g.addMessageHandler("turretUpdate",onTurretUpdate);
		}
		
		public function addEarlyMessageHandlers() : void {
			g.addMessageHandler("turretKilled",killed);
		}
		
		public function syncTurret(m:Message, index:int, stopIndex:int) : void {
			var _local5:* = 0;
			var _local4:Turret = null;
			_local5 = index;
			while(_local5 < stopIndex) {
				_local4 = getTurretsByParentAndSyncId(m.getInt(_local5),m.getInt(_local5 + 1));
				if(_local4 == null || _local4.isBossUnit) {
					Console.write("Turret is null, failed sync.");
				} else {
					_local4.id = m.getInt(_local5 + 2);
					_local4.alive = m.getBoolean(_local5 + 3);
					g.unitManager.add(_local4,g.canvasTurrets,false);
				}
				_local5 += 5;
			}
		}
		
		public function syncTurretTarget(m:Message, startIndex:int, endIndex:int) : void {
			var _local5:* = 0;
			var _local4:Turret = null;
			_local5 = startIndex;
			while(_local5 < endIndex - 3) {
				_local4 = getTurretById(m.getInt(_local5));
				if(_local4 != null) {
					_local4.target = g.shipManager.getShipFromId(m.getInt(_local5 + 1));
					_local4.rotation = m.getNumber(_local5 + 2);
					if(_local4.weapon != null) {
						_local4.weapon.fire = m.getBoolean(_local5 + 3);
					}
				} else {
					Console.write("ERROR: Missing turret with id: " + m.getInt(_local5));
				}
				_local5 += 4;
			}
		}
		
		public function turretChangedTarget(m:Message) : void {
			var _local3:int = 0;
			var _local2:Turret = null;
			_local3 = 0;
			while(_local3 < m.length) {
				_local2 = getTurretById(m.getInt(_local3));
				if(_local2 != null) {
					_local2.target = g.shipManager.getShipFromId(m.getInt(_local3 + 1));
				} else {
					Console.write("Error bad turret id: " + m.getInt(_local3 + 1));
				}
				_local3 += 2;
			}
		}
		
		private function onTurretUpdate(m:Message) : void {
			var _local3:int = 0;
			var _local2:Turret = getTurretById(m.getInt(_local3++));
			if(_local2 == null) {
				return;
			}
			_local2.hp = m.getInt(_local3++);
			_local2.shieldHp = m.getInt(_local3++);
			if(_local2.hp < _local2.hpMax || _local2.shieldHp < _local2.shieldHpMax) {
				_local2.isInjured = true;
			}
			_local2.target = g.shipManager.getShipFromId(m.getInt(_local3++));
			_local2.rotation = m.getNumber(_local3++);
			if(_local2.weapon != null) {
				_local2.weapon.fire = m.getBoolean(_local3++);
			}
		}
		
		public function update() : void {
		}
		
		public function turretFire(m:Message, i:int = 0) : void {
			var _local3:int = 0;
			var _local6:int = m.getInt(i);
			var _local5:Boolean = m.getBoolean(i + 1);
			var _local4:Turret = g.turretManager.getTurretById(_local6);
			if(_local4 != null && _local4.weapon != null) {
				_local4.weapon.fire = _local5;
				if(m.length > 2) {
					_local3 = m.getInt(i + 2);
					_local4.weapon.target = g.shipManager.getShipFromId(_local3);
				}
				return;
			}
		}
		
		public function getTurret() : Turret {
			var _local1:Turret = new Turret(g);
			_local1.reset();
			turrets.push(_local1);
			return _local1;
		}
		
		public function removeTurret(t:Turret) : void {
			turrets.splice(turrets.indexOf(t),1);
		}
		
		public function getTurretById(id:int) : Turret {
			for each(var _local2 in turrets) {
				if(_local2.id == id) {
					return _local2;
				}
			}
			Console.write("Error: missing turret");
			return null;
		}
		
		public function getTurretsByParentAndSyncId(id:int, syncId:int) : Turret {
			for each(var _local3 in turrets) {
				if(_local3.parentObj != null && _local3.parentObj.id == id && _local3.syncId == syncId) {
					return _local3;
				}
			}
			Console.write("Error: missing turret in sync");
			return null;
		}
		
		public function damaged(m:Message, i:int) : void {
			var _local5:int = m.getInt(i + 1);
			var _local3:Turret = getTurretById(_local5);
			if(_local3 == null) {
				Console.write("No turret to damage by id: " + _local5);
				return;
			}
			var _local7:int = m.getInt(i + 2);
			var _local6:int = m.getInt(i + 3);
			if(_local3.shieldHp == 0) {
				if(_local3.shieldRegenCounter > -1000) {
					_local3.shieldRegenCounter = -1000;
				}
			}
			var _local4:int = m.getInt(i + 4);
			if(m.getBoolean(i + 5)) {
				_local3.doDOTEffect(m.getInt(i + 6),m.getString(i + 7),m.getInt(i + 8));
			}
			if(_local3.isAddedToCanvas) {
				_local3.takeDamage(_local7);
			}
			_local3.shieldHp = _local6;
			_local3.hp = _local4;
		}
		
		public function killed(m:Message, i:int) : void {
			var _local4:int = m.getInt(i);
			var _local3:Turret = getTurretById(_local4);
			if(_local3 == null) {
				Console.write("No turret to kill by id: " + _local4);
				return;
			}
			_local3.destroy();
		}
	}
}


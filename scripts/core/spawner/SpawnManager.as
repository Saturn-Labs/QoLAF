package core.spawner {
	import core.scene.Game;
	import debug.Console;
	import playerio.Message;
	
	public class SpawnManager {
		public var spawners:Vector.<Spawner>;
		
		private var g:Game;
		
		private var id:int = 0;
		
		public function SpawnManager(g:Game) {
			super();
			this.g = g;
			spawners = new Vector.<Spawner>();
		}
		
		public function addMessageHandlers() : void {
			g.addMessageHandler("spawnerUpdate",onSpawnerUpdate);
		}
		
		public function addEarlyMessageHandlers() : void {
			g.addMessageHandler("spawnerKilled",killed);
			g.addMessageHandler("spawnerRebuild",rebuild);
		}
		
		public function syncSpawners(m:Message, index:int, stopIndex:int) : void {
			var _local5:* = 0;
			var _local4:Spawner = null;
			_local5 = index;
			while(_local5 < stopIndex) {
				_local4 = getSpawnerByKey(m.getString(_local5));
				if(_local4 == null || _local4.isBossUnit) {
					Console.write("Spawner is null, something went wrong while syncing.");
				} else {
					_local4.id = m.getInt(_local5 + 1);
					_local4.rotationSpeed = m.getNumber(_local5 + 2);
					_local4.orbitAngle = m.getNumber(_local5 + 3);
					_local4.alive = m.getBoolean(_local5 + 4);
					if(!_local4.hidden) {
						g.unitManager.add(_local4,g.canvasSpawners);
						if(!_local4.alive) {
							_local4.destroy(false);
						}
					}
				}
				_local5 += 5;
			}
		}
		
		public function update() : void {
		}
		
		public function getSpawner(type:String) : Spawner {
			var _local2:Spawner = null;
			if(type == "organic") {
				_local2 = new OrganicSpawner(g);
			} else {
				_local2 = new Spawner(g);
			}
			spawners.push(_local2);
			return _local2;
		}
		
		public function removeSpawner(s:Spawner) : void {
			spawners.splice(spawners.indexOf(s),1);
		}
		
		public function getSpawnerByKey(key:String) : Spawner {
			for each(var _local2 in spawners) {
				if(_local2.key == key) {
					return _local2;
				}
			}
			return null;
		}
		
		public function getSpawnerById(id:int) : Spawner {
			for each(var _local2 in spawners) {
				if(_local2.id == id) {
					return _local2;
				}
			}
			return null;
		}
		
		public function damaged(m:Message, i:int) : void {
			var _local6:String = m.getString(i);
			var _local3:Spawner = getSpawnerByKey(_local6);
			if(_local3 == null) {
				Console.write("No spawner to damage by key: " + _local6);
				return;
			}
			var _local7:int = m.getInt(i + 2);
			var _local5:int = m.getInt(i + 3);
			var _local4:int = m.getInt(i + 4);
			if(m.getBoolean(i + 5)) {
				_local3.doDOTEffect(m.getInt(i + 6),m.getString(i + 7),m.getInt(i + 8));
			}
			_local3.takeDamage(_local7);
			_local3.shieldHp = _local5;
			if(_local3.shieldHp == 0) {
				if(_local3.shieldRegenCounter > -1000) {
					_local3.shieldRegenCounter = -1000;
				}
			}
			_local3.hp = _local4;
		}
		
		private function onSpawnerUpdate(m:Message) : void {
			var _local3:int = 0;
			var _local4:String = m.getString(_local3++);
			var _local2:Spawner = getSpawnerByKey(_local4);
			if(_local2 == null) {
				Console.write("No spawner to update, key: " + _local4);
				return;
			}
			_local2.hp = m.getInt(_local3++);
			_local2.shieldHp = m.getInt(_local3++);
			if(_local2.hp < _local2.hpMax || _local2.shieldHp < _local2.shieldHpMax) {
				_local2.isInjured = true;
			}
		}
		
		public function killed(m:Message, i:int) : void {
			var _local4:String = m.getString(i);
			var _local3:Spawner = getSpawnerByKey(_local4);
			if(_local3 == null) {
				Console.write("No spawner to kill by key: " + _local4);
				return;
			}
			_local3.destroy();
		}
		
		public function rebuild(m:Message) : void {
			var _local3:String = m.getString(0);
			var _local2:Spawner = getSpawnerByKey(_local3);
			if(_local2 == null) {
				Console.write("No spawner to rebuild by key: " + _local3);
				return;
			}
			_local2.rebuild();
		}
		
		public function dispose() : void {
			for each(var _local1 in spawners) {
				_local1.reset();
				_local1.removeFromCanvas();
			}
			spawners = null;
		}
	}
}


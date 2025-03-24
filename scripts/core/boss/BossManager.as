package core.boss {
	import core.scene.Game;
	import core.solarSystem.Body;
	import core.unit.Unit;
	import debug.Console;
	import flash.geom.Point;
	import movement.Heading;
	import playerio.Message;
	import sound.SoundLocator;
	
	public class BossManager {
		private var g:Game;
		
		public var bosses:Vector.<Boss>;
		
		public var callbackMessages:Vector.<Message>;
		
		public var callbackFunctions:Vector.<Function>;
		
		public function BossManager(g:Game) {
			super();
			this.g = g;
			bosses = new Vector.<Boss>();
			callbackMessages = new Vector.<Message>();
			callbackFunctions = new Vector.<Function>();
		}
		
		public function update() : void {
			var _local1:Boss = null;
			var _local2:int = 0;
			_local2 = bosses.length - 1;
			while(_local2 >= 0) {
				_local1 = bosses[_local2];
				_local1.update();
				_local2--;
			}
		}
		
		public function forceUpdate() : void {
			var _local1:Boss = null;
			var _local2:int = 0;
			_local2 = bosses.length - 1;
			while(_local2 >= 0) {
				_local1 = bosses[_local2];
				_local1.nextDistanceCalculation = 0;
				_local2--;
			}
		}
		
		public function addMessageHandlers() : void {
			g.addMessageHandler("aiBossTargetChanged",aiBossTargetChanged);
			g.addMessageHandler("aiBossCourse",aiBossCourse);
			g.addMessageHandler("aiBossFireAtBody",aiBossFireAtBody);
			g.addMessageHandler("initBoss",initSyncBoss);
			g.addMessageHandler("bossKilled",bossKilled);
			g.addMessageHandler("spawnBoss",spawnBoss);
		}
		
		public function initBosses(m:Message, i:int, endIndex:int) : void {
			var _local4:String = null;
			var _local9:String = null;
			var _local8:* = null;
			var _local6:Number = NaN;
			var _local7:Number = NaN;
			var _local5:int = (endIndex - 2) / 4;
			if(_local5 == 0) {
				return;
			}
			i;
			while(i < endIndex) {
				_local4 = m.getString(i);
				_local9 = m.getString(i + 1);
				_local6 = m.getNumber(i + 2);
				_local7 = m.getNumber(i + 3);
				createBoss(_local4,_local9,_local6,_local7);
				i += 4;
			}
		}
		
		public function spawnBoss(m:Message) : void {
			var _local2:String = null;
			var _local6:String = null;
			var _local4:int = 0;
			var _local3:Number = NaN;
			var _local5:Number = NaN;
			_local4 = 0;
			while(_local4 < m.length - 1) {
				_local2 = m.getString(_local4);
				_local6 = m.getString(_local4 + 1);
				_local3 = m.getNumber(_local4 + 2);
				_local5 = m.getNumber(_local4 + 3);
				createBoss(_local2,_local6,_local3,_local5);
				_local4 += 4;
			}
		}
		
		public function createBoss(boss:String, key:String, x:Number, y:Number) : void {
			var _local6:Body = g.bodyManager.getBodyByKey(key);
			if(_local6 == null) {
				return;
			}
			var _local5:Boss = BossFactory.createBoss(boss,_local6,_local6.wpArray,key,g);
			_local5.course.pos.x = x;
			_local5.course.pos.y = y;
			_local5.x = x;
			_local5.y = y;
			g.bossManager.add(_local5);
			if(g.gameStartedTime != 0 && g.time - g.gameStartedTime > 10000 && g.me.level > 1) {
				g.textManager.createBossSpawnedText(_local5.name + " has spawned");
				SoundLocator.getService().play("q0CoOEzFYk2yFBRYQtfYvw");
			}
		}
		
		private function bossKilled(m:Message) : void {
			var _local2:Boss = getBossFromKey(m.getString(0));
			if(_local2 != null) {
				killBoss(_local2);
			}
		}
		
		private function killBoss(b:Boss) : void {
			b.destroy();
			g.hud.radar.remove(b);
			b.removeFromCanvas();
			bosses.splice(bosses.indexOf(b),1);
			Console.write("BOSS killed!");
		}
		
		public function aiTeleport(m:Message, i:int) : void {
			var _local3:Boss = g.bossManager.getBossFromKey(m.getString(i));
			if(_local3 == null) {
				return;
			}
			_local3.teleportExitPoint = new Point(m.getNumber(i + 1),m.getNumber(i + 2));
			_local3.teleportExitTime = m.getNumber(i + 3);
			_local3.startTeleportEffect();
		}
		
		public function aiBossFireAtBody(m:Message) : void {
			var _local2:Boss = g.bossManager.getBossFromKey(m.getString(0));
			if(_local2 == null) {
				callbackMessages.push(m);
				callbackFunctions.push(aiBossFireAtBody);
				return;
			}
			_local2.bodyTarget = g.bodyManager.getBodyByKey(m.getString(1));
			_local2.bodyDestroyStart = m.getNumber(2);
			_local2.bodyDestroyEnd = m.getNumber(3);
		}
		
		public function aiBossCourse(m:Message) : void {
			var _local6:int = 0;
			var _local2:Boss = g.bossManager.getBossFromKey(m.getString(0));
			if(_local2 == null) {
				callbackMessages.push(m);
				callbackFunctions.push(aiBossCourse);
				return;
			}
			var _local5:Heading = new Heading();
			var _local3:int = m.getInt(1);
			if(_local3 != 0 && (_local2.currentWaypoint == null || _local3 != _local2.currentWaypoint.id)) {
				_local6 = 0;
				while(_local6 < _local2.waypoints.length) {
					if(_local3 == _local2.waypoints[_local6].id) {
						_local2.currentWaypoint = _local2.waypoints[_local6];
						break;
					}
					_local6++;
				}
			}
			var _local4:int = m.getInt(2);
			var _local7:Unit = g.unitManager.getTarget(_local4);
			_local2.target = _local7;
			_local5.parseMessage(m,3);
			_local2.setConvergeTarget(_local5);
		}
		
		public function aiBossTargetChanged(m:Message) : void {
			var _local2:Boss = g.bossManager.getBossFromKey(m.getString(0));
			var _local3:Unit = g.shipManager.getShipFromId(m.getInt(1));
			if(_local2 == null) {
				callbackMessages.push(m);
				callbackFunctions.push(aiBossTargetChanged);
				return;
			}
			_local2.target = _local3;
		}
		
		public function getBossFromKey(key:String) : Boss {
			for each(var _local2 in bosses) {
				if(_local2.key == key) {
					return _local2;
				}
			}
			return null;
		}
		
		public function getComponentById(id:int) : Unit {
			for each(var _local2 in bosses) {
				for each(var _local3 in _local2.allComponents) {
					if(_local3.syncId == id) {
						return _local3;
					}
				}
			}
			return null;
		}
		
		public function add(b:Boss) : void {
			var _local3:int = 0;
			var _local4:Message = null;
			var _local2:Function = null;
			bosses.push(b);
			g.hud.radar.add(b);
			b.addToCanvas();
			_local3 = callbackMessages.length - 1;
			while(_local3 > -1) {
				if(callbackFunctions[_local3] == initSyncBoss) {
					callbackFunctions.shift();
					_local4 = callbackMessages.shift();
					initSyncBoss(_local4);
				}
				_local3--;
			}
			_local3 = callbackMessages.length - 1;
			while(_local3 > -1) {
				_local4 = callbackMessages.shift();
				_local2 = callbackFunctions.shift();
				_local2(_local4);
				_local3--;
			}
		}
		
		public function killed(m:Message, i:int) : void {
			var _local4:int = m.getInt(i);
			var _local3:Unit = getComponentById(_local4);
			if(_local3 == null) {
				Console.write("No bc to kill by id: " + _local4);
				return;
			}
			_local3.destroy();
		}
		
		public function damaged(m:Message, i:int) : void {
			var _local4:int = m.getInt(i + 1);
			var _local3:Unit = getComponentById(_local4);
			if(_local3 == null) {
				return;
			}
			var _local5:int = m.getInt(i + 2);
			_local3.takeDamage(_local5);
			_local3.shieldHp = m.getInt(i + 3);
			_local3.hp = m.getInt(i + 4);
			if(m.getBoolean(i + 5)) {
				_local3.doDOTEffect(m.getInt(i + 6),m.getString(i + 7));
			}
		}
		
		public function initSyncBoss(m:Message) : void {
			var _local7:int = 0;
			var _local4:Unit = null;
			Console.write("SYNC BOSS!");
			var _local5:int = 0;
			var _local2:Boss = getBossFromKey(m.getString(_local5));
			if(_local2 == null) {
				callbackMessages.push(m);
				callbackFunctions.push(initSyncBoss);
				return;
			}
			_local2.awaitingActivation = false;
			_local2.target = g.unitManager.getTarget(m.getInt(_local5 + 1));
			_local2.alive = m.getBoolean(_local5 + 2);
			var _local3:int = m.getInt(_local5 + 3);
			_local7 = 0;
			while(_local7 < _local2.waypoints.length) {
				if(_local2.waypoints[_local7].id == _local3) {
					_local2.currentWaypoint = _local2.waypoints[_local7];
					break;
				}
				_local7++;
			}
			_local2.rotationForced = m.getBoolean(_local5 + 4);
			_local2.rotationSpeed = m.getNumber(_local5 + 5);
			var _local6:Heading = new Heading();
			_local5 = _local6.parseMessage(m,_local5 + 6);
			_local2.course = _local6;
			var _local8:int = m.getInt(_local5);
			_local5++;
			_local7 = 0;
			while(_local7 < _local8) {
				_local4 = _local2.getComponent(m.getInt(_local5));
				_local4.id = m.getInt(_local5 + 1);
				_local4.hp = m.getInt(_local5 + 2);
				_local4.shieldHp = m.getInt(_local5 + 3);
				_local4.invulnerable = m.getBoolean(_local5 + 4);
				_local4.active = m.getBoolean(_local5 + 5);
				_local4.alive = m.getBoolean(_local5 + 6);
				_local4.triggersToActivte = m.getInt(_local5 + 7);
				Console.write("----------- Sync boss part --------------");
				Console.write(_local4.name);
				Console.write("sync id: ",_local4.syncId);
				Console.write("id: ",_local4.id);
				Console.write("hp: ",_local4.hp);
				Console.write("shiledHp: ",_local4.shieldHp);
				Console.write("invulnerable",_local4.invulnerable);
				Console.write("active",_local4.active);
				Console.write("alive",_local4.alive);
				Console.write("triggersToActivte",_local4.triggersToActivte);
				if(!_local4.alive) {
					_local4.destroy();
				}
				_local4.nextDistanceCalculation = 0;
				_local4.distanceToCamera = 0;
				_local5 += 8;
				_local7++;
			}
		}
	}
}


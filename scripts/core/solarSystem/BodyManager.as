package core.solarSystem {
	import core.scene.Game;
	import debug.Console;
	import flash.utils.Dictionary;
	import playerio.Message;
	
	public class BodyManager {
		private static const MAX_ORBIT_DIFF:Number = 10;
		
		public var bodiesById:Dictionary;
		
		public var bodies:Vector.<Body>;
		
		public var roots:Vector.<Body>;
		
		public var visibleBodies:Vector.<Body>;
		
		private var startTime:Number;
		
		private var bodyId:int = 0;
		
		private var g:Game;
		
		public function BodyManager(m:Game) {
			super();
			this.g = m;
			bodies = new Vector.<Body>();
			roots = new Vector.<Body>();
			bodiesById = new Dictionary();
			visibleBodies = new Vector.<Body>();
		}
		
		public function addMessageHandlers() : void {
		}
		
		public function update() : void {
			var _local3:Body = null;
			var _local1:int = 0;
			if(g.me == null || g.me.ship == null) {
				return;
			}
			var _local2:int = int(roots.length);
			_local1 = _local2 - 1;
			while(_local1 > -1) {
				_local3 = roots[_local1];
				_local3.updateBody(startTime);
				_local1--;
			}
		}
		
		public function forceUpdate() : void {
			var _local3:Body = null;
			var _local1:int = 0;
			var _local2:int = int(bodies.length);
			_local1 = _local2 - 1;
			while(_local1 > -1) {
				_local3 = bodies[_local1];
				_local3.nextDistanceCalculation = 0;
				_local1--;
			}
		}
		
		public function getBodyByKey(key:String) : Body {
			for each(var _local2 in bodies) {
				if(_local2.key == key) {
					return _local2;
				}
			}
			return null;
		}
		
		public function getBody() : Body {
			var _local1:Body = new Body(g);
			bodies.push(_local1);
			return _local1;
		}
		
		public function getRoot() : Body {
			var _local1:Body = getBody();
			roots.push(_local1);
			return _local1;
		}
		
		public function syncBodies(m:Message, index:int, endIndex:int) : void {
			var _local5:* = 0;
			var _local4:Body = null;
			_local5 = index;
			while(_local5 < endIndex) {
				_local4 = getBodyByKey(m.getString(_local5));
				if(_local4 == null) {
					Console.write("Body is null in sync.");
				}
				_local5 += 2;
			}
		}
		
		public function initSolarSystem(m:Message) : void {
			var _local7:* = 0;
			var _local8:String = m.getString(0);
			startTime = m.getNumber(2);
			g.hud.uberStats.uberRank = m.getNumber(3);
			g.hud.uberStats.uberLives = m.getNumber(4);
			BodyFactory.createSolarSystem(g,_local8);
			g.solarSystem.pvpAboveCap = m.getBoolean(1);
			_local7 = 5;
			var _local4:int = m.getInt(_local7++);
			var _local6:int = _local4 * 5 + _local7;
			while(_local7 < _local6) {
				g.deathLineManager.addLine(m.getInt(_local7),m.getInt(_local7 + 1),m.getInt(_local7 + 2),m.getInt(_local7 + 3),m.getString(_local7 + 4));
				_local7 += 5;
			}
			var _local2:int = m.getInt(_local7++);
			_local6 = _local2 * 4 + _local7;
			g.bossManager.initBosses(m,_local7,_local6);
			_local7 = _local6;
			var _local5:int = m.getInt(_local7++);
			_local6 = _local5 * 5 + _local7;
			g.spawnManager.syncSpawners(m,_local7,_local6);
			_local7 = _local6;
			var _local3:int = m.getInt(_local7++);
			_local6 = _local3 * 5 + _local7;
			g.turretManager.syncTurret(m,_local7,_local6);
			_local7 = _local6;
			var _local9:int = m.getInt(_local7++);
			_local6 = _local9 * 2 + _local7;
			g.bodyManager.syncBodies(m,_local7,_local6);
			_local7 = _local6;
		}
		
		public function dispose() : void {
			bodiesById = null;
			for each(var _local1 in bodies) {
				_local1.reset();
			}
			bodies = null;
		}
	}
}


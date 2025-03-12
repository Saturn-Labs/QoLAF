package core.solarSystem
{
	import core.scene.Game;
	import debug.Console;
	import flash.utils.Dictionary;
	import playerio.Message;
	
	public class BodyManager
	{
		private static const MAX_ORBIT_DIFF:Number = 10;
		public var bodiesById:Dictionary;
		
		public var bodies:Vector.<Body>;
		
		public var roots:Vector.<Body>;
		
		public var visibleBodies:Vector.<Body>;
		
		private var startTime:Number;
		
		private var bodyId:int = 0;
		private var g:Game;
		
		public function BodyManager(param1:Game)
		{
			super();
			this.g = param1;
			bodies = new Vector.<Body>();
			roots = new Vector.<Body>();
			bodiesById = new Dictionary();
			visibleBodies = new Vector.<Body>();
		}
		
		public function addMessageHandlers():void
		{
		}
		
		public function update():void
		{
			var _loc2_:Body = null;
			var _loc3_:int = 0;
			if (g.me == null || g.me.ship == null)
			{
				return;
			}
			var _loc1_:int = int(roots.length);
			_loc3_ = _loc1_ - 1;
			while (_loc3_ > -1)
			{
				_loc2_ = roots[_loc3_];
				_loc2_.updateBody(startTime);
				_loc3_--;
			}
		}
		
		public function forceUpdate():void
		{
			var _loc2_:Body = null;
			var _loc3_:int = 0;
			var _loc1_:int = int(bodies.length);
			_loc3_ = _loc1_ - 1;
			while (_loc3_ > -1)
			{
				_loc2_ = bodies[_loc3_];
				_loc2_.nextDistanceCalculation = 0;
				_loc3_--;
			}
		}
		
		public function getBodyByKey(param1:String):Body
		{
			for each (var _loc2_:* in bodies)
			{
				if (_loc2_.key == param1)
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		public function getBody():Body
		{
			var _loc1_:Body = new Body(g);
			bodies.push(_loc1_);
			return _loc1_;
		}
		
		public function getRoot():Body
		{
			var _loc1_:Body = getBody();
			roots.push(_loc1_);
			return _loc1_;
		}
		
		public function syncBodies(param1:Message, param2:int, param3:int):void
		{
			var _loc5_:* = 0;
			var _loc4_:Body = null;
			_loc5_ = param2;
			while (_loc5_ < param3)
			{
				_loc4_ = getBodyByKey(param1.getString(_loc5_));
				if (_loc4_ == null)
				{
					Console.write("Body is null in sync.");
				}
				_loc5_ += 2;
			}
		}
		
		public function initSolarSystem(param1:Message):void
		{
			var _loc9_:* = 0;
			var _loc8_:String = param1.getString(0);
			startTime = param1.getNumber(2);
			g.hud.uberStats.uberRank = param1.getNumber(3);
			g.hud.uberStats.uberLives = param1.getNumber(4);
			BodyFactory.createSolarSystem(g, _loc8_);
			g.solarSystem.pvpAboveCap = param1.getBoolean(1);
			_loc9_ = 5;
			var _loc5_:int = param1.getInt(_loc9_++);
			var _loc6_:int = _loc5_ * 5 + _loc9_;
			while (_loc9_ < _loc6_)
			{
				g.deathLineManager.addLine(param1.getInt(_loc9_), param1.getInt(_loc9_ + 1), param1.getInt(_loc9_ + 2), param1.getInt(_loc9_ + 3), param1.getString(_loc9_ + 4));
				_loc9_ += 5;
			}
			var _loc4_:int = param1.getInt(_loc9_++);
			_loc6_ = _loc4_ * 4 + _loc9_;
			g.bossManager.initBosses(param1, _loc9_, _loc6_);
			_loc9_ = _loc6_;
			var _loc7_:int = param1.getInt(_loc9_++);
			_loc6_ = _loc7_ * 5 + _loc9_;
			g.spawnManager.syncSpawners(param1, _loc9_, _loc6_);
			_loc9_ = _loc6_;
			var _loc2_:int = param1.getInt(_loc9_++);
			_loc6_ = _loc2_ * 5 + _loc9_;
			g.turretManager.syncTurret(param1, _loc9_, _loc6_);
			_loc9_ = _loc6_;
			var _loc3_:int = param1.getInt(_loc9_++);
			_loc6_ = _loc3_ * 2 + _loc9_;
			g.bodyManager.syncBodies(param1, _loc9_, _loc6_);
			_loc9_ = _loc6_;
		}
		
		public function dispose():void
		{
			bodiesById = null;
			for each (var _loc1_:* in bodies)
			{
				_loc1_.reset();
			}
			bodies = null;
		}
	}
}

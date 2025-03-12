package core.ship
{
	import core.particle.EmitterFactory;
	import core.player.Player;
	import core.scene.Game;
	import core.states.AIStates.AIChase;
	import core.states.AIStates.AIExit;
	import core.states.AIStates.AIFlee;
	import core.states.AIStates.AIFollow;
	import core.states.AIStates.AIIdle;
	import core.states.AIStates.AIKamikaze;
	import core.states.AIStates.AIMelee;
	import core.states.AIStates.AIObserve;
	import core.states.AIStates.AIOrbit;
	import core.states.AIStates.AIResurect;
	import core.states.AIStates.AIReturnOrbit;
	import core.states.AIStates.AITeleport;
	import core.states.AIStates.AITeleportExit;
	import core.sync.Converger;
	import core.unit.Unit;
	import core.weapon.Weapon;
	import debug.Console;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import movement.Heading;
	import playerio.Message;
	
	public class ShipSync
	{
		private var g:Game;
		
		public function ShipSync(param1:Game)
		{
			super();
			this.g = param1;
		}
		
		public function addMessageHandlers():void
		{
			g.addMessageHandler("aiCourse", aiCourse);
			g.addMessageHandler("mirrorCourse", mirrorCourse);
			g.addMessageHandler("AIStickyStart", aiStickyStart);
			g.addMessageHandler("AIStickyEnd", aiStickyEnd);
		}
		
		public function playerCourse(param1:Message, param2:int = 0):void
		{
			var _loc5_:Dictionary = g.playerManager.playersById;
			var _loc4_:String = param1.getString(param2);
			var _loc9_:Heading = new Heading();
			_loc9_.parseMessage(param1, param2 + 1);
			var _loc6_:Player = _loc5_[_loc4_];
			if (_loc6_ == null || _loc6_.ship == null)
			{
				return;
			}
			var _loc7_:Ship = _loc6_.ship;
			if (_loc7_.getConverger() == null || _loc7_.course == null)
			{
				return;
			}
			var _loc8_:Converger = _loc7_.getConverger();
			var _loc3_:Heading = _loc7_.course;
			if (_loc3_ == null)
			{
				return;
			}
			if (_loc6_.isMe)
			{
				fastforwardMe(_loc7_, _loc9_);
				if (!_loc3_.almostEqual(_loc9_))
				{
					_loc8_.setConvergeTarget(_loc9_);
				}
			}
			else
			{
				_loc3_.accelerate = _loc9_.accelerate;
				_loc3_.rotateLeft = _loc9_.rotateLeft;
				_loc3_.rotateRight = _loc9_.rotateRight;
				_loc8_.setConvergeTarget(_loc9_);
			}
		}
		
		public function playerUsedBoost(param1:Message, param2:int):void
		{
			var _loc5_:Dictionary = g.playerManager.playersById;
			var _loc4_:String = param1.getString(param2);
			var _loc9_:Heading = new Heading();
			_loc9_.parseMessage(param1, param2 + 1);
			var _loc6_:Player = _loc5_[_loc4_];
			if (_loc6_ == null || _loc6_.ship == null)
			{
				return;
			}
			var _loc7_:PlayerShip = _loc6_.ship;
			var _loc8_:Converger = _loc7_.getConverger();
			var _loc3_:Heading = _loc7_.course;
			if (_loc3_ == null || _loc8_ == null)
			{
				return;
			}
			if (_loc6_.isMe)
			{
				fastforwardMe(_loc7_, _loc9_);
				if (!_loc3_.almostEqual(_loc9_))
				{
					_loc8_.setConvergeTarget(_loc9_);
				}
			}
			else
			{
				_loc3_.accelerate = true;
				_loc3_.deaccelerate = false;
				_loc3_.rotateLeft = false;
				_loc3_.rotateRight = false;
				_loc7_.boost();
				_loc8_.setConvergeTarget(_loc9_);
			}
		}
		
		public function aiCourse(param1:Message):void
		{
			var _loc9_:int = 0;
			var _loc11_:int = 0;
			var _loc15_:Heading = null;
			var _loc2_:EnemyShip = null;
			var _loc7_:int = 0;
			var _loc12_:String = null;
			var _loc14_:Unit = null;
			var _loc5_:int = 0;
			var _loc8_:int = 0;
			var _loc3_:String = null;
			var _loc6_:Boolean = false;
			var _loc4_:Unit = null;
			var _loc13_:Dictionary = g.shipManager.enemiesById;
			_loc9_ = 0;
			while (_loc9_ < param1.length)
			{
				_loc11_ = param1.getInt(_loc9_);
				_loc15_ = new Heading();
				_loc15_.parseMessage(param1, _loc9_ + 1);
				_loc2_ = _loc13_[_loc11_];
				if (_loc2_ == null)
				{
					Console.write("Error bad enemy id in course sync: " + _loc11_);
					return;
				}
				if (!_loc2_.aiCloak)
				{
					_loc2_.setConvergeTarget(_loc15_);
				}
				_loc7_ = param1.getInt(_loc9_ + 1 + 10);
				_loc12_ = param1.getString(_loc9_ + 2 + 10);
				_loc14_ = g.unitManager.getTarget(_loc7_);
				_loc2_.target = _loc14_;
				if (!_loc2_.stateMachine.inState(_loc12_))
				{
					switch (_loc6_)
					{
					case "AIChase": 
						_loc2_.stateMachine.changeState(new AIChase(g, _loc2_, _loc14_, _loc15_, 0));
						break;
					case "AIFollow": 
						_loc2_.stateMachine.changeState(new AIFollow(g, _loc2_, _loc14_, _loc15_, 0));
						break;
					case "AIMelee": 
						_loc2_.stateMachine.changeState(new AIMelee(g, _loc2_, _loc14_, _loc15_, 0));
					}
				}
				_loc5_ = param1.getInt(_loc9_ + 3 + 10);
				_loc8_ = 0;
				while (_loc8_ < _loc5_)
				{
					_loc3_ = param1.getString(_loc9_ + _loc8_ * 3 + 4 + 10);
					_loc6_ = param1.getBoolean(_loc9_ + _loc8_ * 3 + 5 + 10);
					_loc4_ = g.unitManager.getTarget(param1.getInt(_loc9_ + _loc8_ * 3 + 6 + 10));
					for each (var _loc10_:* in _loc2_.weapons)
					{
						if (_loc10_.name == _loc3_)
						{
							_loc10_.fire = _loc6_;
							_loc10_.target = _loc4_;
						}
					}
					_loc8_++;
				}
				_loc9_ += _loc5_ * 3;
				_loc9_ = _loc9_ + (4 + 10);
			}
		}
		
		public function mirrorCourse(param1:Message):void
		{
			var _loc2_:Ship = g.playerManager.me.mirror;
			if (_loc2_ == null)
			{
				return;
			}
			var _loc3_:Heading = new Heading();
			_loc3_.parseMessage(param1, 0);
			_loc2_.course = _loc3_;
		}
		
		public function aiStickyStart(param1:Message):void
		{
			var _loc4_:Dictionary = g.shipManager.enemiesById;
			var _loc3_:int = param1.getInt(0);
			var _loc6_:int = param1.getInt(1);
			var _loc2_:EnemyShip = _loc4_[_loc3_];
			var _loc5_:Unit = g.unitManager.getTarget(_loc6_);
			if (_loc2_ == null || !_loc2_.alive || _loc5_ == null)
			{
				return;
			}
			if (_loc2_.meleeChargeEndTime != 0)
			{
				_loc2_.meleeChargeEndTime = 1;
			}
			_loc2_.target = _loc5_;
			_loc2_.meleeOffset = new Point(param1.getNumber(2), param1.getNumber(3));
			_loc2_.meleeTargetStartAngle = param1.getNumber(4);
			_loc2_.meleeTargetAngleDiff = param1.getNumber(5);
			_loc2_.meleeStuck = true;
		}
		
		public function aiStickyEnd(param1:Message):void
		{
			var _loc4_:Dictionary = g.shipManager.enemiesById;
			var _loc3_:int = param1.getInt(0);
			var _loc2_:EnemyShip = _loc4_[_loc3_];
			if (_loc2_ == null || !_loc2_.alive)
			{
				return;
			}
			_loc2_.meleeStuck = false;
		}
		
		public function aiCharge(param1:Message, param2:int):void
		{
			var _loc5_:Dictionary = g.shipManager.enemiesById;
			var _loc4_:int = param1.getInt(param2);
			var _loc3_:EnemyShip = _loc5_[_loc4_];
			if (_loc3_ == null || !_loc3_.alive)
			{
				return;
			}
			_loc3_.meleeChargeEndTime = g.time + _loc3_.meleeChargeDuration;
			_loc3_.oldSpeed = _loc3_.engine.speed;
			_loc3_.oldTurningSpeed = _loc3_.engine.rotationSpeed;
			_loc3_.engine.rotationSpeed = 0;
			_loc3_.course.rotation = param1.getNumber(param2 + 1);
			_loc3_.engine.speed = (1 + _loc3_.meleeChargeSpeedBonus) * _loc3_.engine.speed;
			_loc3_.chargeEffect = EmitterFactory.create("nHVuxJzeyE-JVcn7M-UOwA", g, _loc3_.pos.x, _loc3_.pos.y, _loc3_, true);
		}
		
		public function aiStateChanged(param1:Message, param2:int = 0):void
		{
			var _loc11_:Dictionary = null;
			var _loc9_:int = 0;
			var _loc4_:String = null;
			var _loc7_:int = 0;
			var _loc13_:Heading = null;
			var _loc3_:EnemyShip = null;
			var _loc5_:int = 0;
			var _loc12_:Unit = null;
			var _loc8_:Number = NaN;
			var _loc10_:Number = NaN;
			var _loc6_:Point = null;
			try
			{
				_loc11_ = g.shipManager.enemiesById;
				_loc9_ = param1.getInt(param2);
				_loc4_ = param1.getString(param2 + 1);
				_loc7_ = param1.getInt(param2 + 2);
				_loc13_ = new Heading();
				param2 = _loc13_.parseMessage(param1, param2 + 3);
				_loc3_ = _loc11_[_loc9_];
				if (_loc3_ == null || !_loc3_.alive)
				{
					return;
				}
				switch (_loc4_)
				{
				case "AICloakStarted": 
					_loc3_.cloakStart();
					break;
				case "AICloakEnded": 
					_loc3_.cloakEnd(_loc13_);
					break;
				case "AIHardenShield": 
					_loc3_.hardenShield();
					break;
				case "AIObserve": 
					_loc5_ = param1.getInt(param2);
					_loc12_ = g.unitManager.getTarget(_loc5_);
					if (_loc12_ != null)
					{
						_loc3_.stateMachine.changeState(new AIObserve(g, _loc3_, _loc12_, _loc13_, _loc7_));
					}
					else
					{
						Console.write("No Ai target: " + _loc5_);
					}
					break;
				case "AIChase": 
					_loc5_ = param1.getInt(param2);
					_loc12_ = g.unitManager.getTarget(_loc5_);
					if (_loc12_ != null)
					{
						_loc3_.stateMachine.changeState(new AIChase(g, _loc3_, _loc12_, _loc13_, _loc7_));
					}
					else
					{
						Console.write("No Ai target: " + _loc5_);
					}
					break;
				case "AIResurect": 
					_loc3_.stateMachine.changeState(new AIResurect(g, _loc3_));
				case "AIFollow": 
					_loc5_ = param1.getInt(param2);
					_loc12_ = g.unitManager.getTarget(_loc5_);
					if (_loc12_ != null)
					{
						_loc3_.stateMachine.changeState(new AIFollow(g, _loc3_, _loc12_, _loc13_, _loc7_));
					}
					else
					{
						Console.write("No Ai target: " + _loc5_);
					}
					break;
				case "AIMelee": 
					_loc5_ = param1.getInt(param2);
					_loc12_ = g.unitManager.getTarget(_loc5_);
					if (_loc12_ != null)
					{
						_loc3_.stateMachine.changeState(new AIMelee(g, _loc3_, _loc12_, _loc13_, _loc7_));
					}
					else
					{
						Console.write("No Ai target: " + _loc5_);
					}
					break;
				case "AIOrbit": 
					_loc3_.stateMachine.changeState(new AIOrbit(g, _loc3_));
					break;
				case "AIIdle": 
					_loc3_.stateMachine.changeState(new AIIdle(g, _loc3_, _loc3_.course));
					break;
				case "AIReturn": 
					_loc8_ = param1.getNumber(param2);
					_loc10_ = param1.getNumber(param2 + 1);
					_loc3_.stateMachine.changeState(new AIReturnOrbit(g, _loc3_, _loc8_, _loc10_, _loc13_, _loc7_));
					break;
				case "AIKamikaze": 
					_loc5_ = param1.getInt(param2);
					_loc12_ = g.unitManager.getTarget(_loc5_);
					if (_loc12_ != null)
					{
						_loc3_.stateMachine.changeState(new AIKamikaze(g, _loc3_, _loc12_, _loc13_, _loc7_));
					}
					else
					{
						Console.write("No Ai target: " + _loc5_);
					}
					break;
				case "AIFlee": 
					_loc6_ = new Point(param1.getNumber(param2), param1.getNumber(param2 + 1));
					_loc3_.stateMachine.changeState(new AIFlee(g, _loc3_, _loc6_, _loc13_, _loc7_));
					break;
				case "AITeleport": 
					_loc3_.stateMachine.changeState(new AITeleport(g, _loc3_, _loc3_.target, _loc7_, param1.getNumber(param2), param1.getNumber(param2 + 1)));
					break;
				case "AITeleportExit": 
					_loc3_.stateMachine.changeState(new AITeleportExit(g, _loc3_));
					break;
				case "AIExit": 
					_loc3_.stateMachine.changeState(new AIExit(g, _loc3_));
				}
			}
			catch (e:Error)
			{
				g.client.errorLog.writeError("MSG PACK: " + e.toString(), "State: " + _loc4_, e.getStackTrace(), {});
			}
		}
		
		private function fastforwardMe(param1:Ship, param2:Heading):void
		{
			g.commandManager.clearCommands(param2.time);
			while (param2.time < param1.course.time)
			{
				g.commandManager.runCommand(param2, param2.time);
				param1.convergerUpdateHeading(param2);
			}
		}
		
		private function fastforward(param1:Ship, param2:Heading):void
		{
			var _loc3_:Heading = param1.course;
			while (param2.time < _loc3_.time)
			{
				param1.convergerUpdateHeading(param2);
			}
		}
	}
}

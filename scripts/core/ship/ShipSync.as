package core.ship {
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
	
	public class ShipSync {
		private var g:Game;
		
		public function ShipSync(g:Game) {
			super();
			this.g = g;
		}
		
		public function addMessageHandlers() : void {
			g.addMessageHandler("aiCourse",aiCourse);
			g.addMessageHandler("mirrorCourse",mirrorCourse);
			g.addMessageHandler("AIStickyStart",aiStickyStart);
			g.addMessageHandler("AIStickyEnd",aiStickyEnd);
		}
		
		public function playerCourse(m:Message, i:int = 0) : void {
			var _local8:Dictionary = g.playerManager.playersById;
			var _local7:String = m.getString(i);
			var _local4:Heading = new Heading();
			_local4.parseMessage(m,i + 1);
			var _local9:Player = _local8[_local7];
			if(_local9 == null || _local9.ship == null) {
				return;
			}
			var _local5:Ship = _local9.ship;
			if(_local5.getConverger() == null || _local5.course == null) {
				return;
			}
			var _local3:Converger = _local5.getConverger();
			var _local6:Heading = _local5.course;
			if(_local6 == null) {
				return;
			}
			if(_local9.isMe) {
				fastforwardMe(_local5,_local4);
				if(!_local6.almostEqual(_local4)) {
					_local3.setConvergeTarget(_local4);
				}
			} else {
				_local6.accelerate = _local4.accelerate;
				_local6.rotateLeft = _local4.rotateLeft;
				_local6.rotateRight = _local4.rotateRight;
				_local3.setConvergeTarget(_local4);
			}
		}
		
		public function playerUsedBoost(m:Message, i:int) : void {
			var _local8:Dictionary = g.playerManager.playersById;
			var _local7:String = m.getString(i);
			var _local4:Heading = new Heading();
			_local4.parseMessage(m,i + 1);
			var _local9:Player = _local8[_local7];
			if(_local9 == null || _local9.ship == null) {
				return;
			}
			var _local5:PlayerShip = _local9.ship;
			var _local3:Converger = _local5.getConverger();
			var _local6:Heading = _local5.course;
			if(_local6 == null || _local3 == null) {
				return;
			}
			if(_local9.isMe) {
				fastforwardMe(_local5,_local4);
				if(!_local6.almostEqual(_local4)) {
					_local3.setConvergeTarget(_local4);
				}
			} else {
				_local6.accelerate = true;
				_local6.deaccelerate = false;
				_local6.rotateLeft = false;
				_local6.rotateRight = false;
				_local5.boost();
				_local3.setConvergeTarget(_local4);
			}
		}
		
		public function aiCourse(m:Message) : void {
			var _local6:int = 0;
			var _local13:int = 0;
			var _local4:Heading = null;
			var _local7:EnemyShip = null;
			var _local3:int = 0;
			var _local12:String = null;
			var _local10:Unit = null;
			var _local5:int = 0;
			var _local8:int = 0;
			var _local2:String = null;
			var _local14:Boolean = false;
			var _local9:Unit = null;
			var _local15:Dictionary = g.shipManager.enemiesById;
			_local6 = 0;
			while(_local6 < m.length) {
				_local13 = m.getInt(_local6);
				_local4 = new Heading();
				_local4.parseMessage(m,_local6 + 1);
				_local7 = _local15[_local13];
				if(_local7 == null) {
					Console.write("Error bad enemy id in course sync: " + _local13);
					return;
				}
				if(!_local7.aiCloak) {
					_local7.setConvergeTarget(_local4);
				}
				_local3 = m.getInt(_local6 + 1 + 10);
				_local12 = m.getString(_local6 + 2 + 10);
				_local10 = g.unitManager.getTarget(_local3);
				_local7.target = _local10;
				if(!_local7.stateMachine.inState(_local12)) {
					switch(_local14) {
						case "AIChase":
							_local7.stateMachine.changeState(new AIChase(g,_local7,_local10,_local4,0));
							break;
						case "AIFollow":
							_local7.stateMachine.changeState(new AIFollow(g,_local7,_local10,_local4,0));
							break;
						case "AIMelee":
							_local7.stateMachine.changeState(new AIMelee(g,_local7,_local10,_local4,0));
					}
				}
				_local5 = m.getInt(_local6 + 3 + 10);
				_local8 = 0;
				while(_local8 < _local5) {
					_local2 = m.getString(_local6 + _local8 * 3 + 4 + 10);
					_local14 = m.getBoolean(_local6 + _local8 * 3 + 5 + 10);
					_local9 = g.unitManager.getTarget(m.getInt(_local6 + _local8 * 3 + 6 + 10));
					for each(var _local11 in _local7.weapons) {
						if(_local11.name == _local2) {
							_local11.fire = _local14;
							_local11.target = _local9;
						}
					}
					_local8++;
				}
				_local6 += _local5 * 3;
				_local6 = _local6 + (4 + 10);
			}
		}
		
		public function mirrorCourse(m:Message) : void {
			var _local2:Ship = g.playerManager.me.mirror;
			if(_local2 == null) {
				return;
			}
			var _local3:Heading = new Heading();
			_local3.parseMessage(m,0);
			_local2.course = _local3;
		}
		
		public function aiStickyStart(m:Message) : void {
			var _local5:Dictionary = g.shipManager.enemiesById;
			var _local4:int = m.getInt(0);
			var _local2:int = m.getInt(1);
			var _local3:EnemyShip = _local5[_local4];
			var _local6:Unit = g.unitManager.getTarget(_local2);
			if(_local3 == null || !_local3.alive || _local6 == null) {
				return;
			}
			if(_local3.meleeChargeEndTime != 0) {
				_local3.meleeChargeEndTime = 1;
			}
			_local3.target = _local6;
			_local3.meleeOffset = new Point(m.getNumber(2),m.getNumber(3));
			_local3.meleeTargetStartAngle = m.getNumber(4);
			_local3.meleeTargetAngleDiff = m.getNumber(5);
			_local3.meleeStuck = true;
		}
		
		public function aiStickyEnd(m:Message) : void {
			var _local4:Dictionary = g.shipManager.enemiesById;
			var _local3:int = m.getInt(0);
			var _local2:EnemyShip = _local4[_local3];
			if(_local2 == null || !_local2.alive) {
				return;
			}
			_local2.meleeStuck = false;
		}
		
		public function aiCharge(m:Message, i:int) : void {
			var _local5:Dictionary = g.shipManager.enemiesById;
			var _local4:int = m.getInt(i);
			var _local3:EnemyShip = _local5[_local4];
			if(_local3 == null || !_local3.alive) {
				return;
			}
			_local3.meleeChargeEndTime = g.time + _local3.meleeChargeDuration;
			_local3.oldSpeed = _local3.engine.speed;
			_local3.oldTurningSpeed = _local3.engine.rotationSpeed;
			_local3.engine.rotationSpeed = 0;
			_local3.course.rotation = m.getNumber(i + 1);
			_local3.engine.speed = (1 + _local3.meleeChargeSpeedBonus) * _local3.engine.speed;
			_local3.chargeEffect = EmitterFactory.create("nHVuxJzeyE-JVcn7M-UOwA",g,_local3.pos.x,_local3.pos.y,_local3,true);
		}
		
		public function aiStateChanged(m:Message, i:int = 0) : void {
			var _local13:Dictionary = null;
			var _local11:int = 0;
			var _local12:String = null;
			var _local5:int = 0;
			var _local6:Heading = null;
			var _local7:EnemyShip = null;
			var _local4:int = 0;
			var _local8:Unit = null;
			var _local9:Number = NaN;
			var _local10:Number = NaN;
			var _local3:Point = null;
			try {
				_local13 = g.shipManager.enemiesById;
				_local11 = m.getInt(i);
				_local12 = m.getString(i + 1);
				_local5 = m.getInt(i + 2);
				_local6 = new Heading();
				i = _local6.parseMessage(m,i + 3);
				_local7 = _local13[_local11];
				if(_local7 == null || !_local7.alive) {
					return;
				}
				switch(_local12) {
					case "AICloakStarted":
						_local7.cloakStart();
						break;
					case "AICloakEnded":
						_local7.cloakEnd(_local6);
						break;
					case "AIHardenShield":
						_local7.hardenShield();
						break;
					case "AIObserve":
						_local4 = m.getInt(i);
						_local8 = g.unitManager.getTarget(_local4);
						if(_local8 != null) {
							_local7.stateMachine.changeState(new AIObserve(g,_local7,_local8,_local6,_local5));
						} else {
							Console.write("No Ai target: " + _local4);
						}
						break;
					case "AIChase":
						_local4 = m.getInt(i);
						_local8 = g.unitManager.getTarget(_local4);
						if(_local8 != null) {
							_local7.stateMachine.changeState(new AIChase(g,_local7,_local8,_local6,_local5));
						} else {
							Console.write("No Ai target: " + _local4);
						}
						break;
					case "AIResurect":
						_local7.stateMachine.changeState(new AIResurect(g,_local7));
					case "AIFollow":
						_local4 = m.getInt(i);
						_local8 = g.unitManager.getTarget(_local4);
						if(_local8 != null) {
							_local7.stateMachine.changeState(new AIFollow(g,_local7,_local8,_local6,_local5));
						} else {
							Console.write("No Ai target: " + _local4);
						}
						break;
					case "AIMelee":
						_local4 = m.getInt(i);
						_local8 = g.unitManager.getTarget(_local4);
						if(_local8 != null) {
							_local7.stateMachine.changeState(new AIMelee(g,_local7,_local8,_local6,_local5));
						} else {
							Console.write("No Ai target: " + _local4);
						}
						break;
					case "AIOrbit":
						_local7.stateMachine.changeState(new AIOrbit(g,_local7));
						break;
					case "AIIdle":
						_local7.stateMachine.changeState(new AIIdle(g,_local7,_local7.course));
						break;
					case "AIReturn":
						_local9 = m.getNumber(i);
						_local10 = m.getNumber(i + 1);
						_local7.stateMachine.changeState(new AIReturnOrbit(g,_local7,_local9,_local10,_local6,_local5));
						break;
					case "AIKamikaze":
						_local4 = m.getInt(i);
						_local8 = g.unitManager.getTarget(_local4);
						if(_local8 != null) {
							_local7.stateMachine.changeState(new AIKamikaze(g,_local7,_local8,_local6,_local5));
						} else {
							Console.write("No Ai target: " + _local4);
						}
						break;
					case "AIFlee":
						_local3 = new Point(m.getNumber(i),m.getNumber(i + 1));
						_local7.stateMachine.changeState(new AIFlee(g,_local7,_local3,_local6,_local5));
						break;
					case "AITeleport":
						_local7.stateMachine.changeState(new AITeleport(g,_local7,_local7.target,_local5,m.getNumber(i),m.getNumber(i + 1)));
						break;
					case "AITeleportExit":
						_local7.stateMachine.changeState(new AITeleportExit(g,_local7));
						break;
					case "AIExit":
						_local7.stateMachine.changeState(new AIExit(g,_local7));
				}
			}
			catch(e:Error) {
				g.client.errorLog.writeError("MSG PACK: " + e.toString(),"State: " + _local12,e.getStackTrace(),{});
			}
		}
		
		private function fastforwardMe(myShip:Ship, heading:Heading) : void {
			g.commandManager.clearCommands(heading.time);
			while(heading.time < myShip.course.time) {
				g.commandManager.runCommand(heading,heading.time);
				myShip.convergerUpdateHeading(heading);
			}
		}
		
		private function fastforward(ship:Ship, heading:Heading) : void {
			var _local3:Heading = ship.course;
			while(heading.time < _local3.time) {
				ship.convergerUpdateHeading(heading);
			}
		}
	}
}


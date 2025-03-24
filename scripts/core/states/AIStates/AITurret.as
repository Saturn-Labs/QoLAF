package core.states.AIStates {
	import core.player.Player;
	import core.scene.Game;
	import core.ship.PlayerShip;
	import core.states.IState;
	import core.states.StateMachine;
	import core.turret.Turret;
	import core.weapon.Blaster;
	import core.weapon.Weapon;
	import flash.geom.Point;
	import generics.Util;
	
	public class AITurret implements IState {
		private var g:Game;
		
		private var t:Turret;
		
		private var sm:StateMachine;
		
		private var me:Player;
		
		public function AITurret(g:Game, t:Turret) {
			super();
			this.g = g;
			this.t = t;
			this.me = g.me;
		}
		
		public function enter() : void {
		}
		
		public function execute() : void {
			if(me == null) {
				me = g.me;
				return;
			}
			if(me.isLanded) {
				return;
			}
			if(!t.isAddedToCanvas && !t.forceupdate && !t.isBossUnit) {
				return;
			}
			t.forceupdate = false;
			t.regenerateShield();
			t.updateHealthBars();
			if(t.target != null && t.target.alive) {
				t.angleTargetPos = t.target.pos;
				if(!(t.target is PlayerShip) && t.factions.length == 0) {
					t.factions.push("tempFaction");
				}
			} else {
				if(t.weapon != null) {
					t.weapon.fire = false;
				}
				t.angleTargetPos = null;
			}
			t.updateRotation();
			var _local1:Number = t.rotation;
			aim();
			t.updateWeapons();
			t.rotation = _local1;
		}
		
		public function aim() : void {
			var _local4:Point = null;
			var _local9:Number = NaN;
			var _local8:Number = NaN;
			var _local1:Point = null;
			var _local2:Point = null;
			var _local3:Number = NaN;
			var _local11:Number = NaN;
			var _local10:Number = NaN;
			var _local6:Number = NaN;
			var _local5:Number = NaN;
			var _local7:Weapon = t.weapon;
			if(_local7 != null && _local7.fire && _local7 is Blaster && t.target != null) {
				_local4 = t.pos;
				_local9 = 0;
				_local8 = 0;
				_local1 = t.target.pos;
				_local2 = t.target.speed;
				_local9 = _local1.x - _local4.x;
				_local8 = _local1.y - _local4.y;
				_local3 = Math.sqrt(_local9 * _local9 + _local8 * _local8);
				_local9 /= _local3;
				_local8 /= _local3;
				_local11 = 0.991;
				_local10 = _local3 / (_local7.speed - Util.dotProduct(_local2.x,_local2.y,_local9,_local8) * _local11);
				_local6 = _local1.x + _local2.x * _local10 * _local11 * t.aimSkill;
				_local5 = _local1.y + _local2.y * _local10 * _local11 * t.aimSkill;
				t.rotation = Math.atan2(_local5 - _local4.y,_local6 - _local4.x);
			}
		}
		
		public function exit() : void {
		}
		
		public function set stateMachine(sm:StateMachine) : void {
			this.sm = sm;
		}
		
		public function get type() : String {
			return "AITurret";
		}
	}
}


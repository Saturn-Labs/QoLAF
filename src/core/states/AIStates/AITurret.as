package core.states.AIStates
{
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
	
	public class AITurret implements IState
	{
		private var g:Game;
		
		private var t:Turret;
		
		private var sm:StateMachine;
		
		private var me:Player;
		
		public function AITurret(param1:Game, param2:Turret)
		{
			super();
			this.g = param1;
			this.t = param2;
			this.me = param1.me;
		}
		
		public function enter():void
		{
		}
		
		public function execute():void
		{
			if (me == null)
			{
				me = g.me;
				return;
			}
			if (me.isLanded)
			{
				return;
			}
			if (!t.isAddedToCanvas && !t.forceupdate && !t.isBossUnit)
			{
				return;
			}
			t.forceupdate = false;
			t.regenerateShield();
			t.updateHealthBars();
			if (t.target != null && t.target.alive)
			{
				t.angleTargetPos = t.target.pos;
				if (!(t.target is PlayerShip) && t.factions.length == 0)
				{
					t.factions.push("tempFaction");
				}
			}
			else
			{
				if (t.weapon != null)
				{
					t.weapon.fire = false;
				}
				t.angleTargetPos = null;
			}
			t.updateRotation();
			var _loc1_:Number = t.rotation;
			aim();
			t.updateWeapons();
			t.rotation = _loc1_;
		}
		
		public function aim():void
		{
			var _loc11_:Point = null;
			var _loc5_:Number = NaN;
			var _loc6_:Number = NaN;
			var _loc8_:Point = null;
			var _loc9_:Point = null;
			var _loc10_:Number = NaN;
			var _loc7_:Number = NaN;
			var _loc2_:Number = NaN;
			var _loc4_:Number = NaN;
			var _loc3_:Number = NaN;
			var _loc1_:Weapon = t.weapon;
			if (_loc1_ != null && _loc1_.fire && _loc1_ is Blaster && t.target != null)
			{
				_loc11_ = t.pos;
				_loc5_ = 0;
				_loc6_ = 0;
				_loc8_ = t.target.pos;
				_loc9_ = t.target.speed;
				_loc5_ = _loc8_.x - _loc11_.x;
				_loc6_ = _loc8_.y - _loc11_.y;
				_loc10_ = Math.sqrt(_loc5_ * _loc5_ + _loc6_ * _loc6_);
				_loc5_ /= _loc10_;
				_loc6_ /= _loc10_;
				_loc7_ = 0.991;
				_loc2_ = _loc10_ / (_loc1_.speed - Util.dotProduct(_loc9_.x, _loc9_.y, _loc5_, _loc6_) * _loc7_);
				_loc4_ = _loc8_.x + _loc9_.x * _loc2_ * _loc7_ * t.aimSkill;
				_loc3_ = _loc8_.y + _loc9_.y * _loc2_ * _loc7_ * t.aimSkill;
				t.rotation = Math.atan2(_loc3_ - _loc11_.y, _loc4_ - _loc11_.x);
			}
		}
		
		public function exit():void
		{
		}
		
		public function set stateMachine(param1:StateMachine):void
		{
			this.sm = param1;
		}
		
		public function get type():String
		{
			return "AITurret";
		}
	}
}

package core.turret
{
	import core.boss.Boss;
	import core.boss.Trigger;
	import core.scene.Game;
	import core.ship.Ship;
	import core.unit.Unit;
	import core.weapon.Weapon;
	import flash.geom.Point;
	import generics.Util;
	
	public class Turret extends Unit
	{
		public var weapon:Weapon;
		
		public var aimSkill:Number;
		
		public var aimArc:Number;
		
		public var target:Ship;
		
		public var visionRange:int;
		
		public var offset:Point;
		
		public var startAngle:Number;
		
		public var angleTargetPos:Point;
		
		public var rotationSpeed:Number;
		
		public function Turret(param1:Game)
		{
			weaponPos = new Point();
			super(param1);
		}
		
		override public function update():void
		{
			if (!alive || !active)
			{
				if (weapon != null)
				{
					weapon.fire = false;
				}
				return;
			}
			if (parentObj is Boss)
			{
				for each (var _loc1_:* in triggers)
				{
					_loc1_.tryActivateTrigger(this, Boss(parentObj));
				}
			}
			var _loc2_:Number = parentObj.rotation;
			_pos.x = offset.x * Math.cos(_loc2_) - offset.y * Math.sin(_loc2_) + parentObj.x;
			_pos.y = offset.x * Math.sin(_loc2_) + offset.y * Math.cos(_loc2_) + parentObj.y;
			stateMachine.update();
			if (lastDmgText != null)
			{
				lastDmgText.x = _pos.x;
				lastDmgText.y = _pos.y - 20 + lastDmgTextOffset;
				lastDmgTextOffset += lastDmgText.speed.y * 33 / 1000;
				if (lastDmgTime < g.time - 1000)
				{
					lastDmgTextOffset = 0;
					lastDmgText = null;
				}
			}
			if (lastHealText != null)
			{
				lastHealText.x = _pos.x;
				lastHealText.y = _pos.y - 5 + lastHealTextOffset;
				lastHealTextOffset += lastHealText.speed.y * 33 / 1000;
				if (lastHealTime < g.time - 1000)
				{
					lastHealTextOffset = 0;
					lastHealText = null;
				}
			}
			super.update();
		}
		
		public function updateRotation():void
		{
			var _loc7_:Number = NaN;
			var _loc6_:Number = NaN;
			var _loc4_:Number = NaN;
			var _loc3_:Number = NaN;
			var _loc1_:int = 33;
			var _loc5_:Number = rotationSpeed * _loc1_ / 1000;
			var _loc2_:Number = parentObj.rotation;
			if (aimArc == 0)
			{
				_rotation = Util.clampRadians(startAngle + _loc2_);
			}
			if (aimArc == 2 * 3.141592653589793)
			{
				if (angleTargetPos != null)
				{
					_loc7_ = Util.clampRadians(Math.atan2(angleTargetPos.y - _pos.y, angleTargetPos.x - _pos.x));
				}
				else
				{
					_loc7_ = Util.clampRadians(startAngle + _loc2_);
				}
				_loc6_ = Util.angleDifference(_rotation, _loc7_ + 3.141592653589793);
				if (_loc6_ > 0 && _loc6_ < 3.141592653589793 - _loc5_)
				{
					_rotation += _loc5_;
					_rotation = Util.clampRadians(_rotation);
				}
				else if (_loc6_ <= 0 && _loc6_ > -3.141592653589793 + _loc5_)
				{
					_rotation -= _loc5_;
					_rotation = Util.clampRadians(_rotation);
				}
				else
				{
					_rotation = Util.clampRadians(_loc7_);
				}
			}
			else
			{
				_loc4_ = Util.clampRadians(startAngle + _loc2_ - aimArc / 2);
				if (angleTargetPos != null)
				{
					_loc7_ = Util.clampRadians(Math.atan2(angleTargetPos.y - _pos.y, angleTargetPos.x - _pos.x) - _loc4_);
				}
				else
				{
					_loc7_ = Util.clampRadians(startAngle + _loc2_ - _loc4_);
				}
				_loc3_ = Util.clampRadians(_rotation - _loc4_);
				if (_loc7_ < 0 || _loc7_ > aimArc)
				{
					_loc7_ = Util.clampRadians(startAngle + _loc2_ - _loc4_);
				}
				if (_loc3_ < _loc7_ - _loc5_)
				{
					_rotation += _loc5_;
					_rotation = Util.clampRadians(_rotation);
				}
				else if (_loc3_ > _loc7_ + _loc5_)
				{
					_rotation -= _loc5_;
					_rotation = Util.clampRadians(_rotation);
				}
				else
				{
					_rotation = Util.clampRadians(_loc7_ + _loc4_);
				}
			}
		}
		
		public function updateWeapons():void
		{
			if (weapon != null)
			{
				weapon.update();
			}
		}
		
		override public function destroy(param1:Boolean = true):void
		{
			hpBar.visible = false;
			shieldBar.visible = false;
			visible = false;
			super.destroy(param1);
		}
		
		public function rebuild():void
		{
			hp = hpMax;
			shieldHp = shieldHpMax;
			hpBar.visible = true;
			shieldBar.visible = true;
			visible = true;
			alive = true;
		}
		
		override public function set id(param1:int):void
		{
			super.id = param1;
		}
		
		override public function get id():int
		{
			return super.id;
		}
		
		override public function get type():String
		{
			return "turret";
		}
	}
}

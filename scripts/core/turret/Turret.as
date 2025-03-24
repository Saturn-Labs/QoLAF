package core.turret {
	import core.boss.Boss;
	import core.boss.Trigger;
	import core.scene.Game;
	import core.ship.Ship;
	import core.unit.Unit;
	import core.weapon.Weapon;
	import flash.geom.Point;
	import generics.Util;
	
	public class Turret extends Unit {
		public var weapon:Weapon;
		
		public var aimSkill:Number;
		
		public var aimArc:Number;
		
		public var target:Ship;
		
		public var visionRange:int;
		
		public var offset:Point;
		
		public var startAngle:Number;
		
		public var angleTargetPos:Point;
		
		public var rotationSpeed:Number;
		
		public function Turret(g:Game) {
			weaponPos = new Point();
			super(g);
		}
		
		override public function update() : void {
			if(!alive || !active) {
				if(weapon != null) {
					weapon.fire = false;
				}
				return;
			}
			if(parentObj is Boss) {
				for each(var _local2 in triggers) {
					_local2.tryActivateTrigger(this,Boss(parentObj));
				}
			}
			var _local1:Number = parentObj.rotation;
			_pos.x = offset.x * Math.cos(_local1) - offset.y * Math.sin(_local1) + parentObj.x;
			_pos.y = offset.x * Math.sin(_local1) + offset.y * Math.cos(_local1) + parentObj.y;
			stateMachine.update();
			if(lastDmgText != null) {
				lastDmgText.x = _pos.x;
				lastDmgText.y = _pos.y - 20 + lastDmgTextOffset;
				lastDmgTextOffset += lastDmgText.speed.y * 33 / 1000;
				if(lastDmgTime < g.time - 1000) {
					lastDmgTextOffset = 0;
					lastDmgText = null;
				}
			}
			if(lastHealText != null) {
				lastHealText.x = _pos.x;
				lastHealText.y = _pos.y - 5 + lastHealTextOffset;
				lastHealTextOffset += lastHealText.speed.y * 33 / 1000;
				if(lastHealTime < g.time - 1000) {
					lastHealTextOffset = 0;
					lastHealText = null;
				}
			}
			super.update();
		}
		
		public function updateRotation() : void {
			var _local3:Number = NaN;
			var _local4:Number = NaN;
			var _local6:Number = NaN;
			var _local7:Number = NaN;
			var _local1:int = 33;
			var _local5:Number = rotationSpeed * _local1 / 1000;
			var _local2:Number = parentObj.rotation;
			if(aimArc == 0) {
				_rotation = Util.clampRadians(startAngle + _local2);
			}
			if(aimArc == 2 * 3.141592653589793) {
				if(angleTargetPos != null) {
					_local3 = Util.clampRadians(Math.atan2(angleTargetPos.y - _pos.y,angleTargetPos.x - _pos.x));
				} else {
					_local3 = Util.clampRadians(startAngle + _local2);
				}
				_local4 = Util.angleDifference(_rotation,_local3 + 3.141592653589793);
				if(_local4 > 0 && _local4 < 3.141592653589793 - _local5) {
					_rotation += _local5;
					_rotation = Util.clampRadians(_rotation);
				} else if(_local4 <= 0 && _local4 > -3.141592653589793 + _local5) {
					_rotation -= _local5;
					_rotation = Util.clampRadians(_rotation);
				} else {
					_rotation = Util.clampRadians(_local3);
				}
			} else {
				_local6 = Util.clampRadians(startAngle + _local2 - aimArc / 2);
				if(angleTargetPos != null) {
					_local3 = Util.clampRadians(Math.atan2(angleTargetPos.y - _pos.y,angleTargetPos.x - _pos.x) - _local6);
				} else {
					_local3 = Util.clampRadians(startAngle + _local2 - _local6);
				}
				_local7 = Util.clampRadians(_rotation - _local6);
				if(_local3 < 0 || _local3 > aimArc) {
					_local3 = Util.clampRadians(startAngle + _local2 - _local6);
				}
				if(_local7 < _local3 - _local5) {
					_rotation += _local5;
					_rotation = Util.clampRadians(_rotation);
				} else if(_local7 > _local3 + _local5) {
					_rotation -= _local5;
					_rotation = Util.clampRadians(_rotation);
				} else {
					_rotation = Util.clampRadians(_local3 + _local6);
				}
			}
		}
		
		public function updateWeapons() : void {
			if(weapon != null) {
				weapon.update();
			}
		}
		
		override public function destroy(explode:Boolean = true) : void {
			hpBar.visible = false;
			shieldBar.visible = false;
			visible = false;
			super.destroy(explode);
		}
		
		public function rebuild() : void {
			hp = hpMax;
			shieldHp = shieldHpMax;
			hpBar.visible = true;
			shieldBar.visible = true;
			visible = true;
			alive = true;
		}
		
		override public function set id(value:int) : void {
			super.id = value;
		}
		
		override public function get id() : int {
			return super.id;
		}
		
		override public function get type() : String {
			return "turret";
		}
	}
}


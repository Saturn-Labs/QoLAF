package core.ship {
	import core.engine.Engine;
	import core.scene.Game;
	import core.sync.Converger;
	import core.unit.Unit;
	import core.weapon.Beam;
	import core.weapon.Weapon;
	import flash.geom.Point;
	import movement.Heading;
	
	public class Ship extends Unit {
		public var engine:Engine;
		
		public var weapons:Vector.<Weapon> = new Vector.<Weapon>();
		
		protected var _usingBoost:Boolean;
		
		public var boostBonus:int;
		
		public var isTeleporting:Boolean;
		
		private var converger:Converger;
		
		public var isVisible:Boolean = false;
		
		public var nextUpdate:Number = 0;
		
		public var rollDir:Number = 0;
		
		public var rollMod:Number = 0;
		
		public var rollSpeed:Number = 0;
		
		public var rollPassive:Number = 0;
		
		public function Ship(g:Game) {
			converger = new Converger(this,g);
			super(g);
			enginePos = new Point();
			weaponPos = new Point();
		}
		
		override public function update() : void {
			var _local1:Number = NaN;
			if(isNaN(pos.x)) {
				return;
			}
			var _local2:Heading = converger.course;
			if(_local2 == null) {
				return;
			}
			stateMachine.update();
			super.update();
			if(!isAddedToCanvas) {
				return;
			}
			if(_local2.accelerate || _local2.deaccelerate && speed.length > 5) {
				engine.accelerate();
			} else {
				engine.idle();
			}
			if(lastDmgText != null) {
				_local1 = 33;
				lastDmgText.x += _local2.speed.x * _local1 / 1000;
				lastDmgText.y += _local2.speed.y * _local1 / 1000;
				if(lastDmgTime < g.time - 1000) {
					lastDmgText = null;
					lastDmg = 0;
				}
			}
			if(lastHealText != null) {
				_local1 = 33;
				lastHealText.x += _local2.speed.x * _local1 / 1000;
				lastHealText.y += _local2.speed.y * _local1 / 1000;
				if(lastHealTime < g.time - 1000) {
					lastHealText = null;
					lastHeal = 0;
				}
			}
		}
		
		public function updateWeapons() : void {
			var _local1:Weapon = null;
			var _local2:int = 0;
			var _local3:Number = weapons.length;
			_local2;
			while(_local2 < _local3) {
				_local1 = weapons[_local2];
				_local1.update();
				_local2++;
			}
		}
		
		public function updateBeamWeapons() : void {
			var _local1:Weapon = null;
			var _local2:int = 0;
			var _local3:Number = weapons.length;
			_local2;
			while(_local2 < _local3) {
				_local1 = weapons[_local2];
				if(_local1 is Beam) {
					_local1.update();
				}
				_local2++;
			}
		}
		
		public function updateNonBeamWeapons() : void {
			var _local1:Weapon = null;
			var _local2:int = 0;
			var _local3:Number = weapons.length;
			_local2;
			while(_local2 < _local3) {
				_local1 = weapons[_local2];
				if(!(_local1 is Beam)) {
					_local1.update();
				}
				_local2++;
			}
		}
		
		override public function destroy(explode:Boolean = true) : void {
			engine.destroy();
			for each(var _local2 in weapons) {
				_local2.destroy();
			}
			super.destroy(explode);
		}
		
		public function runConverger() : void {
			if(converger != null) {
				converger.run();
			}
		}
		
		override public function set pos(value:Point) : void {
			if(course != null) {
				course.pos = value;
			}
		}
		
		override public function get pos() : Point {
			if(converger == null || converger.course == null) {
				return new Point();
			}
			return converger.course.pos;
		}
		
		override public function set x(value:Number) : void {
			pos.x = value;
		}
		
		override public function set y(value:Number) : void {
			pos.y = value;
		}
		
		override public function get x() : Number {
			return pos.x;
		}
		
		override public function get y() : Number {
			return pos.y;
		}
		
		override public function set speed(value:Point) : void {
			if(course != null) {
				course.speed = value;
			}
		}
		
		override public function get speed() : Point {
			if(course != null) {
				return course.speed;
			}
			return new Point();
		}
		
		override public function set rotation(value:Number) : void {
			if(course != null) {
				course.rotation = value;
			}
		}
		
		override public function get rotation() : Number {
			if(course != null) {
				return course.rotation;
			}
			return 0;
		}
		
		public function initCourse(value:Heading) : void {
			if(course != null) {
				converger.setCourse(value,false);
			}
		}
		
		public function set course(value:Heading) : void {
			if(course != null) {
				converger.setCourse(value);
			}
		}
		
		public function get course() : Heading {
			if(converger != null) {
				return converger.course;
			}
			return null;
		}
		
		public function set accelerate(value:Boolean) : void {
			if(course != null) {
				course.accelerate = value;
			}
		}
		
		public function get accelerate() : Boolean {
			if(course != null) {
				return course.accelerate;
			}
			return false;
		}
		
		public function setConvergeTarget(value:Heading) : void {
			converger.setConvergeTarget(value);
		}
		
		public function clearConvergeTarget() : void {
			converger.clearConvergeTarget();
		}
		
		public function getConverger() : Converger {
			return converger;
		}
		
		public function convergerUpdateHeading(heading:Heading) : void {
			converger.updateHeading(heading);
		}
		
		public function setAngleTargetPos(target:Point) : void {
			converger.setAngleTargetPos(target);
		}
		
		public function isFacingAngleTarget() : Boolean {
			return converger.isFacingAngleTarget();
		}
		
		public function setNextTurnDirection(value:int) : void {
			converger.setNextTurnDirection(value);
		}
		
		override public function reset() : void {
			engine = null;
			_usingBoost = false;
			boostBonus = 0;
			isVisible = false;
			nextUpdate = 0;
			converger = new Converger(this,g);
			isTeleporting = false;
			weapons.splice(0,weapons.length);
			super.reset();
		}
		
		override public function addToCanvasForReal() : void {
			super.addToCanvas();
			engine.show();
		}
		
		override public function removeFromCanvas() : void {
			if(!isAddedToCanvas) {
				return;
			}
			engine.hide();
			super.removeFromCanvas();
		}
		
		override public function get type() : String {
			return "ship";
		}
		
		public function get usingBoost() : Boolean {
			return _usingBoost;
		}
	}
}


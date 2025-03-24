package core.hud.components.radar {
	import core.GameObject;
	import core.scene.Game;
	import core.solarSystem.Body;
	
	public class Compas {
		public static const WIDTH:Number = 700;
		
		public static const HEIGHT:Number = 450;
		
		private var arrows:Vector.<TargetArrow> = new Vector.<TargetArrow>();
		
		private var g:Game;
		
		public function Compas(g:Game) {
			this.g = g;
			super();
		}
		
		public function update() : void {
			if(g.me.ship == null) {
				return;
			}
			for each(var _local1 in arrows) {
				_local1.update();
			}
		}
		
		public function removeArrow(go:GameObject) : void {
			var _local3:int = 0;
			var _local2:TargetArrow = null;
			_local3 = arrows.length - 1;
			while(_local3 > -1) {
				_local2 = arrows[_local3];
				if(_local2.target == go) {
					arrows.splice(_local3,1);
					g.removeChildFromCanvas(_local2,true);
				}
				_local3--;
			}
		}
		
		public function addArrow(go:GameObject, color:uint) : TargetArrow {
			var _local3:TargetArrow = new TargetArrow(g,go,color);
			arrows.push(_local3);
			g.addChildToCanvas(_local3);
			return _local3;
		}
		
		public function hasTarget(go:GameObject) : Boolean {
			for each(var _local2 in arrows) {
				if(_local2.target == go) {
					return true;
				}
			}
			return false;
		}
		
		public function addHintArrow(bodyType:String) : void {
			clear();
			var _local2:Vector.<Body> = g.bodyManager.bodies;
			for each(var _local3 in _local2) {
				if(_local3.type == bodyType) {
					addArrow(_local3,0x88ff88).activate();
				}
			}
		}
		
		public function addHintArrowByKey(bodyKey:String) : void {
			clear();
			var _local2:Vector.<Body> = g.bodyManager.bodies;
			for each(var _local3 in _local2) {
				if(_local3.key == bodyKey) {
					addArrow(_local3,0x88ff88).activate();
				}
			}
		}
		
		public function clearType(type:String) : void {
			var _local2:Body = null;
			var _local4:int = 0;
			var _local3:TargetArrow = null;
			_local4 = arrows.length - 1;
			while(_local4 > -1) {
				_local3 = arrows[_local4];
				if(_local3.target is Body) {
					_local2 = _local3.target as Body;
					if(_local2.type == type) {
						g.removeChildFromCanvas(_local3);
						arrows.splice(_local4,1);
					}
				}
				_local4--;
			}
		}
		
		public function clear() : void {
			for each(var _local1 in arrows) {
				_local1.deactivate();
				g.removeChildFromCanvas(_local1);
			}
			arrows.length = 0;
		}
	}
}


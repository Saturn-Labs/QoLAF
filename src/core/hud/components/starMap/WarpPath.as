package core.hud.components.starMap {
	import core.hud.components.Line;
	import core.hud.components.PriceCommodities;
	import core.scene.SceneBase;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	
	public class WarpPath extends Sprite {
		private var obj:Object;
		private var _icon1:SolarSystem;
		private var _icon2:SolarSystem;
		private var _bought:Boolean;
		private var _selected:Boolean;
		private var sb:SceneBase;
		private var line:Line = new Line();
		private var forwardArrow:TransitButton;
		private var backArrow:TransitButton;
		
		public function WarpPath(sb:SceneBase, obj:Object, icon1:SolarSystem, icon2:SolarSystem, bought:Boolean = false) {
			super();
			this.sb = sb;
			this.obj = obj;
			this._icon1 = icon1;
			this._icon2 = icon2;
			_bought = bought;
			addChild(line);
			forwardArrow = new TransitButton(icon2,10453053);
			backArrow = new TransitButton(icon1,10453053);
			forwardArrow.addEventListener("touch",onTouch);
			backArrow.addEventListener("touch",onTouch);
			addChild(forwardArrow);
			addChild(backArrow);
			draw();
		}
		
		public function get key() : String {
			return obj.key;
		}
		
		override public function get name() : String {
			return obj.name;
		}
		
		public function get solarSystem1() : String {
			return obj.solarSystem1;
		}
		
		public function get solarSystem2() : String {
			return obj.solarSystem2;
		}
		
		public function get transit() : Boolean {
			return obj.transit;
		}
		
		public function get icon1() : SolarSystem {
			return _icon1;
		}
		
		public function get icon2() : SolarSystem {
			return _icon2;
		}
		
		public function get bought() : Boolean {
			return _bought;
		}
		
		public function set bought(value:Boolean) : void {
			_bought = value;
			draw();
		}
		
		public function get selected() : Boolean {
			return _selected;
		}
		
		public function set selected(value:Boolean) : void {
			_selected = value;
			draw();
		}
		
		public function get priceItems() : Array {
			return obj.priceItems;
		}
		
		public function isConnectedTo(solarSystem1:String, solarSystem2:String) : Boolean {
			if(solarSystem1 == this.solarSystem1 && solarSystem2 == this.solarSystem2) {
				return true;
			}
			if(solarSystem2 == this.solarSystem1 && solarSystem1 == this.solarSystem2) {
				return true;
			}
			return false;
		}
		
		private function draw() : void {
			forwardArrow.visible = false;
			backArrow.visible = false;
			var _local7:* = 1118481;
			if(_bought) {
				if(transit) {
					_local7 = 10453053;
				} else {
					_local7 = icon1.color;
				}
			}
			if(_selected) {
				_local7 = 0xffffff;
			}
			line.color = _local7;
			line.blendMode = "add";
			var _local5:Number = icon2.x - icon1.x;
			var _local6:Number = icon2.y - icon1.y;
			var _local9:Number = Math.atan2(_local6,_local5);
			var _local1:Number = Math.cos(_local9) * (icon1.size + 2);
			var _local3:Number = Math.sin(_local9) * (icon1.size + 2);
			line.x = _local1;
			line.y = _local3;
			var _local4:Number = icon2.x + Math.cos(_local9 + 3.141592653589793) * (icon2.size + 2) - icon1.x;
			var _local8:Number = icon2.y + Math.sin(_local9 + 3.141592653589793) * (icon2.size + 2) - icon1.y;
			line.lineTo(_local4,_local8);
			line.thickness = 5;
			var _local2:Vector.<Number> = new Vector.<Number>();
			_local2.push(_local1,_local3,_local4,_local8);
			if(transit) {
				forwardArrow.visible = true;
				forwardArrow.rotation = _local9 + 3.141592653589793 / 2;
				forwardArrow.x = Math.cos(_local9) * (icon1.size + 20);
				forwardArrow.y = Math.sin(_local9) * (icon1.size + 20);
				backArrow.visible = true;
				backArrow.rotation = _local9 + 3.141592653589793 + 3.141592653589793 / 2;
				backArrow.x = icon2.x + Math.cos(_local9 + 3.141592653589793) * (icon2.size + 20) - icon1.x;
				backArrow.y = icon2.y + Math.sin(_local9 + 3.141592653589793) * (icon2.size + 20) - icon1.y;
			}
		}
		
		private function onTouch(e:TouchEvent) : void {
			var _local2:TransitButton = e.currentTarget as TransitButton;
			if(e.getTouch(_local2,"ended")) {
				dispatchEvent(new Event("transitClick",false,{"solarSystemKey":_local2.target.key}));
			}
		}
		
		public function get costContainer() : Sprite {
			var _local1:PriceCommodities = null;
			var _local3:Sprite = new Sprite();
			var _local5:int = 0;
			for each(var _local4 in priceItems) {
				_local1 = new PriceCommodities(sb,_local4.item,_local4.amount);
				_local1.x = 10;
				_local1.y = 10 + 30 * _local5;
				_local3.addChild(_local1);
				_local5++;
			}
			var _local2:Quad = new Quad(_local3.width + 20,_local3.height + 10,0);
			_local3.addChildAt(_local2,0);
			return _local3;
		}
	}
}


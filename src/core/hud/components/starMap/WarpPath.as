package core.hud.components.starMap
{
	import core.hud.components.Line;
	import core.hud.components.PriceCommodities;
	import core.scene.SceneBase;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	
	public class WarpPath extends Sprite
	{
		private var obj:Object;
		
		private var _icon1:SolarSystem;
		
		private var _icon2:SolarSystem;
		
		private var _bought:Boolean;
		
		private var _selected:Boolean;
		
		private var sb:SceneBase;
		
		private var line:Line;
		
		private var forwardArrow:TransitButton;
		
		private var backArrow:TransitButton;
		
		public function WarpPath(param1:SceneBase, param2:Object, param3:SolarSystem, param4:SolarSystem, param5:Boolean = false)
		{
			line = new Line();
			super();
			this.sb = param1;
			this.obj = param2;
			this._icon1 = param3;
			this._icon2 = param4;
			_bought = param5;
			addChild(line);
			forwardArrow = new TransitButton(param4, 10453053);
			backArrow = new TransitButton(param3, 10453053);
			forwardArrow.addEventListener("touch", onTouch);
			backArrow.addEventListener("touch", onTouch);
			addChild(forwardArrow);
			addChild(backArrow);
			draw();
		}
		
		public function get key():String
		{
			return obj.key;
		}
		
		override public function get name():String
		{
			return obj.name;
		}
		
		public function get solarSystem1():String
		{
			return obj.solarSystem1;
		}
		
		public function get solarSystem2():String
		{
			return obj.solarSystem2;
		}
		
		public function get transit():Boolean
		{
			return obj.transit;
		}
		
		public function get icon1():SolarSystem
		{
			return _icon1;
		}
		
		public function get icon2():SolarSystem
		{
			return _icon2;
		}
		
		public function get bought():Boolean
		{
			return _bought;
		}
		
		public function set bought(param1:Boolean):void
		{
			_bought = param1;
			draw();
		}
		
		public function get selected():Boolean
		{
			return _selected;
		}
		
		public function set selected(param1:Boolean):void
		{
			_selected = param1;
			draw();
		}
		
		public function get priceItems():Array
		{
			return obj.priceItems;
		}
		
		public function isConnectedTo(param1:String, param2:String):Boolean
		{
			if (param1 == this.solarSystem1 && param2 == this.solarSystem2)
			{
				return true;
			}
			if (param2 == this.solarSystem1 && param1 == this.solarSystem2)
			{
				return true;
			}
			return false;
		}
		
		private function draw():void
		{
			forwardArrow.visible = false;
			backArrow.visible = false;
			var _loc7_:* = 1118481;
			if (_bought)
			{
				if (transit)
				{
					_loc7_ = 10453053;
				}
				else
				{
					_loc7_ = icon1.color;
				}
			}
			if (_selected)
			{
				_loc7_ = 16777215;
			}
			line.color = _loc7_;
			line.blendMode = "add";
			var _loc5_:Number = icon2.x - icon1.x;
			var _loc6_:Number = icon2.y - icon1.y;
			var _loc9_:Number = Math.atan2(_loc6_, _loc5_);
			var _loc1_:Number = Math.cos(_loc9_) * (icon1.size + 2);
			var _loc3_:Number = Math.sin(_loc9_) * (icon1.size + 2);
			line.x = _loc1_;
			line.y = _loc3_;
			var _loc4_:Number = icon2.x + Math.cos(_loc9_ + 3.141592653589793) * (icon2.size + 2) - icon1.x;
			var _loc8_:Number = icon2.y + Math.sin(_loc9_ + 3.141592653589793) * (icon2.size + 2) - icon1.y;
			line.lineTo(_loc4_, _loc8_);
			line.thickness = 5;
			var _loc2_:Vector.<Number> = new Vector.<Number>();
			_loc2_.push(_loc1_, _loc3_, _loc4_, _loc8_);
			if (transit)
			{
				forwardArrow.visible = true;
				forwardArrow.rotation = _loc9_ + 3.141592653589793 / 2;
				forwardArrow.x = Math.cos(_loc9_) * (icon1.size + 20);
				forwardArrow.y = Math.sin(_loc9_) * (icon1.size + 20);
				backArrow.visible = true;
				backArrow.rotation = _loc9_ + 3.141592653589793 + 3.141592653589793 / 2;
				backArrow.x = icon2.x + Math.cos(_loc9_ + 3.141592653589793) * (icon2.size + 20) - icon1.x;
				backArrow.y = icon2.y + Math.sin(_loc9_ + 3.141592653589793) * (icon2.size + 20) - icon1.y;
			}
		}
		
		private function onTouch(param1:TouchEvent):void
		{
			var _loc2_:TransitButton = param1.currentTarget as TransitButton;
			if (param1.getTouch(_loc2_, "ended"))
			{
				dispatchEvent(new Event("transitClick", false, {"solarSystemKey": _loc2_.target.key}));
			}
		}
		
		public function get costContainer():Sprite
		{
			var _loc1_:PriceCommodities = null;
			var _loc3_:Sprite = new Sprite();
			var _loc5_:int = 0;
			for each (var _loc4_:* in priceItems)
			{
				_loc1_ = new PriceCommodities(sb, _loc4_.item, _loc4_.amount);
				_loc1_.x = 10;
				_loc1_.y = 10 + 30 * _loc5_;
				_loc3_.addChild(_loc1_);
				_loc5_++;
			}
			var _loc2_:Quad = new Quad(_loc3_.width + 20, _loc3_.height + 10, 0);
			_loc3_.addChildAt(_loc2_, 0);
			return _loc3_;
		}
	}
}

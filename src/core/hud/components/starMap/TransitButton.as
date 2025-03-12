package core.hud.components.starMap
{
	import flash.display.Sprite;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import textures.TextureManager;
	
	public class TransitButton extends starling.display.Sprite
	{
		public var target:SolarSystem;
		
		private var hovered:Boolean;
		
		private var color:uint;
		
		private var textureImage:Image;
		
		public function TransitButton(param1:SolarSystem, param2:uint)
		{
			super();
			this.target = param1;
			this.color = param2;
			draw();
			useHandCursor = true;
			addEventListener("touch", onTouch);
		}
		
		private function mouseOver(param1:TouchEvent):void
		{
			hovered = true;
			draw();
		}
		
		private function mouseOut(param1:TouchEvent):void
		{
			hovered = false;
			draw();
		}
		
		private function draw():void
		{
			removeChildren();
			var _loc2_:flash.display.Sprite = new flash.display.Sprite();
			_loc2_.graphics.clear();
			var _loc4_:Vector.<int> = new Vector.<int>();
			var _loc1_:Vector.<Number> = new Vector.<Number>();
			_loc4_.push(1, 2, 2, 2);
			_loc1_.push(-8, 8);
			_loc1_.push(8, 8);
			_loc1_.push(0, -8);
			_loc1_.push(-8, 8);
			var _loc3_:uint = color;
			if (hovered)
			{
				_loc3_ = 16777215;
			}
			_loc2_.graphics.lineStyle(2, _loc3_);
			_loc2_.graphics.beginFill(0);
			_loc2_.graphics.drawPath(_loc4_, _loc1_);
			_loc2_.graphics.endFill();
			textureImage = TextureManager.imageFromSprite(_loc2_, "transitButton" + hovered.toString());
			addChild(textureImage);
		}
		
		private function onTouch(param1:TouchEvent):void
		{
			if (param1.getTouch(this, "ended"))
			{
				click(param1);
			}
			else if (param1.interactsWith(this))
			{
				mouseOver(param1);
			}
			else if (!param1.interactsWith(this))
			{
				mouseOut(param1);
			}
		}
		
		private function click(param1:TouchEvent):void
		{
			var _loc2_:ISound = SoundLocator.getService();
			_loc2_.play("3hVYqbNNSUWoDGk_pK1BdQ");
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
	}
}

package core.hud.components
{
	import starling.display.Image;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class Line extends Image
	{
		private var overlap:Boolean;
		
		public var toX:Number;
		
		public var toY:Number;
		
		private var oldTextureName:String;
		
		public function Line(param1:String = "line1")
		{
			var _loc2_:ITextureManager = TextureLocator.getService();
			super(_loc2_.getTextureMainByTextureName(param1));
		}
		
		public function init(param1:String = "line1", param2:int = 1, param3:uint = 16777215, param4:Number = 1, param5:Boolean = false):void
		{
			var _loc6_:ITextureManager = null;
			if (oldTextureName != param1)
			{
				_loc6_ = TextureLocator.getService();
				this.texture = _loc6_.getTextureMainByTextureName(param1);
				this.readjustSize(texture.width, texture.height);
				pivotY = texture.height / 2;
			}
			oldTextureName = param1;
			this.color = param3;
			this.alpha = param4;
			this.overlap = param5;
			this.thickness = param2;
			this.touchable = true;
			this.visible = true;
		}
		
		public function lineTo(param1:Number, param2:Number):void
		{
			this.toX = param1;
			this.toY = param2;
			var _loc3_:Number = param1 - x;
			var _loc5_:Number = param2 - y;
			var _loc4_:Number = Math.sqrt(_loc3_ * _loc3_ + _loc5_ * _loc5_);
			if (_loc4_ == 0)
			{
				return;
			}
			this.rotation = 0;
			width = overlap ? _loc4_ + height : _loc4_;
			this.rotation = Math.atan2(_loc5_, _loc3_);
		}
		
		public function set thickness(param1:Number):void
		{
			var _loc2_:Number = this.rotation;
			this.rotation = 0;
			height = param1;
			this.rotation = _loc2_;
		}
		
		override public function dispose():void
		{
			super.dispose();
		}
	}
}
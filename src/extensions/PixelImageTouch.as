package extensions
{
	import flash.geom.Point;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.textures.SubTexture;
	import starling.textures.Texture;
	
	public class PixelImageTouch extends Image
	{
		private var _hitArea:PixelHitArea;
		
		private var threshold:uint;
		
		public function PixelImageTouch(param1:Texture, param2:PixelHitArea = null, param3:uint = 255)
		{
			super(param1);
			this.hitArea = param2;
			this.threshold = param3;
		}
		
		override public function hitTest(param1:Point):DisplayObject
		{
			var _loc2_:Number = NaN;
			var _loc3_:Number = NaN;
			var _loc4_:SubTexture = null;
			if (getBounds(this).containsPoint(param1) && hitArea && !hitArea.disposed)
			{
				_loc2_ = 0;
				_loc3_ = 0;
				if (texture is SubTexture)
				{
					_loc4_ = SubTexture(texture);
					_loc2_ = _loc4_.region.x / _loc4_.parent.width;
					_loc2_ = _loc4_.region.y / _loc4_.parent.height;
				}
				return hitArea.getAlphaPixel(param1.x + hitArea.width * _loc2_, param1.y + hitArea.height * _loc3_) >= threshold ? this : null;
			}
			return super.hitTest(param1);
		}
		
		override public function dispose():void
		{
			if (hitArea && hitArea.disposed)
			{
				hitArea = null;
			}
			super.dispose();
		}
		
		public function get hitArea():PixelHitArea
		{
			return _hitArea;
		}
		
		public function set hitArea(param1:PixelHitArea):void
		{
			_hitArea = param1;
		}
	}
}

package extensions {
	import flash.geom.Point;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.textures.SubTexture;
	import starling.textures.Texture;
	
	public class PixelImageTouch extends Image {
		private var _hitArea:PixelHitArea;
		
		private var threshold:uint;
		
		public function PixelImageTouch(texture:Texture, hitArea:PixelHitArea = null, threshold:uint = 255) {
			super(texture);
			this.hitArea = hitArea;
			this.threshold = threshold;
		}
		
		override public function hitTest(localPoint:Point) : DisplayObject {
			var _local3:Number = NaN;
			var _local4:Number = NaN;
			var _local2:SubTexture = null;
			if(getBounds(this).containsPoint(localPoint) && hitArea && !hitArea.disposed) {
				_local3 = 0;
				_local4 = 0;
				if(texture is SubTexture) {
					_local2 = SubTexture(texture);
					_local3 = _local2.region.x / _local2.parent.width;
					_local3 = _local2.region.y / _local2.parent.height;
				}
				return hitArea.getAlphaPixel(localPoint.x + hitArea.width * _local3,localPoint.y + hitArea.height * _local4) >= threshold ? this : null;
			}
			return super.hitTest(localPoint);
		}
		
		override public function dispose() : void {
			if(hitArea && hitArea.disposed) {
				hitArea = null;
			}
			super.dispose();
		}
		
		public function get hitArea() : PixelHitArea {
			return _hitArea;
		}
		
		public function set hitArea(value:PixelHitArea) : void {
			_hitArea = value;
		}
	}
}


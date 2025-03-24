package starling.events {
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Point;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.textures.Texture;
	
	internal class TouchMarker extends Sprite {
		private var _center:Point;
		
		private var _texture:Texture;
		
		public function TouchMarker() {
			var _local2:int = 0;
			var _local1:Image = null;
			super();
			_center = new Point();
			_texture = createTexture();
			_local2 = 0;
			while(_local2 < 2) {
				_local1 = new Image(_texture);
				_local1.pivotX = _texture.width / 2;
				_local1.pivotY = _texture.height / 2;
				_local1.touchable = false;
				addChild(_local1);
				_local2++;
			}
		}
		
		override public function dispose() : void {
			_texture.dispose();
			super.dispose();
		}
		
		public function moveMarker(x:Number, y:Number, withCenter:Boolean = false) : void {
			if(withCenter) {
				_center.x += x - realMarker.x;
				_center.y += y - realMarker.y;
			}
			realMarker.x = x;
			realMarker.y = y;
			mockMarker.x = 2 * _center.x - x;
			mockMarker.y = 2 * _center.y - y;
		}
		
		public function moveCenter(x:Number, y:Number) : void {
			_center.x = x;
			_center.y = y;
			moveMarker(realX,realY);
		}
		
		private function createTexture() : Texture {
			var _local5:Number = Starling.contentScaleFactor;
			var _local6:Number = 12 * _local5;
			var _local4:int = 32 * _local5;
			var _local7:int = 32 * _local5;
			var _local3:Number = 1.5 * _local5;
			var _local2:Shape = new Shape();
			_local2.graphics.lineStyle(_local3,0,0.3);
			_local2.graphics.drawCircle(_local4 / 2,_local7 / 2,_local6 + _local3);
			_local2.graphics.beginFill(0xffffff,0.4);
			_local2.graphics.lineStyle(_local3,0xffffff);
			_local2.graphics.drawCircle(_local4 / 2,_local7 / 2,_local6);
			_local2.graphics.endFill();
			var _local1:BitmapData = new BitmapData(_local4,_local7,true,0);
			_local1.draw(_local2);
			return Texture.fromBitmapData(_local1,false,false,_local5);
		}
		
		private function get realMarker() : Image {
			return getChildAt(0) as Image;
		}
		
		private function get mockMarker() : Image {
			return getChildAt(1) as Image;
		}
		
		public function get realX() : Number {
			return realMarker.x;
		}
		
		public function get realY() : Number {
			return realMarker.y;
		}
		
		public function get mockX() : Number {
			return mockMarker.x;
		}
		
		public function get mockY() : Number {
			return mockMarker.y;
		}
	}
}


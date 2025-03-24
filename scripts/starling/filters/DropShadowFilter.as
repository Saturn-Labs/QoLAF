package starling.filters {
	import starling.rendering.Painter;
	import starling.textures.Texture;
	import starling.utils.Padding;
	
	public class DropShadowFilter extends FragmentFilter {
		private var _blurFilter:BlurFilter;
		
		private var _compositeFilter:CompositeFilter;
		
		private var _distance:Number;
		
		private var _angle:Number;
		
		public function DropShadowFilter(distance:Number = 4, angle:Number = 0.785, color:uint = 0, alpha:Number = 0.5, blur:Number = 1, resolution:Number = 0.5) {
			super();
			_compositeFilter = new CompositeFilter();
			_blurFilter = new BlurFilter(blur,blur,resolution);
			_distance = distance;
			_angle = angle;
			this.color = color;
			this.alpha = alpha;
			updatePadding();
		}
		
		override public function dispose() : void {
			_blurFilter.dispose();
			_compositeFilter.dispose();
			super.dispose();
		}
		
		override public function process(painter:Painter, helper:IFilterHelper, input0:Texture = null, input1:Texture = null, input2:Texture = null, input3:Texture = null) : Texture {
			var _local8:Texture = _blurFilter.process(painter,helper,input0);
			var _local7:Texture = _compositeFilter.process(painter,helper,_local8,input0);
			helper.putTexture(_local8);
			return _local7;
		}
		
		override public function get numPasses() : int {
			return _blurFilter.numPasses + _compositeFilter.numPasses;
		}
		
		private function updatePadding() : void {
			var _local1:Number = Math.cos(_angle) * _distance;
			var _local2:Number = Math.sin(_angle) * _distance;
			_compositeFilter.setOffsetAt(0,_local1,_local2);
			var _local6:Padding = _blurFilter.padding;
			var _local4:Number = _local6.left;
			var _local7:Number = _local6.right;
			var _local3:Number = _local6.top;
			var _local5:Number = _local6.bottom;
			if(_local1 > 0) {
				_local7 += _local1;
			} else {
				_local4 -= _local1;
			}
			if(_local2 > 0) {
				_local5 += _local2;
			} else {
				_local3 -= _local2;
			}
			padding.setTo(_local4,_local7,_local3,_local5);
		}
		
		public function get color() : uint {
			return _compositeFilter.getColorAt(0);
		}
		
		public function set color(value:uint) : void {
			if(color != value) {
				_compositeFilter.setColorAt(0,value,true);
				setRequiresRedraw();
			}
		}
		
		public function get alpha() : Number {
			return _compositeFilter.getAlphaAt(0);
		}
		
		public function set alpha(value:Number) : void {
			if(alpha != value) {
				_compositeFilter.setAlphaAt(0,value);
				setRequiresRedraw();
			}
		}
		
		public function get distance() : Number {
			return _distance;
		}
		
		public function set distance(value:Number) : void {
			if(_distance != value) {
				_distance = value;
				setRequiresRedraw();
				updatePadding();
			}
		}
		
		public function get angle() : Number {
			return _angle;
		}
		
		public function set angle(value:Number) : void {
			if(_angle != value) {
				_angle = value;
				setRequiresRedraw();
				updatePadding();
			}
		}
		
		public function get blur() : Number {
			return _blurFilter.blurX;
		}
		
		public function set blur(value:Number) : void {
			if(blur != value) {
				_blurFilter.blurX = _blurFilter.blurY = value;
				setRequiresRedraw();
				updatePadding();
			}
		}
		
		override public function get resolution() : Number {
			return _blurFilter.resolution;
		}
		
		override public function set resolution(value:Number) : void {
			if(resolution != value) {
				_blurFilter.resolution = value;
				setRequiresRedraw();
				updatePadding();
			}
		}
	}
}


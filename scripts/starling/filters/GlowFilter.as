package starling.filters {
	import starling.rendering.Painter;
	import starling.textures.Texture;
	
	public class GlowFilter extends FragmentFilter {
		private var _blurFilter:BlurFilter;
		
		private var _compositeFilter:CompositeFilter;
		
		public function GlowFilter(color:uint = 16776960, alpha:Number = 1, blur:Number = 1, resolution:Number = 0.5) {
			super();
			_blurFilter = new BlurFilter(blur,blur,resolution);
			_compositeFilter = new CompositeFilter();
			_compositeFilter.setColorAt(0,color,true);
			_compositeFilter.setAlphaAt(0,alpha);
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
			padding.copyFrom(_blurFilter.padding);
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


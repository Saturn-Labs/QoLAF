package starling.textures {
	import starling.core.Starling;
	
	public class TextureOptions {
		private var _scale:Number;
		
		private var _format:String;
		
		private var _mipMapping:Boolean;
		
		private var _optimizeForRenderToTexture:Boolean = false;
		
		private var _premultipliedAlpha:Boolean;
		
		private var _forcePotTexture:Boolean;
		
		private var _onReady:Function = null;
		
		public function TextureOptions(scale:Number = 1, mipMapping:Boolean = false, format:String = "bgra", premultipliedAlpha:Boolean = true, forcePotTexture:Boolean = false) {
			super();
			_scale = scale;
			_format = format;
			_mipMapping = mipMapping;
			_forcePotTexture = forcePotTexture;
			_premultipliedAlpha = premultipliedAlpha;
		}
		
		public function clone() : TextureOptions {
			var _local1:TextureOptions = new TextureOptions(_scale,_mipMapping,_format);
			_local1._optimizeForRenderToTexture = _optimizeForRenderToTexture;
			_local1._premultipliedAlpha = _premultipliedAlpha;
			_local1._forcePotTexture = _forcePotTexture;
			_local1._onReady = _onReady;
			return _local1;
		}
		
		public function get scale() : Number {
			return _scale;
		}
		
		public function set scale(value:Number) : void {
			_scale = value > 0 ? value : Starling.contentScaleFactor;
		}
		
		public function get format() : String {
			return _format;
		}
		
		public function set format(value:String) : void {
			_format = value;
		}
		
		public function get mipMapping() : Boolean {
			return _mipMapping;
		}
		
		public function set mipMapping(value:Boolean) : void {
			_mipMapping = value;
		}
		
		public function get optimizeForRenderToTexture() : Boolean {
			return _optimizeForRenderToTexture;
		}
		
		public function set optimizeForRenderToTexture(value:Boolean) : void {
			_optimizeForRenderToTexture = value;
		}
		
		public function get forcePotTexture() : Boolean {
			return _forcePotTexture;
		}
		
		public function set forcePotTexture(value:Boolean) : void {
			_forcePotTexture = value;
		}
		
		public function get onReady() : Function {
			return _onReady;
		}
		
		public function set onReady(value:Function) : void {
			_onReady = value;
		}
		
		public function get premultipliedAlpha() : Boolean {
			return _premultipliedAlpha;
		}
		
		public function set premultipliedAlpha(value:Boolean) : void {
			_premultipliedAlpha = value;
		}
	}
}


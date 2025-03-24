package starling.textures {
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import starling.utils.StringUtil;
	
	public class TextureAtlas {
		private static var sNames:Vector.<String> = new Vector.<String>(0);
		
		private var _atlasTexture:Texture;
		
		private var _subTextures:Dictionary;
		
		private var _subTextureNames:Vector.<String>;
		
		public function TextureAtlas(texture:Texture, atlasXml:XML = null) {
			super();
			_subTextures = new Dictionary();
			_atlasTexture = texture;
			if(atlasXml) {
				parseAtlasXml(atlasXml);
			}
		}
		
		private static function parseBool(value:String) : Boolean {
			return value.toLowerCase() == "true";
		}
		
		public function dispose() : void {
			_atlasTexture.dispose();
		}
		
		protected function parseAtlasXml(atlasXml:XML) : void {
			var _local9:String = null;
			var _local10:Number = NaN;
			var _local12:Number = NaN;
			var _local11:Number = NaN;
			var _local15:Number = NaN;
			var _local4:Number = NaN;
			var _local6:Number = NaN;
			var _local7:Number = NaN;
			var _local2:Number = NaN;
			var _local5:Boolean = false;
			var _local3:Number = _atlasTexture.scale;
			var _local13:Rectangle = new Rectangle();
			var _local14:Rectangle = new Rectangle();
			for each(var _local8 in atlasXml.SubTexture) {
				_local9 = StringUtil.clean(_local8.@name);
				_local10 = parseFloat(_local8.@x) / _local3;
				_local12 = parseFloat(_local8.@y) / _local3;
				_local11 = parseFloat(_local8.@width) / _local3;
				_local15 = parseFloat(_local8.@height) / _local3;
				_local4 = parseFloat(_local8.@frameX) / _local3;
				_local6 = parseFloat(_local8.@frameY) / _local3;
				_local7 = parseFloat(_local8.@frameWidth) / _local3;
				_local2 = parseFloat(_local8.@frameHeight) / _local3;
				_local5 = parseBool(_local8.@rotated);
				_local13.setTo(_local10,_local12,_local11,_local15);
				_local14.setTo(_local4,_local6,_local7,_local2);
				if(_local7 > 0 && _local2 > 0) {
					addRegion(_local9,_local13,_local14,_local5);
				} else {
					addRegion(_local9,_local13,null,_local5);
				}
			}
		}
		
		public function getTexture(name:String) : Texture {
			return _subTextures[name];
		}
		
		public function getTextures(prefix:String = "", out:Vector.<Texture> = null) : Vector.<Texture> {
			if(out == null) {
				out = new Vector.<Texture>(0);
			}
			for each(var _local3 in getNames(prefix,sNames)) {
				out[out.length] = getTexture(_local3);
			}
			sNames.length = 0;
			return out;
		}
		
		public function getNames(prefix:String = "", out:Vector.<String> = null) : Vector.<String> {
			var _local3:String = null;
			if(out == null) {
				out = new Vector.<String>(0);
			}
			if(_subTextureNames == null) {
				_subTextureNames = new Vector.<String>(0);
				for(_local3 in _subTextures) {
					_subTextureNames[_subTextureNames.length] = _local3;
				}
				_subTextureNames.sort(1);
			}
			for each(_local3 in _subTextureNames) {
				if(_local3.indexOf(prefix) == 0) {
					out[out.length] = _local3;
				}
			}
			return out;
		}
		
		public function getRegion(name:String) : Rectangle {
			var _local2:SubTexture = _subTextures[name];
			return !!_local2 ? _local2.region : null;
		}
		
		public function getFrame(name:String) : Rectangle {
			var _local2:SubTexture = _subTextures[name];
			return !!_local2 ? _local2.frame : null;
		}
		
		public function getRotation(name:String) : Boolean {
			var _local2:SubTexture = _subTextures[name];
			return !!_local2 ? _local2.rotated : false;
		}
		
		public function addRegion(name:String, region:Rectangle, frame:Rectangle = null, rotated:Boolean = false) : void {
			_subTextures[name] = new SubTexture(_atlasTexture,region,false,frame,rotated);
			_subTextureNames = null;
		}
		
		public function removeRegion(name:String) : void {
			var _local2:SubTexture = _subTextures[name];
			if(_local2) {
				_local2.dispose();
			}
			delete _subTextures[name];
			_subTextureNames = null;
		}
		
		public function get texture() : Texture {
			return _atlasTexture;
		}
	}
}


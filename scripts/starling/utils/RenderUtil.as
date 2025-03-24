package starling.utils {
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.utils.setTimeout;
	import starling.core.Starling;
	import starling.errors.AbstractClassError;
	import starling.textures.Texture;
	
	public class RenderUtil {
		public function RenderUtil() {
			super();
			throw new AbstractClassError();
		}
		
		public static function clear(rgb:uint = 0, alpha:Number = 0) : void {
			Starling.context.clear(Color.getRed(rgb) / 255,Color.getGreen(rgb) / 255,Color.getBlue(rgb) / 255,alpha);
		}
		
		public static function getTextureLookupFlags(format:String, mipMapping:Boolean, repeat:Boolean = false, smoothing:String = "bilinear") : String {
			var _local5:Array = ["2d",repeat ? "repeat" : "clamp"];
			if(format == "compressed") {
				_local5.push("dxt1");
			} else if(format == "compressedAlpha") {
				_local5.push("dxt5");
			}
			if(smoothing == "none") {
				_local5.push("nearest",mipMapping ? "mipnearest" : "mipnone");
			} else if(smoothing == "bilinear") {
				_local5.push("linear",mipMapping ? "mipnearest" : "mipnone");
			} else {
				_local5.push("linear",mipMapping ? "miplinear" : "mipnone");
			}
			return "<" + _local5.join() + ">";
		}
		
		public static function getTextureVariantBits(texture:Texture) : uint {
			if(texture == null) {
				return 0;
			}
			var _local2:uint = 0;
			var _local3:uint = 0;
			switch(texture.format) {
				case "compressedAlpha":
					_local3 = 3;
					break;
				case "compressed":
					_local3 = 2;
					break;
				default:
					_local3 = 1;
			}
			_local2 |= _local3;
			if(!texture.premultipliedAlpha) {
				_local2 |= 4;
			}
			return _local2;
		}
		
		public static function setSamplerStateAt(sampler:int, mipMapping:Boolean, smoothing:String = "bilinear", repeat:Boolean = false) : void {
			var _local5:String = null;
			var _local6:String = null;
			var _local7:String = repeat ? "repeat" : "clamp";
			if(smoothing == "none") {
				_local5 = "nearest";
				_local6 = mipMapping ? "mipnearest" : "mipnone";
			} else if(smoothing == "bilinear") {
				_local5 = "linear";
				_local6 = mipMapping ? "mipnearest" : "mipnone";
			} else {
				_local5 = "linear";
				_local6 = mipMapping ? "miplinear" : "mipnone";
			}
			Starling.context.setSamplerStateAt(sampler,_local7,_local5,_local6);
		}
		
		public static function createAGALTexOperation(resultReg:String, uvReg:String, sampler:int, texture:Texture, convertToPmaIfRequired:Boolean = true, tempReg:String = "ft0") : String {
			var _local8:String = null;
			var _local10:String;
			switch(_local10 = texture.format) {
				case "compressed":
					_local8 = "dxt1";
					break;
				case "compressedAlpha":
					_local8 = "dxt5";
					break;
				default:
					_local8 = "rgba";
			}
			var _local9:Boolean = convertToPmaIfRequired && !texture.premultipliedAlpha;
			var _local7:String = _local9 && resultReg == "oc" ? tempReg : resultReg;
			var _local11:String = "tex " + _local7 + ", " + uvReg + ", fs" + sampler + " <2d, " + _local8 + ">\n";
			if(_local9) {
				if(resultReg == "oc") {
					_local11 += "mul " + _local7 + ".xyz, " + _local7 + ".xyz, " + _local7 + ".www\n";
					_local11 = _local11 + ("mov " + resultReg + ", " + _local7);
				} else {
					_local11 += "mul " + resultReg + ".xyz, " + _local7 + ".xyz, " + _local7 + ".www\n";
				}
			}
			return _local11;
		}
		
		public static function requestContext3D(stage3D:Stage3D, renderMode:String, profile:*) : void {
			var profiles:Array;
			var currentProfile:String;
			var requestNextProfile:* = function():void {
				currentProfile = profiles.shift();
				try {
					execute(stage3D.requestContext3D,renderMode,currentProfile);
				}
				catch(error:Error) {
					if(profiles.length == 0) {
						throw error;
					}
					setTimeout(requestNextProfile,1);
				}
			};
			var onCreated:* = function(param1:Event):void {
				var _local2:Context3D = stage3D.context3D;
				if(renderMode == "auto" && profiles.length != 0 && _local2.driverInfo.indexOf("Software") != -1) {
					onError(param1);
				} else {
					onFinished();
				}
			};
			var onError:* = function(param1:Event):void {
				if(profiles.length != 0) {
					param1.stopImmediatePropagation();
					setTimeout(requestNextProfile,1);
				} else {
					onFinished();
				}
			};
			var onFinished:* = function():void {
				stage3D.removeEventListener("context3DCreate",onCreated);
				stage3D.removeEventListener("error",onError);
			};
			if(profile == "auto") {
				profiles = ["standardExtended","standard","standardConstrained","baselineExtended","baseline","baselineConstrained"];
			} else if(profile is String) {
				profiles = [profile as String];
			} else {
				if(!(profile is Array)) {
					throw new ArgumentError("Profile must be of type \'String\' or \'Array\'");
				}
				profiles = profile as Array;
			}
			stage3D.addEventListener("context3DCreate",onCreated,false,100);
			stage3D.addEventListener("error",onError,false,100);
			requestNextProfile();
		}
	}
}


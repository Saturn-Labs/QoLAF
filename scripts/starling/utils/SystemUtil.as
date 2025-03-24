package starling.utils {
	import flash.display3D.Context3D;
	import flash.events.EventDispatcher;
	import flash.system.Capabilities;
	import flash.text.Font;
	import flash.utils.getDefinitionByName;
	import starling.errors.AbstractClassError;
	
	public class SystemUtil {
		private static var sInitialized:Boolean = false;
		
		private static var sApplicationActive:Boolean = true;
		
		private static var sPlatform:String;
		
		private static var sDesktop:Boolean;
		
		private static var sVersion:String;
		
		private static var sAIR:Boolean;
		
		private static var sEmbeddedFonts:Array = null;
		
		private static var sSupportsDepthAndStencil:Boolean = true;
		
		private static var sWaitingCalls:Array = [];
		
		public function SystemUtil() {
			super();
			throw new AbstractClassError();
		}
		
		public static function initialize() : void {
			var _local4:Object = null;
			var _local3:EventDispatcher = null;
			var _local1:XML = null;
			var _local2:Namespace = null;
			var _local5:String = null;
			if(sInitialized) {
				return;
			}
			sInitialized = true;
			sPlatform = Capabilities.version.substr(0,3);
			sVersion = Capabilities.version.substr(4);
			sDesktop = /(WIN|MAC|LNX)/.exec(sPlatform) != null;
			try {
				_local4 = getDefinitionByName("flash.desktop::NativeApplication");
				_local3 = _local4["nativeApplication"] as EventDispatcher;
				_local3.addEventListener("activate",onActivate,false,0,true);
				_local3.addEventListener("deactivate",onDeactivate,false,0,true);
				_local1 = _local3["applicationDescriptor"];
				_local2 = _local1.namespace();
				_local5 = _local1._local2::initialWindow._local2::depthAndStencil.toString().toLowerCase();
				sSupportsDepthAndStencil = _local5 == "true";
				sAIR = true;
			}
			catch(e:Error) {
				sAIR = false;
			}
		}
		
		private static function onActivate(event:Object) : void {
			sApplicationActive = true;
			for each(var _local2 in sWaitingCalls) {
				try {
					_local2[0].apply(null,_local2[1]);
				}
				catch(e:Error) {
					trace("[Starling] Error in \'executeWhenApplicationIsActive\' call:",e.message);
				}
			}
			sWaitingCalls = [];
		}
		
		private static function onDeactivate(event:Object) : void {
			sApplicationActive = false;
		}
		
		public static function executeWhenApplicationIsActive(call:Function, ... rest) : void {
			initialize();
			if(sApplicationActive) {
				call.apply(null,rest);
			} else {
				sWaitingCalls.push([call,rest]);
			}
		}
		
		public static function get isApplicationActive() : Boolean {
			initialize();
			return sApplicationActive;
		}
		
		public static function get isAIR() : Boolean {
			initialize();
			return sAIR;
		}
		
		public static function get isDesktop() : Boolean {
			initialize();
			return sDesktop;
		}
		
		public static function get platform() : String {
			initialize();
			return sPlatform;
		}
		
		public static function get version() : String {
			initialize();
			return sVersion;
		}
		
		public static function get supportsDepthAndStencil() : Boolean {
			return sSupportsDepthAndStencil;
		}
		
		public static function get supportsVideoTexture() : Boolean {
			return Context3D["supportsVideoTexture"];
		}
		
		public static function updateEmbeddedFonts() : void {
			sEmbeddedFonts = null;
		}
		
		public static function isEmbeddedFont(fontName:String, bold:Boolean = false, italic:Boolean = false, fontType:String = "embedded") : Boolean {
			var _local6:String = null;
			var _local7:Boolean = false;
			var _local5:Boolean = false;
			if(sEmbeddedFonts == null) {
				sEmbeddedFonts = Font.enumerateFonts(false);
			}
			for each(var _local8 in sEmbeddedFonts) {
				_local6 = _local8.fontStyle;
				_local7 = _local6 == "bold" || _local6 == "boldItalic";
				_local5 = _local6 == "italic" || _local6 == "boldItalic";
				if(fontName == _local8.fontName && bold == _local7 && italic == _local5 && fontType == _local8.fontType) {
					return true;
				}
			}
			return false;
		}
	}
}


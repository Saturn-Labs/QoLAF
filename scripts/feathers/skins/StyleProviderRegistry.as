package feathers.skins {
	import flash.utils.Dictionary;
	
	public class StyleProviderRegistry {
		protected static const GLOBAL_STYLE_PROVIDER_PROPERTY_NAME:String = "globalStyleProvider";
		
		protected var _registerGlobally:Boolean;
		
		protected var _styleProviderFactory:Function;
		
		protected var _classToStyleProvider:Dictionary = new Dictionary(true);
		
		public function StyleProviderRegistry(registerGlobally:Boolean = true, styleProviderFactory:Function = null) {
			super();
			this._registerGlobally = registerGlobally;
			if(styleProviderFactory === null) {
				this._styleProviderFactory = defaultStyleProviderFactory;
			} else {
				this._styleProviderFactory = styleProviderFactory;
			}
		}
		
		protected static function defaultStyleProviderFactory() : IStyleProvider {
			return new StyleNameFunctionStyleProvider();
		}
		
		public function dispose() : void {
			var _local2:Class = null;
			for(var _local1 in this._classToStyleProvider) {
				_local2 = Class(_local1);
				this.clearStyleProvider(_local2);
			}
			this._classToStyleProvider = null;
		}
		
		public function hasStyleProvider(forClass:Class) : Boolean {
			if(this._classToStyleProvider === null) {
				return false;
			}
			return forClass in this._classToStyleProvider;
		}
		
		public function getRegisteredClasses(result:Vector.<Class> = null) : Vector.<Class> {
			if(result !== null) {
				result.length = 0;
			} else {
				result = new Vector.<Class>(0);
			}
			var _local2:int = 0;
			for(var _local3 in this._classToStyleProvider) {
				result[_local2] = _local3 as Class;
				_local2++;
			}
			return result;
		}
		
		public function getStyleProvider(forClass:Class) : IStyleProvider {
			this.validateComponentClass(forClass);
			var _local2:IStyleProvider = IStyleProvider(this._classToStyleProvider[forClass]);
			if(!_local2) {
				_local2 = this._styleProviderFactory();
				this._classToStyleProvider[forClass] = _local2;
				if(this._registerGlobally) {
					forClass["globalStyleProvider"] = _local2;
				}
			}
			return _local2;
		}
		
		public function clearStyleProvider(forClass:Class) : IStyleProvider {
			var _local2:IStyleProvider = null;
			this.validateComponentClass(forClass);
			if(forClass in this._classToStyleProvider) {
				_local2 = IStyleProvider(this._classToStyleProvider[forClass]);
				delete this._classToStyleProvider[forClass];
				if(this._registerGlobally && forClass["globalStyleProvider"] === _local2) {
					forClass["globalStyleProvider"] = null;
				}
				return _local2;
			}
			return null;
		}
		
		protected function validateComponentClass(type:Class) : void {
			if(!this._registerGlobally || Boolean(Object(type).hasOwnProperty("globalStyleProvider"))) {
				return;
			}
			throw ArgumentError("Class " + type + " must have a " + "globalStyleProvider" + " static property to support themes.");
		}
	}
}


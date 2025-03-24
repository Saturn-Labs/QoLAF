package feathers.skins {
	import feathers.core.IFeathersControl;
	import feathers.core.TokenList;
	
	public class StyleNameFunctionStyleProvider implements IStyleProvider {
		protected var _defaultStyleFunction:Function;
		
		protected var _styleNameMap:Object;
		
		public function StyleNameFunctionStyleProvider(styleFunction:Function = null) {
			super();
			this._defaultStyleFunction = styleFunction;
		}
		
		public function get defaultStyleFunction() : Function {
			return this._defaultStyleFunction;
		}
		
		public function set defaultStyleFunction(value:Function) : void {
			this._defaultStyleFunction = value;
		}
		
		public function setFunctionForStyleName(styleName:String, styleFunction:Function) : void {
			if(!this._styleNameMap) {
				this._styleNameMap = {};
			}
			this._styleNameMap[styleName] = styleFunction;
		}
		
		public function applyStyles(target:IFeathersControl) : void {
			var _local3:Boolean = false;
			var _local2:TokenList = null;
			var _local6:int = 0;
			var _local5:int = 0;
			var _local4:String = null;
			var _local7:Function = null;
			if(this._styleNameMap) {
				_local3 = false;
				_local2 = target.styleNameList;
				_local6 = _local2.length;
				_local5 = 0;
				while(_local5 < _local6) {
					_local4 = _local2.item(_local5);
					_local7 = this._styleNameMap[_local4] as Function;
					if(_local7 != null) {
						_local3 = true;
						_local7(target);
					}
					_local5++;
				}
				if(_local3) {
					return;
				}
			}
			if(this._defaultStyleFunction != null) {
				this._defaultStyleFunction(target);
			}
		}
	}
}


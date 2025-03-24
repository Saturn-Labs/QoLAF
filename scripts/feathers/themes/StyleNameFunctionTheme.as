package feathers.themes {
	import feathers.skins.StyleNameFunctionStyleProvider;
	import feathers.skins.StyleProviderRegistry;
	import starling.events.EventDispatcher;
	
	public class StyleNameFunctionTheme extends EventDispatcher {
		protected var _registry:StyleProviderRegistry;
		
		public function StyleNameFunctionTheme() {
			super();
			this.createRegistry();
		}
		
		public function dispose() : void {
			if(this._registry) {
				this._registry.dispose();
				this._registry = null;
			}
		}
		
		public function getStyleProviderForClass(type:Class) : StyleNameFunctionStyleProvider {
			return StyleNameFunctionStyleProvider(this._registry.getStyleProvider(type));
		}
		
		protected function createRegistry() : void {
			this._registry = new StyleProviderRegistry();
		}
	}
}


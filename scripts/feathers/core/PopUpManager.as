package feathers.core {
	import flash.utils.Dictionary;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	
	public class PopUpManager {
		protected static const _starlingToPopUpManager:Dictionary = new Dictionary(true);
		
		public static var popUpManagerFactory:Function = defaultPopUpManagerFactory;
		
		public function PopUpManager() {
			super();
		}
		
		public static function defaultPopUpManagerFactory() : IPopUpManager {
			return new DefaultPopUpManager();
		}
		
		public static function forStarling(starling:Starling) : IPopUpManager {
			var _local3:Function = null;
			if(!starling) {
				throw new ArgumentError("PopUpManager not found. Starling cannot be null.");
			}
			var _local2:IPopUpManager = _starlingToPopUpManager[starling];
			if(!_local2) {
				_local3 = PopUpManager.popUpManagerFactory;
				if(_local3 === null) {
					_local3 = PopUpManager.defaultPopUpManagerFactory;
				}
				_local2 = _local3();
				if(!_local2.root || !starling.stage.contains(_local2.root)) {
					_local2.root = Starling.current.stage;
				}
				PopUpManager._starlingToPopUpManager[starling] = _local2;
			}
			return _local2;
		}
		
		public static function get overlayFactory() : Function {
			return PopUpManager.forStarling(Starling.current).overlayFactory;
		}
		
		public static function set overlayFactory(value:Function) : void {
			PopUpManager.forStarling(Starling.current).overlayFactory = value;
		}
		
		public static function defaultOverlayFactory() : DisplayObject {
			return DefaultPopUpManager.defaultOverlayFactory();
		}
		
		public static function get root() : DisplayObjectContainer {
			return PopUpManager.forStarling(Starling.current).root;
		}
		
		public static function set root(value:DisplayObjectContainer) : void {
			PopUpManager.forStarling(Starling.current).root = value;
		}
		
		public static function addPopUp(popUp:DisplayObject, isModal:Boolean = true, isCentered:Boolean = true, customOverlayFactory:Function = null) : DisplayObject {
			return PopUpManager.forStarling(Starling.current).addPopUp(popUp,isModal,isCentered,customOverlayFactory);
		}
		
		public static function removePopUp(popUp:DisplayObject, dispose:Boolean = false) : DisplayObject {
			return PopUpManager.forStarling(Starling.current).removePopUp(popUp,dispose);
		}
		
		public static function isPopUp(popUp:DisplayObject) : Boolean {
			return PopUpManager.forStarling(Starling.current).isPopUp(popUp);
		}
		
		public static function isTopLevelPopUp(popUp:DisplayObject) : Boolean {
			return PopUpManager.forStarling(Starling.current).isTopLevelPopUp(popUp);
		}
		
		public static function centerPopUp(popUp:DisplayObject) : void {
			PopUpManager.forStarling(Starling.current).centerPopUp(popUp);
		}
	}
}


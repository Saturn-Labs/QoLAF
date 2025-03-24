package feathers.core {
	public interface IFocusDisplayObject extends IFeathersDisplayObject {
		function get focusManager() : IFocusManager;
		
		function set focusManager(value:IFocusManager) : void;
		
		function get isFocusEnabled() : Boolean;
		
		function set isFocusEnabled(value:Boolean) : void;
		
		function get nextTabFocus() : IFocusDisplayObject;
		
		function set nextTabFocus(value:IFocusDisplayObject) : void;
		
		function get previousTabFocus() : IFocusDisplayObject;
		
		function set previousTabFocus(value:IFocusDisplayObject) : void;
		
		function get focusOwner() : IFocusDisplayObject;
		
		function set focusOwner(value:IFocusDisplayObject) : void;
		
		function showFocus() : void;
		
		function hideFocus() : void;
	}
}


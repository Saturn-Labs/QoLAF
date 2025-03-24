package feathers.core {
	public interface IAdvancedNativeFocusOwner extends INativeFocusOwner {
		function get hasFocus() : Boolean;
		
		function setFocus() : void;
	}
}


package feathers.core {
	public interface IToggle extends IFeathersControl {
		function get isSelected() : Boolean;
		
		function set isSelected(value:Boolean) : void;
	}
}


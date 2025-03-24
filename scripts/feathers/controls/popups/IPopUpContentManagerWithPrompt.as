package feathers.controls.popups {
	public interface IPopUpContentManagerWithPrompt extends IPopUpContentManager {
		function get prompt() : String;
		
		function set prompt(value:String) : void;
	}
}


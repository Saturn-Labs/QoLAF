package feathers.core {
	public interface IStateContext extends IFeathersEventDispatcher {
		function get currentState() : String;
	}
}


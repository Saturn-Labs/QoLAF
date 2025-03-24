package feathers.core {
	public interface IStateObserver {
		function get stateContext() : IStateContext;
		
		function set stateContext(value:IStateContext) : void;
	}
}


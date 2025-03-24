package feathers.core {
	import starling.events.Event;
	
	public interface IFeathersEventDispatcher {
		function addEventListener(type:String, listener:Function) : void;
		
		function removeEventListener(type:String, listener:Function) : void;
		
		function removeEventListeners(type:String = null) : void;
		
		function dispatchEvent(event:Event) : void;
		
		function dispatchEventWith(type:String, bubbles:Boolean = false, data:Object = null) : void;
		
		function hasEventListener(type:String, listener:Function = null) : Boolean;
	}
}


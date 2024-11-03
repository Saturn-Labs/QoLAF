package qolaf.events {
	import core.unit.Unit;
	import flash.events.Event;
	import qolaf.target.TargetSystem;
	
	/**
	 * ...
	 * @author 
	 */
	public class TargetUpdatedEvent extends Event {
		public static const EVENT:String = "target_updated_event";
		public var targetSystem:TargetSystem;
		
		public function TargetUpdatedEvent(type:String, targetSystem:TargetSystem, bubbles:Boolean=false, cancelable:Boolean=false) { 
			super(type, bubbles, cancelable);
			this.targetSystem = targetSystem;
		} 
		
		public override function clone():Event { 
			return new TargetUpdatedEvent(type, targetSystem, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("TargetUpdatedEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}
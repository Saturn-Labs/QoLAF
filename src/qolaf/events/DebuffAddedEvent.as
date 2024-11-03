package qolaf.events {
	import flash.events.Event;
	import qolaf.debuff.DebuffEffect;
	
	/**
	 * @author rydev
	 */
	public class DebuffAddedEvent extends Event {
		public static const EVENT:String = "debuff_added_event";
		public var effect:DebuffEffect;
		
		public function DebuffAddedEvent(type:String, effect:DebuffEffect, bubbles:Boolean = false, cancelable:Boolean = false) { 
			super(type, bubbles, cancelable);
			this.effect = effect;
		} 
		
		public override function clone():Event { 
			return new DebuffAddedEvent(type, effect, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("DebuffAddedEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
	}
}
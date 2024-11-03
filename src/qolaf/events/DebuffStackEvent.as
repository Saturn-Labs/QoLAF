package qolaf.events {
	import flash.events.Event;
	import qolaf.debuff.DebuffEffect;
	
	/**
	 * @author rydev
	 */
	public class DebuffStackEvent extends Event {
		public static const EVENT:String = "debuff_stack_event";
		public var effect:DebuffEffect;
		
		public function DebuffStackEvent(type:String, effect:DebuffEffect, bubbles:Boolean = false, cancelable:Boolean = false) { 
			super(type, bubbles, cancelable);
			this.effect = effect;
		} 
		
		public override function clone():Event { 
			return new DebuffStackEvent(type, effect, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("DebuffStackEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
	}
}
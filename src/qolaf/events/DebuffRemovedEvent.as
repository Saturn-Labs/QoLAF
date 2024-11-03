package qolaf.events {
	import flash.events.Event;
	import qolaf.debuff.DebuffEffect;
	
	/**
	 * @author rydev
	 */
	public class DebuffRemovedEvent extends Event {
		public static const EVENT:String = "debuff_removed_event";
		public var effect:DebuffEffect;
		
		public function DebuffRemovedEvent(type:String, effect:DebuffEffect, bubbles:Boolean = false, cancelable:Boolean = false) { 
			super(type, bubbles, cancelable);
			this.effect = effect;
		} 
		
		public override function clone():Event { 
			return new DebuffRemovedEvent(type, effect, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("DebuffRemovedEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
	}
}
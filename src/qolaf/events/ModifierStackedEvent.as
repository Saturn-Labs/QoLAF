package qolaf.events {
	import flash.events.Event;
	import qolaf.modifiers.Modifier;
	
	/**
	 * @author rydev
	 */
	public class ModifierStackedEvent extends Event {
		public static const EVENT:String = "modifier_stacked_event";
		public var modifier:Modifier;
		
		public function ModifierStackedEvent(type:String, modifier:Modifier, bubbles:Boolean = false, cancelable:Boolean = false) { 
			super(type, bubbles, cancelable);
			this.modifier = modifier;
		} 
		
		public override function clone():Event { 
			return new ModifierStackedEvent(type, modifier, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("ModifierStackedEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
	}
}
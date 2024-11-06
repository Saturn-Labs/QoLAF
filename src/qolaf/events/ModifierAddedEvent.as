package qolaf.events
{
	import flash.events.Event;
	import qolaf.modifiers.Modifier;

	/**
	 * @author rydev
	 */
	public class ModifierAddedEvent extends Event
	{
		public static const EVENT:String = "modifier_added_event";
		public var modifier:Modifier;
		public function ModifierAddedEvent(type:String, modifier:Modifier, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.modifier = modifier;
		}

		public override function clone():Event
		{
			return new ModifierAddedEvent(type, modifier, bubbles, cancelable);
		}

		public override function toString():String
		{
			return formatToString("ModifierAddedEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
	}
}
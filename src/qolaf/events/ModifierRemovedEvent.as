package qolaf.events
{
	import flash.events.Event;
	import qolaf.modifiers.Modifier;

	/**
	 * @author rydev
	 */
	public class ModifierRemovedEvent extends Event
	{
		public static const EVENT:String = "modifier_removed_event";
		public var modifier:Modifier;
		public function ModifierRemovedEvent(type:String, modifier:Modifier, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.modifier = modifier;
		}

		public override function clone():Event
		{
			return new ModifierRemovedEvent(type, modifier, bubbles, cancelable);
		}

		public override function toString():String
		{
			return formatToString("ModifierRemovedEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
	}
}
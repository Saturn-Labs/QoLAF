package qolaf.events
{
	import core.unit.Unit;
	import flash.events.Event;
	import qolaf.target.ITarget;
	import qolaf.target.TargetSystem;

	/**
	 * @author rydev
	 */
	public class TargetUpdatedEvent extends Event
	{
		public static const EVENT:String = "target_updated_event";
		public var updatedTarget:ITarget;
		public function TargetUpdatedEvent(type:String, target:ITarget, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.updatedTarget = target;
		}

		public override function clone():Event
		{
			return new TargetUpdatedEvent(type, updatedTarget, bubbles, cancelable);
		}

		public override function toString():String
		{
			return formatToString("TargetUpdatedEvent", "type", "bubbles", "cancelable", "eventPhase");
		}
	}
}
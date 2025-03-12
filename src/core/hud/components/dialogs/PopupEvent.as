package core.hud.components.dialogs
{
	import starling.events.Event;
	
	public class PopupEvent extends Event
	{
		public static const CLOSE:String = "close";
		public static const ACCEPT:String = "accept";
		public function PopupEvent(param1:String)
		{
			super(param1);
		}
	}
}

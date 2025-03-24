package playerio {
	import flash.events.Event;
	
	public class MessageEvent extends Event {
		public static const ON_MESSAGE:String = "onMessage";
		
		public var message:Message;
		
		public function MessageEvent(type:String, message:Message) {
			this.message = message;
			super(type);
		}
		
		override public function clone() : Event {
			return new MessageEvent(type,message);
		}
	}
}


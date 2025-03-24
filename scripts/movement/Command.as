package movement {
	public class Command {
		public static const CMD_ACCELERATE:int = 0;
		
		public static const CMD_ROTATELEFT:int = 1;
		
		public static const CMD_ROTATERIGHT:int = 2;
		
		public static const CMD_FIRE:int = 3;
		
		public static const CMD_BOOST:int = 4;
		
		public static const CMD_HARDENSHIELD:int = 5;
		
		public static const CMD_CONVERTSHIELD:int = 6;
		
		public static const CMD_DMGBOOST:int = 7;
		
		public static const CMD_DEACCELERATE:int = 8;
		
		public var type:int = -1;
		
		public var active:Boolean;
		
		public var time:Number;
		
		public function Command() {
			super();
		}
	}
}


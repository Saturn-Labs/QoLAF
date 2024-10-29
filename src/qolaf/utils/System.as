package qolaf.utils {
	import flash.system.Capabilities;
	import flash.ui.Multitouch;
	/**
	 * @author rydev
	 */
	
	public class System {
		public static function getOSName(): String {
			var os:String = Capabilities.os.split(" ")[0];
			if (os == "Linux" && Multitouch.supportsTouchEvents)
				os == "Android";
			os += " " + Capabilities.cpuArchitecture;
			return os;
		}
	}
}
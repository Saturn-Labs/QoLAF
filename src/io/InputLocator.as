package io
{
	import core.scene.Game;
	
	public class InputLocator
	{
		private static var input:IInput;
		
		public function InputLocator(param1:Game)
		{
			super();
		}
		
		public static function register(param1:IInput):void
		{
			input = param1;
		}
		
		public static function getService():IInput
		{
			return input;
		}
	}
}

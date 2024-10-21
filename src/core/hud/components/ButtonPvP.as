package core.hud.components
{
	
	public class ButtonPvP extends ButtonHud
	{
		public var text1:Text;
		
		public var text2:Text;
		
		private var callback:Function;
		
		private var maxWidthT1:int = 30;
		
		private var maxWidthT2:int = 30;
		
		public function ButtonPvP(param1:Function, param2:String)
		{
			super(param1, param2);
		}
		
		public function setText1(param1:String, param2:int = 18):void
		{
			if (text1 != null && text1.text == param1)
			{
				return;
			}
			if (text1 != null && contains(text1))
			{
				removeChild(text1);
			}
			text1 = new Text();
			text1.glowIn(0, 1, 2, 10);
			text1.size = param2;
			text1.text = param1;
			text1.x = 15;
			text1.y = 15 - param2 + 18;
			addChild(text1);
		}
		
		public function setText2(param1:String, param2:int = 26):void
		{
			if (text2 != null && text2.text == param1)
			{
				return;
			}
			if (text2 != null && contains(text2))
			{
				removeChild(text2);
			}
			text2 = new Text();
			text2.glowIn(0, 1, 2, 10);
			text2.size = param2;
			text2.text = param1;
			text2.x = 15;
			text2.y = 34 - param2 + 26;
			addChild(text2);
		}
	}
}

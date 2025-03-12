package core.states.gameStates.missions
{
	import core.scene.Game;
	import starling.display.Sprite;
	
	public class MissionsDaily extends Sprite
	{
		private var g:Game;
		
		private var list:DailyList;
		
		public function MissionsDaily(param1:Game)
		{
			super();
			this.g = param1;
			list = new DailyList(param1);
			addChild(list);
		}
		
		override public function dispose():void
		{
			super.dispose();
			list.dispose();
		}
	}
}

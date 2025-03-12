package core.states.menuStates
{
	import core.hud.components.Text;
	import core.hud.components.techTree.TechTree;
	import core.player.Player;
	import core.scene.Game;
	import core.states.DisplayState;
	
	public class UpgradesState extends DisplayState
	{
		private var techTree:TechTree;
		
		private var p:Player;
		
		public function UpgradesState(param1:Game, param2:Player)
		{
			super(param1, HomeState);
			this.p = param2;
		}
		
		override public function enter():void
		{
			super.enter();
			var _loc1_:Text = new Text();
			_loc1_.width = 300;
			_loc1_.wordWrap = true;
			_loc1_.font = "Verdana";
			_loc1_.size = 12;
			_loc1_.color = 11184810;
			_loc1_.x = 45;
			_loc1_.y = 80;
			_loc1_.text = "Upgrades can be bought at the upgrade station.";
			addChild(_loc1_);
			techTree = new TechTree(g, 400);
			techTree.load();
			techTree.x = 30;
			techTree.y = _loc1_.y + _loc1_.height;
			addChild(techTree);
		}
	}
}

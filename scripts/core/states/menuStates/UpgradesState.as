package core.states.menuStates {
	import core.hud.components.Text;
	import core.hud.components.techTree.TechTree;
	import core.player.Player;
	import core.scene.Game;
	import core.states.DisplayState;
	
	public class UpgradesState extends DisplayState {
		private var techTree:TechTree;
		
		private var p:Player;
		
		public function UpgradesState(g:Game, p:Player) {
			super(g,HomeState);
			this.p = p;
		}
		
		override public function enter() : void {
			super.enter();
			var _local1:Text = new Text();
			_local1.width = 5 * 60;
			_local1.wordWrap = true;
			_local1.font = "Verdana";
			_local1.size = 12;
			_local1.color = 0xaaaaaa;
			_local1.x = 45;
			_local1.y = 80;
			_local1.text = "Upgrades can be bought at the upgrade station.";
			addChild(_local1);
			techTree = new TechTree(g,400);
			techTree.load();
			techTree.x = 30;
			techTree.y = _local1.y + _local1.height;
			addChild(techTree);
		}
	}
}


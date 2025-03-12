package core.states.menuStates
{
	import core.hud.components.ToolTip;
	import core.hud.components.cargo.Cargo;
	import core.player.Player;
	import core.scene.Game;
	import core.states.DisplayState;
	
	public class CargoState extends DisplayState
	{
		private var cargo:Cargo;
		
		private var p:Player;
		
		public function CargoState(param1:Game, param2:Player, param3:Boolean = false)
		{
			super(param1, HomeState, param3);
			this.p = param2;
		}
		
		override public function get type():String
		{
			return "CargoState";
		}
		
		override public function enter():void
		{
			super.enter();
			cargo = g.myCargo;
			cargo.x = 80;
			cargo.y = 80;
			cargo.redraw();
			cargo.reloadCargoView(function():void
			{
				if (cargo != null)
				{
					addChild(cargo);
				}
				g.tutorial.showCompressorAdvice();
			});
		}
		
		override public function exit():void
		{
			super.exit();
			ToolTip.disposeType("compressor");
		}
	}
}

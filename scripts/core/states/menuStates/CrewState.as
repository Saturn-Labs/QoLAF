package core.states.menuStates {
	import core.hud.components.CrewDisplayBox;
	import core.hud.components.TextBitmap;
	import core.player.CrewMember;
	import core.player.Player;
	import core.scene.Game;
	import core.states.DisplayState;
	import feathers.controls.ScrollContainer;
	
	public class CrewState extends DisplayState {
		public static var WIDTH:Number = 698;
		
		public static var PADDING:Number = 31;
		
		private var p:Player;
		
		private var mainBody:ScrollContainer;
		
		private var crew:Vector.<CrewDisplayBox> = new Vector.<CrewDisplayBox>();
		
		public function CrewState(g:Game) {
			super(g,HomeState);
			this.p = g.me;
		}
		
		override public function enter() : void {
			super.enter();
			var _local1:TextBitmap = new TextBitmap();
			_local1.size = 24;
			_local1.format.color = 0xffffff;
			_local1.text = "Crew";
			_local1.x = 60;
			_local1.y = 50;
			addChild(_local1);
			mainBody = new ScrollContainer();
			mainBody.width = WIDTH;
			mainBody.height = 450;
			mainBody.x = 4;
			mainBody.y = 95;
			addChild(mainBody);
			load();
		}
		
		override public function execute() : void {
			for each(var _local1 in crew) {
				_local1.update();
			}
		}
		
		public function refresh() : void {
			for each(var _local1 in crew) {
				if(mainBody.contains(_local1)) {
					mainBody.removeChild(_local1);
				}
			}
			crew = new Vector.<CrewDisplayBox>();
			load();
		}
		
		private function load() : void {
			var _local2:CrewDisplayBox = null;
			var _local1:Vector.<CrewMember> = g.me.crewMembers;
			super.backButton.visible = false;
			var _local6:int = 0;
			var _local4:int = 70;
			var _local3:int = 330;
			var _local7:int = 28;
			for each(var _local5 in _local1) {
				_local2 = new CrewDisplayBox(g,_local5,null,p,false,this);
				_local2.x = _local4;
				_local2.y = _local7;
				if(_local6 % 2 == 0) {
					_local4 += _local3;
				} else {
					_local4 -= _local3;
					_local7 += _local2.height + 40;
				}
				_local6++;
				mainBody.addChild(_local2);
				crew.push(_local2);
			}
		}
	}
}


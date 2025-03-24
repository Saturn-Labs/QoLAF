package core.states.menuStates {
	import core.hud.components.CrewBuySlot;
	import core.hud.components.CrewDetails;
	import core.hud.components.CrewDisplayBoxNew;
	import core.player.CrewMember;
	import core.player.Player;
	import core.scene.Game;
	import core.states.DisplayState;
	import feathers.controls.ScrollContainer;
	import starling.events.Event;
	
	public class CrewStateNew extends DisplayState {
		public static var WIDTH:Number = 698;
		
		private var p:Player;
		
		private var mainBody:ScrollContainer;
		
		private var selectedCrewMember:CrewDetails;
		
		private var crew:Vector.<CrewDisplayBoxNew> = new Vector.<CrewDisplayBoxNew>();
		
		public function CrewStateNew(g:Game) {
			super(g,HomeState);
			this.p = g.me;
		}
		
		override public function enter() : void {
			super.enter();
			mainBody = new ScrollContainer();
			mainBody.width = WIDTH;
			mainBody.height = 450;
			mainBody.x = 0;
			mainBody.y = 35;
			addChild(mainBody);
			container.addEventListener("reloadDetails",onReloadDetails);
			container.addEventListener("crewSelected",setActive);
			load();
		}
		
		override public function execute() : void {
		}
		
		public function refresh() : void {
			for each(var _local1 in crew) {
				if(mainBody.contains(_local1)) {
					mainBody.removeChild(_local1);
				}
			}
			crew = new Vector.<CrewDisplayBoxNew>();
			load();
		}
		
		public function setActive(e:Event) : void {
			var _local2:CrewDisplayBoxNew = e.target as CrewDisplayBoxNew;
			if(selectedCrewMember != null) {
				removeChild(selectedCrewMember);
			}
			if(_local2 == null) {
				selectedCrewMember = new CrewDetails(g,null);
				addChild(selectedCrewMember);
				selectedCrewMember.x = 350;
				selectedCrewMember.y = 53;
			} else {
				selectedCrewMember = new CrewDetails(g,_local2.crewMember,reloadDetails);
				addChild(selectedCrewMember);
				selectedCrewMember.x = 350;
				selectedCrewMember.y = 53;
			}
		}
		
		private function onReloadDetails(e:Event) : void {
			reloadDetails();
		}
		
		public function reloadDetails(forceRefresh:Boolean = false) : void {
			if(!selectedCrewMember) {
				return;
			}
			var _local2:CrewDetails = new CrewDetails(g,selectedCrewMember.crewMember,reloadDetails);
			_local2.x = selectedCrewMember.x;
			_local2.y = selectedCrewMember.y;
			removeChild(selectedCrewMember);
			selectedCrewMember = _local2;
			addChild(selectedCrewMember);
			if(!forceRefresh) {
				return;
			}
			if(selectedCrewMember != null) {
				removeChild(selectedCrewMember);
			}
			refresh();
		}
		
		private function load() : void {
			var _local2:CrewDisplayBoxNew = null;
			var _local3:CrewBuySlot = null;
			var _local1:Vector.<CrewMember> = g.me.crewMembers;
			super.backButton.visible = false;
			var _local7:int = 0;
			var _local5:int = 60;
			var _local4:int = 330;
			var _local8:int = 25;
			for each(var _local6 in _local1) {
				_local2 = new CrewDisplayBoxNew(g,_local6,0);
				_local2.x = _local5;
				_local2.y = _local8;
				_local8 += _local2.height + 10;
				_local7++;
				mainBody.addChild(_local2);
				crew.push(_local2);
			}
			if(_local1.length < 4) {
				_local3 = new CrewBuySlot(g);
				_local3.x = _local5;
				_local3.y = _local8;
				mainBody.addChild(_local3);
			}
		}
		
		override public function exit() : void {
			container.removeEventListener("reloadDetails",onReloadDetails);
			container.removeEventListener("crewSelected",setActive);
			super.exit();
		}
	}
}


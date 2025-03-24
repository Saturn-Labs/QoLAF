package core.states.gameStates {
	import core.hud.components.CrewDetails;
	import core.hud.components.CrewDisplayBoxNew;
	import core.player.CrewMember;
	import core.scene.Game;
	import core.solarSystem.Body;
	import feathers.controls.ScrollContainer;
	import playerio.Message;
	import starling.events.Event;
	
	public class LandedCantina extends LandedState {
		public static var WIDTH:Number = 698;
		
		private var mainBody:ScrollContainer;
		
		private var selectedCrewMember:CrewDetails;
		
		private var crewMembers:Vector.<CrewMember>;
		
		private var crew:Vector.<CrewDisplayBoxNew> = new Vector.<CrewDisplayBoxNew>();
		
		public function LandedCantina(g:Game, body:Body) {
			super(g,body,body.name);
		}
		
		override public function enter() : void {
			super.enter();
			g.rpc("getCantinaCrew",onGetCantinaCrew);
		}
		
		private function onReloadDetails() : void {
			reloadDetails();
		}
		
		public function reloadDetails(forceRefresh:Boolean = false) : void {
			if(!selectedCrewMember) {
				return;
			}
			var _local2:CrewDetails = new CrewDetails(g,selectedCrewMember.crewMember,reloadDetails,false,1);
			_local2.requestRemovalCallback = removeActiveCrewMember;
			_local2.x = selectedCrewMember.x;
			_local2.y = selectedCrewMember.y;
			removeChild(selectedCrewMember);
			selectedCrewMember = _local2;
			addChild(selectedCrewMember);
		}
		
		private function removeActiveCrewMember(cd:CrewDetails) : void {
			var _local3:int = 0;
			var _local2:CrewDisplayBoxNew = null;
			removeChild(cd);
			_local3 = 0;
			while(_local3 < mainBody.numChildren) {
				if(mainBody.getChildAt(_local3) is CrewDisplayBoxNew) {
					_local2 = mainBody.getChildAt(_local3) as CrewDisplayBoxNew;
					if(_local2.crewMember.seed == cd.crewMember.seed) {
						mainBody.removeChild(_local2);
					}
				}
				_local3++;
			}
		}
		
		public function setActive(e:Event) : void {
			var _local2:CrewDisplayBoxNew = e.target as CrewDisplayBoxNew;
			if(selectedCrewMember != null) {
				removeChild(selectedCrewMember);
			}
			selectedCrewMember = new CrewDetails(g,_local2.crewMember,reloadDetails,false,1);
			selectedCrewMember.requestRemovalCallback = removeActiveCrewMember;
			addChild(selectedCrewMember);
			selectedCrewMember.x = 350;
			selectedCrewMember.y = 53;
		}
		
		private function onGetCantinaCrew(m:Message) : void {
			var _local4:CrewMember = null;
			var _local2:Array = null;
			var _local3:Array = null;
			crewMembers = new Vector.<CrewMember>();
			var _local5:int = 0;
			var _local6:int = m.getInt(_local5++);
			while(_local5 < m.length) {
				_local4 = new CrewMember(g);
				_local4.seed = m.getInt(_local5++);
				_local4.key = m.getString(_local5++);
				_local4.name = m.getString(_local5++);
				_local4.solarSystem = m.getString(_local5++);
				_local4.area = m.getString(_local5++);
				_local4.body = m.getString(_local5++);
				_local4.imageKey = m.getString(_local5++);
				_local4.injuryEnd = m.getNumber(_local5++);
				_local4.injuryStart = m.getNumber(_local5++);
				_local4.trainingEnd = m.getNumber(_local5++);
				_local4.trainingType = m.getInt(_local5++);
				_local4.artifactEnd = m.getNumber(_local5++);
				_local4.artifact = m.getString(_local5++);
				_local4.missions = m.getInt(_local5++);
				_local4.successMissions = m.getInt(_local5++);
				_local4.rank = m.getInt(_local5++);
				_local4.fullLocation = m.getString(_local5++);
				_local4.skillPoints = m.getInt(_local5++);
				_local2 = [];
				_local2.push(m.getNumber(_local5++));
				_local2.push(m.getNumber(_local5++));
				_local2.push(m.getNumber(_local5++));
				_local4.skills = _local2;
				_local3 = [];
				_local3.push(m.getNumber(_local5++));
				_local3.push(m.getNumber(_local5++));
				_local3.push(m.getNumber(_local5++));
				_local3.push(m.getNumber(_local5++));
				_local3.push(m.getNumber(_local5++));
				_local3.push(m.getNumber(_local5++));
				_local3.push(m.getNumber(_local5++));
				_local3.push(m.getNumber(_local5++));
				_local3.push(m.getNumber(_local5++));
				_local4.specials = _local3;
				crewMembers.push(_local4);
			}
			load();
		}
		
		private function load() : void {
			var _local1:CrewDisplayBoxNew = null;
			mainBody = new ScrollContainer();
			mainBody.width = WIDTH;
			mainBody.height = 450;
			mainBody.x = 0;
			mainBody.y = 35;
			mainBody.addEventListener("reloadDetails",onReloadDetails);
			mainBody.addEventListener("crewSelected",setActive);
			var _local5:int = 0;
			var _local3:int = 60;
			var _local2:int = 330;
			var _local6:int = 25;
			for each(var _local4 in crewMembers) {
				_local1 = new CrewDisplayBoxNew(g,_local4,1);
				_local1.x = _local3;
				_local1.y = _local6;
				_local6 += _local1.height + 10;
				_local5++;
				mainBody.addChild(_local1);
				crew.push(_local1);
			}
			addChild(mainBody);
			loadCompleted();
		}
		
		override public function execute() : void {
			super.execute();
		}
		
		override public function exit(callback:Function) : void {
			mainBody.removeEventListener("reloadDetails",onReloadDetails);
			mainBody.removeEventListener("crewSelected",setActive);
			super.exit(callback);
		}
	}
}


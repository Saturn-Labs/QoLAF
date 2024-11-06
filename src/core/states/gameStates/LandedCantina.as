package core.states.gameStates
{
	import core.hud.components.CrewDetails;
	import core.hud.components.CrewDisplayBoxNew;
	import core.player.CrewMember;
	import core.scene.Game;
	import core.solarSystem.Body;
	import feathers.controls.ScrollContainer;
	import playerio.Message;
	import starling.events.Event;

	public class LandedCantina extends LandedState
	{
		public static var WIDTH:Number = 698;
		private var mainBody:ScrollContainer;
		private var selectedCrewMember:CrewDetails;
		private var crewMembers:Vector.<CrewMember>;

		private var crew:Vector.<CrewDisplayBoxNew>;

		public function LandedCantina(param1:Game, param2:Body)
		{
			crew = new Vector.<CrewDisplayBoxNew>();
			super(param1, param2, param2.name);
		}

		override public function enter():void
		{
			super.enter();
			g.rpc("getCantinaCrew", onGetCantinaCrew);
		}

		private function onReloadDetails():void
		{
			reloadDetails();
		}

		public function reloadDetails(param1:Boolean = false):void
		{
			if (!selectedCrewMember)
			{
				return;
			}
			var _loc2_:CrewDetails = new CrewDetails(g, selectedCrewMember.crewMember, reloadDetails, false, 1);
			_loc2_.requestRemovalCallback = removeActiveCrewMember;
			_loc2_.x = selectedCrewMember.x;
			_loc2_.y = selectedCrewMember.y;
			removeChild(selectedCrewMember);
			selectedCrewMember = _loc2_;
			addChild(selectedCrewMember);
		}

		private function removeActiveCrewMember(param1:CrewDetails):void
		{
			var _loc3_:int = 0;
			var _loc2_:CrewDisplayBoxNew = null;
			removeChild(param1);
			_loc3_ = 0;
			while (_loc3_ < mainBody.numChildren)
			{
				if (mainBody.getChildAt(_loc3_) is CrewDisplayBoxNew)
				{
					_loc2_ = mainBody.getChildAt(_loc3_) as CrewDisplayBoxNew;
					if (_loc2_.crewMember.seed == param1.crewMember.seed)
					{
						mainBody.removeChild(_loc2_);
					}
				}
				_loc3_++;
			}
		}

		public function setActive(param1:Event):void
		{
			var _loc2_:CrewDisplayBoxNew = param1.target as CrewDisplayBoxNew;
			if (selectedCrewMember != null)
			{
				removeChild(selectedCrewMember);
			}
			selectedCrewMember = new CrewDetails(g, _loc2_.crewMember, reloadDetails, false, 1);
			selectedCrewMember.requestRemovalCallback = removeActiveCrewMember;
			addChild(selectedCrewMember);
			selectedCrewMember.x = 350;
			selectedCrewMember.y = 53;
		}

		private function onGetCantinaCrew(param1:Message):void
		{
			var _loc4_:CrewMember = null;
			var _loc2_:Array = null;
			var _loc5_:Array = null;
			crewMembers = new Vector.<CrewMember>();
			var _loc6_:int = 0;
			var _loc3_:int = param1.getInt(_loc6_++ );
			while (_loc6_ < param1.length)
			{
				_loc4_ = new CrewMember(g);
				_loc4_.seed = param1.getInt(_loc6_++ );
				_loc4_.key = param1.getString(_loc6_++ );
				_loc4_.name = param1.getString(_loc6_++ );
				_loc4_.solarSystem = param1.getString(_loc6_++ );
				_loc4_.area = param1.getString(_loc6_++ );
				_loc4_.body = param1.getString(_loc6_++ );
				_loc4_.imageKey = param1.getString(_loc6_++ );
				_loc4_.injuryEnd = param1.getNumber(_loc6_++ );
				_loc4_.injuryStart = param1.getNumber(_loc6_++ );
				_loc4_.trainingEnd = param1.getNumber(_loc6_++ );
				_loc4_.trainingType = param1.getInt(_loc6_++ );
				_loc4_.artifactEnd = param1.getNumber(_loc6_++ );
				_loc4_.artifact = param1.getString(_loc6_++ );
				_loc4_.missions = param1.getInt(_loc6_++ );
				_loc4_.successMissions = param1.getInt(_loc6_++ );
				_loc4_.rank = param1.getInt(_loc6_++ );
				_loc4_.fullLocation = param1.getString(_loc6_++ );
				_loc4_.skillPoints = param1.getInt(_loc6_++ );
				_loc2_ = [];
				_loc2_.push(param1.getNumber(_loc6_++ ));
				_loc2_.push(param1.getNumber(_loc6_++ ));
				_loc2_.push(param1.getNumber(_loc6_++ ));
				_loc4_.skills = _loc2_;
				_loc5_ = [];
				_loc5_.push(param1.getNumber(_loc6_++ ));
				_loc5_.push(param1.getNumber(_loc6_++ ));
				_loc5_.push(param1.getNumber(_loc6_++ ));
				_loc5_.push(param1.getNumber(_loc6_++ ));
				_loc5_.push(param1.getNumber(_loc6_++ ));
				_loc5_.push(param1.getNumber(_loc6_++ ));
				_loc5_.push(param1.getNumber(_loc6_++ ));
				_loc5_.push(param1.getNumber(_loc6_++ ));
				_loc5_.push(param1.getNumber(_loc6_++ ));
				_loc4_.specials = _loc5_;
				crewMembers.push(_loc4_);
			}
			load();
		}

		private function load():void
		{
			var _loc2_:CrewDisplayBoxNew = null;
			mainBody = new ScrollContainer();
			mainBody.width = WIDTH;
			mainBody.height = 450;
			mainBody.x = 0;
			mainBody.y = 35;
			mainBody.addEventListener("reloadDetails", onReloadDetails);
			mainBody.addEventListener("crewSelected", setActive);
			var _loc6_:int = 0;
			var _loc5_:int = 60;
			var _loc1_:int = 330;
			var _loc4_:int = 25;
			for each (var _loc3_:* in crewMembers)
			{
				_loc2_ = new CrewDisplayBoxNew(g, _loc3_, 1);
				_loc2_.x = _loc5_;
				_loc2_.y = _loc4_;
				_loc4_ += _loc2_.height + 10;
				_loc6_++;
				mainBody.addChild(_loc2_);
				crew.push(_loc2_);
			}
			addChild(mainBody);
			loadCompleted();
		}

		override public function execute():void
		{
			super.execute();
		}

		override public function exit(param1:Function):void
		{
			mainBody.removeEventListener("reloadDetails", onReloadDetails);
			mainBody.removeEventListener("crewSelected", setActive);
			super.exit(param1);
		}
	}
}

package core.states.menuStates
{
	import core.hud.components.CrewDisplayBox;
	import core.hud.components.TextBitmap;
	import core.player.CrewMember;
	import core.player.Player;
	import core.scene.Game;
	import core.states.DisplayState;
	import feathers.controls.ScrollContainer;
	
	public class CrewState extends DisplayState
	{
		public static var WIDTH:Number = 698;
		public static var PADDING:Number = 31;
		private var p:Player;
		
		private var mainBody:ScrollContainer;
		
		private var crew:Vector.<CrewDisplayBox>;
		
		public function CrewState(param1:Game)
		{
			crew = new Vector.<CrewDisplayBox>();
			super(param1, HomeState);
			this.p = param1.me;
		}
		
		override public function enter():void
		{
			super.enter();
			var _loc1_:TextBitmap = new TextBitmap();
			_loc1_.size = 24;
			_loc1_.format.color = 16777215;
			_loc1_.text = "Crew";
			_loc1_.x = 60;
			_loc1_.y = 50;
			addChild(_loc1_);
			mainBody = new ScrollContainer();
			mainBody.width = WIDTH;
			mainBody.height = 450;
			mainBody.x = 4;
			mainBody.y = 95;
			addChild(mainBody);
			load();
		}
		
		override public function execute():void
		{
			for each (var _loc1_:* in crew)
			{
				_loc1_.update();
			}
		}
		
		public function refresh():void
		{
			for each (var _loc1_:* in crew)
			{
				if (mainBody.contains(_loc1_))
				{
					mainBody.removeChild(_loc1_);
				}
			}
			crew = new Vector.<CrewDisplayBox>();
			load();
		}
		
		private function load():void
		{
			var _loc2_:CrewDisplayBox = null;
			var _loc3_:Vector.<CrewMember> = g.me.crewMembers;
			super.backButton.visible = false;
			var _loc7_:int = 0;
			var _loc6_:int = 70;
			var _loc1_:int = 330;
			var _loc5_:int = 28;
			for each (var _loc4_:* in _loc3_)
			{
				_loc2_ = new CrewDisplayBox(g, _loc4_, null, p, false, this);
				_loc2_.x = _loc6_;
				_loc2_.y = _loc5_;
				if (_loc7_ % 2 == 0)
				{
					_loc6_ += _loc1_;
				}
				else
				{
					_loc6_ -= _loc1_;
					_loc5_ += _loc2_.height + 40;
				}
				_loc7_++;
				mainBody.addChild(_loc2_);
				crew.push(_loc2_);
			}
		}
	}
}

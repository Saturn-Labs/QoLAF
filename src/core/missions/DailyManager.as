package core.missions
{
	import core.player.Player;
	import core.scene.Game;
	import core.states.gameStates.missions.Daily;
	import playerio.Message;
	
	public class DailyManager
	{
		private var g:Game;
		
		public var resetTime:Number;
		
		public function DailyManager(param1:Game)
		{
			super();
			this.g = param1;
		}
		
		public function addMessageHandlers():void
		{
			g.addMessageHandler("dailyMissionsProgress", m_updateProgress);
			g.addMessageHandler("dailyMissionsComplete", m_setComplete);
			g.addMessageHandler("dailyMissionsReset", m_reset);
			g.addMessageHandler("dailyMissionArtifact", m_addArtifactReward);
		}
		
		public function initDailyMissionsFromMessage(param1:Message, param2:int):int
		{
			var _loc5_:Daily = null;
			var _loc4_:Object = g.dataManager.loadTable("DailyMissions");
			for (var _loc6_:* in _loc4_)
			{
				g.me.dailyMissions.push(new Daily(_loc6_, _loc4_[_loc6_]));
			}
			resetTime = param1.getNumber(param2);
			var _loc3_:int = param1.getInt(param2 + 1);
			var _loc7_:int = param2 + 2;
			while (_loc3_ > 0)
			{
				_loc5_ = getDaily(param1.getString(_loc7_++));
				if (_loc5_)
				{
					_loc5_.status = param1.getInt(_loc7_++);
					_loc5_.progress = param1.getInt(_loc7_++);
				}
				else
				{
					_loc7_ += 2;
				}
				_loc3_--;
			}
			return _loc7_;
		}
		
		private function getDaily(param1:String):Daily
		{
			for each (var _loc2_:* in g.me.dailyMissions)
			{
				if (_loc2_.key == param1)
				{
					return _loc2_;
				}
			}
			return null;
		}
		
		private function m_updateProgress(param1:Message):void
		{
			var _loc4_:String = param1.getString(0);
			var _loc2_:int = param1.getInt(1);
			var _loc3_:Daily = getDaily(_loc4_);
			if (_loc3_)
			{
				_loc3_.progress = _loc2_;
				g.textManager.createDailyUpdate(_loc3_.name + " " + Math.floor(_loc2_ / _loc3_.missionGoal * 100) + "%");
			}
		}
		
		private function m_setComplete(param1:Message):void
		{
			var _loc3_:String = param1.getString(0);
			var _loc2_:Daily = getDaily(_loc3_);
			if (_loc2_)
			{
				_loc2_.status = 1;
				g.hud.missionsButton.hintFinished();
				g.textManager.createDailyUpdate("Daily complete!");
			}
		}
		
		private function m_reset(param1:Message):void
		{
			var _loc3_:String = param1.getString(0);
			var _loc2_:Daily = getDaily(_loc3_);
			if (_loc2_)
			{
				_loc2_.status = 0;
				_loc2_.progress = 0;
			}
		}
		
		public function addReward(param1:Message):void
		{
			var _loc5_:int = 0;
			var _loc4_:String = null;
			var _loc3_:String = null;
			var _loc2_:int = 0;
			if (g.me == null || g.myCargo == null)
			{
				return;
			}
			_loc5_ = 0;
			while (_loc5_ < param1.length)
			{
				_loc4_ = param1.getString(_loc5_);
				_loc3_ = param1.getString(_loc5_ + 1);
				_loc2_ = param1.getInt(_loc5_ + 2);
				if (_loc4_ != "xp")
				{
					g.myCargo.addItem("Commodities", _loc3_, _loc2_);
					g.hud.resourceBox.update();
				}
				_loc5_ += 3;
			}
		}
		
		private function m_addArtifactReward(param1:Message):void
		{
			var _loc2_:Player = g.me;
			if (_loc2_ == null)
			{
				return;
			}
			g.me.pickupArtifact(param1);
		}
	}
}

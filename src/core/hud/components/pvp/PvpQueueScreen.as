package core.hud.components.pvp
{
	import core.hud.components.Box;
	import core.hud.components.ButtonQueue;
	import core.hud.components.Text;
	import core.scene.Game;
	import generics.Localize;
	
	public class PvpQueueScreen extends PvpScreen
	{
		private var buttons:Vector.<ButtonQueue>;
		
		public function PvpQueueScreen(param1:Game)
		{
			buttons = new Vector.<ButtonQueue>();
			super(param1);
		}
		
		override public function load():void
		{
			var _loc3_:Number = NaN;
			var _loc2_:ButtonQueue = null;
			super.load();
			var _loc5_:int = -70;
			var _loc4_:Box = new Box(620, 80, "light", 0.75, 20);
			_loc4_.x = 65;
			_loc4_.y = 92;
			addChild(_loc4_);
			_loc4_ = new Box(620, 148, "light", 0.75, 20);
			_loc4_.x = 65;
			_loc4_.y = _loc5_ + 305;
			addChild(_loc4_);
			_loc4_ = new Box(620, 88, "light", 0.75, 20);
			_loc4_.x = 65;
			_loc4_.y = _loc5_ + 516;
			addChild(_loc4_);
			var _loc1_:Text = new Text();
			_loc1_.size = 22;
			_loc1_.color = 5635925;
			_loc1_.x = 175;
			_loc1_.y = 35;
			_loc1_.htmlText = Localize.t("Player Vs Player Combat");
			addChild(_loc1_);
			_loc1_ = new Text();
			_loc1_.size = 16;
			_loc1_.color = 8978312;
			_loc1_.x = 55;
			_loc1_.y = 82;
			_loc1_.htmlText = Localize.t("Your PvP statistics:");
			addChild(_loc1_);
			_loc1_ = new Text();
			_loc1_.size = 14;
			_loc1_.color = 11184810;
			_loc1_.x = 60;
			_loc1_.y = 112;
			_loc1_.htmlText = Localize.t("Name: \nRank: \nPvP Troons:");
			_loc1_.height = 150;
			addChild(_loc1_);
			_loc1_ = new Text();
			_loc1_.size = 14;
			_loc1_.color = 11184810;
			_loc1_.x = 360;
			_loc1_.y = 112;
			_loc1_.htmlText = Localize.t("PvP kills: \nPvP deaths: \nK/D Ratio:");
			_loc1_.height = 150;
			addChild(_loc1_);
			if (g.me.playerDeaths == 0)
			{
				_loc3_ = 0;
			}
			else
			{
				_loc3_ = g.me.playerKills / g.me.playerDeaths;
			}
			_loc1_ = new Text();
			_loc1_.size = 14;
			_loc1_.color = 16777215;
			_loc1_.x = 250;
			_loc1_.y = 112;
			_loc1_.htmlText = g.me.name + "\nxxx" + "\n" + g.me.troons + "\n";
			_loc1_.alignLeft();
			_loc1_.height = 150;
			_loc1_ = new Text();
			_loc1_.size = 14;
			_loc1_.color = 16777215;
			_loc1_.x = 550;
			_loc1_.y = 112;
			_loc1_.htmlText = g.me.playerKills + "\n" + g.me.playerDeaths + "\n" + _loc3_.toPrecision(2);
			_loc1_.alignLeft();
			_loc1_.height = 150;
			addChild(_loc1_);
			_loc1_ = new Text();
			_loc1_.size = 16;
			_loc1_.color = 8978312;
			_loc1_.x = 55;
			_loc1_.y = _loc5_ + 295;
			_loc1_.htmlText = Localize.t("Normal PvP Matches:");
			addChild(_loc1_);
			_loc1_ = new Text();
			_loc1_.size = 14;
			_loc1_.color = 5635925;
			_loc1_.x = 270;
			_loc1_.y = _loc5_ + 330;
			_loc1_.htmlText = Localize.t("Random PvP Match");
			addChild(_loc1_);
			_loc1_ = new Text();
			_loc1_.size = 14;
			_loc1_.color = 5635925;
			_loc1_.x = 270;
			_loc1_.y = _loc5_ + 365;
			_loc1_.htmlText = Localize.t("Domination Team-PvP");
			addChild(_loc1_);
			_loc1_ = new Text();
			_loc1_.size = 14;
			_loc1_.color = 5635925;
			_loc1_.x = 270;
			_loc1_.y = _loc5_ + 400;
			_loc1_.htmlText = Localize.t("Deathmatch");
			addChild(_loc1_);
			_loc1_ = new Text();
			_loc1_.size = 14;
			_loc1_.color = 5635925;
			_loc1_.x = 270;
			_loc1_.y = _loc5_ + 435;
			_loc1_.htmlText = Localize.t("Arena");
			addChild(_loc1_);
			_loc2_ = new ButtonQueue(g, "pvp random", g.queueManager.getQueue("pvp random"), false);
			_loc2_.x = 60;
			_loc2_.y = _loc5_ + 328;
			addChild(_loc2_);
			buttons.push(_loc2_);
			_loc2_ = new ButtonQueue(g, "pvp dom", g.queueManager.getQueue("pvp dom"));
			_loc2_.x = 60;
			_loc2_.y = _loc5_ + 363;
			addChild(_loc2_);
			buttons.push(_loc2_);
			_loc2_ = new ButtonQueue(g, "pvp dm", g.queueManager.getQueue("pvp dm"));
			_loc2_.x = 60;
			_loc2_.y = _loc5_ + 398;
			addChild(_loc2_);
			buttons.push(_loc2_);
			_loc2_ = new ButtonQueue(g, "pvp arena", g.queueManager.getQueue("pvp arena"), false);
			_loc2_.x = 60;
			_loc2_.y = _loc5_ + 433;
			addChild(_loc2_);
			buttons.push(_loc2_);
		}
		
		override public function update():void
		{
			for each (var _loc1_:* in buttons)
			{
				_loc1_.update();
			}
		}
	}
}

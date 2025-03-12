package core.hud.components.pvp
{
	import core.hud.components.Box;
	import core.hud.components.Text;
	import starling.display.Sprite;
	
	public class PvpScoreHolder
	{
		public var img:Sprite;
		
		public var playerKey:String;
		
		public var playerName:String;
		
		public var isMe:Boolean;
		
		public var type:String;
		
		public var rank:int;
		
		public var score:int;
		
		public var kills:int;
		
		public var deaths:int;
		
		public var xpSum:int;
		
		public var steelSum:int;
		
		public var plasmaSum:int;
		
		public var iridiumSum:int;
		
		public var hydrogenSum:int;
		
		public var damageSum:int;
		
		public var healingSum:int;
		
		public var bonusPercent:int;
		
		private var nameText:Text;
		
		private var rankText:Text;
		
		private var scoreText:Text;
		
		private var killsText:Text;
		
		private var deathText:Text;
		
		private var damageText:Text;
		
		private var bonusText:Text;
		
		private var ratingText:Text;
		
		public var first:int;
		
		public var second:int;
		
		public var third:int;
		
		public var hotStreak3:int;
		
		public var hotStreak10:int;
		
		public var defZone:int;
		
		public var capZone:int;
		
		public var noDeaths:int;
		
		public var brokeKillingSpree:int;
		
		public var pickups:int;
		
		public var dailyBonus:int;
		
		public var rating:Number;
		
		public var ratingChange:Number;
		
		public var afk:Boolean;
		
		public var team:int;
		
		private var bg:Box;
		
		public function PvpScoreHolder(param1:String, param2:String, param3:Boolean, param4:String)
		{
			super();
			this.type = param4;
			this.playerKey = param1;
			this.playerName = param2;
			this.isMe = param3;
			rank = 1;
			score = 0;
			kills = 0;
			deaths = 0;
			xpSum = 0;
			steelSum = 0;
			plasmaSum = 0;
			iridiumSum = 0;
			hydrogenSum = 0;
			damageSum = 0;
			healingSum = 0;
			bonusPercent = 0;
			team = -1;
			first = 0;
			second = 0;
			third = 0;
			hotStreak3 = 0;
			hotStreak10 = 0;
			noDeaths = 0;
			brokeKillingSpree = 0;
			pickups = 0;
			dailyBonus = 0;
			rating = 0;
			ratingChange = 0;
			capZone = 0;
			defZone = 0;
		}
		
		public function load():void
		{
			img = new Sprite();
			if (isMe)
			{
				bg = new Box(610, 30, "highlight", 0.5, 10);
			}
			else
			{
				bg = new Box(610, 30, "light", 0.5, 10);
			}
			img.addChild(bg);
			var _loc1_:int = 10;
			rankText = new Text();
			rankText.x = _loc1_;
			rankText.y = 2;
			rankText.color = 5635925;
			rankText.size = 12;
			bg.addChild(rankText);
			_loc1_ += 50;
			nameText = new Text();
			nameText.x = _loc1_;
			nameText.y = 2;
			nameText.color = 5635925;
			nameText.size = 12;
			bg.addChild(nameText);
			if (type == "pvp dom")
			{
				_loc1_ += 150;
			}
			else
			{
				_loc1_ += 180;
			}
			scoreText = new Text();
			scoreText.x = _loc1_;
			scoreText.y = 2;
			scoreText.color = 5635925;
			scoreText.size = 12;
			bg.addChild(scoreText);
			if (type == "pvp dom")
			{
				_loc1_ += 50;
			}
			else
			{
				_loc1_ += 70;
			}
			if (type == "pvp dom")
			{
				killsText = new Text();
				killsText.x = _loc1_;
				killsText.y = 2;
				killsText.color = 5635925;
				killsText.size = 12;
				bg.addChild(killsText);
				_loc1_ += 60;
			}
			deathText = new Text();
			deathText.x = _loc1_;
			deathText.y = 2;
			deathText.color = 5635925;
			deathText.size = 12;
			bg.addChild(deathText);
			if (type == "pvp dom")
			{
				_loc1_ += 50;
			}
			else
			{
				_loc1_ += 70;
			}
			damageText = new Text();
			damageText.x = _loc1_;
			damageText.y = 2;
			damageText.color = 5635925;
			damageText.size = 12;
			bg.addChild(damageText);
			if (type == "pvp dom")
			{
				_loc1_ += 100;
			}
			else
			{
				_loc1_ += 80;
			}
			bonusText = new Text();
			bonusText.x = _loc1_;
			bonusText.y = 2;
			bonusText.color = 5592575;
			bonusText.size = 12;
			bg.addChild(bonusText);
			_loc1_ += 80;
			ratingText = new Text();
			ratingText.x = _loc1_;
			ratingText.y = 2;
			ratingText.color = 5592575;
			ratingText.size = 12;
			bg.addChild(ratingText);
		}
		
		public function addDamage(param1:int):void
		{
			damageSum += param1;
			if (damageText != null)
			{
				damageText.text = damageSum.toString();
			}
		}
		
		public function addHealing(param1:int):void
		{
			healingSum += param1;
		}
		
		public function update(param1:Boolean = false, param2:Boolean = false):void
		{
			var _loc3_:* = 5635925;
			if (param1 == true)
			{
				if (param2 == true)
				{
					_loc3_ = 5592575;
					rankText.text = "Blue";
				}
				else
				{
					_loc3_ = 16733525;
					rankText.text = "Red";
				}
			}
			else
			{
				rankText.text = "#" + rank;
			}
			rankText.color = _loc3_;
			nameText.color = _loc3_;
			nameText.text = playerName;
			scoreText.color = _loc3_;
			scoreText.text = score.toString();
			if (type == "pvp dom")
			{
				killsText.color = _loc3_;
				killsText.text = kills.toString();
			}
			deathText.color = _loc3_;
			deathText.text = deaths.toString();
			damageText.color = _loc3_;
			damageText.text = damageSum.toString();
			bonusText.color = _loc3_;
			bonusText.text = bonusPercent - 100 + "%";
			if (ratingChange > 0)
			{
				ratingText.color = 5635925;
				ratingText.text = Math.floor(rating).toString() + " (+" + Math.floor(ratingChange).toString() + ")";
			}
			else if (ratingChange < 0)
			{
				ratingText.color = 16733525;
				ratingText.text = Math.floor(rating).toString() + " (" + Math.floor(ratingChange).toString() + ")";
			}
			else
			{
				ratingText.color = 16777215;
				ratingText.text = Math.floor(rating).toString();
			}
		}
	}
}

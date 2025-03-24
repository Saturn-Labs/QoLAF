package core.hud.components.pvp {
	import core.hud.components.Box;
	import core.hud.components.Text;
	import starling.display.Sprite;
	
	public class PvpScoreHolder {
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
		
		public function PvpScoreHolder(playerKey:String, playerName:String, isMe:Boolean, type:String) {
			super();
			this.type = type;
			this.playerKey = playerKey;
			this.playerName = playerName;
			this.isMe = isMe;
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
		
		public function load() : void {
			img = new Sprite();
			if(isMe) {
				bg = new Box(610,30,"highlight",0.5,10);
			} else {
				bg = new Box(610,30,"light",0.5,10);
			}
			img.addChild(bg);
			var _local1:int = 10;
			rankText = new Text();
			rankText.x = _local1;
			rankText.y = 2;
			rankText.color = 0x55ff55;
			rankText.size = 12;
			bg.addChild(rankText);
			_local1 += 50;
			nameText = new Text();
			nameText.x = _local1;
			nameText.y = 2;
			nameText.color = 0x55ff55;
			nameText.size = 12;
			bg.addChild(nameText);
			if(type == "pvp dom") {
				_local1 += 150;
			} else {
				_local1 += 3 * 60;
			}
			scoreText = new Text();
			scoreText.x = _local1;
			scoreText.y = 2;
			scoreText.color = 0x55ff55;
			scoreText.size = 12;
			bg.addChild(scoreText);
			if(type == "pvp dom") {
				_local1 += 50;
			} else {
				_local1 += 70;
			}
			if(type == "pvp dom") {
				killsText = new Text();
				killsText.x = _local1;
				killsText.y = 2;
				killsText.color = 0x55ff55;
				killsText.size = 12;
				bg.addChild(killsText);
				_local1 += 60;
			}
			deathText = new Text();
			deathText.x = _local1;
			deathText.y = 2;
			deathText.color = 0x55ff55;
			deathText.size = 12;
			bg.addChild(deathText);
			if(type == "pvp dom") {
				_local1 += 50;
			} else {
				_local1 += 70;
			}
			damageText = new Text();
			damageText.x = _local1;
			damageText.y = 2;
			damageText.color = 0x55ff55;
			damageText.size = 12;
			bg.addChild(damageText);
			if(type == "pvp dom") {
				_local1 += 100;
			} else {
				_local1 += 80;
			}
			bonusText = new Text();
			bonusText.x = _local1;
			bonusText.y = 2;
			bonusText.color = 0x5555ff;
			bonusText.size = 12;
			bg.addChild(bonusText);
			_local1 += 80;
			ratingText = new Text();
			ratingText.x = _local1;
			ratingText.y = 2;
			ratingText.color = 0x5555ff;
			ratingText.size = 12;
			bg.addChild(ratingText);
		}
		
		public function addDamage(dmg:int) : void {
			damageSum += dmg;
			if(damageText != null) {
				damageText.text = damageSum.toString();
			}
		}
		
		public function addHealing(heal:int) : void {
			healingSum += heal;
		}
		
		public function update(isDomination:Boolean = false, myTeam:Boolean = false) : void {
			var _local3:* = 5635925;
			if(isDomination == true) {
				if(myTeam == true) {
					_local3 = 0x5555ff;
					rankText.text = "Blue";
				} else {
					_local3 = 0xff5555;
					rankText.text = "Red";
				}
			} else {
				rankText.text = "#" + rank;
			}
			rankText.color = _local3;
			nameText.color = _local3;
			nameText.text = playerName;
			scoreText.color = _local3;
			scoreText.text = score.toString();
			if(type == "pvp dom") {
				killsText.color = _local3;
				killsText.text = kills.toString();
			}
			deathText.color = _local3;
			deathText.text = deaths.toString();
			damageText.color = _local3;
			damageText.text = damageSum.toString();
			bonusText.color = _local3;
			bonusText.text = bonusPercent - 100 + "%";
			if(ratingChange > 0) {
				ratingText.color = 0x55ff55;
				ratingText.text = Math.floor(rating).toString() + " (+" + Math.floor(ratingChange).toString() + ")";
			} else if(ratingChange < 0) {
				ratingText.color = 0xff5555;
				ratingText.text = Math.floor(rating).toString() + " (" + Math.floor(ratingChange).toString() + ")";
			} else {
				ratingText.color = 0xffffff;
				ratingText.text = Math.floor(rating).toString();
			}
		}
	}
}


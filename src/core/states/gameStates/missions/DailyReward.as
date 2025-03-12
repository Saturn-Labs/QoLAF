package core.states.gameStates.missions
{
	import core.hud.components.ToolTip;
	import core.scene.Game;
	import core.states.gameStates.RoamingState;
	import core.states.gameStates.ShopState;
	import data.DataLocator;
	import generics.Localize;
	import generics.Util;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.TouchEvent;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class DailyReward extends Sprite
	{
		private static var textureManager:ITextureManager;
		
		private var g:Game;
		
		private var daily:Daily;
		
		public function DailyReward(param1:Game, param2:Daily)
		{
			super();
			this.g = param1;
			this.daily = param2;
			textureManager = TextureLocator.getService();
			draw();
		}
		
		public function draw():void
		{
			var key:String;
			var rewardKey:String;
			var reward:Object;
			var itemImage:Image;
			var quantityText:TextField;
			var boostText:TextField;
			var item:Object;
			var baseXp:int;
			var s:String;
			var boostXp:int;
			var text:String;
			var toolTipText:String;
			var xpBoostIcon:Image;
			var xpos:int = 0;
			for (key in daily.reward)
			{
				rewardKey = daily.reward[key];
				reward = DataLocator.getService().loadKey("DailyMissionRewards", rewardKey);
				quantityText = new TextField(120, 18, "", new TextFormat("font13", 13, 11184810, "left"));
				quantityText.batchable = true;
				quantityText.text = Util.formatAmount(getRewardAmount(reward));
				quantityText.autoSize = "horizontal";
				addChild(quantityText);
				boostText = new TextField(120, 18, "", new TextFormat("font13", 13, 11184810, "left"));
				boostText.batchable = true;
				boostText.autoSize = "horizontal";
				if (reward.itemKey)
				{
					item = DataLocator.getService().loadKey("Commodities", reward.itemKey);
					itemImage = new Image(textureManager.getTextureGUIByKey(item.bitmap));
					new ToolTip(g, itemImage, item.name, null, "dailyView");
				}
				else if (reward.key == "xp")
				{
					baseXp = getRewardAmount(reward);
					s = "";
					boostXp = Math.ceil(baseXp * 0.3);
					if (g.me.hasExpBoost)
					{
						s = Localize.t("XP") + " " + int(baseXp * 0.75);
						boostText.format.color = 8978312;
						new ToolTip(g, quantityText, Localize.t("You have XP BOOST enabled!."), null, "dailyView");
					}
					else
					{
						s = Localize.t("XP") + " " + baseXp;
						boostText.format.color = 3355443;
						new ToolTip(g, quantityText, Localize.t("You don't have any XP BOOST active, get one if you want to gain more <FONT COLOR='#FFFFFF'>[xpBoost]%</FONT> more XP.").replace("[xpBoost]", 0.3 * 100), null, "dailyView");
					}
					boostText.text = "(" + boostXp + ")";
					quantityText.text = s;
					addChild(boostText);
				}
				else if (reward.key == "artifact")
				{
					itemImage = new Image(textureManager.getTextureGUIByTextureName("artifact_icon.png"));
					text = Localize.t("artifact potential level [level]").replace("[level]", int(10 + Math.ceil(0.7 * g.me.level)));
					new ToolTip(g, itemImage, text, null, "dailyView");
				}
				else if (reward.key == "pod")
				{
					itemImage = new Image(textureManager.getTextureGUIByTextureName("pod_small"));
					itemImage.scaleX = 0.5;
					itemImage.scaleY = 0.5;
					text = Localize.t("pod with random loot");
					quantityText.text = "1";
					new ToolTip(g, itemImage, text, null, "dailyView");
				}
				if (itemImage)
				{
					itemImage.x = xpos;
					itemImage.y = Math.floor(9 - itemImage.height / 2);
					xpos += itemImage.width + 2;
					addChild(itemImage);
				}
				quantityText.x = xpos;
				xpos += quantityText.width + 8;
				if (boostText.text != "")
				{
					boostText.x = xpos;
					xpos += boostText.width + 5;
				}
				if (!g.me.hasExpBoost && reward.key == "xp")
				{
					toolTipText = Localize.t("Get XP BOOST now!");
					xpBoostIcon = new Image(textureManager.getTextureGUIByTextureName("button_pay"));
					xpBoostIcon.useHandCursor = true;
					xpBoostIcon.addEventListener("touch", function(param1:TouchEvent):void
					{
						if (param1.getTouch(xpBoostIcon, "ended"))
						{
							g.enterState(new RoamingState(g));
							g.enterState(new ShopState(g, "xpBoost"));
						}
					});
					xpBoostIcon.x = xpos;
					xpos += xpBoostIcon.width + 5;
					xpBoostIcon.y = boostText.y;
					addChild(xpBoostIcon);
					new ToolTip(g, xpBoostIcon, toolTipText, null, "dailyView");
				}
				xpos += 20;
			}
		}
		
		public function getRewardAmount(param1:Object):int
		{
			var _loc2_:int = 0;
			if (param1.key == "artifact")
			{
				return 1;
			}
			return int(param1.k1 + param1.k2 * g.me.level);
		}
	}
}

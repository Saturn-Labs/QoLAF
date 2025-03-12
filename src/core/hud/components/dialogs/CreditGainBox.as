package core.hud.components.dialogs
{
	import core.hud.components.Text;
	import core.scene.Game;
	import starling.display.Image;
	import starling.events.Event;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class CreditGainBox extends PopupMessage
	{
		private var g:Game;
		
		private var targetName:String;
		
		private var countText:Text;
		
		private var countText2:Text;
		
		private var creditBmp:Image;
		
		private var podsBmp:Image;
		
		public function CreditGainBox(param1:Game, param2:int, param3:int, param4:String, param5:String = "")
		{
			var _loc8_:Texture = null;
			countText = new Text();
			countText2 = new Text();
			super("Take Reward");
			box.style = "buy";
			this.g = param1;
			this.targetName = param5;
			var _loc6_:ITextureManager = TextureLocator.getService();
			var _loc7_:String = getCaption(param4);
			if (param2 < 10)
			{
				countText.x = 40;
			}
			else
			{
				countText.x = 10;
			}
			countText.size = 50;
			countText.glow = true;
			box.addChild(countText);
			textField.text = _loc7_;
			textField.wordWrap = true;
			textField.width = 180;
			textField.height = 40;
			textField.x = 100;
			textField.y = 100;
			textField.center();
			textField.touchable = false;
			box.addChild(textField);
			if (param2 > 0)
			{
				countText.text = param2.toString();
				_loc8_ = _loc6_.getTextureGUIByTextureName("credit_medium.png");
				creditBmp = new Image(_loc8_);
				creditBmp.x = countText.x + countText.width + 20;
				creditBmp.y = 10;
				box.addChild(creditBmp);
				if (param3 > 0)
				{
					countText.y += 40;
					creditBmp.y += 38;
				}
			}
			if (param3 > 0)
			{
				countText2 = new Text();
				countText2.size = 50;
				countText2.wordWrap = true;
				countText2.color = 16777215;
				countText2.x = countText.x + 12;
				countText2.y = countText.y;
				countText2.text = "" + param3;
				podsBmp = new Image(_loc6_.getTextureGUIByTextureName("pod_small"));
				podsBmp.x = 70;
				podsBmp.y = countText.y + 16;
				if (param2 > 0)
				{
					countText2.y -= 48;
					podsBmp.y -= 48;
					textField.y += 10;
				}
				else
				{
					countText2.x -= 10;
				}
				box.addChild(countText2);
				box.addChild(podsBmp);
			}
			redraw();
		}
		
		override protected function redraw(param1:Event = null):void
		{
			super.redraw();
			closeButton.x = Math.round(100 - closeButton.width / 2);
			closeButton.y = Math.round(textField.y + textField.height + 8);
			var _loc2_:int = closeButton.y + closeButton.height - 3;
			box.width = 200;
			box.height = _loc2_;
		}
		
		private function getCaption(param1:String):String
		{
			switch (param1)
			{
			case "InviteRewardFlux1": 
				return targetName + " accepted your invite!";
			case "InviteRewardFlux2": 
				return "Your friend: " + targetName + " reached level 10!";
			case "planetCleared": 
				return "100% Explored Reward";
			case "daily": 
				return "Daily Login Reward";
			case "planetLanded": 
				return "Discovered New Planet";
			case "fbLike": 
				return "Facebook like reward.";
			case "missions": 
				return "You gained a Pod.";
			case "level": 
				return "Congratulations! You have reached lvl " + g.me.level + "!";
			case "pvp": 
				return targetName;
			default: 
				return "For no apparent reason you got a reward!";
			}
		}
	}
}

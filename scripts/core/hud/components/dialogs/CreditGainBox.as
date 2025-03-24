package core.hud.components.dialogs {
	import core.hud.components.Text;
	import core.scene.Game;
	import starling.display.Image;
	import starling.events.Event;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class CreditGainBox extends PopupMessage {
		private var g:Game;
		
		private var targetName:String;
		
		private var countText:Text;
		
		private var countText2:Text;
		
		private var creditBmp:Image;
		
		private var podsBmp:Image;
		
		public function CreditGainBox(g:Game, nrOfCredits:int, nrOfPods:int, type:String, name:String = "") {
			var _local6:Texture = null;
			countText = new Text();
			countText2 = new Text();
			super("Take Reward");
			box.style = "buy";
			this.g = g;
			this.targetName = name;
			var _local8:ITextureManager = TextureLocator.getService();
			var _local7:String = getCaption(type);
			if(nrOfCredits < 10) {
				countText.x = 40;
			} else {
				countText.x = 10;
			}
			countText.size = 50;
			countText.glow = true;
			box.addChild(countText);
			textField.text = _local7;
			textField.wordWrap = true;
			textField.width = 3 * 60;
			textField.height = 40;
			textField.x = 100;
			textField.y = 100;
			textField.center();
			textField.touchable = false;
			box.addChild(textField);
			if(nrOfCredits > 0) {
				countText.text = nrOfCredits.toString();
				_local6 = _local8.getTextureGUIByTextureName("credit_medium.png");
				creditBmp = new Image(_local6);
				creditBmp.x = countText.x + countText.width + 20;
				creditBmp.y = 10;
				box.addChild(creditBmp);
				if(nrOfPods > 0) {
					countText.y += 40;
					creditBmp.y += 38;
				}
			}
			if(nrOfPods > 0) {
				countText2 = new Text();
				countText2.size = 50;
				countText2.wordWrap = true;
				countText2.color = 0xffffff;
				countText2.x = countText.x + 12;
				countText2.y = countText.y;
				countText2.text = "" + nrOfPods;
				podsBmp = new Image(_local8.getTextureGUIByTextureName("pod_small"));
				podsBmp.x = 70;
				podsBmp.y = countText.y + 16;
				if(nrOfCredits > 0) {
					countText2.y -= 48;
					podsBmp.y -= 48;
					textField.y += 10;
				} else {
					countText2.x -= 10;
				}
				box.addChild(countText2);
				box.addChild(podsBmp);
			}
			redraw();
		}
		
		override protected function redraw(e:Event = null) : void {
			super.redraw();
			closeButton.x = Math.round(100 - closeButton.width / 2);
			closeButton.y = Math.round(textField.y + textField.height + 8);
			var _local2:int = closeButton.y + closeButton.height - 3;
			box.width = 200;
			box.height = _local2;
		}
		
		private function getCaption(type:String) : String {
			switch(type) {
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


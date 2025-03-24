package core.hud.components.dialogs {
	import core.hud.components.Text;
	import core.scene.Game;
	import core.states.gameStates.PodState;
	import starling.events.Event;
	
	public class DailyRewardMessage extends CreditGainBox {
		public static const DAILY_REWARD_FLUX:Vector.<int> = Vector.<int>([4,8,12,0,16]);
		
		public static const DAILY_REWARD_PODS:Vector.<int> = Vector.<int>([0,0,0,1,1]);
		
		private var g:Game;
		
		private var countText:Text;
		
		private var combo:int;
		
		private var boxXPos:int = 0;
		
		private var dayTextField:Text;
		
		public function DailyRewardMessage(g:Game, nrOfCredits:int, combo:int) {
			var xPos:int;
			var i:int;
			var d:DailyRewardChild;
			var spacing:int;
			var allWidth:int;
			var nextXPos:int;
			var boxPlaced:Boolean;
			countText = new Text();
			var flux:int = DAILY_REWARD_FLUX[combo - 1];
			var pods:int = DAILY_REWARD_PODS[combo - 1];
			super(g,flux,pods,"daily");
			if(pods > 0) {
				callback = function():void {
					g.enterState(new PodState(g));
				};
			}
			box.width = 150;
			box.style = "highlight";
			this.combo = combo;
			xPos = g.stage.stageWidth / 2;
			i = 0;
			spacing = 0;
			allWidth = box.width + 4 * DailyRewardChild.boxWidth + 4 * spacing + 100;
			nextXPos = g.stage.stageWidth / 2 - allWidth / 2;
			boxPlaced = false;
			i = 1;
			while(i < 6) {
				if(i == combo) {
					nextXPos += 3;
					boxXPos = nextXPos;
					nextXPos += box.width + spacing + box.padding * 2;
					boxPlaced = true;
				} else {
					flux = DAILY_REWARD_FLUX[i - 1];
					pods = DAILY_REWARD_PODS[i - 1];
					d = new DailyRewardChild(flux,pods,i,boxPlaced);
					d.x = nextXPos;
					nextXPos += d.width + spacing;
					d.y = g.stage.stageHeight / 2 - d.height / 2;
					addChild(d);
				}
				i++;
			}
			textField.color = 16770048;
			textField.x += 7;
			dayTextField = new Text();
			dayTextField.size = 16;
			dayTextField.wordWrap = true;
			dayTextField.color = 0xaffffff;
			dayTextField.text = "TODAY";
			dayTextField.y = 87;
			dayTextField.x = 10;
			addChild(dayTextField);
		}
		
		override protected function redraw(e:Event = null) : void {
			super.redraw();
			box.x = boxXPos;
			if(dayTextField == null) {
				return;
			}
			dayTextField.y = box.y + box.height - 2;
			dayTextField.x = box.x + box.width / 2 - dayTextField.width / 2;
		}
	}
}

import core.hud.components.Box;
import core.hud.components.Text;
import starling.display.Image;
import starling.display.Sprite;
import textures.ITextureManager;
import textures.TextureLocator;

class DailyRewardChild extends Sprite {
	public static var boxWidth:int = 90;
	
	private var textField:Text;
	
	private var textField2:Text;
	
	private var image:Image;
	
	private var dayTextField:Text;
	
	private var box:Box;
	
	public function DailyRewardChild(flux:int, pods:int, combo:int, highlight:Boolean) {
		var _local5:Image = null;
		box = new Box(boxWidth,70,"buy",1,10);
		super();
		textField = new Text();
		textField.size = 28;
		textField.wordWrap = true;
		textField.color = 0xffffff;
		textField.y = 17;
		if(flux > 0) {
			textField.text = "" + flux;
			textField.x = boxWidth / 2 - textField.width / 2 + 10;
			if(flux < 10) {
				textField.x += 7;
			}
		}
		dayTextField = new Text();
		dayTextField.size = 16;
		dayTextField.wordWrap = true;
		dayTextField.color = 0xaffffff;
		dayTextField.text = "Day " + combo;
		dayTextField.y = 87;
		dayTextField.x = 10;
		addChild(box);
		addChild(textField);
		addChild(dayTextField);
		var _local6:ITextureManager = TextureLocator.getService();
		if(flux > 0) {
			_local5 = new Image(_local6.getTextureGUIByTextureName("credit_medium.png"));
			_local5.scaleX = 0.6;
			_local5.scaleY = 0.6;
			_local5.x = 45;
			_local5.y = 23;
			if(flux > 16) {
				_local5.x += 8;
			} else if(flux > 10) {
				_local5.x += 4;
			}
			if(pods > 0) {
				textField.y += 18;
				_local5.y += 16;
			}
			addChild(_local5);
		}
		if(pods > 0) {
			textField2 = new Text();
			textField2.size = 28;
			textField2.wordWrap = true;
			textField2.color = 0xffffff;
			textField2.x += 8;
			textField2.y = textField.y;
			textField2.text = "" + pods;
			image = new Image(_local6.getTextureGUIByTextureName("pod_small"));
			image.x = 30;
			image.y = textField.y + 6;
			image.scaleX = 0.75;
			image.scaleY = 0.75;
			if(flux > 0) {
				textField2.y -= 32;
				image.y -= 32;
			}
			addChild(textField2);
			addChild(image);
		}
	}
}

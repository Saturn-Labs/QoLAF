package qolaf.states 
{
	import core.hud.components.Text;
	import core.scene.Game;
	import core.scene.SceneBase;
	import feathers.controls.Check;
	import feathers.controls.ScrollContainer;
	import generics.Localize;
	import qolaf.data.ClientSettings;
	import starling.display.Sprite;
	import starling.events.Event;
	
	/**
	 * @author rydev
	 */
	public class SettingsQoLAF extends Sprite
	{
		private var game:Game;
		private var clientSettings:ClientSettings;
		private var currentHeight:Number = 20;
		private var currentWidth:Number = 50;
		private var scrollArea:ScrollContainer;
		
		private var autoTarget:Check;
		
		public function SettingsQoLAF(game:Game) 
		{
			this.game = game;
			this.clientSettings = SceneBase.clientSettings;
			scrollArea = new ScrollContainer();
			scrollArea.y = 50;
			scrollArea.x = 10;
			scrollArea.width = 700;
			scrollArea.height = 500;
			initComponents();
			addChild(scrollArea);
		}
		
		private function initComponents(): void {
			var targetSystemSettings:Text = new Text();
			targetSystemSettings.htmlText = Localize.t("Target system:");
			targetSystemSettings.size = 16;
			targetSystemSettings.y = currentHeight;
			targetSystemSettings.x = currentWidth;
			scrollArea.addChild(targetSystemSettings);
			currentHeight += 40;
			
			autoTarget = new Check();
			autoTarget.isSelected = clientSettings.autoTarget;
			autoTarget.addEventListener("change", function(event:Event): void
			{
				clientSettings.autoTarget = autoTarget.isSelected;
			});
			addCheckbox(autoTarget, "Enable auto target");
		}
		
		private function addCheckbox(box:Check, boxText:String): void
		{
			var boxTextDisplay:Text = new Text();
			boxTextDisplay.htmlText = boxText;
			boxTextDisplay.y = currentHeight;
			boxTextDisplay.x = currentWidth + 30;
			box.x = currentWidth;
			box.y = currentHeight - 4;
			box.useHandCursor = true;
			scrollArea.addChild(boxTextDisplay);
			scrollArea.addChild(box);
			currentHeight += 40;
		}
	}
}
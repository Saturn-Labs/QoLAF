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
		private var _game:Game;
		
		private var _clientSettings:ClientSettings;
		private var _currentHeight:Number = 20;
		private var _currentWidth:Number = 50;
		private var _scrollArea:ScrollContainer;
		
		private var _autoTarget:Check;
		
		public function SettingsQoLAF(game:Game) 
		{
			this._game = game;
			this._clientSettings = SceneBase.clientSettings;
			_scrollArea = new ScrollContainer();
			_scrollArea.y = 50;
			_scrollArea.x = 10;
			_scrollArea.width = 700;
			_scrollArea.height = 500;
			initComponents();
			addChild(_scrollArea);
		}
		
		private function initComponents(): void {
			var targetSystemSettings:Text = new Text();
			targetSystemSettings.htmlText = Localize.t("Target system:");
			targetSystemSettings.size = 16;
			targetSystemSettings.y = _currentHeight;
			targetSystemSettings.x = _currentWidth;
			_scrollArea.addChild(targetSystemSettings);
			_currentHeight += 40;
			
			_autoTarget = new Check();
			_autoTarget.isSelected = _clientSettings.autoTarget;
			_autoTarget.addEventListener("change", function(event:Event): void
			{
				_clientSettings.autoTarget = _autoTarget.isSelected;
			});
			addCheckbox(_autoTarget, "Enable auto target");
		}
		
		private function addCheckbox(box:Check, boxText:String): void
		{
			var boxTextDisplay:Text = new Text();
			boxTextDisplay.htmlText = boxText;
			boxTextDisplay.y = _currentHeight;
			boxTextDisplay.x = _currentWidth + 30;
			box.x = _currentWidth;
			box.y = _currentHeight - 4;
			box.useHandCursor = true;
			_scrollArea.addChild(boxTextDisplay);
			_scrollArea.addChild(box);
			_currentHeight += 40;
		}
	}
}
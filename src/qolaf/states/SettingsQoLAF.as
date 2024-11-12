package qolaf.states
{
	import core.hud.components.Text;
	import core.scene.Game;
	import core.scene.SceneBase;
	import feathers.controls.Check;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Slider;
	import flash.geom.Point;
	import generics.Localize;
	import qolaf.data.IDataHandler;
	import qolaf.data.ISharedSettings;
	import qolaf.data.SharedSettings;
	import starling.display.Sprite;
	import starling.events.Event;

	/**
	 * @author rydev
	 */
	public class SettingsQoLAF extends Sprite
	{
		private var _game:Game;
		private var _sharedSettings:ISharedSettings;
		private var _currentHeight:Number = 20;
		private var _currentWidth:Number = 50;
		private var _scrollArea:ScrollContainer;
		private var _autoTarget:Check;
		private var _targetInfoX:Slider;
		private var _targetInfoXText:Text;
		private var _targetInfoY:Slider;
		private var _targetInfoYText:Text;
		public function SettingsQoLAF(game:Game)
		{
			this._game = game;
			this._sharedSettings = SceneBase.sharedSettings;
			_scrollArea = new ScrollContainer();
			_scrollArea.y = 50;
			_scrollArea.x = 10;
			_scrollArea.width = 700;
			_scrollArea.height = 500;
			initComponents();
			addChild(_scrollArea);
		}

		private function initComponents():void
		{
			var targetSystemSettings:Text = new Text();
			targetSystemSettings.htmlText = Localize.t("Target system:");
			targetSystemSettings.size = 16;
			targetSystemSettings.y = _currentHeight;
			targetSystemSettings.x = _currentWidth;
			_scrollArea.addChild(targetSystemSettings);
			_currentHeight += 40;

			_autoTarget = new Check();
			
			var enabledAutoTarget:Boolean = SceneBase.sharedSettings.getValue(function(handler:IDataHandler):Boolean {
				return handler.getSettingOr("auto_target", false);
			}) as Boolean;
			_autoTarget.isSelected = enabledAutoTarget;
			_autoTarget.addEventListener("change", function(event:Event):void
			{
				_sharedSettings.modify(function(handler:IDataHandler):void {
					handler.setSetting("auto_target", _autoTarget.isSelected);
				});
			});
			addCheckbox(_autoTarget, "Enable auto target");

			var currentPos:Point = _sharedSettings.getValue(function(handler:IDataHandler):Point {
				return handler.getSettingOr("target_info_position", new Point(0.5, 0.1)) as Point;
			}) as Point;
			
			_targetInfoX = new Slider();
			addSlider(_targetInfoX, currentPos.x, "Target info X position");
			_targetInfoXText = new Text(_targetInfoX.x + 120, _targetInfoX.y + 10);
			_targetInfoX.addEventListener(Event.CHANGE, function(e:Event):void
			{
				_sharedSettings.modify(function(handler:IDataHandler):void {
					var position:Point = handler.getSettingOr("target_info_position", new Point(0.5, 0.1)) as Point;
					position.x = _targetInfoX.value;
					handler.setSetting("target_info_position", position);
				});
				_targetInfoXText.text = _targetInfoX.value.toFixed(2);
			});
			_targetInfoXText.text = currentPos.x.toFixed(2);
			_scrollArea.addChild(_targetInfoXText);

			_targetInfoY = new Slider();
			addSlider(_targetInfoY, currentPos.y, "Target info Y position");
			_targetInfoYText = new Text(_targetInfoY.x + 120, _targetInfoY.y + 10);
			_targetInfoY.addEventListener(Event.CHANGE, function(e:Event):void
			{
				_sharedSettings.modify(function(handler:IDataHandler):void {
					var position:Point = handler.getSettingOr("target_info_position", new Point(0.5, 0.1)) as Point;
					position.y = _targetInfoY.value;
					handler.setSetting("target_info_position", position);
				});
				_targetInfoYText.text = _targetInfoY.value.toFixed(2);
			});
			_targetInfoYText.text = currentPos.y.toFixed(2);
			_scrollArea.addChild(_targetInfoYText);
		}

		private function addCheckbox(box:Check, boxText:String):void
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

		private function addSlider(slider:Slider, value:Number, text:String):void
		{
			slider.minimum = 0;
			slider.maximum = 1;
			slider.step = 0.001;
			slider.value = value;
			slider.direction = "horizontal";
			slider.useHandCursor = true;
			var sliderText:Text = new Text();
			sliderText.htmlText = text;
			sliderText.y = _currentHeight;
			sliderText.x = _currentWidth;
			slider.x = sliderText.x + sliderText.width + 10;
			slider.y = _currentHeight;
			if (slider.x < 200)
			{
				slider.x = 200;
			}
			_scrollArea.addChild(sliderText);
			_scrollArea.addChild(slider);
			_currentHeight += 40;
		}
	}
}
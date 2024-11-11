package qolaf.ui.elements
{
	import feathers.controls.Label;
	import generics.Util;
	import starling.display.BlendMode;
	import starling.display.DisplayObjectContainer;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.filters.GlowFilter;
	import starling.text.TextField;
	import starling.text.TextFormat;

	/**
	 * @author rydev
	 */
	public class CustomProgressBar extends Sprite
	{
		private var _width:int = 95;
		private var _height:int = 15;
		private var _color:int = 0xffffff;
		private var _lerpSpeed:Number = 1;
		private var _maxValue:Number = 100;
		private var _value:Number = 100;
		private var _lerp:Number = 100;
		private var _overlay:Quad;
		private var _trail:Quad;
		private var _back:Quad;
		private var _valueText:TextField;
		public function CustomProgressBar(width:int = 95, height:int = 15, color:int = 0xffffff)
		{
			this._width = width;
			this._height = height;
			this._color = color;
			createElements();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}

		public function get trailAlpha():Number
		{
			return _trail.alpha;
		}

		public function set trailAlpha(value:Number):void
		{
			_trail.alpha = value;
		}

		public function get lerpSpeed():Number
		{
			return _lerpSpeed;
		}

		public function set lerpSpeed(value:Number):void
		{
			_lerpSpeed = value;
		}

		public function get maxValue():Number
		{
			return _maxValue;
		}

		public function set maxValue(value:Number):void
		{
			_maxValue = value;
			if (value < this.value)
				this.value = value;
			if (_lerp > _maxValue)
				_lerp = _maxValue;
		}

		public function get value():Number
		{
			return _value;
		}

		public function set value(value:Number):void
		{
			_value = value;
			if (_lerp < value)
				_lerp = value;
		}

		override public function get width():Number
		{
			return _width;
		}

		override public function set width(value:Number):void
		{
			_width = value;
		}

		override public function get height():Number
		{
			return _height;
		}

		override public function set height(value:Number):void
		{
			_height = value;
		}

		public function createElements():void
		{
			_overlay = new Quad(_width, _height, _color);
			_trail = new Quad(_width, _height, _color);
			_back = new Quad(_width, _height, 0x0);
			_back.alpha = 0.15;
			trailAlpha = 0.45;
			_valueText = new TextField(_width, _height, "0 / 0", new TextFormat("DAIDRR", 12, 0xffffff, "center", "center"));
			addChild(_back);
			addChild(_trail);
			addChild(_overlay);
			addChild(_valueText);
		}

		public function onEnterFrame(e:EnterFrameEvent):void
		{
			_overlay.width = _width;
			_overlay.height = _height;
			_trail.width = _width;
			_trail.height = _height;
			_back.width = _width;
			_back.height = _height;
			_valueText.width = _width;
			_valueText.height = _height;
			_lerp = Util.lerp(_lerp, _value, _lerpSpeed * e.passedTime);
			var overlayScale:Number = Util.clamp(_value / _maxValue, 0, 1);
			var trailScale:Number = Util.clamp(_lerp / _maxValue, 0, 1);
			_overlay.scaleX = overlayScale;
			_trail.scaleX = trailScale;
			_valueText.text = Math.floor(_value) + " / " + Math.floor(_maxValue);
			_valueText.format.color = _value <= _maxValue * 0.1 ? 0xff0000 : 0xffffff;
		}
	}
}
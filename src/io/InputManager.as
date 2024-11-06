package io
{
	import core.scene.Game;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.utils.Dictionary;
	import starling.core.Starling;
	import starling.display.Stage;
	import starling.events.Event;
	import starling.events.TouchEvent;

	public class InputManager implements IInput
	{
		private var _isMousePressed:Boolean;
		private var _isRightMousePressed:Boolean = false;
		private var downKeys:Dictionary;
		private var pressedKeys:Dictionary;
		private var releasedKeys:Dictionary;
		private var mouseHasMoved:Boolean;
		private var prevMouseX:Number;
		private var prevMouseY:Number;
		private var stage:Stage;
		private var listedListenerKeys:Array;
		public function InputManager(param1:Stage)
		{
			listedListenerKeys = [];
			super();
			this.stage = param1;
			pressedKeys = new Dictionary();
			releasedKeys = new Dictionary();
			downKeys = new Dictionary();
			Starling.current.nativeStage.addEventListener("keyDown", keyDown, false, 10000);
			Starling.current.nativeStage.addEventListener("keyUp", keyUp, false, 10000);
			param1.addEventListener("touch", onTouch);
			Starling.current.nativeStage.addEventListener("mouseFocusChange", focusChange);
			Starling.current.nativeStage.addEventListener("keyFocusChange", focusChange);
			param1.addEventListener("rightClickDown", rightMouseDown);
			param1.addEventListener("rightClickUp", rightMouseUp);
		}

		public function reset():void
		{
			for (var _loc1_:* in releasedKeys)
			{
				releasedKeys[_loc1_] = false;
			}
			for (_loc1_ in pressedKeys)
			{
				pressedKeys[_loc1_] = false;
			}
		}

		private function focusChange(param1:FocusEvent):void
		{
			param1.preventDefault();
		}

		private function rightMouseDown(param1:Event):void
		{
			Game.playerPerformedAction();
			_isRightMousePressed = true;
		}

		private function rightMouseUp(param1:Event):void
		{
			_isRightMousePressed = false;
		}

		private function mouseDown(param1:TouchEvent):void
		{
			Game.playerPerformedAction();
			if (param1.target is Stage)
			{
				_isMousePressed = true;
			}
		}

		private function mouseUp(param1:TouchEvent):void
		{
			_isMousePressed = false;
		}

		private function onTouch(param1:TouchEvent):void
		{
			Game.playerPerformedAction();
			if (param1.getTouch(stage, "began"))
			{
				mouseDown(param1);
			}
			else if (param1.getTouch(stage, "ended"))
			{
				mouseUp(param1);
			}
			mouseHasMoved = !!param1.getTouch(stage, "moved") ? true : false;
		}

		private function keyDown(param1:KeyboardEvent):void
		{
			var _loc2_:Array = null;
			Game.playerPerformedAction();
			if (!isKeyDown(param1.keyCode))
			{
				downKeys[param1.keyCode] = true;
				pressedKeys[param1.keyCode] = true;
				for each (var _loc3_:* in listedListenerKeys)
				{
					_loc2_ = _loc3_[0];
					for each (var _loc4_:* in _loc2_)
					{
						if (_loc4_ == param1.keyCode)
						{
							_loc3_[1]();
							listedListenerKeys.splice(listedListenerKeys.indexOf(_loc3_), 1);
							return;
						}
					}
				}
			}
			param1.stopPropagation();
		}

		private function keyUp(param1:KeyboardEvent):void
		{
			downKeys[param1.keyCode] = false;
			releasedKeys[param1.keyCode] = true;
			param1.stopPropagation();
		}

		public function get isMousePressed():Boolean
		{
			return _isMousePressed;
		}

		public function get isMouseRightPressed():Boolean
		{
			return _isRightMousePressed;
		}

		public function isAnyKeyPressed():Boolean
		{
			for (var _loc1_:* in pressedKeys)
			{
				if (pressedKeys[_loc1_])
				{
					return true;
				}
			}
			return false;
		}

		public function hasMouseMoved():Boolean
		{
			return mouseHasMoved;
		}

		public function isKeyPressed(param1:uint):Boolean
		{
			return pressedKeys[param1];
		}

		public function isKeyReleased(param1:uint):Boolean
		{
			return releasedKeys[param1];
		}

		public function isKeyDown(param1:uint):Boolean
		{
			return downKeys[param1];
		}

		public function isKeyUp(param1:uint):Boolean
		{
			return !isKeyDown(param1);
		}

		public function listenToKeys(param1:Array, param2:Function):void
		{
			if (param2 == null)
			{
				return;
			}
			if (param1 == null || param1.length == 0)
			{
				return;
			}
			listedListenerKeys.push([param1, param2]);
		}

		public function stopListenToKeys(param1:Function):void
		{
			var _loc4_:int = 0;
			var _loc2_:Array = null;
			if (param1 == null)
			{
				return;
			}
			var _loc3_:int = int(listedListenerKeys.length);
			_loc4_ = _loc3_ - 1;
			while (_loc4_ > -1)
			{
				_loc2_ = listedListenerKeys[_loc4_];
				if (_loc2_[1] == param1)
				{
					listedListenerKeys.splice(listedListenerKeys.indexOf(_loc2_), 1);
				}
				_loc4_--;
			}
		}

		public function dispose():void
		{
			listedListenerKeys = [];
		}
	}
}

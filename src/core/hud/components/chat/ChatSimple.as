package core.hud.components.chat
{
	import core.scene.Game;
	import feathers.controls.Label;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class ChatSimple extends Sprite
	{
		private var g:Game;
		
		private var tf:Label;
		
		private var maxLines:int = 10;
		private var nextTimeout:Number = 0;
		public function ChatSimple(param1:Game)
		{
			super();
			this.g = param1;
			tf = new Label();
			tf.styleName = "chat";
			tf.minWidth = 300;
			tf.maxWidth = 500;
			addChild(tf);
			addEventListener("addedToStage", updateTexts);
		}
		
		public function update(param1:Event = null):void
		{
			if (nextTimeout != 0 && nextTimeout < g.time)
			{
				updateTexts();
			}
		}
		
		public function updateTexts(param1:Event = null):void
		{
			var _loc4_:Object = null;
			var _loc3_:Vector.<Object> = MessageLog.textQueue;
			var _loc2_:String = "\n";
			var _loc6_:int = _loc3_.length - 1;
			var _loc5_:int = 0;
			_loc6_;
			while (_loc6_ >= 0)
			{
				_loc4_ = _loc3_[_loc6_];
				if (_loc4_.timeout < g.time)
				{
					break;
				}
				if (!g.messageLog.isMuted(_loc4_.type))
				{
					_loc5_++;
					_loc2_ = _loc4_.text + "\n" + _loc2_;
					nextTimeout = _loc4_.nextTimeout;
					if (_loc5_ > maxLines)
					{
						break;
					}
				}
				_loc6_--;
			}
			if (tf.text != _loc2_)
			{
				tf.text = _loc2_;
			}
		}
	}
}

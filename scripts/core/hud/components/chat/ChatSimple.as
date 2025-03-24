package core.hud.components.chat {
	import core.scene.Game;
	import feathers.controls.Label;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class ChatSimple extends Sprite {
		private var g:Game;
		
		private var tf:Label;
		
		private var maxLines:int = 10;
		
		private var nextTimeout:Number = 0;
		
		public function ChatSimple(g:Game) {
			super();
			this.g = g;
			tf = new Label();
			tf.styleName = "chat";
			tf.minWidth = 5 * 60;
			tf.maxWidth = 500;
			addChild(tf);
			addEventListener("addedToStage",updateTexts);
		}
		
		public function update(e:Event = null) : void {
			if(nextTimeout != 0 && nextTimeout < g.time) {
				updateTexts();
			}
		}
		
		public function updateTexts(e:Event = null) : void {
			var _local2:Object = null;
			var _local3:Vector.<Object> = MessageLog.textQueue;
			var _local5:String = "\n";
			var _local4:int = _local3.length - 1;
			var _local6:int = 0;
			_local4;
			while(_local4 >= 0) {
				_local2 = _local3[_local4];
				if(_local2.timeout < g.time) {
					break;
				}
				if(!g.messageLog.isMuted(_local2.type)) {
					_local6++;
					_local5 = _local2.text + "\n" + _local5;
					nextTimeout = _local2.nextTimeout;
					if(_local6 > maxLines) {
						break;
					}
				}
				_local4--;
			}
			if(tf.text != _local5) {
				tf.text = _local5;
			}
		}
	}
}


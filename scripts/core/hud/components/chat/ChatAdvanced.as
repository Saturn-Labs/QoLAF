package core.hud.components.chat {
	import core.scene.Game;
	import feathers.controls.Label;
	import feathers.controls.ScrollContainer;
	import feathers.layout.VerticalLayout;
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	
	public class ChatAdvanced extends Sprite {
		private var g:Game;
		
		private var scrollView:Sprite;
		
		private var scroll:ScrollContainer;
		
		private var playerChatOptions:PlayerChatOptions;
		
		public function ChatAdvanced(g:Game) {
			super();
			this.g = g;
			var _local6:int = 5 * 60;
			var _local5:int = 5 * 60;
			var _local3:int = 10;
			scrollView = new Sprite();
			var _local4:Quad = new Quad(_local6,_local5,0);
			_local4.alpha = 0.6;
			scrollView.addChild(_local4);
			var _local2:VerticalLayout = new VerticalLayout();
			scroll = new ScrollContainer();
			scroll.layout = _local2;
			scroll.x = _local3;
			scroll.y = _local3;
			scroll.width = _local6 - _local3;
			scroll.height = _local5 - scroll.y;
			scrollView.addChild(scroll);
			addChild(scrollView);
			addEventListener("addedToStage",load);
			addEventListener("removedFromStage",unload);
		}
		
		private function load(e:Event) : void {
			var obj:Object;
			var textQueue:Vector.<Object> = g.messageLog.getQueue();
			for each(obj in textQueue) {
				addText(obj);
			}
			Starling.juggler.delayCall((function():* {
				var later:Function;
				return later = function():void {
					scroll.scrollToPosition(0,scroll.maxVerticalScrollPosition,0);
				};
			})(),0.2);
		}
		
		private function unload(e:Event) : void {
			scroll.removeChildren(0,-1,true);
		}
		
		public function updateText(obj:Object) : void {
			var textQueue:Vector.<Object> = g.messageLog.getQueue();
			if(textQueue.length == 0) {
				return;
			}
			if(textQueue.indexOf(obj) === -1) {
				return;
			}
			addText(obj);
			if(scroll.verticalScrollPosition == scroll.maxVerticalScrollPosition) {
				Starling.juggler.delayCall((function():* {
					var later:Function;
					return later = function():void {
						scroll.scrollToPosition(0,scroll.maxVerticalScrollPosition,0);
					};
				})(),0.2);
			}
		}
		
		private function addText(obj:Object) : void {
			var tf:Label;
			var text:String = obj.text as String;
			if(text == null || text.length == 0 || text.charAt(0) == "/") {
				return;
			}
			tf = new Label();
			tf.styleName = "chat";
			tf.text = text;
			tf.width = scroll.width - 10;
			if(scroll.numChildren > MessageLog.extendedMaxLines) {
				scroll.removeChildAt(0,true);
			}
			scroll.addChild(tf);
			if(obj.playerKey && obj.playerKey != g.me.id) {
				tf.useHandCursor = true;
				tf.touchable = true;
				tf.addEventListener("touch",function(param1:TouchEvent):void {
					var _local2:int = 0;
					if(param1.getTouch(tf,"ended")) {
						if(playerChatOptions) {
							scroll.removeChild(playerChatOptions,true);
						}
						_local2 = scroll.getChildIndex(tf);
						playerChatOptions = new PlayerChatOptions(g,obj);
						scroll.addChildAt(playerChatOptions,_local2 + 1);
					}
				});
			}
		}
		
		override public function dispose() : void {
			removeEventListeners();
			scroll.removeChildren(0,-1,true);
			super.dispose();
		}
	}
}


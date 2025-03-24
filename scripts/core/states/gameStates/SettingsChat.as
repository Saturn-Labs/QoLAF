package core.states.gameStates {
	import core.hud.components.Text;
	import core.scene.Game;
	import feathers.controls.Check;
	import feathers.controls.ScrollContainer;
	import generics.Localize;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class SettingsChat extends Sprite {
		private static var labelFormat:TextFormat = new TextFormat("DAIDRR",13,0xffffff,"left");
		
		private var g:Game;
		
		private var xpos:int = 50;
		
		private var ypos:int = 0;
		
		private var scrollArea:ScrollContainer;
		
		public function SettingsChat(g:Game) {
			super();
			this.g = g;
			scrollArea = new ScrollContainer();
			scrollArea.y = 50;
			scrollArea.x = 10;
			scrollArea.width = 700;
			scrollArea.height = 500;
			addChild(scrollArea);
			var _local2:Text = new Text();
			_local2.htmlText = Localize.t("Active chat channels:");
			_local2.size = 16;
			_local2.y = ypos;
			_local2.x = xpos;
			scrollArea.addChild(_local2);
			ypos += 40;
			addChannel("system","System");
			addChannel("local","Local");
			addChannel("global","Global");
			addChannel("clan","Clan");
			addChannel("group","Group");
			addChannel("private","Private");
			addChannel("planetwars","Planet wars");
			addChannel("join_leave","Player join/leave");
			addChannel("death","Player death");
			addChannel("loot","Loot found");
		}
		
		private function addChannel(msgType:String, text:String) : void {
			var label:TextField;
			var check:Check = new Check();
			check.x = xpos;
			check.y = ypos;
			check.isSelected = !g.messageLog.isMuted(msgType);
			check.addEventListener("change",function(param1:Event):void {
				g.messageLog.toggleMuted(msgType,!check.isSelected);
			});
			scrollArea.addChild(check);
			label = new TextField(200,13,text,labelFormat);
			label.x = xpos + 30;
			label.y = ypos + 5;
			scrollArea.addChild(label);
			ypos += 30;
		}
	}
}


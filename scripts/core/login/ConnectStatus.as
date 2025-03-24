package core.login {
	import com.greensock.TweenMax;
	import core.hud.components.Text;
	import starling.display.Sprite;
	
	public class ConnectStatus extends Sprite {
		private var connectTween:TweenMax;
		
		private var connectText:Text = new Text();
		
		private var connectSubText:Text = new Text();
		
		public function ConnectStatus() {
			super();
			this.visible = false;
			connectText.text = "Connecting...";
			connectText.color = 0xffffff;
			connectText.size = 18;
			connectText.x = 175;
			connectText.y = 10;
			connectText.center();
			this.addChild(connectText);
			connectSubText.text = "";
			connectSubText.color = 0x888888;
			connectSubText.size = 11;
			connectSubText.x = 175;
			connectSubText.y = connectText.y + connectText.height;
			connectSubText.center();
			this.addChild(connectSubText);
			connectTween = TweenMax.fromTo(connectText,1,{"alpha":1},{
				"alpha":0.5,
				"yoyo":true,
				"repeat":-1
			});
		}
		
		public function clean() : void {
			connectTween.kill();
		}
		
		public function set text(value:String) : void {
			connectText.text = value;
		}
		
		public function set subText(value:String) : void {
			if(value != "") {
				connectSubText.text = value;
			}
		}
		
		public function update(e:ConnectEvent) : void {
			if(e.message == "") {
				this.visible = false;
				return;
			}
			this.visible = true;
			connectText.text = e.message;
			subText = e.subMessage;
		}
	}
}


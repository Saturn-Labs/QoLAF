package core.login
{
	import com.greensock.TweenMax;
	import core.hud.components.Text;
	import starling.display.Sprite;
	
	public class ConnectStatus extends Sprite
	{
		private var connectTween:TweenMax;
		
		private var connectText:Text;
		
		private var connectSubText:Text;
		
		public function ConnectStatus()
		{
			connectText = new Text();
			connectSubText = new Text();
			super();
			this.visible = false;
			connectText.text = "Connecting...";
			connectText.color = 16777215;
			connectText.size = 18;
			connectText.x = 175;
			connectText.y = 10;
			connectText.center();
			this.addChild(connectText);
			connectSubText.text = "";
			connectSubText.color = 8947848;
			connectSubText.size = 11;
			connectSubText.x = 175;
			connectSubText.y = connectText.y + connectText.height;
			connectSubText.center();
			this.addChild(connectSubText);
			connectTween = TweenMax.fromTo(connectText, 1, {"alpha": 1}, {"alpha": 0.5, "yoyo": true, "repeat": -1});
		}
		
		public function clean():void
		{
			connectTween.kill();
		}
		
		public function set text(param1:String):void
		{
			connectText.text = param1;
		}
		
		public function set subText(param1:String):void
		{
			if (param1 != "")
			{
				connectSubText.text = param1;
			}
		}
		
		public function update(param1:ConnectEvent):void
		{
			if (param1.message == "")
			{
				this.visible = false;
				return;
			}
			this.visible = true;
			connectText.text = param1.message;
			subText = param1.subMessage;
		}
	}
}

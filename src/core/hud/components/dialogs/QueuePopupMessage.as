package core.hud.components.dialogs
{
	import core.hud.components.Button;
	import core.hud.components.Text;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.TouchEvent;
	
	public class QueuePopupMessage extends PopupMessage
	{
		private var type:String;
		
		private var timeText:Text;
		
		public var confirmButton:Button;
		
		public function QueuePopupMessage(param1:String)
		{
			this.type = param1;
			super("Decline");
			textField.width = 340;
			confirmButton = new Button(confirm, "Join Match!", "positive");
			box.addChild(confirmButton);
		}
		
		override protected function keyDown(param1:KeyboardEvent):void
		{
			if (param1.keyCode == 13)
			{
				param1.stopImmediatePropagation();
				confirm();
			}
		}
		
		public function setPopupText(param1:String):void
		{
			switch (type)
			{
			case "pvp dm": 
				text = "A Deathmatch is ready for you! Joining in:";
				break;
			case "pvp dom": 
				text = "A Domination Team-PvP Match is ready for you! Joining in:";
				break;
			case "pvp arena": 
				text = "You've been matched for an Arena fight! Joining in:";
				break;
			case "pvp random": 
				text = "You have been matched up for a random pvp battle. Joining in:";
				break;
			case "pvp arena ranked": 
				text = "You've been matched for a *RANKED* Arena fight! Joining in:";
			}
			timeText = new Text();
			timeText.htmlText = param1;
			timeText.size = 18;
			timeText.width = 40;
			timeText.wordWrap = true;
			timeText.color = 16733525;
			addChild(timeText);
		}
		
		public function updateTime(param1:String):void
		{
			timeText.htmlText = param1;
		}
		
		public function accept():void
		{
			dispatchEventWith("accept");
		}
		
		protected function confirm(param1:TouchEvent = null):void
		{
			dispatchEventWith("accept");
			removeEventListeners();
		}
		
		override protected function redraw(param1:Event = null):void
		{
			super.redraw();
			if (box == null || confirmButton == null || closeButton == null || stage == null)
			{
				return;
			}
			box.x = Math.round(stage.stageWidth / 2 - box.width / 2);
			box.y = Math.round(stage.stageHeight / 3 - box.height / 2);
			box.width = 340;
			box.height = 90;
			timeText.x = box.x + 150;
			timeText.y = box.y + 40;
			confirmButton.y = 70;
			confirmButton.x = 0;
			closeButton.y = 70;
			closeButton.x = textField.width - closeButton.width;
		}
	}
}

package core.hud.components.dialogs {
	import core.hud.components.Button;
	import core.hud.components.Text;
	import core.scene.Game;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.TouchEvent;
	
	public class TOSPopup extends PopupMessage {
		public var confirmButton:Button;
		
		public var g:Game;
		
		public var textField2:Text;
		
		public var textField3:Text;
		
		public var textField4:Text;
		
		public function TOSPopup(g:Game) {
			super("Decline");
			this.g = g;
			confirmButton = new Button(accept,"I Accept","positive");
			textField.color = 0xeeeeee;
			textField.font = "Verdana";
			textField.width = 400;
			textField.htmlText = "\nNew Terms of Service agreement: \n\nIn the light of GDPR you need to give us consent to store and use personal information in order to continue to use this service.\n\nYou can read in detail what information we store in the Privacy Policy document (tip: disable popup blocker).\n\nIf you regret giving us consent, please contact us at contact@fulafisken.se for support.\n\n\n\n\n\n ";
			box.addChild(confirmButton);
			textField4 = new Text(textField.x + 5,266);
			textField4.font = "Verdana";
			textField4.size = 14;
			textField4.htmlText = "<FONT COLOR=\'#44ff44\'>Privacy Policy</FONT>";
			textField4.touchable = true;
			textField4.useHandCursor = true;
			textField4.addEventListener("touch",openExternalPP);
			box.addChild(textField4);
			textField2 = new Text(textField.x + 5,305);
			textField2.font = "Verdana";
			textField2.size = 14;
			textField2.htmlText = "<FONT COLOR=\'#44ff44\'>Terms of Use</FONT>";
			textField2.touchable = true;
			textField2.useHandCursor = true;
			textField2.addEventListener("touch",openExternalTOS);
			box.addChild(textField2);
			textField3 = new Text(textField.x + 5,346);
			textField3.font = "Verdana";
			textField3.size = 14;
			textField3.htmlText = "<FONT COLOR=\'#44ff44\'>Rules of Conduct</FONT>";
			textField3.touchable = true;
			textField3.useHandCursor = true;
			textField3.addEventListener("touch",openExternalROC);
			box.addChild(textField3);
		}
		
		override protected function keyDown(e:KeyboardEvent) : void {
			if(e.keyCode == 13) {
				e.stopImmediatePropagation();
				accept();
			}
		}
		
		private function accept(e:TouchEvent = null) : void {
			dispatchEventWith("accept");
			removeEventListeners();
		}
		
		private function openExternalPP(e:TouchEvent) : void {
			var _local2:URLRequest = null;
			if(e.getTouch(textField4,"ended")) {
				_local2 = new URLRequest("http://www.astroflux.net/privacy.html");
				navigateToURL(_local2,"_blank");
			}
		}
		
		private function openExternalTOS(e:TouchEvent) : void {
			var _local2:URLRequest = null;
			if(e.getTouch(textField2,"ended")) {
				_local2 = new URLRequest("http://www.astroflux.net/termsofuse.html");
				navigateToURL(_local2,"_blank");
			}
		}
		
		private function openExternalROC(e:TouchEvent) : void {
			var _local2:URLRequest = null;
			if(e.getTouch(textField3,"ended")) {
				_local2 = new URLRequest("http://www.astroflux.net/rulesofconduct.html");
				navigateToURL(_local2,"_blank");
			}
		}
		
		override protected function redraw(e:Event = null) : void {
			super.redraw();
			confirmButton.y = Math.round(textField.height + 25);
			confirmButton.x = 40;
			closeButton.y = Math.round(textField.height + 25);
			closeButton.x = confirmButton.x + confirmButton.width + 30;
			var _local2:int = confirmButton.y + confirmButton.height + 10;
			box.width = textField.width > closeButton.x + closeButton.width ? textField.width : closeButton.x + closeButton.width;
			box.height = _local2;
		}
	}
}


package core.hud.components.dialogs {
	import core.hud.components.Box;
	import core.hud.components.Button;
	import core.hud.components.Text;
	import core.player.CrewMember;
	import core.scene.Game;
	import core.tutorial.Tutorial;
	import debug.Console;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import io.IInput;
	import io.InputLocator;
	import sound.ISound;
	import sound.SoundLocator;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.TouchEvent;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class CrewDialogBox extends Sprite {
		private var t:Text = new Text();
		
		private var face:Image = new Image(Texture.empty(1,1));
		
		private var box:Box;
		
		private var closeButton:Button;
		
		private var soundManager:ISound;
		
		private var g:Game;
		
		private var tutorial:Tutorial;
		
		private var bgrQuad:Quad = new Quad(100,100,0);
		
		private var readTime:int;
		
		private var readTimer:Timer;
		
		private var keyTimer:Timer;
		
		private var voice:String;
		
		private var callback:Function;
		
		private var crewNumber:int;
		
		private var showCloseButton:Boolean;
		
		private var showOverlay:Boolean;
		
		private var endKeys:Array;
		
		public function CrewDialogBox(g:Game, tutorial:Tutorial) {
			super();
			this.g = g;
			this.tutorial = tutorial;
			soundManager = SoundLocator.getService();
			closeButton = new Button(close,"","positive");
			t.font = "Verdana";
			t.wordWrap = true;
			t.size = 12;
			bgrQuad.visible = false;
			bgrQuad.alpha = 0.8;
			addChild(bgrQuad);
			addEventListener("addedToStage",stageAddHandler);
			addEventListener("removedFromStage",clean);
		}
		
		public function load(g:Game, htmlText:String, male:int = 0, showCloseButton:Boolean = false) : void {
			var _local5:CrewMember = null;
			var _local6:ITextureManager = null;
			t.htmlText = htmlText;
			if(g.isLeaving) {
				return;
			}
			if(g.me.crewMembers.length > 0) {
				if(male == -1) {
					male = Math.random() > 0.5 ? 1 : 0;
				}
				_local5 = g.me.crewMembers[0];
				_local6 = TextureLocator.getService();
				face.texture = _local6.getTextureGUIByKey(_local5.imageKey);
				face.scaleX = 0.5;
				face.scaleY = 0.5;
				face.readjustSize();
			}
			t.x = face.x + face.width + 10;
			t.width = 260;
			if(t.height > 140) {
				t.width = 6 * 60;
			}
			if(t.height > 140) {
				t.width = 7 * 60;
			}
			if(box != null) {
				removeChild(box);
			}
			box = new Box(t.x + t.width,Math.max(t.height,face.height) + 20,"buy",1,20);
			closeButton.text = "ok";
			closeButton.visible = showCloseButton;
			addChild(box);
			addChild(face);
			addChild(t);
			addChild(closeButton);
		}
		
		public function show(text:String, voice:String = null, endKeys:Array = null, readTime:int = -1, callback:Function = null, crewNumber:int = -1, showCloseButton:Boolean = true, showOverlay:Boolean = false, buttonText:String = "") : void {
			this.voice = voice;
			this.endKeys = endKeys;
			this.readTime = readTime;
			this.callback = callback;
			this.crewNumber = crewNumber;
			this.showCloseButton = showCloseButton;
			this.showOverlay = showOverlay;
			Tutorial.add(this);
			if(voice != null) {
				soundManager.play(voice);
			}
			load(g,text,crewNumber,showCloseButton);
			visible = true;
			if(showOverlay) {
				bgrQuad.x = -x;
				bgrQuad.y = -y;
				bgrQuad.width = g.stage.stageWidth;
				bgrQuad.height = g.stage.stageHeight;
				bgrQuad.visible = true;
			}
			readTimer = new Timer(1000,readTime);
			keyTimer = new Timer(33,0);
			if(buttonText != "") {
				closeButton.text = buttonText;
				closeButton.width = 150;
			}
			closeButton.x = t.x + t.width - closeButton.width;
			closeButton.y = Math.max(t.height,face.height) - closeButton.height / 2 + 10;
			if(readTime != -1) {
				readTimer.start();
				readTimer.addEventListener("timerComplete",onReadTimerComplete);
			}
			var _local10:IInput = InputLocator.getService();
			if(endKeys != null) {
				_local10.listenToKeys(endKeys,onListenToKeys);
			}
		}
		
		private function stageAddHandler(e:Event) : void {
			stage.addEventListener("keyDown",keyDown);
		}
		
		private function keyDown(e:KeyboardEvent) : void {
			if(e.keyCode == 13) {
				e.stopImmediatePropagation();
				hide();
			}
		}
		
		private function close(e:TouchEvent) : void {
			Console.write("dialog close: button");
			hide();
		}
		
		private function onListenToKeys() : void {
			Console.write("dialog close: keys");
			hide();
		}
		
		private function onReadTimerComplete(e:TimerEvent) : void {
			Console.write("dialog close: timer");
			hide();
		}
		
		public function hide() : void {
			Console.write("Removed hint dialog!");
			Tutorial.remove(this);
			visible = false;
			soundManager.stop(voice);
			var _local1:IInput = InputLocator.getService();
			readTimer.removeEventListener("timerComplete",onReadTimerComplete);
			_local1.stopListenToKeys(onListenToKeys);
			readTimer.stop();
			keyTimer.stop();
			if(callback != null) {
				callback();
			}
		}
		
		private function clean(e:Event) : void {
			stage.removeEventListener("keyDown",keyDown);
			removeEventListener("removedFromStage",clean);
			removeEventListener("addedToStage",stageAddHandler);
			if(readTimer && readTimer.hasEventListener("timerComplete")) {
				readTimer.removeEventListener("timerComplete",onReadTimerComplete);
			}
		}
	}
}


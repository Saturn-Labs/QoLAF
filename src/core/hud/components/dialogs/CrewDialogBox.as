package core.hud.components.dialogs
{
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
	
	public class CrewDialogBox extends Sprite
	{
		private var t:Text;
		
		private var face:Image;
		
		private var box:Box;
		
		private var closeButton:Button;
		
		private var soundManager:ISound;
		
		private var g:Game;
		
		private var tutorial:Tutorial;
		
		private var bgrQuad:Quad;
		
		private var readTime:int;
		
		private var readTimer:Timer;
		
		private var keyTimer:Timer;
		
		private var voice:String;
		
		private var callback:Function;
		
		private var crewNumber:int;
		
		private var showCloseButton:Boolean;
		
		private var showOverlay:Boolean;
		
		private var endKeys:Array;
		
		public function CrewDialogBox(param1:Game, param2:Tutorial)
		{
			t = new Text();
			face = new Image(Texture.empty(1, 1));
			bgrQuad = new Quad(100, 100, 0);
			super();
			this.g = param1;
			this.tutorial = param2;
			soundManager = SoundLocator.getService();
			closeButton = new Button(close, "", "positive");
			t.font = "Verdana";
			t.wordWrap = true;
			t.size = 12;
			bgrQuad.visible = false;
			bgrQuad.alpha = 0.8;
			addChild(bgrQuad);
			addEventListener("addedToStage", stageAddHandler);
			addEventListener("removedFromStage", clean);
		}
		
		public function load(param1:Game, param2:String, param3:int = 0, param4:Boolean = false):void
		{
			var _loc6_:CrewMember = null;
			var _loc5_:ITextureManager = null;
			t.htmlText = param2;
			if (param1.isLeaving)
			{
				return;
			}
			if (param1.me.crewMembers.length > 0)
			{
				if (param3 == -1)
				{
					param3 = Math.random() > 0.5 ? 1 : 0;
				}
				_loc6_ = param1.me.crewMembers[0];
				_loc5_ = TextureLocator.getService();
				face.texture = _loc5_.getTextureGUIByKey(_loc6_.imageKey);
				face.scaleX = 0.5;
				face.scaleY = 0.5;
				face.readjustSize();
			}
			t.x = face.x + face.width + 10;
			t.width = 260;
			if (t.height > 140)
			{
				t.width = 360;
			}
			if (t.height > 140)
			{
				t.width = 420;
			}
			if (box != null)
			{
				removeChild(box);
			}
			box = new Box(t.x + t.width, Math.max(t.height, face.height) + 20, "buy", 1, 20);
			closeButton.text = "ok";
			closeButton.visible = param4;
			addChild(box);
			addChild(face);
			addChild(t);
			addChild(closeButton);
		}
		
		public function show(param1:String, param2:String = null, param3:Array = null, param4:int = -1, param5:Function = null, param6:int = -1, param7:Boolean = true, param8:Boolean = false, param9:String = ""):void
		{
			this.voice = param2;
			this.endKeys = param3;
			this.readTime = param4;
			this.callback = param5;
			this.crewNumber = param6;
			this.showCloseButton = param7;
			this.showOverlay = param8;
			Tutorial.add(this);
			if (param2 != null)
			{
				soundManager.play(param2);
			}
			load(g, param1, param6, param7);
			visible = true;
			if (param8)
			{
				bgrQuad.x = -x;
				bgrQuad.y = -y;
				bgrQuad.width = g.stage.stageWidth;
				bgrQuad.height = g.stage.stageHeight;
				bgrQuad.visible = true;
			}
			readTimer = new Timer(1000, param4);
			keyTimer = new Timer(33, 0);
			if (param9 != "")
			{
				closeButton.text = param9;
				closeButton.width = 150;
			}
			closeButton.x = t.x + t.width - closeButton.width;
			closeButton.y = Math.max(t.height, face.height) - closeButton.height / 2 + 10;
			if (param4 != -1)
			{
				readTimer.start();
				readTimer.addEventListener("timerComplete", onReadTimerComplete);
			}
			var _loc10_:IInput = InputLocator.getService();
			if (param3 != null)
			{
				_loc10_.listenToKeys(param3, onListenToKeys);
			}
		}
		
		private function stageAddHandler(param1:Event):void
		{
			stage.addEventListener("keyDown", keyDown);
		}
		
		private function keyDown(param1:KeyboardEvent):void
		{
			if (param1.keyCode == 13)
			{
				param1.stopImmediatePropagation();
				hide();
			}
		}
		
		private function close(param1:TouchEvent):void
		{
			Console.write("dialog close: button");
			hide();
		}
		
		private function onListenToKeys():void
		{
			Console.write("dialog close: keys");
			hide();
		}
		
		private function onReadTimerComplete(param1:TimerEvent):void
		{
			Console.write("dialog close: timer");
			hide();
		}
		
		public function hide():void
		{
			Console.write("Removed hint dialog!");
			Tutorial.remove(this);
			visible = false;
			soundManager.stop(voice);
			var _loc1_:IInput = InputLocator.getService();
			readTimer.removeEventListener("timerComplete", onReadTimerComplete);
			_loc1_.stopListenToKeys(onListenToKeys);
			readTimer.stop();
			keyTimer.stop();
			if (callback != null)
			{
				callback();
			}
		}
		
		private function clean(param1:Event):void
		{
			stage.removeEventListener("keyDown", keyDown);
			removeEventListener("removedFromStage", clean);
			removeEventListener("addedToStage", stageAddHandler);
			if (readTimer && readTimer.hasEventListener("timerComplete"))
			{
				readTimer.removeEventListener("timerComplete", onReadTimerComplete);
			}
		}
	}
}

package core.states.gameStates.missions {
	import core.hud.components.GradientBox;
	import core.hud.components.ImageButton;
	import core.hud.components.Style;
	import core.hud.components.ToolTip;
	import core.scene.Game;
	import feathers.controls.ScrollContainer;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.text.TextFormat;
	
	public class DailyView extends Sprite {
		private var g:Game;
		
		private var box:GradientBox = new GradientBox(290,90,0,1,15,0x88ff88);
		
		private var daily:Daily;
		
		private var description:TextField;
		
		private var parentContainer:ScrollContainer;
		
		private var header:TextField;
		
		private var reward:DailyReward;
		
		private var statusBar:Statusbar;
		
		private var wikiButton:ImageButton;
		
		public function DailyView(g:Game, daily:Daily, parentContainer:ScrollContainer) {
			super();
			this.g = g;
			this.daily = daily;
			this.parentContainer = parentContainer;
			box.load();
			addChild(box);
			draw();
		}
		
		private function draw() : void {
			var _local1:Quad = null;
			var _local2:Image = null;
			addHeader();
			addRewards();
			addDescription();
			addProgress();
			if(daily.level > g.me.level) {
				_local1 = new Quad(box.width - box.padding * 2,this.height,0);
				_local1.alpha = 0.6;
				_local1.touchable = false;
				addChild(_local1);
				_local2 = new Image(g.textureManager.getTextureGUIByTextureName("lock"));
				_local2.x = box.width - _local2.width - 40;
				_local2.color = 12926522;
				addChild(_local2);
			}
		}
		
		private function onNativeMouseEvent(nativeMouseEvent:MouseEvent) : void {
			var _local6:Point = null;
			var _local2:URLRequest = null;
			if(!wikiButton) {
				return;
			}
			var _local5:Point = new Point();
			var _local3:Rectangle = Starling.current.viewPort;
			_local5.x = (nativeMouseEvent.stageX - _local3.x) / Starling.contentScaleFactor;
			_local5.y = (nativeMouseEvent.stageY - _local3.y) / Starling.contentScaleFactor;
			var _local4:Point = wikiButton.globalToLocal(_local5);
			if(wikiButton.hitTest(_local4)) {
				_local6 = parentContainer.localToGlobal(new Point(0,0));
				if(_local5.y < _local6.y) {
					return;
				}
				if(_local5.y > _local6.y + parentContainer.height) {
					return;
				}
				trace(wikiButton.visible);
				_local2 = new URLRequest("http://astroflux.org/wiki/index.php?title=" + daily.name.replace(" ","_").replace("!",""));
				navigateToURL(_local2,"_blank");
			}
		}
		
		private function addHeader() : void {
			header = new TextField(box.width - box.padding * 2,20,daily.name,new TextFormat("font13",13,0xffffff));
			header.y = -5;
			header.autoSize = "vertical";
			header.format.horizontalAlign = "left";
			header.format.verticalAlign = "top";
			addChild(header);
			if(daily.isClaimed) {
				header.y = 10;
				header.format.horizontalAlign = "center";
			}
		}
		
		private function addDescription() : void {
			description = new TextField(box.width - box.padding * 2,60,daily.description,new TextFormat("Verdana",12,0xffffff));
			description.y = 46;
			description.autoSize = "vertical";
			description.format.horizontalAlign = "left";
			description.format.verticalAlign = "top";
			addChild(description);
			if(daily.isClaimed) {
				description.text = "CLAIMED!";
				description.format.font = "DAIDRR";
				description.y = 35;
				description.format.size = 16;
				description.autoSize = "none";
				description.height = 30;
				description.format.color = Style.COLOR_LIGHT_GREEN;
				description.format.horizontalAlign = "center";
			}
		}
		
		private function addRewards() : void {
			if(daily.isClaimed) {
				return;
			}
			reward = new DailyReward(g,daily);
			reward.x = 4;
			reward.y = 20;
			addChild(reward);
		}
		
		private function addProgress() : void {
			statusBar = new Statusbar(g,daily);
			statusBar.y = description.y + description.height + 5;
			addChild(statusBar);
			statusBar.addEventListener("dailyMissionClaiming",onClaiming);
			statusBar.addEventListener("dailyMissionClaimed",onClaimed);
			statusBar.addEventListener("dailyMissionReset",onReset);
		}
		
		private function addWiki() : void {
			if(daily.level > g.me.level || daily.isClaimed) {
				return;
			}
			wikiButton = new ImageButton(function():void {
			},g.textureManager.getTextureGUIByTextureName("wiki"));
			wikiButton.x = width - 40;
			addChild(wikiButton);
		}
		
		private function onClaiming(e:Event) : void {
			removeChild(description);
			removeChild(header);
			removeChild(reward);
			removeChild(wikiButton);
		}
		
		private function onClaimed(e:Event) : void {
			parentContainer.dispatchEventWith("dailyMissionsUpdateList");
			addHeader();
			addDescription();
		}
		
		public function onReset(e:Event) : void {
			removeChildren();
			addHeader();
			addRewards();
			addDescription();
			addProgress();
			addWiki();
		}
		
		public function isTypeMission() : Boolean {
			return daily.json.type == "missions";
		}
		
		override public function dispose() : void {
			super.dispose();
			statusBar.removeEventListeners();
			statusBar.dispose();
			ToolTip.disposeType("dailyView");
		}
	}
}


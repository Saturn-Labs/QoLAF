package core.hud.components.shipMenu {
	import core.credits.CreditManager;
	import core.hud.components.PriceCommodities;
	import core.hud.components.ToolTip;
	import core.hud.components.dialogs.PopupBuyMessage;
	import core.player.CrewMember;
	import core.player.Player;
	import core.scene.Game;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class CrewSelector extends Sprite {
		private var g:Game;
		
		private var p:Player;
		
		private var icons:Vector.<MenuSelectIcon> = new Vector.<MenuSelectIcon>();
		
		private var textureManager:ITextureManager;
		
		public function CrewSelector(g:Game, p:Player) {
			this.g = g;
			this.p = p;
			super();
			textureManager = TextureLocator.getService();
			load();
		}
		
		private function load() : void {
			var _local1:String = null;
			var _local3:int = 0;
			var _local4:ITextureManager = TextureLocator.getService();
			for each(var _local2 in p.crewMembers) {
				_local1 = "Crew member: " + _local2.name;
				createCrewIcon(_local3,_local4.getTextureGUIByKey(_local2.imageKey),"slot_crew.png",false,true,true,_local1);
				_local3++;
			}
			_local3;
			while(_local3 < p.unlockedCrewSlots) {
				_local1 = "Unlocked crew slot";
				createCrewIcon(_local3,null,"slot_crew.png",false,false,true,_local1);
				_local3++;
			}
			if(_local3 < 5) {
				_local1 = "Locked crew slow, click to buy this slot";
				createCrewIcon(_local3,null,"slot_crew.png",true,false,true,_local1);
				_local3++;
			}
			_local3;
			while(_local3 < 5) {
				_local1 = "Locked crew slot";
				createCrewIcon(_local3,null,"slot_crew.png",true,false,false,_local1);
				_local3++;
			}
		}
		
		private function createCrewIcon(number:int, txt:Texture, type:String, locked:Boolean = true, inUse:Boolean = false, enabled:Boolean = false, tooltip:String = null) : void {
			var crewIcon:MenuSelectIcon = new MenuSelectIcon(number + 1,txt,type,locked,inUse,enabled);
			crewIcon.x = number * (60);
			if(tooltip != null) {
				new ToolTip(g,crewIcon,tooltip,null,"HomeState");
			}
			if(!locked) {
				crewIcon.addEventListener("touch",function(param1:TouchEvent):void {
					if(param1.getTouch(crewIcon,"ended")) {
						dispatchEventWith("crewSelected");
					}
				});
			} else if(locked && enabled) {
				crewIcon.addEventListener("touch",function(param1:TouchEvent):void {
					if(param1.getTouch(crewIcon,"ended")) {
						openUnlockSlot(crewIcon.number);
					}
				});
			}
			addChild(crewIcon);
			icons.push(crewIcon);
		}
		
		private function openUnlockSlot(number:int) : void {
			var fluxCost:int;
			var unlockCost:int = int(Player.SLOT_CREW_UNLOCK_COST[number - 1]);
			var buyBox:PopupBuyMessage = new PopupBuyMessage(g);
			buyBox.text = "Crew Slot";
			if(number < 4) {
				buyBox.addCost(new PriceCommodities(g,"flpbTKautkC1QzjWT28gkw",unlockCost));
			}
			fluxCost = CreditManager.getCostCrewSlot(number);
			if(fluxCost > 0) {
				buyBox.addBuyForFluxButton(fluxCost,number,"buyCrewSlotWithFlux","Are you sure you want to buy a crew slot?");
				buyBox.addEventListener("fluxBuy",function(param1:Event):void {
					Game.trackEvent("used flux","bought crew slot","number " + number,fluxCost);
					p.unlockedCrewSlots = number;
					g.removeChildFromOverlay(buyBox,true);
					refresh();
				});
			}
			buyBox.addEventListener("accept",function(param1:Event):void {
				var e:Event = param1;
				g.me.tryUnlockSlot("slotCrew",number,function():void {
					g.removeChildFromOverlay(buyBox,true);
					refresh();
				});
			});
			buyBox.addEventListener("close",function(param1:Event):void {
				g.removeChildFromOverlay(buyBox,true);
			});
			g.addChildToOverlay(buyBox);
		}
		
		public function refresh() : void {
			for each(var _local1 in icons) {
				if(contains(_local1)) {
					removeChild(_local1,true);
				}
			}
			icons = new Vector.<MenuSelectIcon>();
			dispatchEventWith("refresh");
			load();
		}
		
		override public function dispose() : void {
			for each(var _local1 in icons) {
				if(contains(_local1)) {
					removeChild(_local1,true);
				}
			}
			icons = null;
			super.dispose();
		}
	}
}


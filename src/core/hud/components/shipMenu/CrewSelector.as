package core.hud.components.shipMenu
{
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
	
	public class CrewSelector extends Sprite
	{
		private var g:Game;
		
		private var p:Player;
		
		private var icons:Vector.<MenuSelectIcon>;
		
		private var textureManager:ITextureManager;
		
		public function CrewSelector(param1:Game, param2:Player)
		{
			icons = new Vector.<MenuSelectIcon>();
			this.g = param1;
			this.p = param2;
			super();
			textureManager = TextureLocator.getService();
			load();
		}
		
		private function load():void
		{
			var _loc2_:String = null;
			var _loc4_:int = 0;
			var _loc1_:ITextureManager = TextureLocator.getService();
			for each (var _loc3_:* in p.crewMembers)
			{
				_loc2_ = "Crew member: " + _loc3_.name;
				createCrewIcon(_loc4_, _loc1_.getTextureGUIByKey(_loc3_.imageKey), "slot_crew.png", false, true, true, _loc2_);
				_loc4_++;
			}
			_loc4_;
			while (_loc4_ < p.unlockedCrewSlots)
			{
				_loc2_ = "Unlocked crew slot";
				createCrewIcon(_loc4_, null, "slot_crew.png", false, false, true, _loc2_);
				_loc4_++;
			}
			if (_loc4_ < 5)
			{
				_loc2_ = "Locked crew slow, click to buy this slot";
				createCrewIcon(_loc4_, null, "slot_crew.png", true, false, true, _loc2_);
				_loc4_++;
			}
			_loc4_;
			while (_loc4_ < 5)
			{
				_loc2_ = "Locked crew slot";
				createCrewIcon(_loc4_, null, "slot_crew.png", true, false, false, _loc2_);
				_loc4_++;
			}
		}
		
		private function createCrewIcon(param1:int, param2:Texture, param3:String, param4:Boolean = true, param5:Boolean = false, param6:Boolean = false, param7:String = null):void
		{
			var number:int = param1;
			var txt:Texture = param2;
			var type:String = param3;
			var locked:Boolean = param4;
			var inUse:Boolean = param5;
			var enabled:Boolean = param6;
			var tooltip:String = param7;
			var crewIcon:MenuSelectIcon = new MenuSelectIcon(number + 1, txt, type, locked, inUse, enabled);
			crewIcon.x = number * 60;
			if (tooltip != null)
			{
				new ToolTip(g, crewIcon, tooltip, null, "HomeState");
			}
			if (!locked)
			{
				crewIcon.addEventListener("touch", function(param1:TouchEvent):void
				{
					if (param1.getTouch(crewIcon, "ended"))
					{
						dispatchEventWith("crewSelected");
					}
				});
			}
			else if (locked && enabled)
			{
				crewIcon.addEventListener("touch", function(param1:TouchEvent):void
				{
					if (param1.getTouch(crewIcon, "ended"))
					{
						openUnlockSlot(crewIcon.number);
					}
				});
			}
			addChild(crewIcon);
			icons.push(crewIcon);
		}
		
		private function openUnlockSlot(param1:int):void
		{
			var fluxCost:int;
			var number:int = param1;
			var unlockCost:int = int(Player.SLOT_CREW_UNLOCK_COST[number - 1]);
			var buyBox:PopupBuyMessage = new PopupBuyMessage(g);
			buyBox.text = "Crew Slot";
			if (number < 4)
			{
				buyBox.addCost(new PriceCommodities(g, "flpbTKautkC1QzjWT28gkw", unlockCost));
			}
			fluxCost = CreditManager.getCostCrewSlot(number);
			if (fluxCost > 0)
			{
				buyBox.addBuyForFluxButton(fluxCost, number, "buyCrewSlotWithFlux", "Are you sure you want to buy a crew slot?");
				buyBox.addEventListener("fluxBuy", function(param1:Event):void
				{
					Game.trackEvent("used flux", "bought crew slot", "number " + number, fluxCost);
					p.unlockedCrewSlots = number;
					g.removeChildFromOverlay(buyBox, true);
					refresh();
				});
			}
			buyBox.addEventListener("accept", function(param1:Event):void
			{
				var e:Event = param1;
				g.me.tryUnlockSlot("slotCrew", number, function():void
				{
					g.removeChildFromOverlay(buyBox, true);
					refresh();
				});
			});
			buyBox.addEventListener("close", function(param1:Event):void
			{
				g.removeChildFromOverlay(buyBox, true);
			});
			g.addChildToOverlay(buyBox);
		}
		
		public function refresh():void
		{
			for each (var _loc1_:* in icons)
			{
				if (contains(_loc1_))
				{
					removeChild(_loc1_, true);
				}
			}
			icons = new Vector.<MenuSelectIcon>();
			dispatchEventWith("refresh");
			load();
		}
		
		override public function dispose():void
		{
			for each (var _loc1_:* in icons)
			{
				if (contains(_loc1_))
				{
					removeChild(_loc1_, true);
				}
			}
			icons = null;
			super.dispose();
		}
	}
}

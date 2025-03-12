package core.hud.components.shipMenu
{
	import core.credits.CreditManager;
	import core.hud.components.PriceCommodities;
	import core.hud.components.ToolTip;
	import core.hud.components.dialogs.PopupBuyMessage;
	import core.player.Player;
	import core.scene.Game;
	import core.weapon.Weapon;
	import debug.Console;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import starling.textures.Texture;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class WeaponSelector extends Sprite
	{
		private var g:Game;
		
		private var p:Player;
		
		private var icons:Vector.<MenuSelectIcon>;
		
		public function WeaponSelector(param1:Game, param2:Player)
		{
			icons = new Vector.<MenuSelectIcon>();
			super();
			this.g = param1;
			this.p = param2;
			load();
		}
		
		private function load():void
		{
			var _loc4_:int = 0;
			var _loc1_:Weapon = null;
			var _loc3_:String = null;
			var _loc2_:ITextureManager = TextureLocator.getService();
			_loc4_ = 0;
			while (_loc4_ < 5)
			{
				_loc1_ = p.getWeaponByHotkey(_loc4_ + 1);
				if (_loc1_ != null)
				{
					_loc3_ = "<FONT COLOR='#2233ff'>" + _loc1_.name + "</FONT>: Click to assign a new weapon to this slot";
					addWeaponSelectIcon(_loc4_, _loc2_.getTextureGUIByKey(_loc1_.techIconFileName), "slot_weapon.png", false, true, true, _loc1_.hotkey.toString(), _loc3_);
				}
				else if (_loc4_ < p.unlockedWeaponSlots)
				{
					_loc3_ = "Empty: Click to assign a weapon to this slot";
					Console.write(_loc4_ + " not in use");
					addWeaponSelectIcon(_loc4_, null, "slot_weapon.png", false, false, true, null, _loc3_);
				}
				else if (_loc4_ == p.unlockedWeaponSlots)
				{
					_loc3_ = "Click to unlock this weapon slot";
					Console.write(_loc4_ + " locked");
					addWeaponSelectIcon(_loc4_, null, "slot_weapon.png", true, false, true, null, _loc3_);
				}
				else
				{
					_loc3_ = "Locked.";
					addWeaponSelectIcon(_loc4_, null, "slot_weapon.png", true, false, false, null, _loc3_);
				}
				_loc4_++;
			}
		}
		
		private function addWeaponSelectIcon(param1:int, param2:Texture, param3:String, param4:Boolean = true, param5:Boolean = false, param6:Boolean = false, param7:String = null, param8:String = null):void
		{
			var i:int = param1;
			var txt:Texture = param2;
			var type:String = param3;
			var locked:Boolean = param4;
			var inUse:Boolean = param5;
			var enabled:Boolean = param6;
			var caption:String = param7;
			var tooltip:String = param8;
			var weaponSelectIcon:MenuSelectIcon = new MenuSelectIcon(i + 1, txt, type, locked, inUse, enabled, 0, caption);
			weaponSelectIcon.x = i * 60;
			addChild(weaponSelectIcon);
			icons.push(weaponSelectIcon);
			if (!locked)
			{
				weaponSelectIcon.addEventListener("touch", function(param1:TouchEvent):void
				{
					if (param1.getTouch(weaponSelectIcon, "ended"))
					{
						dispatchEventWith("changeWeapon", false, weaponSelectIcon.number);
					}
				});
			}
			else if (locked && enabled)
			{
				weaponSelectIcon.addEventListener("touch", function(param1:TouchEvent):void
				{
					if (param1.getTouch(weaponSelectIcon, "ended"))
					{
						openUnlockSlot(weaponSelectIcon.number);
					}
				});
			}
			if (tooltip != null)
			{
				new ToolTip(g, weaponSelectIcon, tooltip, null, "HomeState");
			}
		}
		
		private function openUnlockSlot(param1:int):void
		{
			var fluxCost:int;
			var number:int = param1;
			var unlockCost:int = int(Player.SLOT_WEAPON_UNLOCK_COST[number - 1]);
			var buyBox:PopupBuyMessage = new PopupBuyMessage(g);
			buyBox.text = "Weapon Slot";
			buyBox.addCost(new PriceCommodities(g, "flpbTKautkC1QzjWT28gkw", unlockCost));
			buyBox.x = g.stage.stageWidth / 2 - buyBox.width / 2;
			buyBox.y = g.stage.stageHeight / 2 - buyBox.height / 2;
			fluxCost = CreditManager.getCostWeaponSlot(number);
			if (fluxCost > 0)
			{
				buyBox.addBuyForFluxButton(fluxCost, number, "buyWeaponSlotWithFlux", "Are you sure you want to buy a weapon slot?");
				buyBox.addEventListener("fluxBuy", function(param1:Event):void
				{
					Game.trackEvent("used flux", "bought weapon slot", "number " + number);
					p.unlockedWeaponSlots = number;
					g.removeChildFromOverlay(buyBox, true);
					refresh();
				});
			}
			buyBox.addEventListener("accept", function(param1:Event):void
			{
				var e:Event = param1;
				g.me.tryUnlockSlot("slotWeapon", number, function():void
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

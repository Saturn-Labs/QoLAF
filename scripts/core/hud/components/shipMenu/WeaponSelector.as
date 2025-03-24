package core.hud.components.shipMenu {
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
	
	public class WeaponSelector extends Sprite {
		private var g:Game;
		
		private var p:Player;
		
		private var icons:Vector.<MenuSelectIcon> = new Vector.<MenuSelectIcon>();
		
		public function WeaponSelector(g:Game, p:Player) {
			super();
			this.g = g;
			this.p = p;
			load();
		}
		
		private function load() : void {
			var _local3:int = 0;
			var _local2:Weapon = null;
			var _local1:String = null;
			var _local4:ITextureManager = TextureLocator.getService();
			_local3 = 0;
			while(_local3 < 5) {
				_local2 = p.getWeaponByHotkey(_local3 + 1);
				if(_local2 != null) {
					_local1 = "<FONT COLOR=\'#2233ff\'>" + _local2.name + "</FONT>: Click to assign a new weapon to this slot";
					addWeaponSelectIcon(_local3,_local4.getTextureGUIByKey(_local2.techIconFileName),"slot_weapon.png",false,true,true,_local2.hotkey.toString(),_local1);
				} else if(_local3 < p.unlockedWeaponSlots) {
					_local1 = "Empty: Click to assign a weapon to this slot";
					Console.write(_local3 + " not in use");
					addWeaponSelectIcon(_local3,null,"slot_weapon.png",false,false,true,null,_local1);
				} else if(_local3 == p.unlockedWeaponSlots) {
					_local1 = "Click to unlock this weapon slot";
					Console.write(_local3 + " locked");
					addWeaponSelectIcon(_local3,null,"slot_weapon.png",true,false,true,null,_local1);
				} else {
					_local1 = "Locked.";
					addWeaponSelectIcon(_local3,null,"slot_weapon.png",true,false,false,null,_local1);
				}
				_local3++;
			}
		}
		
		private function addWeaponSelectIcon(i:int, txt:Texture, type:String, locked:Boolean = true, inUse:Boolean = false, enabled:Boolean = false, caption:String = null, tooltip:String = null) : void {
			var weaponSelectIcon:MenuSelectIcon = new MenuSelectIcon(i + 1,txt,type,locked,inUse,enabled,0,caption);
			weaponSelectIcon.x = i * (60);
			addChild(weaponSelectIcon);
			icons.push(weaponSelectIcon);
			if(!locked) {
				weaponSelectIcon.addEventListener("touch",function(param1:TouchEvent):void {
					if(param1.getTouch(weaponSelectIcon,"ended")) {
						dispatchEventWith("changeWeapon",false,weaponSelectIcon.number);
					}
				});
			} else if(locked && enabled) {
				weaponSelectIcon.addEventListener("touch",function(param1:TouchEvent):void {
					if(param1.getTouch(weaponSelectIcon,"ended")) {
						openUnlockSlot(weaponSelectIcon.number);
					}
				});
			}
			if(tooltip != null) {
				new ToolTip(g,weaponSelectIcon,tooltip,null,"HomeState");
			}
		}
		
		private function openUnlockSlot(number:int) : void {
			var fluxCost:int;
			var unlockCost:int = int(Player.SLOT_WEAPON_UNLOCK_COST[number - 1]);
			var buyBox:PopupBuyMessage = new PopupBuyMessage(g);
			buyBox.text = "Weapon Slot";
			buyBox.addCost(new PriceCommodities(g,"flpbTKautkC1QzjWT28gkw",unlockCost));
			buyBox.x = g.stage.stageWidth / 2 - buyBox.width / 2;
			buyBox.y = g.stage.stageHeight / 2 - buyBox.height / 2;
			fluxCost = CreditManager.getCostWeaponSlot(number);
			if(fluxCost > 0) {
				buyBox.addBuyForFluxButton(fluxCost,number,"buyWeaponSlotWithFlux","Are you sure you want to buy a weapon slot?");
				buyBox.addEventListener("fluxBuy",function(param1:Event):void {
					Game.trackEvent("used flux","bought weapon slot","number " + number);
					p.unlockedWeaponSlots = number;
					g.removeChildFromOverlay(buyBox,true);
					refresh();
				});
			}
			buyBox.addEventListener("accept",function(param1:Event):void {
				var e:Event = param1;
				g.me.tryUnlockSlot("slotWeapon",number,function():void {
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


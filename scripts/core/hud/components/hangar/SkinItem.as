package core.hud.components.hangar {
	import core.GameObject;
	import core.artifact.ArtifactStat;
	import core.hud.components.Button;
	import core.hud.components.SaleTimer;
	import core.hud.components.Text;
	import core.hud.components.credits.CreditLabel;
	import core.hud.components.dialogs.CreditBuyBox;
	import core.hud.components.techTree.TechBar;
	import core.particle.Emitter;
	import core.particle.EmitterFactory;
	import core.player.FleetObj;
	import core.player.TechSkill;
	import core.scene.Game;
	import core.ship.ShipFactory;
	import facebook.Action;
	import generics.Color;
	import generics.Localize;
	import generics.Util;
	import playerio.Message;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import textures.TextureLocator;
	
	public class SkinItem extends Sprite {
		public static const MODE_SWITCH:int = 0;
		
		public static const MODE_BUY:int = 1;
		
		public static const MODE_PREVIEW:int = 2;
		
		public static const MODE_SPINNER:int = 3;
		
		private var g:Game;
		
		private var obj:Object;
		
		private var mode:int;
		
		public var buyContainer:Sprite = new Sprite();
		
		public var buyButton:Button = null;
		
		private var premanufacturedDetails:Sprite = new Sprite();
		
		private var hasSpecialWeapon:Boolean = false;
		
		private var specialweapon:Sprite = new Sprite();
		
		private var premanufactured:Sprite = new Sprite();
		
		private var specialStats:Sprite = new Sprite();
		
		private var specialCount:int = 0;
		
		private var stats:SkinItemBaseStats;
		
		private var cost:CreditLabel;
		
		private var desc:Text = new Text(0,50,true,"Verdana");
		
		private var emitters:Vector.<Emitter> = new Vector.<Emitter>();
		
		private var clickedButton:Button;
		
		private var activateButton:Button;
		
		public function SkinItem(g:Game, obj:Object, mode:int) {
			super();
			this.g = g;
			this.obj = obj;
			this.mode = mode;
			addBuy();
			addShip();
			addNameAndDescription();
			addBaseStats();
			addSpecialStats();
			addSpecialWeapon();
			addPremanufacturedSkills();
			addPremanufacturedDetails();
		}
		
		private function addPremanufacturedDetails() : void {
			premanufacturedDetails.y = premanufactured.y + premanufactured.height + 15;
			var _local2:Text = new Text(0,0,true,"Verdana");
			_local2.text = Localize.t(obj.upgradeDescription);
			_local2.width = 372;
			_local2.size = 14;
			_local2.color = 0xaaaaaa;
			premanufacturedDetails.addChild(_local2);
			var _local1:Quad = new Quad(100,20,0);
			_local1.y = _local2.height + 3;
			premanufacturedDetails.addChild(_local1);
			addChild(premanufacturedDetails);
		}
		
		private function addSpecialWeapon() : void {
			var _local6:int = 0;
			var _local7:Object = null;
			var _local5:TechSkill = null;
			var _local1:TechBar = null;
			var _local3:Text = null;
			var _local4:Text = null;
			specialweapon.y = stats.y + stats.height + 10;
			var _local2:int = 30;
			_local6 = 0;
			while(_local6 < obj.upgrades.length) {
				_local7 = obj.upgrades[_local6];
				if(!(_local7.table != "Weapons" || _local7.name == "Blaster")) {
					_local5 = new TechSkill();
					_local5.setData(_local7);
					_local1 = new TechBar(g,_local5,g.me,true,true);
					_local1.y = _local2;
					specialweapon.addChild(_local1);
					_local2 += 45;
					hasSpecialWeapon = true;
				}
				_local6++;
			}
			if(hasSpecialWeapon) {
				_local3 = getHeaderText(Localize.t("Special Weapon") + ":");
				specialweapon.addChild(_local3);
				_local4 = new Text(0,specialweapon.height + 20,true,"Verdana");
				_local4.text = obj.specialDescription;
				_local4.width = 372;
				_local4.size = 14;
				_local4.color = 0xaaaaaa;
				specialweapon.addChild(_local4);
				addChild(specialweapon);
			}
		}
		
		private function addPremanufacturedSkills() : void {
			var _local5:int = 0;
			var _local6:Object = null;
			var _local4:TechSkill = null;
			var _local1:TechBar = null;
			var _local2:Text = getHeaderText(Localize.t("Premanufactured") + ":");
			premanufactured.addChild(_local2);
			if(hasSpecialWeapon) {
				premanufactured.y = specialweapon.y + specialweapon.height + 10;
			} else {
				premanufactured.y = stats.y + stats.height + 10;
			}
			obj.upgrades.sortOn("level",16);
			obj.upgrades.reverse();
			var _local3:int = 0;
			_local5 = 0;
			while(_local5 < obj.upgrades.length) {
				_local6 = obj.upgrades[_local5];
				if(!(!_local6.table || _local6.level < 1)) {
					_local4 = new TechSkill();
					_local4.setData(_local6);
					_local1 = new TechBar(g,_local4,g.me,true,true,_local6.level);
					_local1.y = 30 + _local5 * 45;
					premanufactured.addChild(_local1);
					_local3++;
				}
				_local5++;
			}
			if(_local3 == 0) {
				_local2.visible = false;
			}
			addChild(premanufactured);
		}
		
		private function addSpecialStats() : void {
			var _local2:Text = getHeaderText(Localize.t("Specialties") + ":");
			_local2.alignRight();
			var _local1:int = 20;
			specialStats.addChild(_local2);
			specialStats.x = 370;
			specialStats.y = stats.y;
			for(var _local3 in obj.specials) {
				addSpecialText("" + _local3);
			}
			if(specialCount == 0) {
				_local2.visible = false;
			}
			addChild(specialStats);
		}
		
		private function addSpecialText(type:String) : void {
			var _local2:Object = obj.specials;
			if(_local2[type] == 0) {
				return;
			}
			var _local3:Text = new Text(0,23 + specialCount * 20,false,"Verdana");
			_local3.size = 13;
			_local3.color = 0xffffff;
			_local3.text = ArtifactStat.parseTextFromStatTypeShort(type,_local2[type]);
			_local3.alignRight();
			specialStats.addChild(_local3);
			specialCount++;
		}
		
		private function addBaseStats() : void {
			var _local1:Text = getHeaderText(Localize.t("Base stats") + ":");
			stats = new SkinItemBaseStats(obj);
			stats.y = desc.y + desc.height + 15;
			stats.addChild(_local1);
			addChild(stats);
		}
		
		private function addBuy() : void {
			var originalCost:Text;
			var crossOver:Image;
			var saleTimer:SaleTimer;
			buyContainer.removeChildren();
			if(mode == 2) {
				return;
			}
			if(!g.me.hasSkin(obj.key)) {
				cost = new CreditLabel();
				cost.x = 263;
				cost.y = 20;
				cost.text = !!obj.salePrice ? obj.salePrice : obj.price;
				cost.size = 16;
				cost.alignRight();
				buyContainer.addChild(cost);
				if(obj.salePrice) {
					originalCost = new Text();
					originalCost.text = obj.price;
					originalCost.size = 14;
					originalCost.x = cost.x - cost.width - 20 - originalCost.width;
					originalCost.y = cost.y + 2;
					originalCost.color = 0xaaaaaa;
					buyContainer.addChild(originalCost);
					crossOver = new Image(TextureLocator.getService().getTextureGUIByTextureName("cross_over"));
					crossOver.x = originalCost.x - 15;
					crossOver.y = originalCost.y - 5;
					buyContainer.addChild(crossOver);
				}
				buyButton = createButton(obj);
				if(g.salesManager.getSpecialSkinSale(obj.key) && mode != 3) {
					saleTimer = new SaleTimer(g,g.time - 2 * 60 * 1000,g.time + 2 * 60 * 1000,function():void {
						if(buyButton != null) {
							buyButton.enabled = false;
						}
					});
					buyContainer.addChild(saleTimer);
				}
			} else if(mode == 1 || mode == 3) {
				addAquiredText();
			} else if(mode == 0 && g.me.activeSkin != obj.key) {
				addSwitchButton();
			}
			if(mode != 3) {
				addChild(buyContainer);
			}
		}
		
		private function getHeaderText(txt:String) : Text {
			var _local2:Text = new Text();
			_local2.color = 16689475;
			_local2.text = txt;
			_local2.size = 13;
			return _local2;
		}
		
		private function addNameAndDescription() : void {
			var _local1:Text = new Text();
			_local1.size = 22;
			_local1.y = mode == 3 ? 0 : 60;
			_local1.color = 16689475;
			_local1.text = Localize.t(obj.name);
			addChild(_local1);
			desc.text = Localize.t(obj.description);
			desc.width = 372;
			desc.size = 14;
			desc.y = _local1.y + _local1.height + 10;
			desc.color = 0xaaaaaa;
			addChild(desc);
		}
		
		private function addShip() : void {
			var _local4:* = null;
			var _local2:* = undefined;
			var _local9:FleetObj = g.me.getFleetObj(obj.key);
			var _local8:Object = g.dataManager.loadKey("Ships",obj.ship);
			var _local6:Object = g.dataManager.loadKey("Engines",obj.engine);
			var _local1:GameObject = new GameObject();
			_local1.switchTexturesByObj(_local8);
			var _local7:Number = 0;
			if(mode == 0) {
				_local7 = !!_local9.engineHue ? _local9.engineHue : 0;
				_local1.movieClip.filter = ShipFactory.createPlayerShipColorMatrixFilter(_local9);
			}
			var _local5:Vector.<Emitter> = EmitterFactory.create(_local6.effect,g,_local8.enginePosX,0,_local1,true,true,true,this);
			var _local3:Sprite = new Sprite();
			_local1.canvas = _local3;
			_local1.addToCanvas();
			_local3.x = 339;
			_local3.y = mode == 3 ? _local1.movieClip.height / 2 : 76;
			addChild(_local3);
			if(_local6.dual) {
				for each(_local4 in _local5) {
					_local4.global = true;
					_local4.delay = 0;
					_local4.followTarget = false;
					_local4.posX = _local3.x - _local8.enginePosX;
					_local4.posY = _local3.y + _local6.dualDistance / 2;
					_local4.angle = Util.degreesToRadians(3 * 60);
					emitters.push(_local4);
				}
				_local2 = EmitterFactory.create(_local6.effect,g,_local8.enginePosX,0,_local1,true,true,true,this);
				for each(_local4 in _local2) {
					_local4.global = true;
					_local4.delay = 0;
					_local4.followTarget = false;
					_local4.posX = _local3.x - _local8.enginePosX;
					_local4.posY = _local3.y - _local6.dualDistance / 2;
					_local4.angle = Util.degreesToRadians(3 * 60);
					emitters.push(_local4);
				}
			} else {
				for each(_local4 in _local5) {
					_local4.global = true;
					_local4.delay = 0;
					_local4.followTarget = false;
					_local4.posX = _local3.x - _local8.enginePosX;
					_local4.posY = _local3.y;
					_local4.angle = Util.degreesToRadians(3 * 60);
					emitters.push(_local4);
				}
			}
			if(mode == 0) {
				if(_local6.changeThrustColors) {
					for each(_local4 in emitters) {
						_local4.startColor = Color.HEXHue(_local6.thrustStartColor,_local7);
						_local4.finishColor = Color.HEXHue(_local6.thrustFinishColor,_local7);
					}
				} else {
					for each(_local4 in emitters) {
						_local4.changeHue(_local7);
					}
				}
			} else if(_local6.changeThrustColors) {
				for each(_local4 in emitters) {
					_local4.startColor = _local6.thrustStartColor;
					_local4.finishColor = _local6.thrustFinishColor;
				}
			}
		}
		
		private function createButton(obj:Object) : Button {
			var buyButton:Button = new Button(function():void {
				var buyConfirm:CreditBuyBox = new CreditBuyBox(g,!!obj.salePrice ? obj.salePrice : obj.price,Localize.t("This will add a new ship to your fleet."));
				g.addChildToOverlay(buyConfirm);
				buyConfirm.addEventListener("accept",function(param1:Event):void {
					onBuy(obj);
					clickedButton = buyButton;
					buyConfirm.removeEventListeners();
					buyButton.enabled = false;
					buyButton.visible = false;
				});
				buyConfirm.addEventListener("close",function(param1:Event):void {
					buyConfirm.removeEventListeners();
					buyButton.enabled = true;
				});
			},Localize.t("Buy"),"buy");
			buyButton.width = 70;
			buyButton.size = 11;
			buyButton.x = 5 * 60;
			buyButton.y = 16;
			buyContainer.addChild(buyButton);
			return buyButton;
		}
		
		private function onBuy(obj:Object) : void {
			g.rpc("buySkin",onBuyComplete,obj.key);
		}
		
		private function onBuyComplete(m:Message) : void {
			if(!m.getBoolean(0)) {
				g.showErrorDialog(m.getString(1));
				clickedButton.enabled = true;
				return;
			}
			g.me.addNewSkin(m.getString(1));
			g.infoMessageDialog(Localize.t("Purchase successful!\nYour new ship is added to your fleet."));
			Game.trackEvent("used flux","bought ship",obj.name,obj.price);
			Action.unlockShip(m.getString(1));
			buyContainer.removeChildren();
			addAquiredText();
			removeChild(clickedButton);
			removeChild(cost);
			dispatchEventWith("bought");
		}
		
		private function addAquiredText() : void {
			var _local1:Text = new Text(375,15);
			_local1.text = Localize.t("You already own this ship.");
			_local1.alignRight();
			_local1.size = 12;
			_local1.color = 0x44ff44;
			buyContainer.addChild(_local1);
		}
		
		private function addSwitchButton() : void {
			activateButton = new Button(activateShip,Localize.t("Use this ship"),"positive");
			activateButton.x = 230;
			activateButton.y = 15;
			addChild(activateButton);
		}
		
		private function activateShip(e:TouchEvent = null) : void {
			g.me.changeSkin(obj.key);
			removeChild(activateButton);
			var _local2:Text = new Text(375,15);
			_local2.text = Localize.t("Activated");
			_local2.alignRight();
			_local2.size = 12;
			_local2.color = 0x44ff44;
			addChild(_local2);
			g.me.leaveBody();
		}
		
		override public function dispose() : void {
			for each(var _local1 in emitters) {
				_local1.killEmitter();
			}
			emitters = null;
			super.dispose();
		}
	}
}


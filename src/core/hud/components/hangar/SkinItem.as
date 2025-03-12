package core.hud.components.hangar
{
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
	
	public class SkinItem extends Sprite
	{
		public static const MODE_SWITCH:int = 0;
		public static const MODE_BUY:int = 1;
		public static const MODE_PREVIEW:int = 2;
		public static const MODE_SPINNER:int = 3;
		private var g:Game;
		
		private var obj:Object;
		
		private var mode:int;
		
		public var buyContainer:Sprite;
		
		public var buyButton:Button = null;
		private var premanufacturedDetails:Sprite;
		
		private var hasSpecialWeapon:Boolean = false;
		private var specialweapon:Sprite;
		
		private var premanufactured:Sprite;
		
		private var specialStats:Sprite;
		
		private var specialCount:int = 0;
		private var stats:SkinItemBaseStats;
		
		private var cost:CreditLabel;
		
		private var desc:Text;
		
		private var emitters:Vector.<Emitter>;
		
		private var clickedButton:Button;
		
		private var activateButton:Button;
		
		public function SkinItem(param1:Game, param2:Object, param3:int)
		{
			buyContainer = new Sprite();
			premanufacturedDetails = new Sprite();
			specialweapon = new Sprite();
			premanufactured = new Sprite();
			specialStats = new Sprite();
			desc = new Text(0, 50, true, "Verdana");
			emitters = new Vector.<Emitter>();
			super();
			this.g = param1;
			this.obj = param2;
			this.mode = param3;
			addBuy();
			addShip();
			addNameAndDescription();
			addBaseStats();
			addSpecialStats();
			addSpecialWeapon();
			addPremanufacturedSkills();
			addPremanufacturedDetails();
		}
		
		private function addPremanufacturedDetails():void
		{
			premanufacturedDetails.y = premanufactured.y + premanufactured.height + 15;
			var _loc1_:Text = new Text(0, 0, true, "Verdana");
			_loc1_.text = Localize.t(obj.upgradeDescription);
			_loc1_.width = 372;
			_loc1_.size = 14;
			_loc1_.color = 11184810;
			premanufacturedDetails.addChild(_loc1_);
			var _loc2_:Quad = new Quad(100, 20, 0);
			_loc2_.y = _loc1_.height + 3;
			premanufacturedDetails.addChild(_loc2_);
			addChild(premanufacturedDetails);
		}
		
		private function addSpecialWeapon():void
		{
			var _loc7_:int = 0;
			var _loc5_:Object = null;
			var _loc4_:TechSkill = null;
			var _loc1_:TechBar = null;
			var _loc3_:Text = null;
			var _loc2_:Text = null;
			specialweapon.y = stats.y + stats.height + 10;
			var _loc6_:int = 30;
			_loc7_ = 0;
			while (_loc7_ < obj.upgrades.length)
			{
				_loc5_ = obj.upgrades[_loc7_];
				if (!(_loc5_.table != "Weapons" || _loc5_.name == "Blaster"))
				{
					_loc4_ = new TechSkill();
					_loc4_.setData(_loc5_);
					_loc1_ = new TechBar(g, _loc4_, g.me, true, true);
					_loc1_.y = _loc6_;
					specialweapon.addChild(_loc1_);
					_loc6_ += 45;
					hasSpecialWeapon = true;
				}
				_loc7_++;
			}
			if (hasSpecialWeapon)
			{
				_loc3_ = getHeaderText(Localize.t("Special Weapon") + ":");
				specialweapon.addChild(_loc3_);
				_loc2_ = new Text(0, specialweapon.height + 20, true, "Verdana");
				_loc2_.text = obj.specialDescription;
				_loc2_.width = 372;
				_loc2_.size = 14;
				_loc2_.color = 11184810;
				specialweapon.addChild(_loc2_);
				addChild(specialweapon);
			}
		}
		
		private function addPremanufacturedSkills():void
		{
			var _loc6_:int = 0;
			var _loc5_:Object = null;
			var _loc2_:TechSkill = null;
			var _loc1_:TechBar = null;
			var _loc3_:Text = getHeaderText(Localize.t("Premanufactured") + ":");
			premanufactured.addChild(_loc3_);
			if (hasSpecialWeapon)
			{
				premanufactured.y = specialweapon.y + specialweapon.height + 10;
			}
			else
			{
				premanufactured.y = stats.y + stats.height + 10;
			}
			obj.upgrades.sortOn("level", 16);
			obj.upgrades.reverse();
			var _loc4_:int = 0;
			_loc6_ = 0;
			while (_loc6_ < obj.upgrades.length)
			{
				_loc5_ = obj.upgrades[_loc6_];
				if (!(!_loc5_.table || _loc5_.level < 1))
				{
					_loc2_ = new TechSkill();
					_loc2_.setData(_loc5_);
					_loc1_ = new TechBar(g, _loc2_, g.me, true, true, _loc5_.level);
					_loc1_.y = 30 + _loc6_ * 45;
					premanufactured.addChild(_loc1_);
					_loc4_++;
				}
				_loc6_++;
			}
			if (_loc4_ == 0)
			{
				_loc3_.visible = false;
			}
			addChild(premanufactured);
		}
		
		private function addSpecialStats():void
		{
			var _loc2_:Text = getHeaderText(Localize.t("Specialties") + ":");
			_loc2_.alignRight();
			var _loc1_:int = 20;
			specialStats.addChild(_loc2_);
			specialStats.x = 370;
			specialStats.y = stats.y;
			for (var _loc3_:* in obj.specials)
			{
				addSpecialText("" + _loc3_);
			}
			if (specialCount == 0)
			{
				_loc2_.visible = false;
			}
			addChild(specialStats);
		}
		
		private function addSpecialText(param1:String):void
		{
			var _loc3_:Object = obj.specials;
			if (_loc3_[param1] == 0)
			{
				return;
			}
			var _loc2_:Text = new Text(0, 23 + specialCount * 20, false, "Verdana");
			_loc2_.size = 13;
			_loc2_.color = 16777215;
			_loc2_.text = ArtifactStat.parseTextFromStatTypeShort(param1, _loc3_[param1]);
			_loc2_.alignRight();
			specialStats.addChild(_loc2_);
			specialCount++;
		}
		
		private function addBaseStats():void
		{
			var _loc1_:Text = getHeaderText(Localize.t("Base stats") + ":");
			stats = new SkinItemBaseStats(obj);
			stats.y = desc.y + desc.height + 15;
			stats.addChild(_loc1_);
			addChild(stats);
		}
		
		private function addBuy():void
		{
			var originalCost:Text;
			var crossOver:Image;
			var saleTimer:SaleTimer;
			buyContainer.removeChildren();
			if (mode == 2)
			{
				return;
			}
			if (!g.me.hasSkin(obj.key))
			{
				cost = new CreditLabel();
				cost.x = 263;
				cost.y = 20;
				cost.text = !!obj.salePrice ? obj.salePrice : obj.price;
				cost.size = 16;
				cost.alignRight();
				buyContainer.addChild(cost);
				if (obj.salePrice)
				{
					originalCost = new Text();
					originalCost.text = obj.price;
					originalCost.size = 14;
					originalCost.x = cost.x - cost.width - 20 - originalCost.width;
					originalCost.y = cost.y + 2;
					originalCost.color = 11184810;
					buyContainer.addChild(originalCost);
					crossOver = new Image(TextureLocator.getService().getTextureGUIByTextureName("cross_over"));
					crossOver.x = originalCost.x - 15;
					crossOver.y = originalCost.y - 5;
					buyContainer.addChild(crossOver);
				}
				buyButton = createButton(obj);
				if (g.salesManager.getSpecialSkinSale(obj.key) && mode != 3)
				{
					saleTimer = new SaleTimer(g, g.time - 120000, g.time + 120000, function():void
					{
						if (buyButton != null)
						{
							buyButton.enabled = false;
						}
					});
					buyContainer.addChild(saleTimer);
				}
			}
			else if (mode == 1 || mode == 3)
			{
				addAquiredText();
			}
			else if (mode == 0 && g.me.activeSkin != obj.key)
			{
				addSwitchButton();
			}
			if (mode != 3)
			{
				addChild(buyContainer);
			}
		}
		
		private function getHeaderText(param1:String):Text
		{
			var _loc2_:Text = new Text();
			_loc2_.color = 16689475;
			_loc2_.text = param1;
			_loc2_.size = 13;
			return _loc2_;
		}
		
		private function addNameAndDescription():void
		{
			var _loc1_:Text = new Text();
			_loc1_.size = 22;
			_loc1_.y = mode == 3 ? 0 : 60;
			_loc1_.color = 16689475;
			_loc1_.text = Localize.t(obj.name);
			addChild(_loc1_);
			desc.text = Localize.t(obj.description);
			desc.width = 372;
			desc.size = 14;
			desc.y = _loc1_.y + _loc1_.height + 10;
			desc.color = 11184810;
			addChild(desc);
		}
		
		private function addShip():void
		{
			var _loc1_:* = null;
			var _loc5_:* = undefined;
			var _loc8_:FleetObj = g.me.getFleetObj(obj.key);
			var _loc9_:Object = g.dataManager.loadKey("Ships", obj.ship);
			var _loc7_:Object = g.dataManager.loadKey("Engines", obj.engine);
			var _loc3_:GameObject = new GameObject();
			_loc3_.switchTexturesByObj(_loc9_);
			var _loc4_:Number = 0;
			if (mode == 0)
			{
				_loc4_ = !!_loc8_.engineHue ? _loc8_.engineHue : 0;
				_loc3_.movieClip.filter = ShipFactory.createPlayerShipColorMatrixFilter(_loc8_);
			}
			var _loc2_:Vector.<Emitter> = EmitterFactory.create(_loc7_.effect, g, _loc9_.enginePosX, 0, _loc3_, true, true, true, this);
			var _loc6_:Sprite = new Sprite();
			_loc3_.canvas = _loc6_;
			_loc3_.addToCanvas();
			_loc6_.x = 339;
			_loc6_.y = mode == 3 ? _loc3_.movieClip.height / 2 : 76;
			addChild(_loc6_);
			if (_loc7_.dual)
			{
				for each (_loc1_ in _loc2_)
				{
					_loc1_.global = true;
					_loc1_.delay = 0;
					_loc1_.followTarget = false;
					_loc1_.posX = _loc6_.x - _loc9_.enginePosX;
					_loc1_.posY = _loc6_.y + _loc7_.dualDistance / 2;
					_loc1_.angle = Util.degreesToRadians(180);
					emitters.push(_loc1_);
				}
				_loc5_ = EmitterFactory.create(_loc7_.effect, g, _loc9_.enginePosX, 0, _loc3_, true, true, true, this);
				for each (_loc1_ in _loc5_)
				{
					_loc1_.global = true;
					_loc1_.delay = 0;
					_loc1_.followTarget = false;
					_loc1_.posX = _loc6_.x - _loc9_.enginePosX;
					_loc1_.posY = _loc6_.y - _loc7_.dualDistance / 2;
					_loc1_.angle = Util.degreesToRadians(180);
					emitters.push(_loc1_);
				}
			}
			else
			{
				for each (_loc1_ in _loc2_)
				{
					_loc1_.global = true;
					_loc1_.delay = 0;
					_loc1_.followTarget = false;
					_loc1_.posX = _loc6_.x - _loc9_.enginePosX;
					_loc1_.posY = _loc6_.y;
					_loc1_.angle = Util.degreesToRadians(180);
					emitters.push(_loc1_);
				}
			}
			if (mode == 0)
			{
				if (_loc7_.changeThrustColors)
				{
					for each (_loc1_ in emitters)
					{
						_loc1_.startColor = Color.HEXHue(_loc7_.thrustStartColor, _loc4_);
						_loc1_.finishColor = Color.HEXHue(_loc7_.thrustFinishColor, _loc4_);
					}
				}
				else
				{
					for each (_loc1_ in emitters)
					{
						_loc1_.changeHue(_loc4_);
					}
				}
			}
			else if (_loc7_.changeThrustColors)
			{
				for each (_loc1_ in emitters)
				{
					_loc1_.startColor = _loc7_.thrustStartColor;
					_loc1_.finishColor = _loc7_.thrustFinishColor;
				}
			}
		}
		
		private function createButton(param1:Object):Button
		{
			var obj:Object = param1;
			var buyButton:Button = new Button(function():void
			{
				var buyConfirm:CreditBuyBox = new CreditBuyBox(g, !!obj.salePrice ? obj.salePrice : obj.price, Localize.t("This will add a new ship to your fleet."));
				g.addChildToOverlay(buyConfirm);
				buyConfirm.addEventListener("accept", function(param1:Event):void
				{
					onBuy(obj);
					clickedButton = buyButton;
					buyConfirm.removeEventListeners();
					buyButton.enabled = false;
					buyButton.visible = false;
				});
				buyConfirm.addEventListener("close", function(param1:Event):void
				{
					buyConfirm.removeEventListeners();
					buyButton.enabled = true;
				});
			}, Localize.t("Buy"), "buy");
			buyButton.width = 70;
			buyButton.size = 11;
			buyButton.x = 300;
			buyButton.y = 16;
			buyContainer.addChild(buyButton);
			return buyButton;
		}
		
		private function onBuy(param1:Object):void
		{
			g.rpc("buySkin", onBuyComplete, param1.key);
		}
		
		private function onBuyComplete(param1:Message):void
		{
			if (!param1.getBoolean(0))
			{
				g.showErrorDialog(param1.getString(1));
				clickedButton.enabled = true;
				return;
			}
			g.me.addNewSkin(param1.getString(1));
			g.infoMessageDialog(Localize.t("Purchase successful!\nYour new ship is added to your fleet."));
			Game.trackEvent("used flux", "bought ship", obj.name, obj.price);
			Action.unlockShip(param1.getString(1));
			buyContainer.removeChildren();
			addAquiredText();
			removeChild(clickedButton);
			removeChild(cost);
			dispatchEventWith("bought");
		}
		
		private function addAquiredText():void
		{
			var _loc1_:Text = new Text(375, 15);
			_loc1_.text = Localize.t("You already own this ship.");
			_loc1_.alignRight();
			_loc1_.size = 12;
			_loc1_.color = 4521796;
			buyContainer.addChild(_loc1_);
		}
		
		private function addSwitchButton():void
		{
			activateButton = new Button(activateShip, Localize.t("Use this ship"), "positive");
			activateButton.x = 230;
			activateButton.y = 15;
			addChild(activateButton);
		}
		
		private function activateShip(param1:TouchEvent = null):void
		{
			g.me.changeSkin(obj.key);
			removeChild(activateButton);
			var _loc2_:Text = new Text(375, 15);
			_loc2_.text = Localize.t("Activated");
			_loc2_.alignRight();
			_loc2_.size = 12;
			_loc2_.color = 4521796;
			addChild(_loc2_);
			g.me.leaveBody();
		}
		
		override public function dispose():void
		{
			for each (var _loc1_:* in emitters)
			{
				_loc1_.killEmitter();
			}
			emitters = null;
			super.dispose();
		}
	}
}

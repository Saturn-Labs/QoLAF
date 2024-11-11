package core.hud.components.credits
{
	import core.hud.components.Button;
	import core.hud.components.Style;
	import core.hud.components.Text;
	import core.hud.components.dialogs.CreditBuyBox;
	import core.scene.Game;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;

	public class CreditDayItem extends CreditBaseItem
	{
		public static var PRICE_1_DAY:int = 75;
		public static var PRICE_3_DAY:int = 215;
		public static var PRICE_7_DAY:int = 425;
		protected var buyContainer:Sprite;
		protected var descriptionContainer:Sprite;
		protected var aquiredContainer:Sprite;
		protected var waitingContainer:Sprite;
		protected var description:String;
		protected var confirmText:String = "";
		protected var preview:String;
		protected var aquiredText:Text;
		protected var expiryTime:Number;
		protected var aquired:Boolean = false;
		protected var bundles:Array;
		public function CreditDayItem(param1:Game, param2:Sprite)
		{
			buyContainer = new Sprite();
			descriptionContainer = new Sprite();
			aquiredContainer = new Sprite();
			waitingContainer = new Sprite();
			aquiredText = new Text();
			bundles = [];
			super(param1, param2);
		}

		override protected function load():void
		{
			super.load();
			infoContainer.x = 40;
			addBuyOptions();
			addDescription();
			addAquired();
			addWaiting();
			updateAquiredText();
			updateContainers();
		}

		protected function addBuyOptions():void
		{
			var _loc4_:int = 0;
			var _loc2_:Object = null;
			var _loc1_:CreditLabel = null;
			var _loc5_:int = 0;
			var _loc3_:int = 0;
			_loc4_ = 0;
			while (_loc4_ < bundles.length)
			{
				_loc2_ = bundles[_loc4_];
				_loc3_ = 40 * _loc4_;
				createButton(_loc2_, _loc3_);
				_loc1_ = new CreditLabel();
				_loc1_.x = 170;
				_loc1_.y = _loc3_;
				_loc1_.text = _loc2_.cost;
				_loc1_.alignRight();
				buyContainer.addChild(_loc1_);
				_loc4_++;
			}
			buyContainer.x = 30;
			infoContainer.addChild(buyContainer);
		}

		private function createButton(param1:Object, param2:int):void
		{
			var button:Button;
			var obj:Object = param1;
			var y:int = param2;
			var text:String = "Buy " + obj.days + " day";
			if (obj.days > 1)
			{
				text += "s";
			}
			button = new Button(function():void
				{
					var buyConfirm:CreditBuyBox = new CreditBuyBox(g, obj.cost, confirmText);
					buyConfirm.addEventListener("accept", function():void
						{
							onBuy(obj.days);
							buyConfirm.removeEventListeners();
							button.enabled = true;
						});
					buyConfirm.addEventListener("close", function():void
						{
							buyConfirm.removeEventListeners();
							button.enabled = true;
						});
					g.addChildToOverlay(buyConfirm);
				}, text, "positive");
			button.x = 20;
			button.y = y;
			button.width = 100;
			button.alignWithText();
			buyContainer.addChild(button);
		}

		protected function addDescription():void
		{
			var _loc3_:int = 0;
			var _loc2_:Image = null;
			var _loc4_:Quad = null;
			var _loc1_:Text = new Text();
			_loc1_.text = description;
			_loc1_.color = 11184810;
			_loc1_.width = 300;
			_loc1_.height = 300;
			_loc1_.wordWrap = true;
			descriptionContainer.addChild(_loc1_);
			if (preview != null)
			{
				_loc3_ = 4;
				_loc2_ = new Image(textureManager.getTextureGUIByTextureName(preview));
				_loc2_.x = 4;
				_loc2_.y = _loc1_.height + 10;
				_loc4_ = new Quad(_loc2_.width + 6, _loc2_.height + 6, 11184810);
				_loc4_.x = _loc2_.x - 3;
				_loc4_.y = _loc2_.y - 3;
				descriptionContainer.addChild(_loc4_);
				descriptionContainer.addChild(_loc2_);
			}
			descriptionContainer.y = 130;
			infoContainer.addChild(descriptionContainer);
		}

		protected function addWaiting():void
		{
			var _loc1_:Text = new Text();
			_loc1_.text = "waiting...";
			_loc1_.x = 60;
			_loc1_.y = 40;
			waitingContainer.addChild(_loc1_);
			waitingContainer.visible = false;
			infoContainer.addChild(waitingContainer);
		}

		protected function addAquired():void
		{
			aquiredText.x = 0;
			aquiredText.y = 40;
			aquiredText.color = Style.COLOR_HIGHLIGHT;
			aquiredText.wordWrap = true;
			aquiredText.width = 300;
			aquiredContainer.addChild(aquiredText);
			aquiredContainer.visible = false;
			infoContainer.addChild(aquiredContainer);
		}

		protected function updateContainers():void
		{
			buyContainer.visible = !aquired;
			aquiredContainer.visible = aquired;
			waitingContainer.visible = false;
		}

		protected function onBuy(param1:int):void
		{
			buyContainer.visible = false;
			waitingContainer.visible = true;
		}

		protected function updateAquiredText():void
		{
			var _loc2_:Number = NaN;
			var _loc1_:Date = null;
			if (aquired)
			{
				_loc2_ = expiryTime - g.time;
				_loc1_ = new Date();
				_loc1_.milliseconds += _loc2_;
				aquiredText.text = "Aquired!\nActive until: " + _loc1_.toLocaleDateString();
			}
		}

		protected function showFailed(param1:String):void
		{
			g.showErrorDialog(param1);
			buyContainer.visible = true;
			waitingContainer.visible = false;
		}
	}
}

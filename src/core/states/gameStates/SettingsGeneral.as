package core.states.gameStates
{
	import core.hud.components.Button;
	import core.hud.components.Text;
	import core.scene.Game;
	import core.scene.SceneBase;
	import data.Settings;
	import feathers.controls.Check;
	import feathers.controls.PickerList;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Slider;
	import feathers.controls.renderers.DefaultListItemRenderer;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import generics.Localize;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.TouchEvent;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	public class SettingsGeneral extends Sprite
	{
		private static const START_HEIGHT:int = 20;
		
		private static const START_WIDTH:int = 50;
		
		private var g:Game;
		
		private var currentHeight:Number = 20;
		
		private var currentWidth:Number = 50;
		
		private var settings:Settings;
		
		private var musicSlider:Slider;
		
		private var effectSlider:Slider;
		
		private var showHud:Check;
		
		private var showEffects:Check;
		
		private var showLatency:Check;
		
		private var showBackground:Check;
		
		private var mouseAim:Check;
		
		private var keyboardAim:Check;
		
		private var rotationSlider:Slider;
		
		private var rotationSpeedText:Text;
		
		private var iWantAllTimedMissions:Check;
		
		private var fireWithHotkeys:Check;
		
		private var scrollArea:ScrollContainer;
		
		public function SettingsGeneral(param1:Game)
		{
			super();
			this.g = param1;
			this.settings = SceneBase.settings;
			scrollArea = new ScrollContainer();
			scrollArea.y = 50;
			scrollArea.x = 10;
			scrollArea.width = 700;
			scrollArea.height = 500;
			initComponents();
			addChild(scrollArea);
		}
		
		private function initComponents():void
		{
			var rotationValue:Number;
			if (g.me.isTranslator || g.me.isDeveloper)
			{
				addLanguage();
			}
			musicSlider = new Slider();
			addSlider(musicSlider, settings.musicVolume, Localize.t("Music Volume"));
			musicSlider.addEventListener("change", function(param1:Event):void
			{
				settings.musicVolume = musicSlider.value;
			});
			effectSlider = new Slider();
			addSlider(effectSlider, settings.effectVolume, Localize.t("Effect Volume"));
			effectSlider.addEventListener("change", function(param1:Event):void
			{
				settings.effectVolume = effectSlider.value;
			});
			showHud = new Check();
			showHud.isSelected = settings.showHud;
			showHud.addEventListener("change", function(param1:Event):void
			{
				settings.showHud = showHud.isSelected;
			});
			addCheckbox(showHud, Localize.t("Show Hud"));
			showLatency = new Check();
			showLatency.isSelected = settings.showLatency;
			showLatency.addEventListener("change", function(param1:Event):void
			{
				settings.showLatency = showLatency.isSelected;
			});
			addCheckbox(showLatency, Localize.t("Show Latency/fps"));
			showEffects = new Check();
			showEffects.isSelected = settings.showEffects;
			showEffects.addEventListener("change", function(param1:Event):void
			{
				settings.showEffects = showEffects.isSelected;
				g.toggleHighGraphics(settings.showEffects);
			});
			addCheckbox(showEffects, Localize.t("High graphic settings <font color='#a1a1a1'>(uncheck for better performance)</font>"));
			showBackground = new Check();
			showBackground.isSelected = settings.showBackground;
			showBackground.addEventListener("change", function(param1:Event):void
			{
				settings.showBackground = showBackground.isSelected;
				g.parallaxManager.refresh();
			});
			addCheckbox(showBackground, Localize.t("Show Background <font color='#a1a1a1'>(uncheck for better performance)</font>"));
			mouseAim = new Check();
			mouseAim.isSelected = !settings.mouseAim;
			mouseAim.addEventListener("change", function(param1:Event):void
			{
				settings.mouseAim = !mouseAim.isSelected;
			});
			addCheckbox(mouseAim, Localize.t("Disable Mouse Aim"));
			fireWithHotkeys = new Check();
			fireWithHotkeys.isSelected = settings.fireWithHotkeys;
			fireWithHotkeys.addEventListener("change", function(param1:Event):void
			{
				settings.fireWithHotkeys = fireWithHotkeys.isSelected;
			});
			addCheckbox(fireWithHotkeys, Localize.t("Fire with Weapon Hotkeys"));
			rotationSlider = new Slider();
			rotationValue = (settings.rotationSpeed - 0.75) * 2;
			addSlider(rotationSlider, rotationValue, Localize.t("Player Rotation Speed"));
			rotationSlider.addEventListener("change", function(param1:Event):void
			{
				settings.rotationSpeed = 0.75 + 0.5 * rotationSlider.value;
				rotationSpeedText.text = settings.rotationSpeed.toFixed(2);
			});
			rotationSpeedText = new Text(rotationSlider.x + 120, rotationSlider.y + 10);
			rotationSpeedText.text = settings.rotationSpeed.toFixed(2);
			scrollArea.addChild(rotationSpeedText);
			iWantAllTimedMissions = new Check();
			iWantAllTimedMissions.isSelected = settings.iWantAllTimedMissions;
			iWantAllTimedMissions.addEventListener("change", function(param1:Event):void
			{
				settings.iWantAllTimedMissions = iWantAllTimedMissions.isSelected;
			});
			addCheckbox(iWantAllTimedMissions, Localize.t("I want all timed missions."));
		}
		
		private function addLanguage():void
		{
			var selectedIndex:int;
			var i:int;
			var item:Object;
			var b:Button;
			var list:PickerList = new PickerList();
			var textureManager:ITextureManager = TextureLocator.getService();
			list.dataProvider = new ListCollection([{"text": "en"}, {"text": "de"}, {"text": "fr"}, {"text": "es"}, {"text": "ru"}, {"text": "uk"}, {"text": "nl"}, {"text": "sv"}, {"text": "pe"}]);
			selectedIndex = 0;
			i = 0;
			while (i < list.dataProvider.length)
			{
				item = list.dataProvider.getItemAt(i);
				if (item.text == Localize.language)
				{
					selectedIndex = i;
				}
				i++;
			}
			list.selectedIndex = selectedIndex;
			list.listProperties.itemRendererFactory = function():IListItemRenderer
			{
				var _loc1_:DefaultListItemRenderer = new DefaultListItemRenderer();
				_loc1_.labelField = "text";
				_loc1_.height = 25;
				return _loc1_;
			};
			list.prompt = "Select language";
			list.typicalItem = {"text": "Select an Item"};
			list.labelField = "text";
			list.addEventListener("change", function(param1:Event):void
			{
				var _loc3_:PickerList = PickerList(param1.currentTarget);
				var _loc2_:Object = _loc3_.selectedItem;
				Localize.language = _loc2_.text;
			});
			list.x = currentWidth;
			list.y = currentHeight;
			scrollArea.addChild(list);
			b = new Button(function(param1:TouchEvent):void
			{
				Localize.activateLanguageSelection = true;
				g.reloadTexts();
			}, "Reload texts");
			b.x = currentWidth + 150;
			b.y = currentHeight + 3;
			scrollArea.addChild(b);
			currentHeight += 60;
		}
		
		private function addQualitySlider():void
		{
			var labelText:Text;
			var descText:Text;
			var slider:Slider = new Slider();
			slider.minimum = 0;
			slider.maximum = 5;
			slider.step = 1;
			slider.value = settings.quality;
			slider.direction = "horizontal";
			slider.useHandCursor = true;
			labelText = new Text();
			labelText.htmlText = Localize.t("Quality");
			labelText.y = currentHeight;
			labelText.x = currentWidth;
			slider.x = labelText.x + labelText.width + 10;
			slider.y = currentHeight;
			descText = new Text();
			switch (slider.value)
			{
			case 0: 
				RymdenRunt.s.nativeStage.quality = "low";
				RymdenRunt.s.antiAliasing = 0;
				descText.htmlText = Localize.t("Low");
				break;
			case 1: 
				RymdenRunt.s.nativeStage.quality = "medium";
				RymdenRunt.s.antiAliasing = 2;
				descText.htmlText = Localize.t("Medium");
				break;
			case 2: 
				RymdenRunt.s.nativeStage.quality = "high";
				RymdenRunt.s.antiAliasing = 4;
				descText.htmlText = Localize.t("High, AAx4");
				break;
			case 3: 
				RymdenRunt.s.nativeStage.quality = "8x8";
				RymdenRunt.s.antiAliasing = 8;
				descText.htmlText = Localize.t("High, AAx8");
				break;
			case 4: 
				RymdenRunt.s.nativeStage.quality = "16x16";
				RymdenRunt.s.antiAliasing = 16;
				descText.htmlText = Localize.t("High, AAx16");
				break;
			case 5: 
				RymdenRunt.s.nativeStage.quality = "best";
				RymdenRunt.s.antiAliasing = 16;
				descText.htmlText = Localize.t("Best, AAx16");
			}
			descText.y = currentHeight;
			descText.x = slider.x + slider.width;
			if (slider.x < 200)
			{
				slider.x = 200;
			}
			scrollArea.addChild(labelText);
			scrollArea.addChild(slider);
			scrollArea.addChild(descText);
			currentHeight += 40;
			slider.addEventListener("change", function(param1:Event):void
			{
				settings.quality = slider.value;
				switch (slider.value)
				{
				case 0: 
					RymdenRunt.s.nativeStage.quality = "low";
					RymdenRunt.s.antiAliasing = 0;
					descText.htmlText = Localize.t("Low");
					break;
				case 1: 
					RymdenRunt.s.nativeStage.quality = "medium";
					RymdenRunt.s.antiAliasing = 2;
					descText.htmlText = Localize.t("Medium");
					break;
				case 2: 
					RymdenRunt.s.nativeStage.quality = "high";
					RymdenRunt.s.antiAliasing = 4;
					descText.htmlText = Localize.t("High, AAx4");
					break;
				case 3: 
					RymdenRunt.s.nativeStage.quality = "8x8";
					RymdenRunt.s.antiAliasing = 8;
					descText.htmlText = Localize.t("High, AAx8");
					break;
				case 4: 
					RymdenRunt.s.nativeStage.quality = "16x16";
					RymdenRunt.s.antiAliasing = 16;
					descText.htmlText = Localize.t("High, AAx16");
					break;
				case 5: 
					RymdenRunt.s.nativeStage.quality = "best";
					RymdenRunt.s.antiAliasing = 16;
					descText.htmlText = Localize.t("Best, AAx16");
				}
			});
		}
		
		private function addCheckbox(param1:Check, param2:String):void
		{
			var _loc3_:Text = new Text();
			_loc3_.htmlText = param2;
			_loc3_.y = currentHeight;
			_loc3_.x = currentWidth + 30;
			param1.x = currentWidth;
			param1.y = currentHeight - 4;
			param1.useHandCursor = true;
			scrollArea.addChild(_loc3_);
			scrollArea.addChild(param1);
			currentHeight += 40;
		}
		
		private function addSlider(param1:Slider, param2:Number, param3:String):void
		{
			param1.minimum = 0;
			param1.maximum = 1;
			param1.step = 0.1;
			param1.value = param2;
			param1.direction = "horizontal";
			param1.useHandCursor = true;
			var _loc4_:Text = new Text();
			_loc4_.htmlText = param3;
			_loc4_.y = currentHeight;
			_loc4_.x = currentWidth;
			param1.x = _loc4_.x + _loc4_.width + 10;
			param1.y = currentHeight;
			if (param1.x < 200)
			{
				param1.x = 200;
			}
			scrollArea.addChild(_loc4_);
			scrollArea.addChild(param1);
			currentHeight += 40;
		}
	}
}

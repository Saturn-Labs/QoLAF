package qolaf.ui.modifiers {
	import core.scene.Game;
	import core.unit.Unit;
	import feathers.controls.LayoutGroup;
	import feathers.layout.TiledRowsLayout;
	import feathers.layout.VerticalLayout;
	import qolaf.data.ModifierInfo;
	import qolaf.events.ModifierAddedEvent;
	import qolaf.events.ModifierRemovedEvent;
	import qolaf.modifiers.IModifierTarget;
	import qolaf.ui.TargetInfoElement;
	import qolaf.ui.elements.ModifierTooltip;
	import qolaf.utils.ColorUtils;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.filters.ColorMatrixFilter;
	import starling.textures.Texture;
	import qolaf.modifiers.Modifier;
	import qolaf.utils.ObjectPool;
	import qolaf.utils.StringUtils;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.text.TextField;
	import starling.text.TextFieldAutoSize;
	import starling.text.TextFormat;
	import textures.ITextureManager;
	import textures.TextureLocator;
	import textures.TextureManager;
	
	/**
	 * @author rydev
	 */
	// I really need to rewrite this code lmao...
	public class TargetModifierDisplay extends LayoutGroup implements IModifierDisplay {
		private var _target:IModifierTarget;
		private var _currentModifiers:Vector.<Modifier> = new Vector.<Modifier>();
		private var _selectedModifier:Modifier;
		private var _textureManager:ITextureManager;
		
		private var _imagePool:ObjectPool;
		private var _modifierDefaultIcon:Texture;
		private var _modifierTooltip:ModifierTooltip;
		
		public function TargetModifierDisplay() {	
			setupLayout();
			createPools();
			createElements();
			
			_textureManager = TextureLocator.getService();
			_modifierDefaultIcon = _textureManager.getTextureByTextureName("ti_astro_lance_levels", "texture_gui1_test.png");
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function setupLayout():void {
			var rowsLayout:TiledRowsLayout = new TiledRowsLayout();
			rowsLayout.horizontalAlign = TiledRowsLayout.HORIZONTAL_ALIGN_LEFT;
			rowsLayout.verticalAlign = TiledRowsLayout.VERTICAL_ALIGN_TOP;
			rowsLayout.paddingTop = 2;
			rowsLayout.requestedColumnCount = 13;
			rowsLayout.gap = 2;
			layout = rowsLayout;
		}
		
		private function createPools():void {
			_imagePool = new ObjectPool(function():Image {
				var image:Image = new Image(_modifierDefaultIcon);
				image.width = image.height = 21.2;
				return image;
			}, function(obj:Object):void {
				if (!(obj is Image))
					return;
				var image:Image = obj as Image;
				image.texture = _modifierDefaultIcon;
				image.removeEventListeners(TouchEvent.TOUCH);
				image.removeEventListeners(Event.ADDED_TO_STAGE);
			});
		}
		
		private function createElements():void {
			_modifierTooltip = new ModifierTooltip();
			Game.instance.stage.addChild(_modifierTooltip);
			_modifierTooltip.visible = false;
		}
		
		private function onEnterFrame(e:EnterFrameEvent):void {
			if (_selectedModifier != null && _selectedModifier.hasEnded)
				_selectedModifier = null;
			
			_modifierTooltip.visible = _selectedModifier != null;
			if (_selectedModifier == null)
				return;
				
			var debuffInfo:Object = ModifierInfo.getModifier(_selectedModifier.id);
			var name:String = debuffInfo != null ? debuffInfo.name : "Unknown Debuff";
			var description:String = debuffInfo != null ? debuffInfo["enemy_description"] : "Unknown Debuff Description";
			
			_modifierTooltip.title.text = StringUtils.substitute(ModifierTooltip.MODIFIER_NAME_TEMPLATE, {
				"[name]": name,
				"[stacks]": _selectedModifier.stacks
			});
			
			_modifierTooltip.time.text = StringUtils.formatTime(_selectedModifier.currentDuration);
			_modifierTooltip.time.format.color = _selectedModifier.currentDuration <= 10000 ? 0xff0000 : 0xffffff;
			
			_modifierTooltip.descriptionText = StringUtils.substitute(description, {
				"[enemy]": _target is Unit ? TargetInfoElement.getUnitTrueName(_target as Unit) : "Unknown"
			});
		}
		
		private function recycleChildrenImages():void {
			for (var i:int = 0; i < numChildren; i++) {
				var child:DisplayObject = getChildAt(i);
				if (child is Image) {
					_imagePool.recycleOne(child);
				}
			}
		}
		
		public function getTooltip():ModifierTooltip {
			return _modifierTooltip;
		}
		
		public function clearModifiers():void {
			_selectedModifier = null;
			_currentModifiers.splice(0, _currentModifiers.length);
			recycleChildrenImages();
			removeChildren();
		}
		
		public function addModifier(modifier:Modifier):void {
			_currentModifiers.push(modifier);
			var image:Image = _imagePool.getOne() as Image;
			var modifierInfo:Object = ModifierInfo.getModifier(modifier.id);
			if (modifierInfo != null) {
				image.texture = _textureManager.getTextureByTextureName(modifierInfo.icon, "texture_gui1_test.png");
			}
			
			image.addEventListener(TouchEvent.TOUCH, function(e:TouchEvent):void {
				var touch:Touch = e.getTouch(e.currentTarget as Image);
				if (touch != null && touch.phase == TouchPhase.BEGAN && _selectedModifier == null) {
					_selectedModifier = modifier;
				}
				else if (touch != null && touch.phase == TouchPhase.ENDED && _selectedModifier == modifier) {
					_selectedModifier = null;
				}
			});
			addChild(image);
		}
		
		public function removeModifier(modifier:Modifier):void {
			var idx:int = _currentModifiers.indexOf(modifier);
			if (idx == -1)
				return;
			var image:Image = getChildAt(idx) as Image;
			if (_selectedModifier == modifier)
				_selectedModifier = null;
			_imagePool.recycleOne(image);
			removeChildAt(idx);
			_currentModifiers.removeAt(idx);
		}
		
		private function onTargetModifierAdded(e:ModifierAddedEvent):void {
			addModifier(e.modifier);
		}
		
		private function onTargetModifierRemoved(e:ModifierRemovedEvent):void {
			removeModifier(e.modifier);
		}
		
		public function setTarget(target:IModifierTarget):void {
			if (_target == target)
				return;
				
			if (_target != null) {
				_target.removeEventListener(ModifierAddedEvent.EVENT, onTargetModifierAdded);
				_target.removeEventListener(ModifierRemovedEvent.EVENT, onTargetModifierRemoved);
			}
			
			_target = target;
			clearModifiers();
			if (target != null) {
				for each (var modifier:Modifier in target.getModifiers()) {
					addModifier(modifier);
				}
				
				target.addEventListener(ModifierAddedEvent.EVENT, onTargetModifierAdded);
				target.addEventListener(ModifierRemovedEvent.EVENT, onTargetModifierRemoved);
			}
		}
	}
}
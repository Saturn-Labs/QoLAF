package qolaf.ui.modifiers {
	import core.scene.Game;
	import core.unit.Unit;
	import core.weapon.Debuff;
	import feathers.controls.LayoutGroup;
	import feathers.layout.TiledRowsLayout;
	import feathers.layout.VerticalLayout;
	import qolaf.data.ModifierInfo;
	import qolaf.events.ModifierAddedEvent;
	import qolaf.events.ModifierRemovedEvent;
	import qolaf.modifiers.IModifierTarget;
	import qolaf.ui.TargetInfoElement;
	import qolaf.ui.elements.ModifierIcon;
	import qolaf.ui.elements.ModifierTooltip;
	import qolaf.utils.ColorUtils;
	import qolaf.utils.Query;
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
	// Wonderful code of my life....
	public class TargetModifierDisplay extends LayoutGroup implements IModifierDisplay {
		private var _game:Game;
		private var _target:IModifierTarget;
		private var _textureManager:ITextureManager;
		
		private var _iconPool:ObjectPool;
		private var _modifierDefaultIcon:Texture;
		
		private var _modifierTooltip:ModifierTooltip;
		
		public function TargetModifierDisplay() {
			this._game = Game.instance;
			this._modifierTooltip = _game.hud.getModifierTooltip();
			this._textureManager = TextureLocator.getService();
			this._modifierDefaultIcon = ModifierInfo.getIcon(_textureManager, "ti_astro_lance_levels");
			setupLayout();
			createPools();
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
			_iconPool = new ObjectPool(function():ModifierIcon {
				var icon:ModifierIcon = new ModifierIcon(null);
				return icon;
			}, function(obj:Object):void {
				if (!(obj is ModifierIcon))
					return;
				var icon:ModifierIcon = obj as ModifierIcon;
				icon.modifier = null;
				icon.removeEventListeners(TouchEvent.TOUCH);
				icon.removeEventListeners(Event.ADDED_TO_STAGE);
			});
		}
		
		private function recycleIcons():void {
			for (var i:int = 0; i < numChildren; i++) {
				var child:DisplayObject = getChildAt(i);
				if (child is ModifierIcon) {
					_iconPool.recycleOne(child);
				}
			}
		}
		
		public function clearModifiers():void {
			_modifierTooltip.setModifier(null, null);
			recycleIcons();
			removeChildren();
		}
		
		public function addModifier(modifier:Modifier):void {
			var icon:ModifierIcon = _iconPool.getOne() as ModifierIcon;
			icon.modifier = modifier;
			
			icon.addEventListener(TouchEvent.TOUCH, function(e:TouchEvent):void {
				var touch:Touch = e.getTouch(e.currentTarget as Image);
				if (touch != null && touch.phase == TouchPhase.BEGAN && _modifierTooltip.modifier == null) {
					_modifierTooltip.setModifier(_target, modifier);
				}
				else if (touch != null && touch.phase == TouchPhase.ENDED && _modifierTooltip.modifier == modifier) {
					_modifierTooltip.setModifier(null, null);
				}
			});
			addChild(icon);
		}
		
		public function removeModifier(modifier:Modifier):void {
			if (modifier == null)
				return;
				
			var icon:ModifierIcon = Query.findChild(this, function(child:DisplayObject):Boolean {
				if (child is ModifierIcon) {
					var modifierIcon:ModifierIcon = child as ModifierIcon;
					return modifierIcon.modifier != null && modifierIcon.modifier.id == modifier.id;
				}
				return false;
			}) as ModifierIcon;
			
			if (icon == null)
				return;
			
			if (_modifierTooltip.modifier != null && _modifierTooltip.modifier.id == modifier.id) {
				_modifierTooltip.setModifier(null, null);
			}
			
			_iconPool.recycleOne(icon);
			removeChild(icon);
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
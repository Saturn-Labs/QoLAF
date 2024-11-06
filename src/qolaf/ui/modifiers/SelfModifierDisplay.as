package qolaf.ui.modifiers {
	import core.scene.Game;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.TiledColumnsLayout;
	import feathers.layout.VerticalAlign;
	import qolaf.data.ModifierInfo;
	import qolaf.events.ModifierAddedEvent;
	import qolaf.events.ModifierRemovedEvent;
	import qolaf.ui.elements.ModifierIcon;
	import qolaf.ui.elements.ModifierTooltip;
	import feathers.controls.LayoutGroup;
	import qolaf.modifiers.IModifierTarget;
	import qolaf.modifiers.Modifier;
	import qolaf.ui.layout.InvertedTiledColumnsLayout;
	import qolaf.utils.ObjectPool;
	import qolaf.utils.Query;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.textures.Texture;
	import starling.utils.Align;
	import textures.ITextureManager;
	import textures.TextureLocator;
	
	/**
	 * @author rydev
	 */
	public class SelfModifierDisplay extends LayoutGroup implements IModifierDisplay {
		private var _game:Game;
		private var _target:IModifierTarget;
		private var _textureManager:ITextureManager;
		
		private var _iconPool:ObjectPool;
		private var _modifierDefaultIcon:Texture;
		
		private var _modifierTooltip:ModifierTooltip;
		
		private var _lastHeight:Number = 0;
		private var _tiledCollumnsLayout:InvertedTiledColumnsLayout;
		private var _iconSize:Number = 21.2;
		
		public function SelfModifierDisplay(iconSize:Number = 30) {
			this._game = Game.instance;
			this._iconSize = iconSize;
			this._modifierTooltip = _game.hud.getModifierTooltip();
			this._textureManager = TextureLocator.getService();
			this._modifierDefaultIcon = ModifierInfo.getIcon(_textureManager, "ti_astro_lance_levels");
			setupLayout();
			backgroundSkin = new Quad(1, 1, 0xff0000);
			createPools();
			updateMaxRows();
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		private function setupLayout():void {
			_tiledCollumnsLayout = new InvertedTiledColumnsLayout();
			_tiledCollumnsLayout.padding = 4;
			_tiledCollumnsLayout.gap = 4;
			_tiledCollumnsLayout.invertHorizontal = true;
			_tiledCollumnsLayout.invertHorizontalAlign = true;
			layout = _tiledCollumnsLayout;
		}
		
		private function createPools():void {
			_iconPool = new ObjectPool(function():ModifierIcon {
				var icon:ModifierIcon = new ModifierIcon(null, _iconSize, _iconSize);
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
		
		private function onEnterFrame(e:Event):void {
			if (_lastHeight != maxHeight) {
				updateMaxRows();
			}
			_lastHeight = maxHeight;
		}
		
		public function clearModifiers():void {
			_modifierTooltip.setModifier(null, null);
			recycleIcons();
			removeChildren();
			updateMaxRows();
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
			updateMaxRows();
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
			updateMaxRows();
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
		
		override public function get maxHeight():Number {
			return (_game.stage.stageHeight - 154) - y;
		}
		
		public function updateMaxRows():void {
			_tiledCollumnsLayout.requestedRowCount = Math.max(3, Math.floor(
				(maxHeight - _tiledCollumnsLayout.padding * 2 + _tiledCollumnsLayout.gap) / 
				(_iconSize + _tiledCollumnsLayout.gap)));
			readjustLayout();
		}
	}
}
package qolaf.ui.modifiers {
	import qolaf.modifiers.IModifierTarget;
	import qolaf.modifiers.Modifier;
	import qolaf.ui.elements.ModifierTooltip;
	import starling.display.DisplayObject;
	
	/**
	 * @author rydev
	 */
	public interface IModifierDisplay {
		function clearModifiers():void;
		function addModifier(modifier:Modifier):void;
		function removeModifier(modifier:Modifier):void;
		function setTarget(target:IModifierTarget):void;
	}
}
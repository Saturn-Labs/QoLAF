package qolaf.modifiers {
	import flash.events.IEventDispatcher;
	import qolaf.modifiers.Modifier;
	import qolaf.target.ITarget;
	
	/**
	 * @author rydev
	 */
	public interface IModifierTarget extends ITarget {
		function getModifiers():Vector.<Modifier>;
		function addModifier(modifier:Modifier):void;
		function removeModifier(modifier:Modifier):Boolean;
		function removeModifierById(modifierId:int):Boolean;
	}
}
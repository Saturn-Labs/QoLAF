package feathers.core
{
   public interface IFocusContainer extends IFocusDisplayObject
   {
      function get isChildFocusEnabled() : Boolean;
      
      function set isChildFocusEnabled(param1:Boolean) : void;
   }
}


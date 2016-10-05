package fl.managers {
    import fl.controls.*;
    import flash.display.*;

    public interface IFocusManager {

        function getFocus():InteractiveObject;
        function deactivate():void;
        function set defaultButton(_arg1:Button):void;
        function set showFocusIndicator(_arg1:Boolean):void;
        function get defaultButtonEnabled():Boolean;
        function findFocusManagerComponent(_arg1:InteractiveObject):InteractiveObject;
        function get nextTabIndex():int;
        function get defaultButton():Button;
        function get showFocusIndicator():Boolean;
        function hideFocus():void;
        function activate():void;
        function showFocus():void;
        function set defaultButtonEnabled(_arg1:Boolean):void;
        function setFocus(_arg1:InteractiveObject):void;
        function getNextFocusManagerComponent(_arg1:Boolean=false):InteractiveObject;

    }
}//package fl.managers 

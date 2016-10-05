package zoomify.viewer {
    import flash.display.*;
    import flash.text.*;

    public class SplashScreen extends MovieClip {

        public var tfMessage:TextField;

        public function SplashScreen():void{
            tfMessage = new TextField();
            tfMessage.x = 0;
            tfMessage.y = 120;
            tfMessage.width = 240;
            tfMessage.height = 120;
            tfMessage.multiline = true;
            tfMessage.selectable = false;
            tfMessage.wordWrap = true;
            tfMessage.defaultTextFormat = new TextFormat("_sans", 12, 0, null, null, null, null, null, TextFormatAlign.CENTER);
            addChild(tfMessage);
        }
        public function getMessage():String{
            return (tfMessage.text);
        }
        public function setMessage(_arg1:String):void{
            tfMessage.text = _arg1;
        }

    }
}//package zoomify.viewer 

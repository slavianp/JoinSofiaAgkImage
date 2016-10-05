package zoomify.utils {
    import flash.display.*;
    import zoomify.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.utils.*;
    import flash.text.*;

    public class Tooltip {

        protected static var fadeIn:Boolean;
        protected static var delayTimer:Timer;
        protected static var tooltip:Sprite;
        protected static var viewerRef:IZoomifyViewer;

        public function Tooltip():void{
        }
        public static function delayTimerHandler(_arg1:TimerEvent):void{
            tooltip.visible = true;
        }
        public static function hide():void{
            if (tooltip != null){
                if (delayTimer){
                    if (delayTimer.running){
                        delayTimer.stop();
                    };
                };
                tooltip.visible = false;
            };
        }
        public static function initialize(_arg1:IZoomifyViewer):void{
            if (tooltip == null){
                tooltip = new Sprite();
                tooltip.visible = false;
                Sprite(_arg1).stage.addChild(tooltip);
                viewerRef = _arg1;
            };
        }
        public static function show(_arg1:String, _arg2:Boolean=false):void{
            var _local3:TextField;
            var _local4:TextFormat;
            var _local5:DisplayObject;
            var _local6:Stage;
            var _local7:Number;
            var _local8:Number;
            var _local9:Point;
            if (tooltip != null){
                while (tooltip.numChildren > 0) {
                    tooltip.removeChildAt(0);
                };
                _local3 = new TextField();
                _local4 = new TextFormat("_sans", 12, 0, false, false, false, null, null, TextFormatAlign.LEFT);
                _local3.autoSize = TextFieldAutoSize.LEFT;
                _local3.multiline = true;
                _local3.selectable = false;
                _local3.condenseWhite = true;
                _local3.defaultTextFormat = _local4;
                _local3.htmlText = _arg1;
                _local3.x = 4;
                _local3.y = 1;
                _local5 = viewerRef.getTooltipBackground();
                if (_local5){
                    _local5.width = (_local3.width + 8);
                    _local5.height = (_local3.height + 2);
                    tooltip.addChild(_local5);
                };
                tooltip.addChild(_local3);
                _local6 = tooltip.stage;
                _local7 = tooltip.width;
                _local8 = tooltip.height;
                _local9 = new Point((_local6.mouseX + 18), (_local6.mouseY + 18));
                if ((_local9.y + _local8) > _local6.stageHeight){
                    _local9.y = ((_local6.mouseY - _local8) - 3);
                    _local9.x = (_local6.mouseX + 3);
                };
                if ((_local9.x + _local7) > _local6.stageWidth){
                    _local9.x = ((_local6.mouseX - _local7) - 3);
                };
                tooltip.x = _local9.x;
                tooltip.y = _local9.y;
                if (_arg2){
                    hide();
                    delayTimer = new Timer(1000, 1);
                    delayTimer.addEventListener("timer", delayTimerHandler, false, 0, true);
                    delayTimer.start();
                } else {
                    tooltip.visible = true;
                };
            };
        }

    }
}//package zoomify.utils 

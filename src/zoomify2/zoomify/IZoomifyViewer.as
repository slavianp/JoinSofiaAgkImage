package zoomify {
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import zoomify.viewer.*;

    public interface IZoomifyViewer extends IEventDispatcher {

        function zoomToInitialView():void;
        function setSize(_arg1:Number, _arg2:Number):void;
        function get fadeInSpeed():Number;
        function set minZoom(_arg1:Number):void;
        function get name():String;
        function set fadeInSpeed(_arg1:Number):void;
        function getMinimumZoomDecimal():Number;
        function zoomOut():void;
        function get initialX():String;
        function get initialY():String;
        function get viewZoom():Number;
        function setImageOffset(_arg1:Point):void;
        function zoomToViewStop():void;
        function panUp():void;
        function get imagePath():String;
        function get splashScreenVisibility():Boolean;
        function set viewX(_arg1:Number):void;
        function setView(_arg1:Number, _arg2:Number, _arg3:Number):void;
        function set viewY(_arg1:Number):void;
        function set initialY(_arg1:String):void;
        function get imageWidth():Number;
        function get height():Number;
        function set initialX(_arg1:String):void;
        function set viewZoom(_arg1:Number):void;
        function set panConstrain(_arg1:Boolean):void;
        function set maxZoom(_arg1:Number):void;
        function get initialZoom():Number;
        function getImageOffset():Point;
        function get zoomSpeed():Number;
        function setZoomDecimal(_arg1:Number, _arg2:Boolean=true):void;
        function setExternalZoomingFlag(_arg1:Boolean):void;
        function panStop():void;
        function set imagePath(_arg1:String):void;
        function invalidate(_arg1:String="all", _arg2:Boolean=true):void;
        function getMaximumZoomDecimal():Number;
        function panLeft():void;
        function get minZoom():Number;
        function get width():Number;
        function setInitialView():void;
        function getZoomDecimal():Number;
        function set splashScreenVisibility(_arg1:Boolean):void;
        function zoomToFitDisplay():void;
        function set eventsEnabled(_arg1:Boolean):void;
        function showMessage(_arg1:String=null):void;
        function get viewX():Number;
        function get viewY():Number;
        function get maxZoom():Number;
        function zoomIn():void;
        function get panConstrain():Boolean;
        function get initialized():Boolean;
        function panDown():void;
        function get imageHeight():Number;
        function hideMessage():void;
        function set zoomSpeed(_arg1:Number):void;
        function getTooltipBackground():DisplayObject;
        function set initialZoom(_arg1:Number):void;
        function get eventsEnabled():Boolean;
        function setExternalPanningFlag(_arg1:Boolean):void;
        function zoomToView(_arg1:Number, _arg2:Number, _arg3:Number, _arg4:Number, _arg5:Number):void;
        function get tileCache():TileCache;
        function zoomStop():void;
        function set clickZoom(_arg1:Boolean):void;
        function get clickZoom():Boolean;
        function panRight():void;

    }
}//package zoomify 

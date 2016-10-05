package zoomify.utils {
    import flash.events.*;
    import flash.utils.*;
    import flash.net.*;

    public class Parameters extends EventDispatcher {

        protected var dict:Dictionary;
        protected var xmlParamsMap:Dictionary;

        public function Parameters(_arg1:Object=null):void{
            dict = new Dictionary();
            initializeXMLParamsMap();
            initialize(_arg1);
        }
        protected function securityErrorHandler(_arg1:SecurityErrorEvent):void{
            dispatchEvent(_arg1.clone());
        }
        public function load(_arg1:String):void{
            var _local2:URLRequest = new URLRequest(_arg1);
            var _local3:URLLoader = new URLLoader();
            _local3.addEventListener(Event.COMPLETE, completeHandler);
            _local3.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            _local3.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            _local3.load(_local2);
        }
        protected function ioErrorHandler(_arg1:IOErrorEvent):void{
            dispatchEvent(_arg1.clone());
        }
        public function getParameterAsNumber(_arg1:String, _arg2:Number=0):Number{
            var _local3:Number = parseFloat((dict[_arg1] as String));
            return (((isNaN(_local3)) ? _arg2 : _local3));
        }
        protected function initializeXMLParamsMap():void{
            xmlParamsMap = new Dictionary();
            xmlParamsMap["IMAGEPATH"] = "zoomifyImagePath";
            xmlParamsMap["INITIALX"] = "zoomifyInitialX";
            xmlParamsMap["INITIALY"] = "zoomifyInitialY";
            xmlParamsMap["INITIALZOOM"] = "zoomifyInitialZoom";
            xmlParamsMap["MINZOOM"] = "zoomifyMinZoom";
            xmlParamsMap["MAXZOOM"] = "zoomifyMaxZoom";
            xmlParamsMap["SPLASHSCREEN"] = "zoomifySplashScreen";
            xmlParamsMap["CLICKZOOM"] = "zoomifyClickZoom";
            xmlParamsMap["ZOOMSPEED"] = "zoomifyZoomSpeed";
            xmlParamsMap["FADEINSPEED"] = "zoomifyFadeInSpeed";
            xmlParamsMap["PANCONSTRAIN"] = "zoomifyPanConstrain";
            xmlParamsMap["TOOLBARVISIBLE"] = "zoomifyToolbarVisible";
            xmlParamsMap["TOOLBARSPACING"] = "zoomifyToolbarSpacing";
            xmlParamsMap["TOOLBARSKINXMLPATH"] = "zoomifyToolbarSkinXMLPath";
            xmlParamsMap["TOOLBARTOOLTIPS"] = "zoomifyToolbarTooltips";
            xmlParamsMap["SLIDERVISIBLE"] = "zoomifySliderVisible";
            xmlParamsMap["TOOLBARLOGO"] = "zoomifyToolbarLogo";
            xmlParamsMap["NAVIGATORVISIBLE"] = "zoomifyNavigatorVisible";
            xmlParamsMap["NAVIGATORWIDTH"] = "zoomifyNavigatorWidth";
            xmlParamsMap["NAVIGATORHEIGHT"] = "zoomifyNavigatorHeight";
            xmlParamsMap["NAVIGATORFIT"] = "zoomifyNavigatorFit";
            xmlParamsMap["NAVIGATORX"] = "zoomifyNavigatorX";
            xmlParamsMap["NAVIGATORY"] = "zoomifyNavigatorY";
            xmlParamsMap["EVENTS"] = "zoomifyEvents";
        }
        public function initialize(_arg1:Object):void{
            var _local2:String;
            if (_arg1 != null){
                for (_local2 in _arg1) {
                    if (_arg1[_local2] != ""){
                        dict[_local2] = _arg1[_local2];
                    };
                };
            };
        }
        protected function completeHandler(_arg1:Event):void{
            var _local3:XML;
            var _local4:XMLList;
            var _local5:uint;
            var _local6:XML;
            var _local7:String;
            var _local8:String;
            var _local9:String;
            var _local2:URLLoader = (_arg1.target as URLLoader);
            if (_local2){
                _local3 = new XML(_local2.data);
                _local4 = _local3.@*;
                _local5 = 0;
                while (_local5 < _local4.length()) {
                    _local6 = (_local4[_local5] as XML);
                    _local7 = _local6.name().localName.toUpperCase();
                    _local8 = _local6.toString();
                    _local9 = (xmlParamsMap[_local7] as String);
                    if (((_local9) && (!((_local9 == ""))))){
                        dict[_local9] = _local8;
                    };
                    _local5++;
                };
            };
            dispatchEvent(_arg1.clone());
        }
        public function getParameterAsString(_arg1:String, _arg2:String=""):String{
            var _local3:String = (dict[_arg1] as String);
            return (((((!((_local3 == null))) && (!((_local3 == ""))))) ? _local3 : _arg2));
        }

    }
}//package zoomify.utils 

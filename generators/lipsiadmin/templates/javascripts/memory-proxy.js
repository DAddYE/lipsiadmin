/**
  * Ext.ux.data.PagingMemoryProxy.js
  *
  * A proxy for local / in-browser data structures
  * supports paging / sorting / filtering / etc
  *
  * @file	Ext.ux.PagingMemoryProxy.js
  * @author	Ing. Ido Sebastiaan Bas van Oostveen
  * 
  * @changelog:
  * @version    1.5
  * @date       26-March-2008
  *             - rewritten search by Davide D'Agostino
  * @version    1.4
  * @date       21-Februari-2008
  *             - added filter prototype method for array's
  * @version    1.3
  * @date       30-September-2007
  *             - added customFilter config option
  * @version	1.2 
  * @date	29-September-2007
  *		- fixed several sorting bugs
  * @version	1.1
  * @date	30-August-2007
  * @version	1.0
  * @date	22-August-2007
  *
  */

Ext.namespace("Ext.ux");
Ext.namespace("Ext.ux.data");

/* Fixes for IE/Opera old javascript versions */
if(!Array.prototype.map){
    Array.prototype.map = function(fun){
	var len = this.length;
	if(typeof fun != "function"){
	    throw new TypeError();
	}
	var res = new Array(len);
	var thisp = arguments[1];
		for(var i = 0; i < len; i++){
		    if(i in this){
					res[i] = fun.call(thisp, this[i], i, this);
		    }
		}
    return res;
  };
}

if (!Array.prototype.filter){
  Array.prototype.filter = function(fun /*, thisp*/){
    var len = this.length;
    if (typeof fun != "function")
      throw new TypeError();

    var res = new Array();
    var thisp = arguments[1];
    for (var i = 0; i < len; i++){
      if (i in this){
        var val = this[i]; // in case fun mutates this
        if (fun.call(thisp, val, i, this))
          res.push(val);
      }
    }
    return res;
  };
}

/* Paging Memory Proxy, allows to use paging grid with in memory dataset */
Ext.ux.data.PagingMemoryProxy = function(data, config) {
	Ext.ux.data.PagingMemoryProxy.superclass.constructor.call(this);
	this.data = data || [];
	Ext.apply(this, config);
};

Ext.extend(Ext.ux.data.PagingMemoryProxy, Ext.data.MemoryProxy, {
	customFilter: null,
	reload : function(data){ this.data = data; },
	load : function(params, reader, callback, scope, arg) {
		params = params || {};
		var result;
		try {
			result = reader.readRecords(this.data);
		} catch(e) {
			this.fireEvent("loadexception", this, arg, null, e);
			callback.call(scope, null, arg, false);
			return;
		}
		// filtering
		if (this.customFilter!=null) {
			result.records = result.records.filter(this.customFilter);
			result.totalRecords = result.records.length;
		} else if (params.filter!==undefined && params.items!==undefined) {
			result.records = result.records.filter(function(r){
				var items = params.items;
				valueArr = params.filter.split(/\ +/);
				for (var j=0; j<valueArr.length; j++) {
					re = new RegExp(Ext.escapeRe(valueArr[j]), "i");
					keep = false;
					for (var i=0; i < items.length; i++) {
						if (re.test(r.data[items[i].name])==true){
							keep=true;
						}
					}
					if (!keep){
						return false;
					}
				}
				return true;
			});
			result.totalRecords = result.records.length;
		}
		// sorting
		if (params.sort!==undefined) {
		    // use integer as params.sort to specify column, since arrays are not named
		    // params.sort=0; would also match a array without columns
		    var dir = String(params.dir).toUpperCase() == "DESC" ? -1 : 1;
        var fn = function(r1, r2){
			    return r1==r2 ? 0 : r1<r2 ? -1 : 1;
        };
		    var st = reader.recordType.getField(params.sort).sortType;
		    result.records.sort(function(a, b) {
				var v = 0;
				if (typeof(a)=="object"){
				    v = fn(st(a.data[params.sort]), st(b.data[params.sort])) * dir;
				} else {
				    v = fn(a, b) * dir;
				}
				if (v==0) {
				    v = (a.index < b.index ? -1 : 1);
				}
				return v;
		    });
		}
		// paging (use undefined cause start can also be 0 (thus false))
		if (params.start!==undefined && params.limit!==undefined) {
			result.records = result.records.slice(params.start, params.start+params.limit);
		}
		
		callback.call(scope, result, arg, true);
	}
});
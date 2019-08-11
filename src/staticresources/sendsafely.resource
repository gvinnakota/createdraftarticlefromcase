window.SendSafelyDropzone = (function (apiKey, $domElement, $urlElement) {
  this.url = 'https://app.sendsafely.com';

  this.INJECTED_TEXT = '\n\nThis ticket includes a secure attachment. Use this link to access the attached files:\n {url}';
  this.CREATING_ENTROPY_MSG = 'We need some random data to get started. Please move your mouse quickly around the screen: {percent}%';
  this.FILE_ROW_STYLE = 'background: #F8F8F8; border-radius: 3px; clear: left; float: left; font-size: 11px; margin: 10px 0px 0px 0px; padding: 3px 10px; position: relative; overflow: hidden; width: 100%;';
  this.FILE_ROW_CLASSES = '';
  this.PROGRESS_STYLE = 'background: rgba(0,0,0,0.04); bottom: 0; left: 0; position: absolute; right: 0; top: 0; -webkit-transition-property: width; -moz-transition-property: width; transition-property: width; -webkit-transition-duration: 0.5s; -moz-transition-duration: 0.5s; transition-duration: 0.5s; -webkit-transition-timing-function: linear; -moz-transition-timing-function: linear; transition-timing-function: linear; width: 3%;';
  this.PROGRESS_CLASSES = '';
  this.UPLOAD_PERCENTAGE_STYLE = 'color: #888; float: right; font-weight: bold; margin-left: 15px; position: relative; z-index:1';
  this.UPLOAD_PERCENTAGE_CLASS = '';
  this.FAILURE_CLASS = 'alert-danger';
  this.DROPZONE_TEXT = 'Drag files here or click to add file';
  this.FILES_NOT_DONE_WARNING = 'Please wait until all files are done uploading';
  this.STILL_WORKING_MESSAGE = 'Still working...wait a few seconds and try again.';
  this.FILE_COMPLETED_TEXT = 'Completed';
  this.FAILURE_STYLE = 'padding: 7px; margin-bottom: 20px; margin-top: 10px; text-align: center; border: 1px solid transparent; border-radius: 4px; color: #a94442; background-color: #f2dede; border-color: #ebccd1; -webkit-box-sizing: border-box; -moz-box-sizing: border-box; box-sizing: border-box;';
  this.INFO_CLASS = 'alert-info';
  this.INFO_STYLE = 'padding: 7px; margin-bottom: 20px; margin-top: 10px; text-align: center; border: 1px solid transparent; border-radius: 4px; color: #8a6d3b; background-color: #fcf8e3; border-color: #faebcc; -webkit-box-sizing: border-box; -moz-box-sizing: border-box; box-sizing: border-box;';
  this.DROPZONE_STYLE = 'border: 2px dashed #F3F3F3; border-color: rgba(0,0,0,0.05); font-size: 14px; text-align: center; padding-top: 10px; padding-bottom: 10px;';
  this.BOXING_CSS = '-webkit-box-sizing: border-box; -moz-box-sizing: border-box; box-sizing: border-box; -webkit-box-sizing: border-box; -moz-box-sizing: border-box; box-sizing: border-box;';
  this.WIDTH = '100%';
  this.HEIGHT = '100%';
  this.BACKGROUND_COLOR = '#ffffff';
  this.DROP_TEXT_COLOR = '#666666';
  this.UPLOAD_API = undefined;
  this.logoPath = 'https://app-static.sendsafely.com/images/external/logo.png';
  this.ongoingUploadsCallback = function(){};

  this.apiKey = apiKey;
  this.keyCodesUploaded = false;
  this.disableAutoSubmit = false;
  this.hasUploadedFiles = false;
  this.packageIsFinalized = false;
  this.nbrOfFilesAttached = 0;

  this.noKeycodeUrl = undefined;
  this.unconfirmedSender = undefined;
  this.dropZone = undefined;
    
 
  this.iframeStartSize = 130;

  this.dropZone = undefined;

  var myself = this;
    
  /*
  Private functions below this point.
   */
  this.initialize = function () {
    
    if(myself.isBrowserSupported()) {
      jQuery(window).off("message");
      // Clear out all css on the div
      $domElement.attr("style","");
      $domElement.removeClass(); 
      
      myself.createIFrameElement($domElement);

      myself.iframe.onload = function() {
        var message = {};
        message['command'] = 'api-key';
        message['key'] = myself.apiKey;
        if(myself.UPLOAD_API !== undefined) {
          message['uploadAPI'] = myself.UPLOAD_API;
        }

        send(message);
        
        //send api-key message until we know HostedDropzone received it
        var hostedDzTimer = setInterval(function(){
        	send(message);
        },500);

        //Listener to stop HostedDropzone timer once api-key message confirmed received
        myself.addFrameListener('api-key-received',function(event) {
        	clearInterval(hostedDzTimer);
        });
        
        myself.addFrameListener('file-attached', function(data) {
          myself.nbrOfFilesAttached++;
          myself.handleAttachedFile(data.name, data.fileId, data.packageCode);
        });
        myself.addFrameListener('file-progress', function(data) {
          myself.handleFileProgress(data.fileId, data.progress);
        });
        myself.addFrameListener('file-uploaded', function(data) {
          myself.packageCode = data.packageCode;
          myself.fileUploaded(data.fileId);
        });
        myself.addFrameListener('file-removed', function(data) {
          myself.fileRemoved(data.fileId);
        });
        myself.addFrameListener('error', function(data) {
          myself.failure(data.message);
        });
        myself.addFrameListener('entropy', function(data) {
          myself.updateEntropy(data.entropy);
        });
        myself.addFrameListener('entropy-ready', function() {
          jQuery('#sendsafely-error-message').hide();
        });
        myself.addFrameListener('file-remove-error', function() {
          myself.fileRemovedFailed(data.fileId);
        });
        myself.addFrameListener('keycodes-uploaded', function() {
          myself.keyCodesUploaded = true;
        });
        myself.addFrameListener('ongoing-uploads', function(data) {
          myself.ongoingUploadsCallback(data.ongoingUploads);
        });
        myself.addFrameListener('set-unconfirmed-sender', function(data) {
            myself.setUnconfirmedSender(data.unconfirmedSender);
        });
      };

      if(myself.disableAutoSubmit !== true) {
        jQuery('form').submit(function(event) {
          if(myself.nbrOfFilesAttached > 0 && !myself.packageIsFinalized) {
            var $form = jQuery(this);

            if(myself.unconfirmedSender != null){
              this.setUnconfirmedSender(myself.unconfirmedSender);
            }
            myself.finalizePackage(function (message) {
              var text = myself.INJECTED_TEXT;
              text = text.replace('{url}', message);

              $urlElement.val(function(_, val){return val + text;});

              $form.submit();
            });

            event.preventDefault();
          }
        });
      }
    } else {
      myself.browserIsNotSupported();
    }
  };

  this.isBrowserSupported = function() {
    return true;
      //return Blob != undefined &&
    //    Worker != undefined &&
    //    XMLHttpRequest != undefined;
  };

  this.browserIsNotSupported = function () {
	alert("NOT SUPPORTED");
  };

  this.updateEntropy = function(entropy) {
    jQuery('#sendsafely-error-message').removeClass(myself.FAILURE_CLASS + ' ' + myself.INFO_CLASS);
    jQuery('#sendsafely-error-message').addClass(myself.INFO_CLASS);
    jQuery('#sendsafely-error-message').attr('style', myself.INFO_STYLE);
    jQuery('#sendsafely-error-message').show();

    var message = myself.CREATING_ENTROPY_MSG;
    message = message.replace('{percent}', Math.round(entropy));
    jQuery('#sendsafely-error-message').text(message);
  };

  this.failure = function (message) {
    jQuery('#sendsafely-error-message').removeClass(myself.FAILURE_CLASS + ' ' + myself.INFO_CLASS);
    jQuery('#sendsafely-error-message').addClass(myself.FAILURE_CLASS);
    jQuery('#sendsafely-error-message').attr('style', myself.FAILURE_STYLE);
    jQuery('#sendsafely-error-message').text(message);
    jQuery('#sendsafely-error-message').show();

    setTimeout(function() {jQuery('#sendsafely-error-message').hide()}, 5000);
  };

  this.fileUploaded = function(fileId) {
    var elem = jQuery('li[data-upload-item="' + fileId + '"]');
    elem.attr('aria-busy', 'false');
    elem.find('a[data-upload-link]').attr("href", "https://www.sendsafely.com");
    elem.find('p[data-upload-path]').append('https://www.sendsafely.com');

    elem.find('div[data-upload-progress]').css('width', '100%');

    jQuery('li[data-upload-id="' + fileId + '"] span[data-upload-remove]').show();
    jQuery('li[data-upload-id="' + fileId + '"] span[data-upload-percentage]').text(myself.FILE_COMPLETED_TEXT);
  };

  this.handleAttachedFile = function(filename, fileId, packageCode) {
    myself.packageCode = packageCode;

    var output = '';
    output +=
        '<li class="sendsafely-upload-item ' +  myself.FILE_ROW_CLASSES + '" data-upload-id="' + htmlEncode(fileId) + '" style="' + myself.FILE_ROW_STYLE + ' ' + myself.BOXING_CSS + '">' +
            '<img src="' + myself.createPadlockImage() + '" width="14px" height="14px" style=""/>' +
            '<div style="vertical-align: top; display: inline; margin-top:2px;">&nbsp;' + htmlEncode(filename) + '</div>' +
            '<span data-upload-remove="" style="color: #888; cursor: pointer; float: right; font-weight: bold; margin-left: 15px; position: relative; z-index:1; display:none">x</span>' +
            '<span data-upload-percentage="" class="' + myself.UPLOAD_PERCENTAGE_CLASS + '" style="' + myself.UPLOAD_PERCENTAGE_STYLE + '"></span>' +
            '<div class="' + myself.PROGRESS_CLASSES + '" data-upload-progress="" style="' +  myself.PROGRESS_STYLE + '"></div>' +
            '</li>';

    jQuery('#sendsafely-attached-file-list').append(output);

    // Set up remove event handler
    jQuery('li[data-upload-id="' + fileId + '"] span[data-upload-remove]').click(function (){
      myself.removeFile(jQuery(this));
    });
  };

  this.removeFile = function($element) {
    var $parent = $element.parent();
    var fileId = $parent.data('upload-id');

    send({command: 'remove-file', fileId: fileId});

    jQuery('li[data-upload-id="' + fileId + '"] span[data-upload-remove]').unbind('click');
  };

  this.fileRemoved = function(fileId) {
    myself.nbrOfFilesAttached--;
    jQuery('li[data-upload-id="' + fileId + '"] span[data-upload-remove]').parent().remove();
  };

  this.fileRemovedFailed = function(fileId) {
    jQuery('li[data-upload-id="' + fileId + '"] span[data-upload-remove]').click(function (){
      myself.removeFile(jQuery(this));
    });
  };

  this.handleFileProgress = function (fileId, progress) {
    var elem = jQuery('li[data-upload-id="' + fileId + '"] div[data-upload-progress]');
    elem.css('width', progress + '%');

    if(parseFloat(progress) <= 100) {
      if(jQuery('li[data-upload-id="' + fileId + '"] span[data-upload-percentage]').text() !== myself.FILE_COMPLETED_TEXT) {
        jQuery('li[data-upload-id="' + fileId + '"] span[data-upload-percentage]').text(parseFloat(progress).toFixed(2) + '%');
      }
    }
  };

  this.addMessage = function(message) {
    send({command: "set-message", message: message});
  };
  
  this.setUnconfirmedSender = function(unconfirmedSender){
	  send({command: "set-unconfirmed-sender", unconfirmedSender: unconfirmedSender});
  }

  this.createStaticURL = function (url) {
    if(url.indexOf("https://static-") < 0 && url.indexOf("https://") >= 0) {
      url = url.replace('https://', 'https://static-');
    }
    else if (url.indexOf("http://static-") < 0 && url.indexOf("http://") >= 0) {
      url = url.replace('http://', 'http://static-');
    }
    return url;
  };

  this.finalizePackage = function(callback, errorCallback) {
    myself.hasOngoingUploads(function(hasOngoingUploads) {
      //Do basic sanity checks here to make sure we are ready to finalize/submit
      if(!hasOngoingUploads && myself.packageCode !== undefined && myself.keyCodesUploaded) {
        myself.addFrameListener('package-link', function(data) {
          myself.packageIsFinalized = true;
          myself.noKeycodeUrl = data.noKeycodeUrl;
          callback(data.url);
        });
        myself.addFrameListener('error', errorCallback);
        sendCommand('finalize');
      } else {
        //Not ready, show a please wait message
        if (hasOngoingUploads || myself.packageCode === undefined)
        {
          myself.failure(myself.FILES_NOT_DONE_WARNING);
        }
        else
        {
          myself.failure(myself.STILL_WORKING_MESSAGE);
        }
        if(errorCallback !== undefined) {errorCallback();}
      }
    });
  };

  this.hasOngoingUploads = function(callback) {

    myself.ongoingUploadsCallback = callback;

    sendCommand('has-ongoing-uploads');
  };

  this.addFrameListener = function(command, callback) {
    function listener(event){
      if(event.originalEvent.data.command == command) {
        callback(event.originalEvent.data);
        event.stopPropagation();
      }
    }

	jQuery(window).on("message", listener);
  }

  this.createIFrameElement = function (elem) {
    var ouput = ''
        + '<div style="position: relative; width: ' + myself.WIDTH + '; height: ' + myself.HEIGHT + '">'
        +   '<div id="sendsafely-iframe" style="position: absolute; top: 0; left: 0; width:100%; height:100%; z-index: 10;"></div>'
        +   '<div id="sendsafely-dropzone" style="position: absolute; top: 0; left: 0; width: 100%; height:100%; overflow: hidden; position: relative; z-index: 1;">'
        +     myself.renderDropzone()
        +   '</div>'
        + '</div>';
    var iframe = document.createElement("IFRAME");
    iframe.setAttribute("src", myself.createStaticURL(myself.url) + "/html/dropzone.html");
    iframe.style.width = '100%';
    iframe.style.height = '100%';
    iframe.seamless = "seamless";
    iframe.scrolling="no";
    
    //Fix for unclickable widget when widget reinitialized without page reload
    if (elem.html().length === 0) {
    	elem.html(ouput);
    } else {
          jQuery('#sendsafely-attached-file-list').remove();
          jQuery('#sendsafely-error-message').remove();
    }

    jQuery('#sendsafely-iframe').html(iframe);


    jQuery('#sendsafely-iframe').css('filter', 'alpha(opacity=0)');
    jQuery('#sendsafely-iframe').css('opacity', '0.01');

    var fileList =
        '<div>' +
        //'<ul id="sendsafely-attached-file-list" style="margin: 0; overflow: hidden; padding: 0; ' + myself.BOXING_CSS + '"></ul>' +
        '<ul id="sendsafely-attached-file-list" style="margin: 0; overflow: hidden; padding: 0;"></ul>' +
        '</div>';

    var errorBox = '<div id="sendsafely-error-message" class="alert alert-dismissible" role="alert" style="display:none; margin-top:5px; ' + myself.BOXING_CSS + '"></div>';

    elem.append(fileList + errorBox);
    
    myself.iframe = iframe;
  };

  this.addDocumentEventHandlers = function() {
    document.getElementById('sendsafely-iframe').addEventListener('dragover', myself.handleDragOverDropzone, false);
    document.getElementById('sendsafely-iframe').addEventListener('dragleave',myself.handleDragLeaveDropzone, false);
  };

  this.handleDragOverDropzone = function(evt) {
    evt.dataTransfer.dropEffect = 'copy';
    jQuery("#sendsafely-dropzone").css("border","2px dashed black");
  };

  this.handleDragLeaveDropzone = function(evt) {
    jQuery('#sendsafely-dropzone').css("border","2px dashed #F3F3F3");
  };

  this.renderDropzone = function() {
    var html = '<div style="width: 100%; ' + myself.DROPZONE_STYLE + '; color: ' + myself.DROP_TEXT_COLOR + '; background-color: ' + myself.BACKGROUND_COLOR + ' ' + myself.BOXING_CSS + '" align="center">'
        +       '<div style="margin: 0 auto; float:center; min-width: 45%; max-width: 95%; display: inline-block; white-space:nowrap;">'
        +         '<div style="float:left;"><img src="' + myself.logoPath + '" width="23px" height="23px" style="margin-right:5px; margin-top: -2px;"></img></div><div>' + myself.DROPZONE_TEXT + '</div>'
        +       '</span>'
        +      '</div>';
    return html;
  };

  this.sendFeedback = function(message) {
    var eventHandler = new EventHandler(myself);
    var request = new AnonymousRequest(eventHandler, myself.url, myself.apiKey);
    new SendFeedback(eventHandler, request).execute(message, undefined, true);
  };

  this.createPadlockImage = function () {
    return myself.logoPath;
  };

  function sendCommand(command) {
    send({command: command});
  }

  function send(data) {
    var win = myself.iframe.contentWindow;
    win.postMessage(data, myself.createStaticURL(myself.url));
  }

  function htmlEncode(stringToEncode) {
    return jQuery('<div/>').text(stringToEncode).html();
  }
})

window.AnonymousRequest = (function(eventHandler, url, apiKey, requestAPI) {

  var myself = this;

  this.apiPrefix = '/drop-zone/v2.0';
  this.url = url;
  this.apiKey = apiKey;
  this.eventHandler = eventHandler;

  this.sendRequest = function (requestType, messageData, a_sync){
    if(typeof a_sync === "undefined"){
      a_sync = true;
    }

    return $.ajax({
      url: myself.url + myself.apiPrefix + requestType.url,
      type: requestType.HTTPMethod,
      timeout: 25000,
      data: messageData == null ? null : JSON.stringify(messageData),
      contentType: requestType.mimetype,
      headers: { 	'ss-api-key': myself.apiKey, 'ss-request-api' : requestAPI},
      crossDomain: true,
      async: a_sync,
      retryCount: 2
    })
  };

  this.getHTTPObjForFileUpload = function (uri, messageData, boundary, a_sync) {

    var xhr = new XMLHttpRequest();
    var url = myself.url + myself.apiPrefix + uri;

    xhr.open('POST', url, a_sync);

    xhr.setRequestHeader('Content-Type', 'multipart/form-data; boundary=' + boundary);
    xhr.setRequestHeader('ss-api-key', myself.apiKey);
    xhr.setRequestHeader('ss-request-api', requestAPI);

    return xhr;
  };

  this.extend = function (a, b){
    for(var key in b)
      if(b.hasOwnProperty(key))
        a[key] = b[key];
    return a;
  }
})

window.EventHandler = (function(parent) {

  var myself = this;

  this.eventlist = {};
  this.ERROR_EVENT = 'sendsafely.error';

  // Inject into the parent
  if(parent !== undefined) {
    parent.on = function(eventStr, callback) {
      return myself.bind(eventStr, callback);
    };

    parent.unbind = function(eventStr, id) {
      myself.unbind(eventStr, id);
    };

    parent.isBound = function(eventStr) {
      myself.isBound(eventStr);
    };
  }

  this.bind = function (event, callback) {
    var list = myself.getList(event);
    list.push(callback);

    myself.eventlist[event] = list;

    return list.length-1;
  };

  this.unbind = function (event, id) {
    var list = myself.getList(event);

    if(id === undefined) { // Thrash the whole list
      list = undefined;
    }
    else if(list.length > id) {
      list[id] = undefined;
    }

    myself.eventlist[event] = list;
  };

  this.isBound = function(event) {
    return myself.eventlist[event] !== undefined && myself.eventlist[event].length > 0;
  };

  this.raise = function(event, data) {
    if(myself.eventlist[event] !== undefined) {
      var length = myself.eventlist[event].length;
      var i = 0;
      while(i<length && myself.eventlist[event] !== undefined) {
        var callback = myself.eventlist[event][i];
        if(callback != undefined) {
          callback(data);
        }
        i++;
      }
    }
  };

  this.raiseError = function(code, message, customError) {
    if(customError !== undefined && myself.eventlist[customError] !== undefined) {
      myself.eventlist[customError].forEach(function(callback) {
        if(callback != undefined) {
          callback(code, message);
        }
      });
    } else {
      if(myself.eventlist[myself.ERROR_EVENT] !== undefined) {
        //var data = {'error': code, 'message': message};
        myself.eventlist[myself.ERROR_EVENT].forEach(function(callback) {
          if(callback !== undefined) {
            callback(code, message);
          }
        });
      }
    }
  };

  this.getList = function(event) {
    if(myself.eventlist[event] === undefined) {
      myself.eventlist[event] = [];
    }

    return myself.eventlist[event];
  };

})

window.ResponseParser = (function(eventHandler) {

  this.eventHandler = eventHandler;
  this.defaultEventError = 'sendsafely.error';

  var myself = this;

  /**
   * Function used to deal with Errors, and callbacks for AJAX Requests.
   * Progress callback cannot be done when async is false.
   *
   * @param {promise} ajax AJAX Promise
   * @param {function} error_callback Function is called when there is an error with the function or when there is an error in the responce.
   * @param {function} success_callback Function is called when data is receved from the server with no errors.
   * @param {function} progress_callback Function is called when the data is being uploaded.
   */
  this.processAjaxData = function(ajax, success_callback, errorEvent) {
    ajax.fail(function (xhr, status, error) {
      // Wrap the error to a format we recognize.
      var data = {response: this.AJAX_ERROR, message: error.message};
      myself.raiseError(errorEvent, {'error': this.NETWORK_ERROR, 'data': data});
    }).done(function (data) {
          if(typeof data == "string"){
            data = JSON.parse(data);
          }
          if(data.response == "SUCCESS") {
            if(success_callback != undefined) {
              success_callback(data);
            }
          }
          else if(data.response == "TIMEOUT") {
            myself.eventHandler.raise('session.timeout', data.message);
          }
          else {
            myself.raiseError(errorEvent, {'error': data.response, 'data': data});
          }
        })
  };

  /**
   * Function used to deal with Errors, and callbacks for AJAX Requests.
   * Progress callback cannot be done when async is false.
   *
   * @param {promise} ajax AJAX Promise
   * @param {function} error_callback Function is called when there is an error with the function or when there is an error in the responce.
   * @param {function} success_callback Function is called when data is receved from the server with no errors.
   * @param {function} progress_callback Function is called when the data is being uploaded.
   */


  this.processAjaxDataRaw = function(ajax, callback, errorEvent) {
      ajax.fail(function (xhr, status, error) {
          var errorMessage;
          if(typeof error == "string"){
              errorMessage = error;
          } else {
              errorMessage = error.message;
          }
          // Wrap the error to a format we recognize.
          var data = {response: "AJAX_ERROR", message: "A server error has occurred (" + errorMessage + "). Please try again."};
          callback(data);
      }).done(function (data) {
          if(typeof data == "string"){
              data = JSON.parse(data);
          }
          callback(data);
      })
  };

  this.raiseError = function(customEvent, data) {
    myself.eventHandler.raiseError(data.error, data.data.message, customEvent);

  };

})

window.SendFeedback = (function(eventHandler, request) {
  this.request = request;
  this.endpoint = { "url": "/feedback/", "HTTPMethod" : "PUT", "mimetype": "application/json"};
  this.eventHandler = eventHandler;
  this.customErrorEvent = 'send.feedback.failed';
  this.responseParser = new ResponseParser(eventHandler);

  var myself = this;

  this.execute = function (message, stacktrace, async, callback) {
    var endpoint = myself.request.extend({}, myself.endpoint);

    var requestData = buildRequestData(message, stacktrace);
    var response = myself.request.sendRequest(endpoint, requestData, async);
    myself.responseParser.processAjaxData(response, function(res) {
      if(callback) {
        callback();
      }
    });
  };

  function buildRequestData(message, stacktrace) {
    var postData = {};
    postData.message = message;
    postData.stacktrace = stacktrace;
    return postData;
  }
})


class VideoSnifferScript {
  static const String snifferScript = r'''
    (function(){
    if (window.__videoSnifferInstalled) return;
    window.__videoSnifferInstalled = true;

    
    const videoRegex = /\.(m3u8|mp4|webm|mpd|flv|avi|mov|wmv|mkv)(\?.*)?$/i;
    
    function report(url) {
      try{

        if (!url) return;

        url = String(url);

        if (videoRegex.test(url) && !url.includes('.ts')){
          VideoSniffer.postMessage(url);
        }
      } catch (e) {}
    }

    const originalFetch = window.fetch;

    window.fetch = function(...args){

      try{ 
        const request = args[0];

        if (typeof request === 'string'){
          report(request);
        } else if (request && request.url){
          report(request.url);
        }
      } catch (e){}
      return originalFetch.apply(this, args);
    };
    
    const originalOpen = XMLHttpRequest.prototype.open;

    XMLHttpRequest.prototype.open = function(method, url){
      try { report(url.toString()); } catch (e) {}
      return originalOpen.apply(this, arguments)
    };

    function scanNode(node) {
      if (!node) return;

      try{

        if (node.tagName === 'VIDEO' || node.tagName === 'SOURCE'){
          if (node.src){ 
            report(node.src);
          }      
        }

        if (typeof node.querySelectorAll == 'function'){
          node.querySelectorAll('video, source').forEach(function (el) {
            if (el && el.src){
              report(el.src);
            }        
          });
        }
      }catch (e) {}
    }


    if (document.documentElement) {
      scanNode(document.documentElement);
    }

    
    if (document.documentElement){
      const observer = new MutationObserver(function (mutations) {
        mutations.forEach(function (mutation) {
          mutation.addedNodes.forEach(function (node) {
            if (node && node.nodeType === Node.ELEMENT_NODE){
              scanNode (node);
            } 
          });
        });
      });
    
      observer.observe(document.documentElement, { 
        childList: true, subtree: true
      });
    }
  })();
  ''';
}

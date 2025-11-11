// (function (d, t) {
//     var BASE_URL = "http://comms.entrata.localhost:81";
//     var g = d.createElement(t), s = d.getElementsByTagName(t)[0];
//     g.src = BASE_URL + "/packs/js/sdk.js";
//     g.defer = true;
//     g.async = true;
//     s.parentNode.insertBefore(g, s);
//     g.onload = function () {
//         window.chatwootSDK.run({
//               // Identify user securely
//             // identifier: "user@example.com",
//             // hmac: "generated_token",
//             // timestamp: 1718073394,
//             // Website token
//             // websiteToken: 'TSu7UeCoVwejcbqsuU9HaiKb',
//             websiteToken: 'TPhdscNbzPsGN78Yfu2Z1AVK',
//             baseUrl: BASE_URL
//         })
//     }
// })(document, "script");

// Configure Chatwoot widget
Object.assign(window, { 
    // baseURL: "http://comms.entrata.localhost:81",
    websiteToken: "TPhdscNbzPsGN78Yfu2Z1AVK", 
    siteConfig: { 
        comms: { 
            position: "right" 
        },
        clt_i: 2138,
        property_id: 125478
    } 
});

// Load Chatwoot initialization script
(function() {
    var script = document.createElement('script');
    script.src = "http://localhost:7003/scripts/client.min.js";
    script.async = true;
    document.head.appendChild(script);
})();

// Adjust widget positioning on page load
window.onload = function() {
    var chatWidgetHolderElements = document.querySelectorAll('.woot-widget-holder');
    var chatWidgetBubbleElements = document.querySelectorAll('.woot-widget-bubble');
    var chatWidgetElements = [...chatWidgetHolderElements, ...chatWidgetBubbleElements];
    
    chatWidgetElements.forEach(function(el) {
        el.style.marginRight = '60px';
    });
};
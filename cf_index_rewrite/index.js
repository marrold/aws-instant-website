'use strict';
exports.handler = (event, context, callback) => {
    
    // Extract the request from the CloudFront event that is sent to Lambda@Edge 
    var request = event.Records[0].cf.request;

    // Extract the URI from the request
    var olduri = request.uri;

    // Regular expression to match a filename with a 3 or 4 character extension
    var filePattern = /\/[^\/]+\.[a-zA-Z0-9]{3,4}$/;

    // Check if the URI does not end with a filename format 'something.format'
    if (!filePattern.test(olduri)) {
        // If not, replace it with a default index
        olduri = olduri.replace(/\/?$/, '/index.html');
    }

    // Log the URI as received by CloudFront and the new URI to be used to fetch from origin
    console.log("Old URI: " + olduri);
    console.log("New URI: " + olduri); // Note: The variable should be 'olduri' since it's updated now
    
    // Replace the received URI with the updated URI
    request.uri = olduri;
    
    // Return to CloudFront
    return callback(null, request);
};

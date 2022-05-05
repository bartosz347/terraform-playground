function handler(event) {
    var request = event.request;
    var headers = request.headers;

    var city = 'unknown';
    var countryCode = 'unknown';
    var countryName = 'unknown';

    if (headers["cloudfront-viewer-city"] && headers["cloudfront-viewer-city"].value) {
        city = headers["cloudfront-viewer-city"].value;
    }

    if (headers["cloudfront-viewer-country"] && headers["cloudfront-viewer-country"].value) {
        countryCode = headers["cloudfront-viewer-country"].value;
    }

    if (headers["cloudfront-viewer-country-name"] && headers["cloudfront-viewer-country-name"].value) {
        countryName = headers["cloudfront-viewer-country-name"].value;
    }

    return {
        statusCode: 200,
        statusDescription: 'OK',
        "headers": {
            "data-city": {
                "value": city,
            },
            "data-country-name": {
                "value": countryName,
            },
            "data-country-code": {
                "value": countryCode,
            },
        },
    };
}

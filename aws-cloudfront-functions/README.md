## Info

AWS CloudFront provides approximate user location data in headers
https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-cloudfront-headers.html

It is not possible to directly access these headers from a frontend application.

This demo presents how CloudFront function can be used to create an endpoint for fetching location data from headers supplied by CloudFront.

## Terraform output

- `demo_page` - path to a website that presents how data can be fetched
- `demo_script` – path to a script that can be used to fetch location

variable route53_zone {
  description = "The domain associated with your route53 zone."
  type        = string
  default     = ""
}

variable "fqdn" {
  description = "Fully Qualified Domain Name for the website"
  type        = string
}

variable "subdomains" {
  description = "List of subdomains for the website"
  type        = list
  default     = []
}

locals {
  reassembled_subdomains = flatten([
    for subdomain in var.subdomains : [
      format("%s.%s", subdomain, var.fqdn)
    ]
  ])
}

variable "index_html" {
  description = "The file to display as the root document, e.g index.html"
  type        = string
  default     = "index.html"
}

variable "error_html" {
  description = "File to display when there is an error."
  type        = string
  default     = "error.html"
}

variable "viewer_protocol_policy" {
  description = "Sets viewer policy protocol."
  type        = string
  default     = "redirect-to-https"

}

variable "file_path" {
  description = "Path to directory of files you wish to upload to S3. See README."
  type        = string
  default     = null
}

variable "price_class" {
  description = "Price class for the Cloudfront distribution"
  type        = string
  default     = "PriceClass_100"
}

variable "mime_type_overrides" {
  description = "Map of mime-type overrides"
  type        = map
  default     = {}
}
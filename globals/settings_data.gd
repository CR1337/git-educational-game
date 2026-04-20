extends Node

enum ApiProtocol { HTTP, HTTPS }
enum Language { DE, EN }

var api_protocol: ApiProtocol = ApiProtocol.HTTP
var api_address: String = "localhost"
var api_port: int = 8080

var language: Language = Language.DE
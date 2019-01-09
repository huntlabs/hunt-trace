module zipkin.constrants;

/// kind
enum KindOfClient = "CLIENT";
enum KindOfServer = "SERVER";
enum KindOfPRODUCER = "PRODUCER";
enum KindOfCONSUMER = "CONSUMER";


/// tag key
enum HTTP_HOST = "http.host";
enum HTTP_METHOD = "http.method";
enum HTTP_PATH = "http.path";
enum HTTP_URL = "http.url";
enum HTTP_STATUS_CODE = "http.status_code";
enum HTTP_REQUEST_SIZE = "http.request.size";
enum HTTP_RESPONSE_SIZE = "http.response.size";
enum SPAN_ERROR = "error"; 
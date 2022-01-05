public without sharing class LoaPdfUtility {

  public static final String CLASS_NAME = 'LoaPdfUtility';
  public static final String GENERATE_PDF_METHOD_NAME = 'generatePdf';
  public static final String UPLOAD_PDF_FILE_METHOD_NAME = 'uploadPdfFile';
  public static final String LOA_DOCUMENT_NAME = '{0}_LOA_{1}.pdf';

  public static final String CALLOUT_CONTENT_TYPE_KEY = 'Content-Type';
  public static final String CALLOUT_CONTENT_LENGTH_KEY = 'Content-Length';

  public static final String INPUT_MAP_KEY_DOC_ID = 'docId';
  public static final String INPUT_MAP_KEY_ORDER_ID = 'orderId';
  public static final String INPUT_MAP_KEY_ORDER_NUMBER = 'orderNumber';
  public static final String INPUT_MAP_KEY_BODY = 'body';
  public static final String INPUT_MAP_KEY_FILE_NAME = 'fileName';
  public static final String INPUT_MAP_KEY_ENDPOINT = 'endpoint';

  public static final String OUTPUT_MAP_KEY_PDF_ID = 'pdfId';

  public static final String PAGE_REFERENCE_ID_KEY = 'id';

  public static void generatePdf(
      Map<String, Object> input,
      Map<String, Object> output,
      Map<String, Object> options
  ) {
    String docId = String.valueOf(input.get(INPUT_MAP_KEY_DOC_ID));
    String orderNumber = String.valueOf(
        input.get(INPUT_MAP_KEY_ORDER_NUMBER));
    String orderId = String.valueOf(
        input.get(INPUT_MAP_KEY_ORDER_ID));
    try {
      PageReference pgReference = Page.vlocity_cmt__ObjectDocumentPdfPage;
      pgReference.getParameters().put(PAGE_REFERENCE_ID_KEY, docId);
      Attachment pdf = new Attachment(
          ParentId = orderId,
          Body = pgReference.getContentAsPdf(),
          Name = String.format(LOA_DOCUMENT_NAME,
            new List<String>{orderNumber, String.valueOf(System.now())}),
          ContentType = 'application/pdf'
      );
      insert pdf;
      output.put(OUTPUT_MAP_KEY_PDF_ID, pdf.Id);
    } catch(Exception e) {
      LoggingUtility.insertExceptionLog(CLASS_NAME,
          GENERATE_PDF_METHOD_NAME, e.getMessage());
    }
  }

  public static void uploadPdfFile(
      Map<String, Object> input,
      Map<String, Object> output,
      Map<String, Object> options
  ) {
    String pdfId = String.valueOf(input.get('pdfId'));
    String endpoint = String.valueOf(input.get(
        INPUT_MAP_KEY_ENDPOINT));
    try {
      Attachment pdf = [
          SELECT
            Id,
            Body,
            Name
          FROM
            Attachment
          WHERE
            Id = :pdfId
          LIMIT 1
      ];
      Http http = new Http();
      HttpRequest request = new HttpRequest();
      HttpResponse response = new HttpResponse();
      String boundary = generateRandomString();
      System.debug(':::Boudary:::' + boundary);
      Blob bodyBlob = createRequestBlobBody(pdf, boundary);
      endpoint = 'callout:BandwidthAPI' + endpoint;
      System.debug(':::PDF:::'+pdf.Body);
      System.debug(':::Request Body:::\n' + bodyBlob);
      request.setEndpoint(endpoint);
      request.setMethod('POST');
      request.setHeader(CALLOUT_CONTENT_TYPE_KEY,
          'application/pdf;boundary=' + boundary);
      //request.setBody(requestBody);
      request.setBodyAsBlob(bodyBlob);
      System.debug(':::Request as Blob:::' + request.getBodyAsBlob());
      request.setHeader(CALLOUT_CONTENT_LENGTH_KEY, String.valueOf(
      request.getBodyAsBlob().size()));
      System.debug(':::Request:::' + request);
      response = http.send(request);
      System.debug(':::Response:::' + response);
    } catch(Exception e) {
      LoggingUtility.insertExceptionLog(CLASS_NAME,
          UPLOAD_PDF_FILE_METHOD_NAME, e.getMessage());
    }
  }

  private static Blob createRequestBlobBody(Attachment pdf, String boundary) {
    String header = '--' + boundary + 
        '\nContent-Disposition: form-data; name=""; filename="'
          + pdf.Name + '"\nContent-Type: application/pdf\n';
      String footer = '\n' + '--' + boundary + '--';
    String headerEncoded;
    do {
      header += ' ';
      headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(
          header + '\r\n\r\n'));
    } while(headerEncoded.endsWith('='));
    String bodyEncoded = EncodingUtil.base64Encode(pdf.Body);
    if (bodyEncoded.endsWith('==')) {
      bodyEncoded = bodyEncoded.substring(0, bodyEncoded.length()-2) + '0K';
    } else if(bodyEncoded.endsWith('=')) {
      bodyEncoded = bodyEncoded.substring(0, bodyEncoded.length()-1) + 'N';
      footer = '\n' + footer;           
    } else {
      footer = '\r\n' + footer;
    }
    String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
    Blob bodyBlob = EncodingUtil.base64Decode(
        headerEncoded + bodyEncoded + footerEncoded);
    return bodyBlob;
  }

  private static String generateRandomString() {
    String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    String randStr = '';
    while (randStr.length() < 8) {
      Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()),
          chars.length());
      randStr += chars.substring(idx, idx+1);
    }
    return randStr;
  }

}
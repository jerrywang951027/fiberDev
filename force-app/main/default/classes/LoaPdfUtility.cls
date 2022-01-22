/**
 * @group LoaPdf
 * @description Utility class for generating and uploading letter of authorization pdf
 * to the bandwidth system.
 */
public with sharing class LoaPdfUtility {

  // Initialize class constants.
  public static final String CLASS_NAME = 'LoaPdfUtility';
  public static final String GENERATE_PDF_METHOD_NAME = 'generatePdf';
  public static final String UPLOAD_PDF_FILE_METHOD_NAME = 'uploadPdfFile';
  public static final String LOA_DOCUMENT_NAME = '{0}_LOA_{1}.pdf';

  // Keys for callout.
  public static final String CALLOUT_CONTENT_TYPE_KEY = 'Content-Type';
  public static final String CALLOUT_CONTENT_LENGTH_KEY = 'Content-Length';

  // Keys for input map.
  public static final String INPUT_MAP_KEY_BODY = 'body';
  public static final String INPUT_MAP_KEY_DOC_ID = 'docId';
  public static final String INPUT_MAP_KEY_ENDPOINT = 'endpoint';
  public static final String INPUT_MAP_KEY_FILE_NAME = 'fileName';
  public static final String INPUT_MAP_KEY_ORDER_ID = 'orderId';
  public static final String INPUT_MAP_KEY_ORDER_NUMBER = 'orderNumber';

  // Keys for output map.
  public static final String OUTPUT_MAP_KEY_PDF_ID = 'pdfId';

  /**
   * @description This method is used to generate letter of authorization pdf and upload it
   * to the bandwidth system.
   * @param input
   * @param output
   * @param options
   */
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
    String endpoint = String.valueOf(input.get(
        INPUT_MAP_KEY_ENDPOINT));
    Attachment pdf = null;
    try {
      PageReference pgReference = Page.vlocity_cmt__ObjectDocumentPdfPage;
      pgReference.getParameters().put('id', docId);
      pdf = new Attachment(
          ParentId = orderId,
          Name = String.format(LOA_DOCUMENT_NAME,
            new List<String>{orderNumber, String.valueOf(System.now())}),
          ContentType = 'application/pdf',
          Body = pgReference.getContent()
      );
      System.debug('::::Success::::');
      //insert pdf;
      //output.put(OUTPUT_MAP_KEY_PDF_ID, pdf.Id);
      uploadPdfFile(endpoint, pdf, output);
    } catch(Exception e) {
      System.debug(':::Error::: '+ e.getStackTraceString());
      LoggingUtility.insertExceptionLog(CLASS_NAME,
          GENERATE_PDF_METHOD_NAME, e.getMessage());
      throw e;
    } finally {
      if(pdf != null && pdf.Body != null) {
        try{
          insert pdf;
          output.put(OUTPUT_MAP_KEY_PDF_ID, pdf.Id);
        } catch(Exception e) {
          LoggingUtility.insertExceptionLog(CLASS_NAME,
              GENERATE_PDF_METHOD_NAME, e.getMessage());
          throw e;
        }
      }
    }
  }

  /**
   * @description This method uploads the generated pdf to the bandwidth system.
   * @param endpoint
   * @param pdf
   * @param output
   * 
   */
  public static void uploadPdfFile(
      String endpoint, Attachment pdf, Map<String, Object> output
  ) {
    Boolean isFileUploadSuccess;
    try {
      Http http = new Http();
      HttpRequest request = new HttpRequest();
      HttpResponse response = new HttpResponse();
      String boundary = generateRandomString();
      Blob bodyBlob = createRequestBlobBody(pdf, boundary);
      endpoint = 'callout:BandwidthAPI' + endpoint+'?documentType=LOA';
      System.debug(':::Request Body:::\n' + bodyBlob);
      request.setEndpoint(endpoint);
      request.setMethod('POST');
      request.setHeader(CALLOUT_CONTENT_TYPE_KEY,
          'application/pdf;boundary=' + boundary);
      request.setHeader('Accept', 'application/xml');
      //request.setBody(requestBody);
      request.setBodyAsBlob(bodyBlob);
      request.setHeader(CALLOUT_CONTENT_LENGTH_KEY, String.valueOf(
      request.getBodyAsBlob().size()));
      System.debug(':::Request:::' + request);
      response = http.send(request);
      System.debug(':::Response:::' + response);
      System.debug(':::Error Response Message:::' + response.getBody());
      if(response.getStatusCode() >= 200 && response.getStatusCode() <= 299) {
        isFileUploadSuccess = true;
      } else {
        isFileUploadSuccess = false;
        LoggingUtility.insertExceptionLog(CLASS_NAME,
            UPLOAD_PDF_FILE_METHOD_NAME, response.getBody());
      }
      output.put('isFileUploadSuccess', isFileUploadSuccess);
      output.put('response', response.getBody());
    } catch(Exception e) {
      LoggingUtility.insertExceptionLog(CLASS_NAME,
          UPLOAD_PDF_FILE_METHOD_NAME, e.getMessage());
      throw e;
    }
  }

  /**
   * @description This method is used to create the blob body of the generated pdf.
   * @param pdf
   * @param boundary
   * @return Blob
   */
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

  /**
   * @description This method generates a random 10 digit string
   * 
   */
  private static String generateRandomString() {
    String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
    String randStr = '';
    while (randStr.length() < 10) {
      Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()),
          chars.length());
      randStr += chars.substring(idx, idx+1);
    }
    return randStr;
  }

}